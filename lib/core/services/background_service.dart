import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meshkat_elhoda/core/services/occasion_notification_service.dart';
import 'package:meshkat_elhoda/core/services/prayer_notification_service_new.dart';
import 'package:meshkat_elhoda/core/services/smart_dhikr_service.dart';
import 'package:hijri/hijri_calendar.dart';

const String smartDhikrTask = "smartDhikrTask";
const String locationUpdateTask = "locationUpdateTask";
const String prayerRescheduleTask = "prayerRescheduleTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Notifications (Required for both tasks)
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'smart_dhikr_channel',
            channelName: 'Smart Dhikr',
            channelDescription: 'Notifications for voice dhikr',
            playSound: false,
            importance: NotificationImportance.Default,
          ),
          NotificationChannel(
            channelKey: 'occasions_channel',
            channelName: 'Islamic Occasions',
            channelDescription: 'Reminders for Friday, White Days, and Islamic Events',
            defaultColor: const Color(0xFFD4AF37),
            ledColor: const Color(0xFFD4AF37),
            importance: NotificationImportance.High,
            playSound: true,
          ),
        ],
      );

      if (task == smartDhikrTask) {
        return await _handleSmartDhikrTask();
      } else if (task == locationUpdateTask) {
        return await _handleLocationUpdateTask();
      } else if (task == prayerRescheduleTask) {
        return await _handlePrayerRescheduleTask();
      }

      return Future.value(true);
    } catch (e) {
      debugPrint("Background Task Error ($task): $e");
      return Future.value(false);
    }
  });
}

Future<bool> _handleSmartDhikrTask() async {
  try {
    // 1. Check & Notify for Occasions
    await OccasionNotificationService().checkAndNotify();

    // 2. Smart Voice Dhikr Logic (Delegated to Service)
    return await SmartDhikrService().triggerSmartDhikr();
  } catch (e) {
    debugPrint("Background Task Error: $e");
    return false;
  }
}

Future<bool> _handleLocationUpdateTask() async {
  try {
    debugPrint("🔄 Background Location Check Started");
    
    // Check permissions first
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      debugPrint("❌ Location permission missing in background");
      return true;
    }

    // Get current location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 30),
    );

    final prefs = await SharedPreferences.getInstance();
    final lastLat = prefs.getDouble('latitude');
    final lastLng = prefs.getDouble('longitude');

    // Calculate distance if we have previous location
    bool significantChange = true;
    if (lastLat != null && lastLng != null) {
      final distance = Geolocator.distanceBetween(
        lastLat,
        lastLng,
        position.latitude,
        position.longitude,
      );
      // Only update if moved more than 2km
      if (distance < 2000) {
        significantChange = false;
        debugPrint("📍 Location change insignificant (${distance.toInt()}m)");
      }
    }

    if (significantChange) {
      debugPrint("📍 Significant location change detected. Updating...");
      
      // 1. Save for PrayerNotificationService
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
      
      // 2. Save for LocationRefreshService (UI Startup Check)
      await prefs.setDouble('LAST_LATITUDE', position.latitude);
      await prefs.setDouble('LAST_LONGITUDE', position.longitude);
      
      // Reschedule Prayer Notifications for new location
      final prayerService = PrayerNotificationService();
      // We don't need full init if we just want to reschedule, but it's safer
      // await prayerService.initialize(); 
      
      final language = prefs.getString('language') ?? 'ar';
      
      await prayerService.rescheduleAll(
        latitude: position.latitude, 
        longitude: position.longitude,
        language: language
      );
      
      // Notify user of update
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999,
          channelKey: 'smart_dhikr_channel',
          title: language == 'ar' ? 'تم تحديث الموقع' : 'Location Updated',
          body: language == 'ar' 
              ? 'تم تعديل مواقيت الصلاة بناءً على موقعك الجديد'
              : 'Prayer times adjusted to your new location',
          notificationLayout: NotificationLayout.Default,
        ),
      );
    }

    return true;
  } catch (e) {
    debugPrint("Background Location Error: $e");
    return false;
  }
}

Future<bool> _handlePrayerRescheduleTask() async {
  try {
    debugPrint("🕌 Prayer Reschedule Task Started");

    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('latitude');
    final lng = prefs.getDouble('longitude');
    final language = prefs.getString('language') ?? 'ar';

    if (lat == null || lng == null) {
      debugPrint("⚠️ No cached coordinates found. Skipping prayer reschedule.");
      return true;
    }

    await PrayerNotificationService().rescheduleAll(
      latitude: lat,
      longitude: lng,
      language: language,
    );

    debugPrint("✅ Prayer notifications rescheduled successfully");
    return true;
  } catch (e) {
    debugPrint("❌ Prayer Reschedule Task Error: $e");
    return false;
  }
}

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  Future<void> registerPeriodicTasks() async {
    // 1. Smart Dhikr (Existing)
    // Managed by SmartDhikrService, so we leave it there or move it?
    // SmartDhikrService calls registerPeriodicTask. 
    // We just need to ensure `callbackDispatcher` handles it.
    
    // 2. Location Update (New) - Every 6 hours
    await Workmanager().registerPeriodicTask(
      "2002",
      locationUpdateTask,
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected, 
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );

    // 3. Prayer reschedule (Daily-ish) - ensures tomorrow is scheduled even if user doesn't open the app
    // WorkManager periodic tasks are not exact; 12h reduces risk of missing a day due to OEM restrictions.
    await Workmanager().registerPeriodicTask(
      "2003",
      prayerRescheduleTask,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
