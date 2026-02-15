import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:meshkat_elhoda/core/services/flutter_athan_service.dart';
import 'package:meshkat_elhoda/core/services/khushoo_mode_service.dart';

/// ✅ معالج الإشعارات - يتحقق من وضع الخشوع ويعالج إشعارات الأذان
/// ملاحظة مهمة: هذه الدوال يجب أن تكون static و top-level للعمل مع AwesomeNotifications
class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  /// ✅ تهيئة معالج الإشعارات
  /// ملاحظة: setListeners يتم تسجيلها في main() الآن للعمل في terminated state
  Future<void> initialize() async {
    // تم نقل setListeners إلى main() للعمل قبل أي await
    log('✅ تم تهيئة معالج الإشعارات مع فحص وضع الخشوع ودعم الأذان');
  }

  /// ✅ عند إنشاء الإشعار
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    log(
      '📝 تم إنشاء إشعار: ${receivedNotification.id} - ${receivedNotification.title}',
    );

    // التحقق من وضع الخشوع عند الإنشاء أيضاً
    final payload = receivedNotification.payload;
    if (payload != null && payload['check_khushoo'] == 'true') {
      log('🔍 الإشعار يتطلب فحص وضع الخشوع...');
      final isKhushooActive = await KhushooModeService().isKhushooModeActive();

      if (isKhushooActive) {
        log(
          '🤲 وضع الخشوع مفعل - سيتم إلغاء الإشعار ${receivedNotification.id}',
        );
        // إلغاء الإشعار فوراً
        await AwesomeNotifications().cancel(receivedNotification.id!);
      }
    }
  }

  /// ✅ عند عرض الإشعار - التحقق من وضع الخشوع وتفعيله للأذان
  /// ملاحظة: لا نشغل الأذان هنا لأن صوت الإشعار يكفي
  /// تشغيل الأذان هنا سيسبب مشاكل مثل تشغيله عند فتح التطبيق
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    log(
      '👁️ عرض إشعار: ${receivedNotification.id} - ${receivedNotification.title}',
    );

    final payload = receivedNotification.payload;
    if (payload == null) return;

    // ✅ تفعيل وضع الخشوع وتشغيل الأذان عند عرض الإشعار
    if (payload['type'] == 'athan') {
      log('🕌 تم عرض إشعار الأذان - بدء الإجراءات...');
      
      // 1. تشغيل الأذان (Robust Audio Player)
      // هذا يضمن استمرار الصوت حتى عند التفاعل مع الإشعارات
      if (payload['play_full_athan'] == 'true') {
        try {
          final prayerName = payload['prayer'] ?? 'Prayer';
          final muezzinId = payload['muezzin'];
          
          log('▶️ محاولة تشغيل الأذان عبر FlutterAthanService...');
          await FlutterAthanService().playFullAthan(
            prayerName: prayerName,
            muezzinId: muezzinId,
          );
        } catch (e) {
          log('⚠️ خطأ في تشغيل صوت الأذان: $e');
        }
      }

      // 2. تفعيل وضع الخشوع
      log('🤲 تفعيل وضع الخشوع...');
      try {
        await KhushooModeService().activateKhushooMode();
        log('✅ تم تفعيل وضع الخشوع');
      } catch (e) {
        log('⚠️ خطأ في تفعيل وضع الخشوع: $e');
      }
    } else if (payload['type'] == 'suhoor') {
      log('🥣 عرض إشعار السحور - تشغيل الصوت...');
      await SmartDhikrService().playSuhoorAudio();
    } else if (payload['type'] == 'iftar') {
      log('🌙 عرض إشعار الإفطار - تشغيل الدعاء...');
      await SmartDhikrService().playIftarAudio();
    }

    // التحقق من وضع الخشوع للإشعارات الأخرى
    if (payload['check_khushoo'] == 'true') {
      log('🔍 فحص وضع الخشوع للإشعار ${receivedNotification.id}...');
      final isKhushooActive = await KhushooModeService().isKhushooModeActive();

      if (isKhushooActive) {
        log(
          '🤲 وضع الخشوع مفعل - إلغاء الإشعار ${receivedNotification.id} فوراً',
        );
        // إلغاء الإشعار فوراً لأن وضع الخشوع مفعل
        await AwesomeNotifications().dismiss(receivedNotification.id!);
        await AwesomeNotifications().cancel(receivedNotification.id!);
      } else {
        log('🔔 وضع الخشوع غير مفعل - عرض الإشعار بشكل طبيعي');
      }
    }
  }

  /// ✅ عند الضغط على الإشعار
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    log('👆 تم الضغط على الإشعار: ${receivedAction.id}');
    log('🔘 زر: ${receivedAction.buttonKeyPressed}');

    // التحقق من نوع الإشعار والإجراء المطلوب
    final payload = receivedAction.payload;
    if (payload != null) {
      final type = payload['type'];

      switch (type) {
        case 'athan':
          // معالجة إشعار الأذان
          await _handleAthanAction(receivedAction);
          break;
        case 'prayer_time':
          // يمكن إضافة منطق إضافي هنا
          break;
        case 'zikr_reminder':
          // يمكن فتح صفحة الأذكار
          break;
        case 'azkar_sabah':
        case 'azkar_masa':
          // يمكن فتح صفحة أذكار الصباح/المساء
          break;
      }
    }
  }

  /// ✅ معالجة تفاعلات إشعار الأذان
  static Future<void> _handleAthanAction(ReceivedAction receivedAction) async {
    final buttonKey = receivedAction.buttonKeyPressed;
    final payload = receivedAction.payload;

    log('🕌 معالجة إجراء الأذان: $buttonKey');

    if (buttonKey == 'STOP_ATHAN') {
      // إيقاف الأذان
      log('⏹️ إيقاف الأذان بناءً على طلب المستخدم');
      await FlutterAthanService().stopAthan();
      await AwesomeNotifications().dismiss(receivedAction.id!);
    } else if (buttonKey == 'DISMISS') {
      // الضغط على زر DISMISS أو سحب الإشعار
      log('🔔 تفاعل مع إشعار الأذان (Dismiss)');
      await FlutterAthanService().stopAthan();
    } else if (buttonKey.isEmpty) {
      // الضغط على الإشعار نفسه (Tap) -> فتح التطبيق فقط
      log('🔔 تم الضغط على الإشعار - فتح التطبيق (الصوت سيستمر)');
      // لا نوقف الأذان هنا
    } else if (payload != null && payload['play_full_athan'] == 'true') {
      // محاولة تشغيل الأذان كاملاً عند الضغط
      final prayerName = payload['prayer'] ?? 'Dhuhr';
      final muezzinId = payload['muezzin'];

      try {
        await FlutterAthanService().playFullAthan(
          prayerName: prayerName,
          muezzinId: muezzinId,
        );
      } catch (e) {
        log('⚠️ لا يمكن تشغيل الأذان كاملاً: $e');
      }
    }
  }

  /// ✅ عند رفض الإشعار
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    log('❌ تم رفض الإشعار: ${receivedAction.id}');

    final payload = receivedAction.payload;
    if (payload != null && payload['type'] == 'athan') {
      // إيقاف الأذان إذا تم رفض الإشعار
      log('⏹️ إيقاف الأذان بسبب رفض الإشعار');
      await FlutterAthanService().stopAthan();
    }
  }
}
