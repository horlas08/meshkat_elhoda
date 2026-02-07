import 'dart:async';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meshkat_elhoda/core/services/khushoo_mode_service.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/repositories/prayer_times_repository.dart';

/// ✅ خدمة الأذان الهجينة - تعمل بـ Flutter فقط بدون native code
///
/// الآلية:
/// 1. إشعار مجدول مع صوت الأذان - يعمل دائماً حتى لو التطبيق مغلق
/// 2. محاولة تشغيل الأذان كاملاً إذا كان التطبيق في الخلفية
///
/// ملاحظة: iOS يحد من صوت الإشعار لـ 30 ثانية كحد أقصى
class FlutterAthanService {
  static final FlutterAthanService _instance = FlutterAthanService._internal();
  factory FlutterAthanService() => _instance;
  FlutterAthanService._internal();

  /// Notification IDs for Athan (200-210 range)
  static const int _athanNotificationIdBase = 200;

  /// Audio player for full athan playback
  AudioPlayer? _audioPlayer;
  bool _isInitialized = false;
  bool _isPlaying = false;

  /// Prayer name to Arabic translation
  static const Map<String, String> _prayerNameArabic = {
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  /// الحصول على معرف المؤذن من الإعدادات
  Future<String> _getSelectedMuezzinId() async {
    try {
      if (!getIt.isRegistered<PrayerTimesRepository>()) {
        return 'ali_almula';
      }

      final repository = getIt<PrayerTimesRepository>();
      final result = await repository.getSelectedMuezzinId();

      String? muezzinId;
      result.fold(
        (failure) => muezzinId = 'ali_almula',
        (id) => muezzinId = id,
      );

      return muezzinId ?? 'ali_almula';
    } catch (e) {
      log('⚠️ Error getting muezzin ID, using default: $e');
      return 'ali_almula';
    }
  }

  /// ✅ الحصول على مفتاح القناة المناسبة للمؤذن
  String _getChannelKeyForMuezzin(String muezzinId, bool isFajr) {
    final suffix = isFajr ? 'fajr' : 'regular';

    // القنوات المتاحة
    const validMuezzins = ['ali_almula', 'nasr_tobar', 'srehi'];

    // إذا كان المؤذن غير معروف، استخدم علي الملا
    final actualMuezzin = validMuezzins.contains(muezzinId)
        ? muezzinId
        : 'ali_almula';

    return 'athan_${actualMuezzin}_$suffix';
  }

  /// ✅ تهيئة خدمة الأذان
  /// ملاحظة: القنوات تُهيأ في PrayerNotificationService.initialize()
  Future<void> initialize() async {
    if (_isInitialized) {
      log('ℹ️ FlutterAthanService already initialized');
      return;
    }

    try {
      // ملاحظة: لا نهيئ القنوات هنا لأنها تُهيأ في PrayerNotificationService
      // نتأكد فقط من تهيئة مشغل الصوت

      // تهيئة مشغل الصوت
      _audioPlayer = AudioPlayer();

      // الاستماع لانتهاء التشغيل
      _audioPlayer?.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _onAthanCompleted();
        }
      });

