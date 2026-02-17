import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meshkat_elhoda/core/services/flutter_athan_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ✅ خدمة الأذان - تستخدم Flutter فقط بدون native code
///
/// هذا الملف هو wrapper للتوافق مع الكود القديم
/// جميع الوظائف تُفوّض إلى FlutterAthanService
///
/// الآلية الجديدة:
/// 1. إشعار مجدول مع صوت أذان قصير (30 ثانية) - يعمل دائماً
/// 2. محاولة تشغيل الأذان كاملاً إذا كان التطبيق في الخلفية
class AthanAudioService {
  static final AthanAudioService _instance = AthanAudioService._internal();
  factory AthanAudioService() => _instance;
  AthanAudioService._internal();

  static const MethodChannel _channel = MethodChannel('com.meshkatelhoda.pro/athan');

  static const String _selectedMuezzinKey = 'SELECTED_MUEZZIN_ID';

  Future<String> _getSelectedMuezzinIdOrDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_selectedMuezzinKey) ?? 'ali_almula';
    } catch (e) {
      log('⚠️ Failed to read selected muezzin from prefs: $e');
      return 'ali_almula';
    }
  }

  /// ✅ Schedule Smart Voice (Smart Dhikr) via native AlarmManager (Android only)
  Future<void> scheduleSmartDhikrNative({
    required int alarmId,
    required DateTime triggerTime,
  }) async {
    try {
      if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        return;
      }
      await _channel.invokeMethod('scheduleSmartDhikrNative', {
        'alarmId': alarmId,
        'triggerTimeMillis': triggerTime.millisecondsSinceEpoch,
      });
    } catch (e) {
      log('❌ Error scheduling Smart Dhikr native: $e');
    }
  }

  /// ✅ Cancel Smart Voice (Smart Dhikr) native alarm
  Future<void> cancelSmartDhikrNative({required int alarmId}) async {
    try {
      if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        return;
      }
      await _channel.invokeMethod('cancelSmartDhikrNative', {
        'alarmId': alarmId,
      });
    } catch (e) {
      log('❌ Error cancelling Smart Dhikr native: $e');
    }
  }

  Future<void> scheduleRamadanReminderNative({
    required String type,
    required DateTime triggerTime,
    required String title,
    required String body,
  }) async {
    try {
      if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        return;
      }
      await _channel.invokeMethod('scheduleRamadanReminder', {
        'type': type,
        'triggerTimeMillis': triggerTime.millisecondsSinceEpoch,
        'title': title,
        'body': body,
      });
    } catch (e) {
      log('❌ Error scheduling Ramadan reminder native: $e');
    }
  }

  Future<void> cancelRamadanReminderNative({required String type}) async {
    try {
      if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        return;
      }
      await _channel.invokeMethod('cancelRamadanReminder', {
        'type': type,
      });
    } catch (e) {
      log('❌ Error cancelling Ramadan reminder native: $e');
    }
  }

  Future<void> syncNativeAthanActionLabels({
    required String stopLabel,
    required String hideLabel,
    required String stopHint,
  }) async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('setAthanActionLabels', {
        'stopLabel': stopLabel,
        'hideLabel': hideLabel,
        'stopHint': stopHint,
      });
    } catch (e) {
      log('❌ syncNativeAthanActionLabels error: $e');
    }
  }

  /// الخدمة الفعلية
  final FlutterAthanService _flutterAthanService = FlutterAthanService();

  /// ✅ تهيئة الخدمة
  Future<void> initialize() async {
    try {
      await _flutterAthanService.initialize();
      log('✅ AthanAudioService initialized (Flutter-based)');
    } catch (e) {
      log('❌ Error initializing AthanAudioService: $e');
    }
  }

  /// ✅ Check if app can schedule exact alarms
  Future<bool> canScheduleExactAlarms() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return true;
    }
    try {
      final res = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return res ?? true;
    } catch (e) {
      log('❌ canScheduleExactAlarms MethodChannel error: $e');
      return true;
    }
  }

  /// ✅ Open system settings to request exact alarm permission
  Future<void> requestExactAlarmPermission() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      log('❌ requestExactAlarmPermission MethodChannel error: $e');
    }
  }

  /// ✅ Check if app is being battery optimized
  Future<bool> isBatteryOptimized() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return false;
    }
    try {
      final res = await _channel.invokeMethod<bool>('isBatteryOptimized');
      return res ?? false;
    } catch (e) {
      log('❌ isBatteryOptimized MethodChannel error: $e');
      return false;
    }
  }

  /// ✅ Request battery optimization exemption
  Future<void> requestBatteryOptimizationExemption() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('requestBatteryOptimizationExemption');
    } catch (e) {
      log('❌ requestBatteryOptimizationExemption MethodChannel error: $e');
    }
  }

  /// ✅ Open system app settings
  Future<void> openAppSettings() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('openAppSettings');
    } catch (e) {
      log('❌ openAppSettings MethodChannel error: $e');
    }
  }

  Future<String> getDeviceInfo() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return '';
    }
    try {
      final res = await _channel.invokeMethod<String>('getDeviceInfo');
      return res ?? '';
    } catch (e) {
      log('❌ getDeviceInfo MethodChannel error: $e');
      return '';
    }
  }

  Future<void> openOverlayPermissionSettings() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('openOverlaySettings');
    } catch (e) {
      log('❌ openOverlayPermissionSettings error: $e');
      await openAppSettings();
    }
  }

  Future<void> openAppNotificationSettings() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('openAppNotificationSettings');
    } catch (e) {
      log('❌ openAppNotificationSettings error: $e');
      await openAppSettings();
    }
  }

  Future<void> openAthanNotificationChannelSettings() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('openAthanNotificationChannelSettings');
    } catch (e) {
      log('❌ openAthanNotificationChannelSettings error: $e');
      await openAppNotificationSettings();
    }
  }

  Future<void> openBatterySaverSettings() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('openBatterySaverSettings');
    } catch (e) {
      log('❌ openBatterySaverSettings error: $e');
      await openAppSettings();
    }
  }

  Future<void> openAutoStartSettings() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('openAutoStartSettings');
    } catch (e) {
      log('❌ openAutoStartSettings error: $e');
      await openAppSettings();
    }
  }

  Future<void> openAdvancedScreenOffSettings() async {
    if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
      return;
    }
    try {
      await _channel.invokeMethod('openAdvancedScreenOffSettings');
    } catch (e) {
      log('❌ openAdvancedScreenOffSettings error: $e');
      await openAppSettings();
    }
  }

  /// ✅ Play Athan immediately for a prayer
  /// Used for testing or manual trigger from within the app
  Future<void> playAthanForPrayer(String prayerName) async {
    try {
      if (defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        log('🔔 Playing Athan for $prayerName via native channel...');
        final isFajr = prayerName == 'Fajr';
        final muezzinId = await _getSelectedMuezzinIdOrDefault();
        // Keep native side responsible for sound in background.
        await _channel.invokeMethod('playAthan', {
          'muezzinId': muezzinId,
          'isFajr': isFajr,
          'prayerName': prayerName,
          'title': '🕌 Prayer Time',
          'body': 'It is time for prayer $prayerName',
        });
        log('✅ Native Athan playback triggered');
        return;
      }

      log('🔔 Playing Athan for $prayerName via Flutter...');
      await _flutterAthanService.playAthanForPrayer(prayerName);
      log('✅ Athan playback started successfully');
    } catch (e) {
      log('❌ Error playing Athan: $e');
    }
  }

  /// ✅ Schedule Athan for a specific prayer time
  /// Uses awesome_notifications for reliable execution
  Future<void> scheduleAthan({
    required int prayerId,
    required DateTime prayerTime,
    required String prayerName,
  }) async {
    try {
      log('📅 [AthanAudioService] Scheduling Athan for $prayerName at $prayerTime...');

      if (defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        final isFajr = prayerName == 'Fajr';
        final muezzinId = await _getSelectedMuezzinIdOrDefault();
        await _channel.invokeMethod('scheduleAthan', {
          'prayerId': prayerId,
          'triggerTimeMillis': prayerTime.millisecondsSinceEpoch,
          'muezzinId': muezzinId,
          'isFajr': isFajr,
          'prayerName': prayerName,
          'title': '🕌 Prayer Time',
          'body': 'It is time for prayer $prayerName',
        });
        log('✅ Athan scheduled successfully via native for $prayerName');
        return;
      }

      await _flutterAthanService.scheduleAthan(
        prayerId: prayerId,
        prayerTime: prayerTime,
        prayerName: prayerName,
      );
      log('✅ Athan scheduled successfully for $prayerName');
    } catch (e) {
      log('❌ Error scheduling Athan: $e');
    }
  }

  /// ✅ Cancel a specific scheduled Athan
  Future<void> cancelAthan(int prayerId) async {
    try {
      if (defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        await _channel.invokeMethod('cancelAthan', {
          'prayerId': prayerId,
        });
      } else {
        await _flutterAthanService.cancelAthan(prayerId);
      }
      log('✅ Athan cancelled for prayer ID: $prayerId');
    } catch (e) {
      log('❌ Error cancelling Athan: $e');
    }
  }

  /// ✅ Cancel all scheduled Athans
  Future<void> cancelAllAthans() async {
    try {
      if (defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        await _channel.invokeMethod('cancelAllAthans');
      } else {
        await _flutterAthanService.cancelAllAthans();
      }
      log('✅ All Athans cancelled');
    } catch (e) {
      log('❌ Error cancelling all Athans: $e');
    }
  }

  /// ✅ Stop currently playing Athan
  Future<void> stopAthan() async {
    try {
      if (defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        await _channel.invokeMethod('stopAthan');
      } else {
        await _flutterAthanService.stopAthan();
      }
      log('✅ Athan stopped');
    } catch (e) {
      log('❌ Error stopping Athan: $e');
    }
  }

  /// ✅ Schedule a Pre-Athan reminder (e.g., 5 minutes before prayer)
  Future<void> schedulePreAthanReminder({
    required int reminderId,
    required DateTime triggerTime,
    required String title,
    required String body,
  }) async {
    try {
      if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        return;
      }

      await _channel.invokeMethod('schedulePreAthanReminder', {
        'reminderId': reminderId,
        'triggerTimeMillis': triggerTime.millisecondsSinceEpoch,
        'title': title,
        'body': body,
      });
    } catch (e) {
      log('❌ Error scheduling pre-athan reminder: $e');
    }
  }

  /// ✅ Cancel a Pre-Athan reminder
  Future<void> cancelPreAthanReminder(int reminderId) async {
    try {
      if (!defaultTargetPlatform.toString().toLowerCase().contains('android')) {
        return;
      }
      await _channel.invokeMethod('cancelPreAthanReminder', {
        'reminderId': reminderId,
      });
    } catch (e) {
      log('❌ Error cancelling pre-athan reminder: $e');
    }
  }

  /// ✅ Request critical alerts permission (iOS)
  Future<bool> requestCriticalAlertsPermission() async {
    return await _flutterAthanService.requestCriticalAlertsPermission();
  }

  /// ✅ Dispose resources
  Future<void> dispose() async {
    await _flutterAthanService.dispose();
  }

  // ============================================================
  // LEGACY METHODS - kept for compatibility
  // ============================================================

  @Deprecated('Use playAthanForPrayer instead')
  Future<void> playAthan(String audioPath) async {
    // Extract prayer name from path
    final fileName = audioPath.split('/').last.replaceAll('.mp3', '');
    final isFajr = fileName.contains('fajr');
    final prayerName = isFajr ? 'Fajr' : 'Dhuhr';

    await playAthanForPrayer(prayerName);
  }
}
