import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'dart:ui';

class WeatherService {
  // ⚠️ REPLACE WITH YOUR API KEY
  static const String _apiKey = "842a9704bc3ec81d0b95b601e5628e36";
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<void> checkWeatherAndNotify() async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint("WeatherService: API Key not set.");
        return;
      }

      // 1. Get Location (Assuming permission is granted, otherwise return)
      // We rely on LocationBloc having handled permission, or we check quickly.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      // Get last known to be fast
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      
      if (position == null) return;

      // 2. Call API
      final url = Uri.parse("$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> weatherList = data['weather'];
        if (weatherList.isNotEmpty) {
          final int conditionId = weatherList[0]['id'];
          final double tempK = (data['main']['temp'] as num).toDouble();
          
          await _checkCondition(conditionId, tempK);
        }
      }
    } catch (e) {
      debugPrint("WeatherService Error: $e");
    }
  }

  Future<void> _checkCondition(int conditionId, double tempK) async {
    // Determine condition type
    String? titleKey;
    String? bodyKey;
    String? prefsKey;
    
    // 1. Thunderstorm (2xx)
    if (conditionId >= 200 && conditionId < 300) {
      titleKey = 'weatherThunderTitle';
      bodyKey = 'weatherThunderBody';
      prefsKey = 'last_thunder_notification_time';
    } 
    // 2. Rain / Drizzle (3xx, 5xx)
    else if ((conditionId >= 300 && conditionId < 600)) {
      titleKey = 'weatherRainTitle';
      bodyKey = 'weatherRainBody';
      prefsKey = 'last_rain_notification_time';
    }
    // 3. Snow / Extreme Cold (6xx or Temp < 5°C)
    // 278.15K = 5°C
    else if (conditionId >= 600 && conditionId < 700 || tempK < 278.15) {
      if (tempK < 278.15) {
         titleKey = 'weatherColdTitle';
         bodyKey = 'weatherColdBody';
         prefsKey = 'last_cold_notification_time';
      }
      // If just snow but not super cold, maybe just ignore or treat as rain? 
      // User asked for "Extreme Cold"Azkar specifically usually.
      // Let's prioritize Temp for Cold Azkar.
    }
    // 4. Atmosphere (Mist, Smoke, Sand/Dust) - 7xx
    // Sand/Dust (731, 751, 761) -> Wind Dua
    // Squalls (771) -> Wind Dua
    // Tornado (781) -> Wind Dua
    else if ([731, 751, 761, 771, 781].contains(conditionId)) {
      titleKey = 'weatherWindTitle';
      bodyKey = 'weatherWindBody';
      prefsKey = 'last_wind_notification_time';
    }
    // 5. Extreme Heat (Temp > 40°C)
    // 313.15K = 40°C
    else if (tempK > 313.15) {
      titleKey = 'weatherHeatTitle';
      bodyKey = 'weatherHeatBody';
      prefsKey = 'last_heat_notification_time';
    }

    if (titleKey != null && bodyKey != null && prefsKey != null) {
      await _sendNotification(titleKey, bodyKey, prefsKey);
    }
  }

  Future<void> _sendNotification(String titleKey, String bodyKey, String prefsKey) async {
    final prefs = await SharedPreferences.getInstance();
    final lastTime = prefs.getInt(prefsKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Cooldown: 6 hours for weather notifications to avoid spam
    if (now - lastTime < 6 * 60 * 60 * 1000) {
      return;
    }

    // Get Locale
    String langCode = prefs.getString('language_code') ?? 'en';
    // Fallback if 'ar' is not explicitly set but device is ar? 
    // Usually we save it. If null, safe to default to 'ar' for this app? 
    // Or just 'en'. User said "app language is currently in english".
    // Let's try to parse 'language_code'.
    
    Locale locale = Locale(langCode);
    // Load Localizations manually
    AppLocalizations? localizations = await AppLocalizations.delegate.load(locale);
    
    String title = '';
    String body = '';
    
    // Map keys to getters (Reflection not available, so manual mapping)
    switch (titleKey) {
      case 'weatherThunderTitle': title = localizations.weatherThunderTitle; break;
      case 'weatherRainTitle': title = localizations.weatherRainTitle; break;
      case 'weatherWindTitle': title = localizations.weatherWindTitle; break;
      case 'weatherHeatTitle': title = localizations.weatherHeatTitle; break;
      case 'weatherColdTitle': title = localizations.weatherColdTitle; break;
    }
    
    switch (bodyKey) {
      case 'weatherThunderBody': body = localizations.weatherThunderBody; break;
      case 'weatherRainBody': body = localizations.weatherRainBody; break;
      case 'weatherWindBody': body = localizations.weatherWindBody; break;
      case 'weatherHeatBody': body = localizations.weatherHeatBody; break;
      case 'weatherColdBody': body = localizations.weatherColdBody; break;
    }

    if (title.isEmpty) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
        channelKey: 'occasions_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigText,
      ),
    );
    
    await prefs.setInt(prefsKey, now);
  }
}
