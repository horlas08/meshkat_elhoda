import 'dart:async';
import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hijri/hijri_calendar.dart';

class SmartDhikrService {
  static final SmartDhikrService _instance = SmartDhikrService._internal();
  factory SmartDhikrService() => _instance;
  SmartDhikrService._internal();

  Future<void> initialize() async {
    // WorkManager initialization is now handled in BackgroundService or main.dart
    // We just need to schedule the task here if needed.
    
    // Ensure task is valid on startup
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('isSmartVoiceEnabled') ?? false;
    final interval = prefs.getInt('smartVoiceIntervalMinutes') ?? 60;
    
    if (isEnabled) {
      await scheduleDhikr(interval);
    }
  }

  Future<void> scheduleDhikr(int intervalInMinutes) async {
    await Workmanager().registerPeriodicTask(
      "1001", 
      "smartDhikrTask",
      frequency: Duration(minutes: intervalInMinutes < 15 ? 15 : intervalInMinutes), // Min 15m on Android
      constraints: Constraints(
        networkType: NetworkType.connected, 
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  Future<void> cancelDhikr() async {
    await Workmanager().cancelByUniqueName("1001");
  }

  /// 🛠️ Debug: Schedule a one-off task in 2 minutes to test WorkManager
  Future<void> scheduleImmediateDhikr() async {
    debugPrint("🛠️ Scheduling Immediate Smart Dhikr Test (2 mins)...");
    try {
      await Workmanager().registerOneOffTask(
        "debug_smart_dhikr_${DateTime.now().millisecondsSinceEpoch}",
        "smartDhikrTask", // Must match the constant in BackgroundService
        initialDelay: const Duration(minutes: 1),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.append,
      );
    } catch (e) {
      debugPrint("❌ Smart Dhikr Schedule Error: $e");
    }
  }

  /// ✅ Trigger Smart Dhikr Instantly (for testing or background task)
  Future<bool> triggerSmartDhikr({bool ignoreSettings = false}) async {
    try {
      debugPrint("🔊 Triggering Smart Dhikr (Ignore Settings: $ignoreSettings)...");
      
      // 1. Check Preferences (unless ignored)
      if (!ignoreSettings) {
        final prefs = await SharedPreferences.getInstance();
        // ⚠️ Fix: Read from JSON blob if possible, or legacy key
        // For now, we stick to legacy key but we MUST ensure it is synced.
        final isEnabled = prefs.getBool('isSmartVoiceEnabled') ?? false;

        if (!isEnabled) {
          debugPrint("⚠️ Smart Voice is disabled in settings.");
          return true;
        }
      }

      // 2. Curated List of Short Dhikr Audio URLs
      final List<String> dhikrUrls = [
        "http://www.hisnmuslim.com/audio/ar/91.mp3", // Subhan Allah
        "http://www.hisnmuslim.com/audio/ar/96.mp3", // Astaghfirullah
        "http://www.hisnmuslim.com/audio/ar/98.mp3", // Salawat
        "http://www.hisnmuslim.com/audio/ar/92.mp3", // Alhamdulillah
        "http://www.hisnmuslim.com/audio/ar/93.mp3", // Allahu Akbar
        "http://www.hisnmuslim.com/audio/ar/94.mp3", // La ilaha illa Allah
        "http://www.hisnmuslim.com/audio/ar/97.mp3", // Astaghfirullah 2
        "http://www.hisnmuslim.com/audio/ar/99.mp3", // Subhan Allah wa Bihamdihi
        "http://www.hisnmuslim.com/audio/ar/100.mp3",// Subhan Allah Al-Adheem
        "http://www.hisnmuslim.com/audio/ar/101.mp3",// La Hawla wala Quwwata illa Billah
      ];

      // 🌙 Ramadan Additions using Hijri Calendar
      try {
        final HijriCalendar nowHijri = HijriCalendar.now();
        // Ramadan is the 9th month
        if (nowHijri.hMonth == 9) {
          debugPrint("🌙 It's Ramadan! Adding special Dhikr...");
          dhikrUrls.addAll([
             "http://www.hisnmuslim.com/audio/ar/102.mp3", // Dua related to forgiveness (Example)
             "http://www.hisnmuslim.com/audio/ar/103.mp3", // Special Ramadan Dua (Placeholder)
             // Add more Ramadan specific URLs here
          ]);
        }
      } catch (e) {
        debugPrint("⚠️ Hijri check failed: $e");
      }

      final random = Random();
      final url = dhikrUrls[random.nextInt(dhikrUrls.length)];

      debugPrint("▶️ Playing Random Dhikr: $url");

      final player = AudioPlayer();
      await player.setUrl(url);
      await player.play();

      // Wait for completion
      await player.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed);

      await player.dispose();
      debugPrint("✅ Smart Dhikr Finished.");
      return true;
    } catch (e) {
      debugPrint("❌ Smart Dhikr Error: $e");
      return false;
    }
  }

  Future<void> playIftarAudio() async {
    try {
      debugPrint("🌙 Playing Iftar Dua...");
      final player = AudioPlayer();
      // Dua upon breaking fast
      await player.setUrl("http://www.hisnmuslim.com/audio/ar/103.mp3");
      await player.play();
      await player.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed);
      await player.dispose();
      debugPrint("✅ Iftar Audio Finished.");
    } catch (e) {
      debugPrint("❌ Iftar Audio Error: $e");
    }
  }

  Future<void> playSuhoorAudio() async {
    try {
      debugPrint("🥣 Playing Suhoor Dua/Reminder...");
      final player = AudioPlayer();
      // Using Astaghfirullah for Suhoor (Pre-Fajr spiritual time)
      await player.setUrl("http://www.hisnmuslim.com/audio/ar/96.mp3");
      await player.play();
      await player.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed);
      await player.dispose();
      debugPrint("✅ Suhoor Audio Finished.");
    } catch (e) {
      debugPrint("❌ Suhoor Audio Error: $e");
    }
  }
}
