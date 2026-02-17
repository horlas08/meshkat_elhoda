import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hijri/hijri_calendar.dart';

class SmartDhikrService {
  static final SmartDhikrService _instance = SmartDhikrService._internal();
  factory SmartDhikrService() => _instance;
  SmartDhikrService._internal();

  static const String _dhikrDownloadedIdsKey = 'smart_dhikr_downloaded_ids';
  static const String _dhikrLocalDirName = 'smart_dhikr_audio';

  static const Map<String, String> _dhikrUrlById = {
    '91': 'http://www.hisnmuslim.com/audio/ar/91.mp3',
    '92': 'http://www.hisnmuslim.com/audio/ar/92.mp3',
    '93': 'http://www.hisnmuslim.com/audio/ar/93.mp3',
    '94': 'http://www.hisnmuslim.com/audio/ar/94.mp3',
    '96': 'http://www.hisnmuslim.com/audio/ar/96.mp3',
    '97': 'http://www.hisnmuslim.com/audio/ar/97.mp3',
    '98': 'http://www.hisnmuslim.com/audio/ar/98.mp3',
    '99': 'http://www.hisnmuslim.com/audio/ar/99.mp3',
    '100': 'http://www.hisnmuslim.com/audio/ar/100.mp3',
    '101': 'http://www.hisnmuslim.com/audio/ar/101.mp3',
    '102': 'http://www.hisnmuslim.com/audio/ar/102.mp3',
    '103': 'http://www.hisnmuslim.com/audio/ar/103.mp3',
  };

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

  Future<Directory> _getDhikrLocalDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${baseDir.path}/$_dhikrLocalDirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _getDhikrLocalFile(String id) async {
    final dir = await _getDhikrLocalDirectory();
    return File('${dir.path}/$id.mp3');
  }

  Future<Set<String>> getDownloadedDhikrIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dhikrDownloadedIdsKey);
    if (raw == null || raw.trim().isEmpty) {
      return <String>{};
    }
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toSet();
      }
      return <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _setDownloadedDhikrIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dhikrDownloadedIdsKey, json.encode(ids.toList()..sort()));
  }

  Future<bool> isDhikrDownloaded(String id) async {
    final ids = await getDownloadedDhikrIds();
    if (!ids.contains(id)) return false;
    final file = await _getDhikrLocalFile(id);
    return file.exists();
  }

  Future<void> downloadDhikrPack({void Function(String id, int done, int total)? onProgress}) async {
    final client = http.Client();
    try {
      final total = _dhikrUrlById.length;
      var done = 0;
      final downloadedIds = await getDownloadedDhikrIds();

      for (final entry in _dhikrUrlById.entries) {
        final id = entry.key;
        final url = entry.value;

        final file = await _getDhikrLocalFile(id);
        if (!await file.exists()) {
          final res = await client.get(Uri.parse(url));
          if (res.statusCode != 200) {
            throw Exception('Failed to download dhikr $id (HTTP ${res.statusCode})');
          }
          await file.writeAsBytes(res.bodyBytes, flush: true);
        }

        downloadedIds.add(id);
        done += 1;
        onProgress?.call(id, done, total);
      }

      await _setDownloadedDhikrIds(downloadedIds);
    } finally {
      client.close();
    }
  }

  Future<void> deleteDhikrPack() async {
    final downloadedIds = await getDownloadedDhikrIds();
    for (final id in downloadedIds) {
      final file = await _getDhikrLocalFile(id);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _setDownloadedDhikrIds(<String>{});
  }

  Future<String?> getDhikrLocalPathIfAvailable(String id) async {
    if (!await isDhikrDownloaded(id)) return null;
    final file = await _getDhikrLocalFile(id);
    return file.path;
  }

  Future<bool> isDhikrPackFullyDownloaded() async {
    for (final id in getAllDhikrIds()) {
      if (!await isDhikrDownloaded(id)) {
        return false;
      }
    }
    return true;
  }

  List<String> getAllDhikrIds() => _dhikrUrlById.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

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

      final List<String> dhikrIds = [
        '91',
        '96',
        '98',
        '92',
        '93',
        '94',
        '97',
        '99',
        '100',
        '101',
      ];

      // 🌙 Ramadan Additions using Hijri Calendar
      try {
        final HijriCalendar nowHijri = HijriCalendar.now();
        // Ramadan is the 9th month
        if (nowHijri.hMonth == 9) {
          debugPrint("🌙 It's Ramadan! Adding special Dhikr...");
          dhikrIds.addAll(['102', '103']);
        }
      } catch (e) {
        debugPrint("⚠️ Hijri check failed: $e");
      }

      final random = Random();
      final id = dhikrIds[random.nextInt(dhikrIds.length)];
      final url = _dhikrUrlById[id] ?? _dhikrUrlById['96']!;

      final localPath = await getDhikrLocalPathIfAvailable(id);
      final sourceLabel = localPath != null ? 'LOCAL' : 'REMOTE';

      debugPrint("▶️ Playing Random Dhikr ($sourceLabel): ${localPath ?? url}");

      final player = AudioPlayer();
      if (localPath != null) {
        await player.setFilePath(localPath);
      } else {
        await player.setUrl(url);
      }
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
      final localPath = await getDhikrLocalPathIfAvailable('103');
      if (localPath != null) {
        await player.setFilePath(localPath);
      } else {
        await player.setUrl("http://www.hisnmuslim.com/audio/ar/103.mp3");
      }
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
      final localPath = await getDhikrLocalPathIfAvailable('96');
      if (localPath != null) {
        await player.setFilePath(localPath);
      } else {
        await player.setUrl("http://www.hisnmuslim.com/audio/ar/96.mp3");
      }
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
