import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/settings/data/models/notification_settings_model.dart';

/// ✅ خدمة وضع الخشوع - تكتم الإشعارات لمدة 30 دقيقة بعد الأذان
///
/// يتم تفعيلها تلقائياً بعد انتهاء الأذان ولا تحتاج تدخل من المستخدم
class KhushooModeService {
  static final KhushooModeService _instance = KhushooModeService._internal();
  factory KhushooModeService() => _instance;
  KhushooModeService._internal();

  /// مدة وضع الخشوع بالدقائق (30 دقيقة)
  static const int khushooModeDurationMinutes = 30;

  /// مفتاح حفظ وقت انتهاء وضع الخشوع (للاستخدام من Flutter)
  static const String _khushooEndTimeKey = 'khushoo_mode_end_time';

  /// مفتاح حفظ حالة تفعيل وضع الخشوع (للاستخدام من Flutter)
  static const String _khushooEnabledKey = 'khushoo_mode_enabled';

  /// ✅ تفعيل وضع الخشوع
  /// يتم استدعاؤها عند انتهاء الأذان
  Future<void> activateKhushooMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ 1. التحقق من تفعيل الميزة من الإعدادات
      final settingsJson = prefs.getString('NOTIFICATION_SETTINGS');
      if (settingsJson != null) {
        final settings = NotificationSettingsModel.fromJson(settingsJson);
        if (!settings.isKhushooModeEnabled) {
          log('🚫 وضع الخشوع معطل من الإعدادات - لن يتم التفعيل');
          return;
        }
      } else {
        // إذا لم توجد إعدادات محفوظة، نعتبر الميزة معطلة افتراضياً
        log('ℹ️ إعدادات الإشعارات غير موجودة - وضع الخشوع معطل');
        return;
      }

      // حساب وقت انتهاء وضع الخشوع (الآن + 30 دقيقة)
      final endTime = DateTime.now().add(
        const Duration(minutes: khushooModeDurationMinutes),
      );

      // حفظ وقت الانتهاء
      await prefs.setString(_khushooEndTimeKey, endTime.toIso8601String());
      await prefs.setBool(_khushooEnabledKey, true);

      log('🧸 تم تفعيل وضع الخشوع - سينتهي في: ${endTime.toString()}');
      log('🔕 كتم جميع الإشعارات لمدة $khushooModeDurationMinutes دقيقة');
    } catch (e) {
      log('❌ خطأ في تفعيل وضع الخشوع: $e');
    }
  }

  /// ✅ إلغاء وضع الخشوع يدوياً (إذا لزم الأمر)
  Future<void> deactivateKhushooMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_khushooEndTimeKey);
      await prefs.setBool(_khushooEnabledKey, false);

      log('✅ تم إلغاء وضع الخشوع');
    } catch (e) {
      log('❌ خطأ في إلغاء وضع الخشوع: $e');
    }
  }

  /// ✅ التحقق ما إذا كان وضع الخشوع مفعل حالياً
  /// يجب استدعاؤها قبل إرسال أي إشعار
  /// هذه الدالة تقرأ من كلا المفتاحين (Flutter و Native)
  Future<bool> isKhushooModeActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // أولاً: تحقق من المفاتيح التي يكتبها Flutter
      bool isEnabled = prefs.getBool(_khushooEnabledKey) ?? false;
      String? endTimeStr = prefs.getString(_khushooEndTimeKey);

      // ثانياً: إذا لم يتم العثور عليها، تحقق من المفاتيح التي يكتبها Native Android
      // الكود الـ Native يحفظ بالبادئة flutter. مباشرة
      if (!isEnabled) {
        // نحتاج للقراءة مباشرة من SharedPreferences بدون استخدام flutter wrapper
        // لأن Flutter يضيف 'flutter.' تلقائياً
        final allKeys = prefs.getKeys();
        log('🔑 جميع المفاتيح في SharedPreferences: $allKeys');

        // البحث عن المفتاح الذي يحفظه Native
        for (final key in allKeys) {
          if (key.contains('khushoo_mode_enabled')) {
            final value = prefs.getBool(key);
            log('🔍 وجدت مفتاح: $key = $value');
            if (value == true) {
              isEnabled = true;
            }
          }
          if (key.contains('khushoo_mode_end_time')) {
            final value = prefs.getString(key);
            log('🔍 وجدت مفتاح: $key = $value');
            if (value != null && endTimeStr == null) {
              endTimeStr = value;
            }
          }
        }
      }

      if (!isEnabled) {
        log('🔔 وضع الخشوع غير مفعل');
        return false;
      }

      // التحقق من وقت الانتهاء
      if (endTimeStr == null) {
        log('⚠️ لا يوجد وقت انتهاء محفوظ');
        return false;
      }

      // محاولة تحليل التاريخ (قد يكون ISO8601 أو Instant.toString)
      DateTime? endTime;
      try {
        endTime = DateTime.parse(endTimeStr);
      } catch (e) {
        // محاولة تحليل صيغة Instant (Java)
        // الصيغة: 2024-12-05T21:19:17.123Z
        final instant = endTimeStr.replaceAll('Z', '+00:00');
        try {
          endTime = DateTime.parse(instant);
        } catch (e2) {
          log('❌ خطأ في تحليل التاريخ: $endTimeStr');
          return false;
        }
      }

      final now = DateTime.now();

      // إذا انتهى الوقت، نلغي الوضع تلقائياً
      if (now.isAfter(endTime)) {
        await deactivateKhushooMode();
        log('✅ انتهى وضع الخشوع تلقائياً');
        return false;
      }

      // الوضع لا يزال مفعلاً
      final remainingMinutes = endTime.difference(now).inMinutes;
      log('🧸 وضع الخشوع مفعل - متبقي: $remainingMinutes دقيقة');
      return true;
    } catch (e) {
      log('❌ خطأ في فحص وضع الخشوع: $e');
      return false;
    }
  }

  /// ✅ الحصول على الوقت المتبقي لوضع الخشوع بالدقائق
  Future<int> getRemainingMinutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final endTimeStr = prefs.getString(_khushooEndTimeKey);

      if (endTimeStr == null) return 0;

      final endTime = DateTime.parse(endTimeStr);
      final now = DateTime.now();

      if (now.isAfter(endTime)) return 0;

      return endTime.difference(now).inMinutes;
    } catch (e) {
      return 0;
    }
  }

  /// ✅ الحصول على وقت انتهاء وضع الخشوع
  Future<DateTime?> getEndTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final endTimeStr = prefs.getString(_khushooEndTimeKey);

      if (endTimeStr == null) return null;

      return DateTime.parse(endTimeStr);
    } catch (e) {
      return null;
    }
  }
}
