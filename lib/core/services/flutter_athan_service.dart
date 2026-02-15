import 'dart:developer';
import 'dart:ui';
import 'dart:isolate';

import 'package:audio_session/audio_session.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';

import '../../features/prayer_times/domain/repositories/prayer_times_repository.dart';
import 'khushoo_mode_service.dart';

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
  
  /// Isolate Port Name
  static const String _isolatePortName = 'athan_audio_service_port';
  ReceivePort? _receivePort;

  /// Audio player for full athan playback
  AudioPlayer? _audioPlayer;
  bool _isInitialized = false;
  bool _isPlaying = false;
  
  // ... (Other properties remain same)

  /// ✅ تهيئة خدمة الأذان
  Future<void> initialize() async {
    if (_isInitialized) {
      log('ℹ️ FlutterAthanService already initialized (Isolate: ${Isolate.current.hashCode})');
      return;
    }

    try {
      _audioPlayer = AudioPlayer();

      // الاستماع لانتهاء التشغيل
      _audioPlayer?.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _onAthanCompleted();
        }
      });
      
      // ⚠️ Note: We do NOT register the port here anymore.
      // We only register it in playFullAthan() to prevent the Main Isolate
      // from stealing the port from the Background Isolate.

      _isInitialized = true;
      log('✅ FlutterAthanService initialized (Isolate: ${Isolate.current.hashCode})');
    } catch (e) {
      log('❌ Error initializing FlutterAthanService: $e');
      rethrow;
    }
  }

  /// ✅ تسجيل منفذ الاستماع للأوامر
  void _registerIsolatePort() {
    try {
      final currentIso = Isolate.current.hashCode;
      log('🔌 Registering Isolate Port for Isolate: $currentIso');
      
      // إزالة أي منفذ مسجل سابقاً بنفس الاسم
      IsolateNameServer.removePortNameMapping(_isolatePortName);
      
      _receivePort = ReceivePort();
      _receivePort!.listen((message) {
        log('📩 Received Isolate Message: $message in Isolate: $currentIso');
        if (message == 'STOP') {
          stopAthan(fromIsolate: true);
        }
      });
      
      final registered = IsolateNameServer.registerPortWithName(
        _receivePort!.sendPort,
        _isolatePortName,
      );
      
      log('✅ Isolate Port Registered: $registered');
    } catch (e) {
      log('❌ Error registering isolate port: $e');
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
          criticalAlert: true,
          autoDismissible: false,
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
            key: 'DISMISS',
            label: '✓ Hide',
            actionType: ActionType.DismissAction,
          ),
          NotificationActionButton(
            key: 'STOP_ATHAN',
            label: '⏹️ Stop',
            actionType: ActionType.SilentAction,
            isDangerousOption: true,
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

  /// ✅ تشغيل الأذان كاملاً
  Future<void> playFullAthan({
    required String prayerName,
    String? muezzinId,
  }) async {
    try {
      log('🚀 playFullAthan called in Isolate: ${Isolate.current.hashCode}');
      
      // 1. أولاً: إيقاف أي تشغيل سابق وتدمير المشغل القديم (لضمان بداية نظيفة)
      await stopAthan();
      
      // 2. ثانياً: إعادة التهيئة (إنشاء مشغل جديد)
      await initialize();
      
      // 3. ✅ ثالثاً: تسجيل المنفذ هنا حصرياً
      // هذا يضمن أن المنفذ يشير دائماً للعزل الذي يشغل الصوت حالياً
      _registerIsolatePort();

      final selectedMuezzin = muezzinId ?? await _getSelectedMuezzinId();
      final isFajr = prayerName == 'Fajr';

      // اسم ملف الصوت الكامل
      final audioFileName = isFajr
          ? '${selectedMuezzin}_fajr'
          : '${selectedMuezzin}_regular';

      log('▶️ Playing full Athan for $prayerName: $audioFileName');

      // تحميل وتشغيل الصوت
      await _audioPlayer?.setAudioSource(
          AudioSource.asset('assets/athan/$audioFileName.mp3'),
      );
      
      // ✅ تكوين جلسة الصوت (Media Stream)
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
        androidWillPauseWhenDucked: false,
      ));

      await _audioPlayer?.setAndroidAudioAttributes(
        const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
      );

      await _audioPlayer?.setVolume(1.0);
      
      // ✅ Set Playing flag BEFORE waiting
      _isPlaying = true;
      log('✅ Full Athan playing: $audioFileName');
      
      try {
        await _audioPlayer?.play();
      } finally {
        _isPlaying = false;
        log('🏁 Playback finished or stopped');
      }
    } catch (e) {
      log('❌ Error playing full Athan: $e');
      _isPlaying = false;
    }
  }
  
  /// ✅ إيقاف الأذان (يدعم الإيقاف عبر العزل)
  Future<void> stopAthan({bool fromIsolate = false}) async {
    final serviceId = hashCode;
    final playerId = _audioPlayer?.hashCode;
    
    log('🛑 Stop Request (iso=$fromIsolate) [Svc:$serviceId, Player:$playerId]');
    
    try {
      // 1. محاولة الإيقاف المحلي - Force Stop regardless of state
      if (_audioPlayer != null) {
        log('⚡ Disposing local player to force stop...');
        try {
          // Dispose kills the underlying platform channel connection immediately
          await _audioPlayer!.dispose(); 
        } catch (e) {
          log('⚠️ Error disposing player: $e');
        }
        
        _audioPlayer = null; // Clear reference
        _isInitialized = false; // Require re-init next time
        
        _isPlaying = false;
        
        // Deactivate Audio Session to kill any lingering focus
        try {
          final session = await AudioSession.instance;
          await session.setActive(false);
        } catch (e) { /* ignore */ }

        await KhushooModeService().deactivateKhushooMode();
        log('✅ Player Disposed & Session Deactivated');
        return;
      } 
      
      // 2. إذا لم نكن في نفس العزل، أرسل رسالة للعزل الأصلي
      if (!fromIsolate) {
        log('🔍 Local player null. Checking Isolate Port...');
        final sendPort = IsolateNameServer.lookupPortByName(_isolatePortName);
        
        if (sendPort != null) {
          log('📤 Sending STOP command to original isolate...');
          sendPort.send('STOP');
        } else {
          log('⚠️ No registered Isolate Port found. Proceeding to Focus Steal...');
        }
        
        // 3. Fallback: Steal Audio Focus (Nuclear Option 2)
        // Even if message failed, taking Exclusive Focus forces OS to mute/pause the background player
        try {
          log('🔇 Initiating Audio Focus Steal to kill background audio...');
          final session = await AudioSession.instance;
          await session.configure(const AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playback,
            avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
            avAudioSessionMode: AVAudioSessionMode.defaultMode,
            avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
            avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
            androidAudioAttributes: AndroidAudioAttributes(
              contentType: AndroidAudioContentType.speech,
              flags: AndroidAudioFlags.none,
              usage: AndroidAudioUsage.media,
            ),
            androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientExclusive,
          ));
          
          await session.setActive(true);
          await Future.delayed(const Duration(milliseconds: 500));
          await session.setActive(false);
          log('✅ Audio Focus Steal completed.');
        } catch (e) {
          log('⚠️ Audio Focus Steal failed: $e');
        }
        
      } else {
        log('⚠️ Stop command via isolate: Player was already null.');
      }
      
      _isPlaying = false;
    } catch (e) {
      log('❌ Error stopping Athan: $e');
    }
  }

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

    return 'athan_${actualMuezzin}_${suffix}_v3';
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
            NotificationPermission.OverrideDnD,
            NotificationPermission.Provisional,
            NotificationPermission.Vibration,
            NotificationPermission.Car,
            NotificationPermission.FullScreenIntent,
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
