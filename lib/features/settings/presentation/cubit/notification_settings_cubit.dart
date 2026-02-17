import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/prayer_notification_service_new.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/settings/data/models/notification_settings_model.dart';
import 'package:meshkat_elhoda/core/services/smart_dhikr_service.dart';
import 'dart:developer';

class NotificationSettingsCubit extends Cubit<NotificationSettingsModel> {
  final SharedPreferences _prefs;
  final PrayerNotificationService _notificationService;

  static const String _storageKey = 'NOTIFICATION_SETTINGS';

  NotificationSettingsCubit(this._prefs, this._notificationService)
    : super(const NotificationSettingsModel()) {
    _loadSettings();
  }

  /// تحميل الإعدادات المحفوظة
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs.getString(_storageKey);
      if (settingsJson != null) {
        final settings = NotificationSettingsModel.fromJson(settingsJson);
        emit(settings);
        log('✅ تم تحميل إعدادات الإشعارات: $settingsJson');
      } else {
        log('ℹ️ لا توجد إعدادات محفوظة، استخدام الإعدادات الافتراضية');
      }
    } catch (e) {
      log('❌ خطأ في تحميل إعدادات الإشعارات: $e');
    }
  }

  /// حفظ الإعدادات وإعادة جدولة الإشعارات
  Future<void> _saveAndReschedule(NotificationSettingsModel newSettings) async {
    try {
      // 1. حفظ في SharedPreferences
      await _prefs.setString(_storageKey, newSettings.toJson());
      
      // ✅ Sync individual keys for Background Services (SmartDhikrService, etc.)
      // These services read boolean keys directly to avoid parsing full JSON
      await _prefs.setBool('isSmartVoiceEnabled', newSettings.isSmartVoiceEnabled);
      await _prefs.setInt('smartVoiceIntervalMinutes', newSettings.smartVoiceIntervalMinutes);
      await _prefs.setBool('isAthanOverlayEnabled', newSettings.isAthanOverlayEnabled);
      await _prefs.setBool('isSuhoorAlarmEnabled', newSettings.isSuhoorAlarmEnabled);
      await _prefs.setBool('isIftarAlarmEnabled', newSettings.isIftarAlarmEnabled);
      // We can add others if needed, but these are the critical ones for background tasks


      // 2. تحديث الحالة
      emit(newSettings);

      // 3. إعادة جدولة الإشعارات بناءً على الإعدادات الجديدة
      await _rescheduleNotifications();

      log('✅ تم حفظ إعدادات الإشعارات وإعادة الجدولة');
    } catch (e) {
      log('❌ خطأ في حفظ الإعدادات: $e');
    }
  }

  /// إعادة جدولة جميع الإشعارات بناءً على الإعدادات الحالية
  Future<void> _rescheduleNotifications() async {
    try {
      // الحصول على بيانات الموقع المحفوظة
      final latitude = _prefs.getDouble('latitude');
      final longitude = _prefs.getDouble('longitude');
      final language = _prefs.getString('language') ?? 'ar';

      if (latitude != null && longitude != null) {
        // إلغاء جميع الإشعارات المجدولة
        await _notificationService.cancelAllNotifications();

        // إعادة الجدولة بناءً على الإعدادات الجديدة
        // استخدام forceReschedule: true لتجاوز فحص الـ 30 ثانية
        await _notificationService.scheduleTodayPrayers(
          latitude: latitude,
          longitude: longitude,
          language: language,
          settings: state,
          forceReschedule:
              true, // ⚠️ مهم: تجاوز فحص الوقت عند تحديث الإعدادات يدوياً
        );

        log('✅ تم إعادة جدولة الإشعارات بنجاح');
      } else {
        log('⚠️ لا توجد بيانات موقع محفوظة، لا يمكن جدولة الإشعارات');
      }
    } catch (e) {
      log('❌ خطأ في إعادة جدولة الإشعارات: $e');
    }
  }

  /// تبديل حالة إشعار الأذان
  Future<void> toggleAthanNotification(bool value) async {
    final newSettings = state.copyWith(isAthanEnabled: value);
    await _saveAndReschedule(newSettings);
  }

  /// تبديل حالة إشعار قبل الأذان
  Future<void> togglePreAthanNotification(bool value) async {
    final newSettings = state.copyWith(isPreAthanEnabled: value);
    await _saveAndReschedule(newSettings);
  }

  /// تبديل حالة إشعار أذكار الصباح والمساء
  Future<void> toggleAzkarSabahMasa(bool value) async {
    final newSettings = state.copyWith(isAzkarSabahMasaEnabled: value);
    await _saveAndReschedule(newSettings);
  }

  /// تبديل حالة إشعار ذكرني بالله
  Future<void> toggleZikrAllah(bool value) async {
    final newSettings = state.copyWith(isZikrAllahEnabled: value);
    await _saveAndReschedule(newSettings);
  }

  Future<void> toggleAthanOverlay(bool value) async {
    final newSettings = state.copyWith(isAthanOverlayEnabled: value);
    await _saveAndReschedule(newSettings);
  }

  Future<void> toggleSuhoorAlarm(bool value) async {
    final newSettings = state.copyWith(isSuhoorAlarmEnabled: value);
    await _saveAndReschedule(newSettings);
  }

  Future<void> toggleIftarAlarm(bool value) async {
    final newSettings = state.copyWith(isIftarAlarmEnabled: value);
    await _saveAndReschedule(newSettings);
  }

  /// تغيير فترة تكرار ذكرني بالله
  Future<void> setZikrInterval(int minutes) async {
    final newSettings = state.copyWith(zikrIntervalMinutes: minutes);
    await _saveAndReschedule(newSettings);
  }

  /// تبديل حالة وضع الخشوع
  Future<void> toggleKhushooMode(bool value) async {
    final newSettings = state.copyWith(isKhushooModeEnabled: value);
    await _saveAndReschedule(newSettings);
  }

  /// تبديل حالة إشعارات الختمة الجماعية
  Future<void> toggleCollectiveKhatma(bool value) async {
    final newSettings = state.copyWith(isCollectiveKhatmaEnabled: value);
    await _saveAndReschedule(newSettings);
  }

  /// تبديل حالة الأذكار الصوتية الذكية
  Future<void> toggleSmartVoice(bool value) async {
    final newSettings = state.copyWith(isSmartVoiceEnabled: value);
    // حفظ الإعدادات أولاً (يستدعي _rescheduleNotifications)
    await _saveAndReschedule(newSettings);
    
    // التعامل مع SmartDhikrService مباشرة
    if (value) {
      await SmartDhikrService().scheduleDhikr(newSettings.smartVoiceIntervalMinutes);
    } else {
      // إذا تم تعطيل الصوت، لا نلغي المهمة تماماً لأننا نحتاجها للمناسبات (Occasions)
      // نجدولها كل 60 دقيقة للتحقق من المناسبات (تكلفة منخفضة)
      await SmartDhikrService().scheduleDhikr(60);
    }
  }



  Future<void> setSmartVoiceInterval(int minutes) async {
    final newSettings = state.copyWith(smartVoiceIntervalMinutes: minutes);
    await _saveAndReschedule(newSettings);

    if (newSettings.isSmartVoiceEnabled) {
      await SmartDhikrService().scheduleDhikr(minutes);
    } else {
       // If disabled, we ensure it's at 60 default (redundant but safe)
       await SmartDhikrService().scheduleDhikr(60);
    }
  }
}
