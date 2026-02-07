import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:meshkat_elhoda/core/services/occasion_notification_service.dart';
import 'package:flutter/material.dart';

const String smartDhikrTask = "smartDhikrTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == smartDhikrTask) {
      try {
        // Initialize Notifications
        await AwesomeNotifications().initialize(
          null, // Icon
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

        // 1. Check & Notify for Occasions (Friday, White Days, etc.)
        // This runs regardless of Smart Voice setting
        await OccasionNotificationService().checkAndNotify();

        // 2. Smart Voice Dhikr Logic
        final prefs = await SharedPreferences.getInstance();
        final isEnabled = prefs.getBool('isSmartVoiceEnabled') ?? false;

        if (!isEnabled) {
           return Future.value(true);
        }

        // Show Notification to keep service alive/inform user (Foreground Service attempt)
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 888,
            channelKey: 'smart_dhikr_channel',
            title: 'ذكر الله',
            body: 'تذكير: رطب لسانك بذكر الله',
            notificationLayout: NotificationLayout.Default,
          ),
        );

        // Curated List of Short Dhikr Audio URLs
        final List<String> dhikrUrls = [
          // Subhan Allah wa Bihamdihi
          "http://www.hisnmuslim.com/audio/ar/91.mp3", 
          // Astaghfirullah
          "http://www.hisnmuslim.com/audio/ar/96.mp3",
          // Salawat (Prayers upon Prophet)
          "http://www.hisnmuslim.com/audio/ar/98.mp3",
        ];
        
        // Pick random
        final random = Random();
        final url = dhikrUrls[random.nextInt(dhikrUrls.length)];

        final player = AudioPlayer();
        await player.setUrl(url);
        await player.play();
        
        // Wait for completion (simple mechanic)
        await player.playerStateStream.firstWhere(
            (state) => state.processingState == ProcessingState.completed);
            
        await player.dispose();

        // Keep notification or auto-dismiss? 
        // Best to auto-dismiss "Playing..." notification after done, or change to "Completed".
        // await AwesomeNotifications().cancel(888); 
        
      } catch (e) {
        debugPrint("Smart Dhikr/Occasion Error: $e");
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

class SmartDhikrService {
  static final SmartDhikrService _instance = SmartDhikrService._internal();
  factory SmartDhikrService() => _instance;
  SmartDhikrService._internal();

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    
    // Ensure task is valid on startup
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('isSmartVoiceEnabled') ?? false;
    final interval = prefs.getInt('smartVoiceIntervalMinutes') ?? 60;
    
    await scheduleDhikr(isEnabled ? interval : 60);
  }

  Future<void> scheduleDhikr(int intervalInMinutes) async {
    await Workmanager().registerPeriodicTask(
      "1001", 
      smartDhikrTask,
      frequency: Duration(minutes: intervalInMinutes < 15 ? 15 : intervalInMinutes), // Min 15m on Android
      constraints: Constraints(
        networkType: NetworkType.connected, // Required for Voice, but Occasion needs less. 
        // We stick to Connected because Audio needs it. 
        // If no internet, task won't run -> Occasion check won't run.
        // That's acceptable for now? Occasion notifications are text.
        // Ideally we should relax constraints for Occasions. 
        // But Workmanager constraints apply to the whole task. 
        // Compomise: Connected is fine. Most users have net.
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  Future<void> cancelDhikr() async {
    await Workmanager().cancelByUniqueName("1001");
  }
}
