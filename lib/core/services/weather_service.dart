import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  // ⚠️ REPLACE WITH YOUR API KEY
  static const String _apiKey = "YOUR_OPEN_WEATHER_MAP_API_KEY"; 
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<void> checkWeatherAndNotify() async {
    try {
      if (_apiKey == "YOUR_OPEN_WEATHER_MAP_API_KEY") {
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
          
          // Condition 2xx is Thunderstorm
          if (conditionId >= 200 && conditionId < 300) {
             await _sendThunderNotification();
          }
        }
      }
    } catch (e) {
      debugPrint("WeatherService Error: $e");
    }
  }

  Future<void> _sendThunderNotification() async {
    // Avoid spamming: Check if notified recently (e.g., in last 2 hours)
    final prefs = await SharedPreferences.getInstance();
    final lastTime = prefs.getInt('last_thunder_notification_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - lastTime < 2 * 60 * 60 * 1000) {
      // Less than 2 hours passed
      return;
    }

    // Initialize Channel if not exists (We reuse 'occasions_channel' or create new)
    // Assuming context is hard to get, we use generic channel.
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 777,
        channelKey: 'occasions_channel', // Reuse existing channel
        title: "دعاء الرعد",
        body: "سُبْحَانَ الَّذِي يُسَبِّحُ الرَّعْدُ بِحَمْدِهِ وَالْمَلَائِكَةُ مِنْ خِيفَتِهِ",
        notificationLayout: NotificationLayout.Default,
      ),
    );
    
    await prefs.setInt('last_thunder_notification_time', now);
  }
}
