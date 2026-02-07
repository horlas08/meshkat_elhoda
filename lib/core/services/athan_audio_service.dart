import 'dart:developer';
import 'package:meshkat_elhoda/core/services/flutter_athan_service.dart';

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
  /// Returns true always for Flutter implementation
  Future<bool> canScheduleExactAlarms() async {
    return true; // Flutter handles this internally
  }

  /// ✅ Open system settings to request exact alarm permission
  /// Not needed for Flutter implementation
  Future<void> requestExactAlarmPermission() async {
    log('ℹ️ requestExactAlarmPermission not needed for Flutter implementation');
  }

  /// ✅ Check if app is being battery optimized
  /// Not needed for Flutter implementation
  Future<bool> isBatteryOptimized() async {
    return false;
  }

  /// ✅ Request battery optimization exemption
  /// Not needed for Flutter implementation
  Future<void> requestBatteryOptimizationExemption() async {
    log(
      'ℹ️ Battery optimization exemption not needed for Flutter implementation',
    );
  }

  /// ✅ Open system app settings
  Future<void> openAppSettings() async {
    log('ℹ️ openAppSettings - use system settings');
  }

  /// ✅ Play Athan immediately for a prayer
  /// Used for testing or manual trigger from within the app
  Future<void> playAthanForPrayer(String prayerName) async {
    try {
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
      log(
        '📅 [AthanAudioService] Scheduling Athan for $prayerName at $prayerTime...',
      );

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
      await _flutterAthanService.cancelAthan(prayerId);
      log('✅ Athan cancelled for prayer ID: $prayerId');
    } catch (e) {
      log('❌ Error cancelling Athan: $e');
    }
  }

  /// ✅ Cancel all scheduled Athans
  Future<void> cancelAllAthans() async {
    try {
      await _flutterAthanService.cancelAllAthans();
      log('✅ All Athans cancelled');
    } catch (e) {
      log('❌ Error cancelling all Athans: $e');
    }
  }

  /// ✅ Stop currently playing Athan
  Future<void> stopAthan() async {
    try {
      await _flutterAthanService.stopAthan();
      log('✅ Athan stopped');
    } catch (e) {
      log('❌ Error stopping Athan: $e');
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