      _isInitialized = true;
      log('✅ FlutterAthanService initialized');
    } catch (e) {
      log('❌ Error initializing FlutterAthanService: $e');
      rethrow;
    }
  }

  /// ✅ جدولة إشعار الأذان مع صوت
  ///
  /// هذا الإشعار سيعمل حتى لو كان التطبيق مغلقاً تماماً
  /// يستخدم قناة مختلفة لكل مؤذن لضمان تشغيل الصوت الصحيح
  Future<void> scheduleAthan({
    required int prayerId,
    required DateTime prayerTime,
    required String prayerName,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final muezzinId = await _getSelectedMuezzinId();
      final isFajr = prayerName == 'Fajr';
      final arabicName = _prayerNameArabic[prayerName] ?? prayerName;

      // اختيار القناة المناسبة بناءً على المؤذن ونوع الصلاة
      final channelKey = _getChannelKeyForMuezzin(muezzinId, isFajr);

      final notificationId = _athanNotificationIdBase + prayerId;

      log('📅 [FlutterAthanService] Scheduling Athan:');
      log('   - Prayer: $prayerName ($arabicName)');
      log('   - Time: $prayerTime');
      log('   - Notification ID: $notificationId');
      log('   - Muezzin: $muezzinId');
      log('   - Channel: $channelKey');

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: channelKey,
          title: '🕌 Prayer Time',
          body: 'It is time for prayer $arabicName',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: false,
          criticalAlert: false,
          autoDismissible: true,
          payload: {
            'type': 'athan',
            'prayer': prayerName,
            'muezzin': muezzinId,
            'is_fajr': isFajr.toString(),
            'play_full_athan': 'true',
          },
          actionType: ActionType.KeepOnTop,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'STOP_ATHAN',
            label: '⏹️ Stop',
            actionType: ActionType.SilentAction,
          ),
          NotificationActionButton(
            key: 'DISMISS',
            label: '✓ Hide',
            actionType: ActionType.DismissAction,
          ),
        ],
        schedule: NotificationCalendar(
          year: prayerTime.year,
          month: prayerTime.month,
          day: prayerTime.day,
          hour: prayerTime.hour,
          minute: prayerTime.minute,
          second: 0,
          millisecond: 0,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      log('✅ Athan scheduled successfully for $prayerName at $prayerTime');
    } catch (e) {
      log('❌ Error scheduling Athan: $e');
    }
  }

  /// ✅ تشغيل الأذان كاملاً (يُستخدم عندما يكون التطبيق في الخلفية)
  ///
  /// هذه الدالة تُستدعى من معالج الإشعارات عند استلام إشعار الأذان
  Future<void> playFullAthan({
    required String prayerName,
    String? muezzinId,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final selectedMuezzin = muezzinId ?? await _getSelectedMuezzinId();
      final isFajr = prayerName == 'Fajr';

      // اسم ملف الصوت الكامل
      final audioFileName = isFajr
          ? '${selectedMuezzin}_fajr'
          : '${selectedMuezzin}_regular';

      log('▶️ Playing full Athan for $prayerName: $audioFileName');

      // إيقاف أي تشغيل سابق
      await stopAthan();

      // تحميل وتشغيل الصوت
      await _audioPlayer?.setAsset('assets/athan/$audioFileName.mp3');
      await _audioPlayer?.play();

      _isPlaying = true;
      log('✅ Full Athan playing: $audioFileName');
    } catch (e) {
      log('❌ Error playing full Athan: $e');
    }
  }

  /// ✅ تشغيل الأذان فوراً (للاختبار أو التشغيل اليدوي)
  Future<void> playAthanForPrayer(String prayerName) async {
    try {
      if (!_isInitialized) await initialize();

      final muezzinId = await _getSelectedMuezzinId();
      final isFajr = prayerName == 'Fajr';
      final arabicName = _prayerNameArabic[prayerName] ?? prayerName;
      final channelKey = _getChannelKeyForMuezzin(muezzinId, isFajr);

      log('🔔 Playing Athan immediately for $prayerName');

      // عرض إشعار فوري - بدون اهتزاز وبدون فتح التطبيق
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _athanNotificationIdBase + 99, // ID خاص للتشغيل الفوري
          channelKey: channelKey,
          title: '🕌 حان وقت الصلاة',
          body: 'حان الآن موعد صلاة $arabicName',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: false,
          autoDismissible: true,
          payload: {
            'type': 'athan',
            'prayer': prayerName,
            'muezzin': muezzinId,
            'is_fajr': isFajr.toString(),
          },
          actionType: ActionType.KeepOnTop,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'STOP_ATHAN',
            label: '⏹️ Stop',
            actionType: ActionType.SilentAction,
          ),
        ],
      );

      // تشغيل الأذان كاملاً
      await playFullAthan(prayerName: prayerName, muezzinId: muezzinId);
    } catch (e) {
      log('❌ Error playing Athan for prayer: $e');
    }
  }

  /// ✅ إيقاف الأذان
  Future<void> stopAthan() async {
    try {
      if (_audioPlayer != null && _isPlaying) {
        await _audioPlayer?.stop();
        _isPlaying = false;
        log('⏹️ Athan stopped');
      }
    } catch (e) {
      log('❌ Error stopping Athan: $e');
    }
  }

  /// ✅ إلغاء إشعار أذان محدد
  Future<void> cancelAthan(int prayerId) async {
    try {
      final notificationId = _athanNotificationIdBase + prayerId;
      await AwesomeNotifications().cancel(notificationId);
      log('✅ Athan notification cancelled: $prayerId');
    } catch (e) {
      log('❌ Error cancelling Athan: $e');
    }
  }

  /// ✅ إلغاء جميع إشعارات الأذان المجدولة
  Future<void> cancelAllAthans() async {
    try {
      // إلغاء IDs من 200 إلى 215
      for (int i = 0; i <= 15; i++) {
        await AwesomeNotifications().cancel(_athanNotificationIdBase + i);
      }
      await stopAthan();
      log('✅ All Athan notifications cancelled');
    } catch (e) {
      log('❌ Error cancelling all Athans: $e');
    }
  }

  /// ✅ معالجة انتهاء الأذان
  void _onAthanCompleted() async {
    log('🏁 Athan playback completed');
    _isPlaying = false;

    // تفعيل وضع الخشوع
    try {
      await KhushooModeService().activateKhushooMode();
      log('🤲 Khushoo mode activated after Athan');
    } catch (e) {
      log('⚠️ Error activating Khushoo mode: $e');
    }
  }

  /// ✅ معالجة الضغط على إشعار الأذان
  ///
  /// تُستدعى من NotificationHandler
  static Future<void> handleAthanNotification(
    ReceivedAction receivedAction,
  ) async {
    final payload = receivedAction.payload;
    if (payload == null) return;

    final type = payload['type'];
    if (type != 'athan') return;

    final buttonKey = receivedAction.buttonKeyPressed;
    log('🔔 Athan notification action: $buttonKey');

    if (buttonKey == 'STOP_ATHAN') {
      // إيقاف الأذان
      await FlutterAthanService().stopAthan();
      await AwesomeNotifications().dismiss(receivedAction.id!);
    } else if (payload['play_full_athan'] == 'true') {
      // محاولة تشغيل الأذان كاملاً
      final prayerName = payload['prayer'] ?? 'Dhuhr';
      final muezzinId = payload['muezzin'];

      try {
        await FlutterAthanService().playFullAthan(
          prayerName: prayerName,
          muezzinId: muezzinId,
        );
      } catch (e) {
        log('⚠️ Could not play full Athan (app might be terminated): $e');
        // الصوت القصير من الإشعار سيعمل على أي حال
      }
    }
  }

  /// ✅ التحقق من إذن الصوت الحرج (iOS)
  Future<bool> requestCriticalAlertsPermission() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications(
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Badge,
            NotificationPermission.CriticalAlert,
          ],
        );
      }
      return true;
    } catch (e) {
      log('❌ Error requesting critical alerts permission: $e');
      return false;
    }
  }

  /// ✅ التخلص من الموارد
  Future<void> dispose() async {
    try {
      await stopAthan();
      await _audioPlayer?.dispose();
      _audioPlayer = null;
      _isInitialized = false;
      log('🔌 FlutterAthanService disposed');
    } catch (e) {
      log('❌ Error disposing FlutterAthanService: $e');
    }
  }

  // ============================================================
  // Compatibility methods with old AthanAudioService
  // ============================================================

  /// ✅ [DEPRECATED] للتوافق مع الكود القديم
  @Deprecated('Use scheduleAthan instead')
  Future<bool> canScheduleExactAlarms() async => true;

  @Deprecated('Not needed for Flutter implementation')
  Future<void> requestExactAlarmPermission() async {}

  @Deprecated('Not needed for Flutter implementation')
  Future<bool> isBatteryOptimized() async => false;

  @Deprecated('Not needed for Flutter implementation')
  Future<void> requestBatteryOptimizationExemption() async {}

  @Deprecated('Not needed for Flutter implementation')
  Future<void> openAppSettings() async {}
}
