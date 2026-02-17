import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:meshkat_elhoda/features/settings/data/models/notification_settings_model.dart';
import 'package:meshkat_elhoda/core/services/athan_audio_service.dart';
import 'package:meshkat_elhoda/core/services/khushoo_mode_service.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

// ✅ خريطة مواقع طرق الحساب المختلفة
const Map<String, Map<String, dynamic>> _calculationMethods = {
  'MWL': {'id': 3, 'lat': 51.5194682, 'lng': -0.1360365},
  'ISNA': {'id': 2, 'lat': 39.7042123, 'lng': -86.3994387},
  'EGYPT': {'id': 5, 'lat': 30.0444196, 'lng': 31.2357116},
  'MAKKAH': {'id': 4, 'lat': 21.3890824, 'lng': 39.8579118},
  'KARACHI': {'id': 1, 'lat': 24.8614622, 'lng': 67.0099388},
  'TEHRAN': {'id': 7, 'lat': 35.6891975, 'lng': 51.3889736},
  'JAFARI': {'id': 0, 'lat': 34.6415764, 'lng': 50.8746035},
  'GULF': {'id': 8, 'lat': 24.1323638, 'lng': 53.3199527},
  'KUWAIT': {'id': 9, 'lat': 29.375859, 'lng': 47.9774052},
  'QATAR': {'id': 10, 'lat': 25.2854473, 'lng': 51.5310398},
  'SINGAPORE': {'id': 11, 'lat': 1.352083, 'lng': 103.819836},
  'FRANCE': {'id': 12, 'lat': 48.856614, 'lng': 2.3522219},
  'TURKEY': {'id': 13, 'lat': 39.9333635, 'lng': 32.8597419},
  'RUSSIA': {'id': 14, 'lat': 54.734791, 'lng': 55.9578555},
  'DUBAI': {'id': 16, 'lat': 25.0762677, 'lng': 55.087404},
  'JAKIM': {'id': 17, 'lat': 3.139003, 'lng': 101.686855},
  'TUNISIA': {'id': 18, 'lat': 36.8064948, 'lng': 10.1815316},
  'ALGERIA': {'id': 19, 'lat': 36.753768, 'lng': 3.0587561},
  'KEMENAG': {'id': 20, 'lat': -6.2087634, 'lng': 106.845599},
  'MOROCCO': {'id': 21, 'lat': 33.9715904, 'lng': -6.8498129},
  'PORTUGAL': {'id': 22, 'lat': 38.7222524, 'lng': -9.1393366},
  'JORDAN': {'id': 23, 'lat': 31.9461222, 'lng': 35.923844},
};

// ✅ حساب المسافة بين نقطتين جغرافيتين (Haversine formula)
double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  const earthRadius = 6371; // km
  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);

  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);

  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

double _toRadians(double degrees) {
  return degrees * math.pi / 180;
}

// ✅ إيجاد أقرب طريقة حساب بناءً على الموقع
int _getClosestCalculationMethod(double latitude, double longitude) {
  String closestMethod = 'EGYPT'; // default
  double minDistance = double.infinity;

  _calculationMethods.forEach((key, value) {
    final distance = _calculateDistance(
      latitude,
      longitude,
      value['lat'] as double,
      value['lng'] as double,
    );

    if (distance < minDistance) {
      minDistance = distance;
      closestMethod = key;
    }
  });

  final methodId = _calculationMethods[closestMethod]!['id'] as int;
  log(
    '📍 أقرب طريقة حساب: $closestMethod (ID: $methodId) - المسافة: ${minDistance.toStringAsFixed(2)} km',
  );
  return methodId;
}

/// ✅ خدمة إشعارات الصلاة المبسطة - بدون WorkManager أو Isolates
/// تعمل بنفس طريقة CollectiveKhatmaNotificationService
class PrayerNotificationService {
  static final PrayerNotificationService _instance =
      PrayerNotificationService._internal();
  factory PrayerNotificationService() => _instance;
  PrayerNotificationService._internal();

  bool _notificationsInitialized = false;
  DateTime? _lastSchedulingTime;

  /// ✅ تهيئة قنوات الإشعارات
  Future<void> initialize() async {
    if (_notificationsInitialized) {
      log('ℹ️ خدمة الإشعارات مهيأة بالفعل');
      return;
    }

    try {
      await AwesomeNotifications().initialize(null, [
        // =========================================
        // قنوات الأذان - قناة لكل مؤذن
        // =========================================

        // قناة علي الملا - عادي
        NotificationChannel(
          channelKey: 'athan_ali_almula_regular_v3',
          channelName: 'أذان علي الملا',
          channelDescription: 'إشعارات الأذان بصوت الشيخ علي الملا',
          defaultColor: const Color(0xFF4CAF50),
          importance: NotificationImportance.High,
          playSound: false,
          // soundSource: 'resource://raw/ali_almula_regular',
          enableVibration: false,
          criticalAlerts: false,
        ),
        // قناة علي الملا - فجر
        NotificationChannel(
          channelKey: 'athan_ali_almula_fajr_v3',
          channelName: 'أذان علي الملا - الفجر',
          channelDescription: 'إشعارات أذان الفجر بصوت الشيخ علي الملا',
          defaultColor: const Color(0xFF4CAF50),
          importance: NotificationImportance.High,
          playSound: false,
          // soundSource: 'resource://raw/ali_almula_fajr',
          enableVibration: false,
          criticalAlerts: false,
        ),

        // قناة نصر الدين طوبار - عادي
        NotificationChannel(
          channelKey: 'athan_nasr_tobar_regular_v3',
          channelName: 'أذان نصر الدين طوبار',
          channelDescription: 'إشعارات الأذان بصوت الشيخ نصر الدين طوبار',
          defaultColor: const Color(0xFF4CAF50),
          importance: NotificationImportance.High,
          playSound: false,
          // soundSource: 'resource://raw/nasr_tobar_regular',
          enableVibration: false,
          criticalAlerts: false,
        ),
        // قناة نصر الدين طوبار - فجر
        NotificationChannel(
          channelKey: 'athan_nasr_tobar_fajr_v3',
          channelName: 'أذان نصر الدين طوبار - الفجر',
          channelDescription: 'إشعارات أذان الفجر بصوت الشيخ نصر الدين طوبار',
          defaultColor: const Color(0xFF4CAF50),
          importance: NotificationImportance.High,
          playSound: false,
          // soundSource: 'resource://raw/nasr_tobar_fajr',
          enableVibration: false,
          criticalAlerts: false,
        ),

        // قناة الشيخ سريحي - عادي
        NotificationChannel(
          channelKey: 'athan_srehi_regular_v3',
          channelName: 'أذان الشيخ سريحي',
          channelDescription: 'إشعارات الأذان بصوت الشيخ سريحي',
          defaultColor: const Color(0xFF4CAF50),
          importance: NotificationImportance.High,
          playSound: false,
          // soundSource: 'resource://raw/srehi_regular',
          enableVibration: false,
          criticalAlerts: false,
        ),
        // قناة الشيخ سريحي - فجر
        NotificationChannel(
          channelKey: 'athan_srehi_fajr_v3',
          channelName: 'أذان الشيخ سريحي - الفجر',
          channelDescription: 'إشعارات أذان الفجر بصوت الشيخ سريحي',
          defaultColor: const Color(0xFF4CAF50),
          importance: NotificationImportance.High,
          playSound: false,
          // soundSource: 'resource://raw/srehi_fajr',
          enableVibration: false,
          criticalAlerts: false,
        ),

        // =========================================
        // قنوات أخرى
        // =========================================

        // قناة التنبيه قبل الأذان
        NotificationChannel(
          channelKey: 'reminder_channel',
          channelName: 'تذكير قبل الأذان',
          channelDescription: 'تنبيه قبل موعد الصلاة بـ 5 دقائق',
          defaultColor: const Color(0xFF2196F3),
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
          criticalAlerts: false,
        ),
        // قناة ذكرني بالله
        NotificationChannel(
          channelKey: 'zikr_channel',
          channelName: 'ذكرني بالله',
          channelDescription: 'تذكير دوري بالأذكار',
          defaultColor: const Color(0xFFFF9800),
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
        // قناة أذكار الصباح والمساء
        NotificationChannel(
          channelKey: 'azkar_sabah_masa_channel',
          channelName: 'أذكار الصباح والمساء',
          channelDescription: 'تنبيهات يومية لقراءة الأذكار',
          defaultColor: const Color(0xFF9C27B0),
          importance: NotificationImportance.High,
          playSound: true,

          enableVibration: true,
        ),
        // قناة رمضان (سحور وإفطار)
        NotificationChannel(
          channelKey: 'ramadan_channel',
          channelName: 'Ramadan Reminders',
          channelDescription: 'Suhoor and Iftar notifications',
          defaultColor: const Color(0xFF009688),
          importance: NotificationImportance.High,
          playSound: false, // Silent so we can play custom audio
          enableVibration: true,
        ),
      ]);

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
          ]
        );
      }

      _notificationsInitialized = true;
      log('✅ تم تهيئة خدمة إشعارات الصلاة');
    } catch (e) {
      log('❌ خطأ في تهيئة إشعارات الصلاة: $e');
      rethrow;
    }
  }

  /// ✅ جدولة إشعارات الصلاة (بدون WorkManager)
  /// [forceReschedule] - إذا كان true، يتجاوز فحص الـ 30 ثانية (للاستخدام عند تحديث الإعدادات يدوياً)
  Future<void> scheduleTodayPrayers({
    required double latitude,
    required double longitude,
    String language = 'ar',
    NotificationSettingsModel? settings,
    bool forceReschedule = false,
  }) async {
    try {
      log('📍 بدء جدولة إشعارات الصلاة - الموقع: ($latitude, $longitude)');
      log(
        '⚙️ الإعدادات: Athan=${settings?.isAthanEnabled}, PreAthan=${settings?.isPreAthanEnabled}, Zikr=${settings?.isZikrAllahEnabled}, Azkar=${settings?.isAzkarSabahMasaEnabled}',
      );

      // منع الجدولة المتكررة خلال فترة قصيرة (إلا إذا كان تحديث يدوي)
      if (!forceReschedule && _lastSchedulingTime != null) {
        final secondsSinceLastScheduling = DateTime.now()
            .difference(_lastSchedulingTime!)
            .inSeconds;
        if (secondsSinceLastScheduling < 30) {
          log('⏳ تم الجدولة منذ $secondsSinceLastScheduling ثانية فقط، تجاهل');
          return;
        }
      }

      _lastSchedulingTime = DateTime.now();

      if (!_notificationsInitialized) await initialize();

      final effectiveSettings = settings ?? const NotificationSettingsModel();

      // جلب مواقيت الصلاة
      final prayerTimes = await _fetchPrayerTimes(latitude, longitude);

      // حفظ البيانات محلياً
      await _savePrayerDataLocally(latitude, longitude, language, prayerTimes);

      // إلغاء إشعارات الصلاة السابقة فقط (IDs 1-100)
      for (int i = 1; i <= 100; i++) {
        await AwesomeNotifications().cancel(i);
      }
      log('✅ تم إلغاء إشعارات الصلاة السابقة');

      // إلغاء جميع الأذانات المجدولة
      await AthanAudioService().cancelAllAthans();
      log('✅ تم إلغاء جميع الأذانات المجدولة');

      // جدولة إشعارات الصلاة
      final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      int notificationId = 1;

      for (final prayer in prayers) {
        final prayerTime = prayerTimes[prayer];
        if (prayerTime != null) {
          // 1. إشعار التنبيه قبل 5 دقائق
          if (effectiveSettings.isPreAthanEnabled) {
            await _scheduleSingleNotification(
              notificationId++,
              prayer,
              prayerTime,
              language,
            );
          } else {
            notificationId++; // حافظ على تسلسل IDs
          }

          // 2. إشعار وقت الصلاة + تشغيل الأذان (عبر Native)
          await _schedulePrayerTimeNotification(
            notificationId++,
            prayer,
            prayerTime,
            language,
            shouldPlayAthan: effectiveSettings.isAthanEnabled,
          );
        }
      }

      // جدولة ذكرني بالله
      if (effectiveSettings.isZikrAllahEnabled) {
        await scheduleZikrReminders(
          intervalMinutes: effectiveSettings.zikrIntervalMinutes,
          language: language,
        );
      } else {
        // إلغاء إشعارات الذكر (IDs 5000-5100)
        for (int i = 5000; i < 5100; i++) {
          await AwesomeNotifications().cancel(i);
        }
        log('✅ تم إلغاء إشعارات ذكرني بالله');
      }

      // جدولة أذكار الصباح والمساء
      if (effectiveSettings.isAzkarSabahMasaEnabled) {
        await scheduleMorningEveningAzkar(language);
      } else {
        await AwesomeNotifications().cancel(6000);
        await AwesomeNotifications().cancel(6001);
        log('✅ تم إلغاء إشعارات أذكار الصباح والمساء');
      }

      // 🌙 جدولة إشعارات رمضان (سحور وإفطار)
      final hijriDate = HijriCalendar.now();
      if (hijriDate.hMonth == 9) {
        log('🌙 شهر رمضان المبارك - بدء جدولة السحور والإفطار...');

        // 1. وقت السحور (الفجر - 45 دقيقة)
        final fajrTimeStr = prayerTimes['Fajr'];
        if (fajrTimeStr != null) {
          try {

            // Parse "HH:mm" to DateTime
            final now = DateTime.now();
            final parts = fajrTimeStr.split(':')[0].split(' '); // Handle "05:45" or "05:45 (EST)"
            final timeParts = parts[0].split(':'); 
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            
            final fajrTime = DateTime(now.year, now.month, now.day, hour, minute);
            
            final suhoorTime = fajrTime.subtract(const Duration(minutes: 45));
            if (suhoorTime.isAfter(DateTime.now())) {
              await AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: 7001,
                  channelKey: 'ramadan_channel',
                  title: language == 'ar' ? '🌟 وقت السحور' : 'Suhoor Time',
                  body: language == 'ar' 
                      ? 'تسحروا فإن في السحور بركة' 
                      : 'Wake up for Suhoor',
                  notificationLayout: NotificationLayout.Default,
                  payload: {'type': 'suhoor'},
                  wakeUpScreen: true,
                  category: NotificationCategory.Reminder,
                ),
                schedule: NotificationCalendar.fromDate(date: suhoorTime),
              );
              log('🥣 تم جدولة السحور في: $suhoorTime');
            }
          } catch (e) {
            log('⚠️ خطأ في معالجة وقت السحور: $e');
          }
        }

        // 2. وقت الإفطار (المغرب)
        final maghribTimeStr = prayerTimes['Maghrib'];
        if (maghribTimeStr != null) {
          try {
            final now = DateTime.now();
            final parts = maghribTimeStr.split(':')[0].split(' ');
            final timeParts = parts[0].split(':');
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            
            final maghribTime = DateTime(now.year, now.month, now.day, hour, minute);

            if (maghribTime.isAfter(DateTime.now())) {
              await AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: 7002,
                  channelKey: 'ramadan_channel',
                  title: language == 'ar' ? '🌙 وقت الإفطار' : 'Iftar Time',
                  body: language == 'ar'
                      ? 'ذهب الظمأ وابتلت العروق وثبت الأجر إن شاء الله'
                      : 'Time to break your fast',
                  notificationLayout: NotificationLayout.Default,
                  payload: {'type': 'iftar'},
                  wakeUpScreen: true,
                  category: NotificationCategory.Event,
                ),
                schedule: NotificationCalendar.fromDate(date: maghribTime),
              );
              log('🍇 تم جدولة الإفطار في: $maghribTime');
            }
          } catch (e) {
            log('⚠️ خطأ في معالجة وقت الإفطار: $e');
          }
        }
      }

      log('✅ تم جدولة إشعارات الصلوات بنجاح');
    } catch (e) {
      log('❌ خطأ في جدولة الإشعارات: $e');
      rethrow;
    }
  }

  /// ✅ إعادة جدولة جميع الإشعارات (يستخدم في WorkManager)
  Future<void> rescheduleAll({
    required double latitude,
    required double longitude,
    required String language,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('NOTIFICATION_SETTINGS');
      final settings = settingsJson != null
          ? NotificationSettingsModel.fromJson(settingsJson)
          : const NotificationSettingsModel();

      await scheduleTodayPrayers(
        latitude: latitude,
        longitude: longitude,
        language: language,
        settings: settings,
        forceReschedule: true,
      );
      log('✅ تم إعادة جدولة جميع الإشعارات بناءً على الموقع الجديد');
    } catch (e) {
      log('❌ خطأ في إعادة الجدولة: $e');
    }
  }

  /// ✅ جلب مواقيت الصلاة من API
  Future<Map<String, String>> _fetchPrayerTimes(
    double latitude,
    double longitude,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final method = _getClosestCalculationMethod(latitude, longitude);
    final url =
        'https://api.aladhan.com/v1/timings/$timestamp?latitude=$latitude&longitude=$longitude&method=$method';

    log('🌐 جلب مواقيت الصلاة من: $url');

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final timings = data['data']['timings'] as Map<String, dynamic>;

          final result = {
            'Fajr': timings['Fajr'] as String,
            'Dhuhr': timings['Dhuhr'] as String,
            'Asr': timings['Asr'] as String,
            'Maghrib': timings['Maghrib'] as String,
            'Isha': timings['Isha'] as String,
          };

          log(
            '✅ تم جلب مواقيت الصلاة: ${result.entries.map((e) => "${e.key}=${e.value}").join(", ")}',
          );
          return result;
        } else {
          log('⚠️ API response error: ${response.statusCode}');
        }
      } catch (e) {
        log('⚠️ محاولة $attempt لجلب المواقيت فشلت: $e');
        if (attempt == 3) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('فشل جلب المواقيت');
  }

  /// ✅ حفظ البيانات محلياً
  Future<void> _savePrayerDataLocally(
    double latitude,
    double longitude,
    String language,
    Map<String, String> prayerTimes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', latitude);
      await prefs.setDouble('longitude', longitude);
      await prefs.setString('language', language);
      await prefs.setString('CACHED_PRAYER_TIMES', json.encode(prayerTimes));
      await prefs.setString('lastUpdate', DateTime.now().toIso8601String());
      log('✅ تم حفظ مواقيت الصلاة محلياً');
    } catch (e) {
      log('⚠️ خطأ في حفظ البيانات المحلية: $e');
    }
  }

  /// ✅ جدولة إشعار التنبيه قبل الصلاة بـ 5 دقائق
  Future<void> _scheduleSingleNotification(
    int id,
    String prayerName,
    String prayerTime,
    String language,
  ) async {
    try {
      final timeStr = prayerTime.split(' ')[0];
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();

      // ✅ إنشاء وقت الصلاة أولاً
      var prayerDateTime = DateTime(now.year, now.month, now.day, hour, minute);

      // ✅ التحقق: إذا مضى وقت الصلاة، اجعله لليوم التالي
      if (prayerDateTime.isBefore(now) ||
          prayerDateTime.isAtSameMomentAs(now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      // ✅ الآن احسب وقت التنبيه (5 دقائق قبل الصلاة)
      var notificationTime = prayerDateTime.subtract(
        const Duration(minutes: 5),
      );

      final prayerNameAr = _getPrayerNameInArabic(prayerName);
      String title = language == 'ar'
          ? '⏳ اقتربت الصلاة'
          : '⏳ Prayer Approaching';
      String body = language == 'ar'
          ? 'باقي 5 دقائق على صلاة $prayerNameAr'
          : '5 minutes remaining to $prayerName prayer';

      // 🌙 Ramadan check for Suhoor (Fajr)
      if (prayerName == 'Fajr') {
        final hijri = HijriCalendar.fromDate(prayerDateTime);
        if (hijri.hMonth == 9) {
           title = language == 'ar' ? '🌙 وقت السحور ينتهي قريباً' : '🌙 Suhoor time is ending';
           body = language == 'ar' 
               ? 'باقي 5 دقائق على أذان الفجر. تسحروا فإن في السحور بركة.' 
               : '5 mins to Fajr. Eat Suhoor for there is blessing in it.';
        }
      }

      // ✅ On Android (Tecno / aggressive OEMs), schedule pre-Athan reminder via native AlarmManager
      // for reliability when app is idle/terminated.
      if (defaultTargetPlatform == TargetPlatform.android) {
        await AthanAudioService().schedulePreAthanReminder(
          reminderId: id,
          triggerTime: notificationTime,
          title: title,
          body: body,
        );
      } else {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: 'reminder_channel',
            title: title,
            body: body,
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
          ),
          schedule: NotificationCalendar(
            year: notificationTime.year,
            month: notificationTime.month,
            day: notificationTime.day,
            hour: notificationTime.hour,
            minute: notificationTime.minute,
            second: 0,
            millisecond: 0,
            allowWhileIdle: true,
            preciseAlarm: true,
          ),
        );
      }

      log(
        '📅 جدولة تنبيه قبل صلاة $prayerName في ${notificationTime.toString()}',
      );
    } catch (e) {
      log('❌ خطأ في جدولة تذكير $prayerName: $e');
    }
  }

  /// ✅ جدولة إشعار وقت الصلاة + تشغيل الأذان (عبر Flutter)
  Future<void> _schedulePrayerTimeNotification(
    int id,
    String prayerName,
    String prayerTime,
    String language, {
    required bool shouldPlayAthan,
  }) async {
    try {
      final timeStr = prayerTime.split(' ')[0];
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      var prayerDateTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (prayerDateTime.isBefore(now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      final notificationText = _getPrayerNotificationText(prayerName, language);

      // 🌙 Ramadan check for Iftar (Maghrib)
      if (prayerName == 'Maghrib') {
        final hijri = HijriCalendar.fromDate(prayerDateTime);
        if (hijri.hMonth == 9) {
           final iftarTitle = language == 'ar' ? '🌙 موعد الإفطار' : '🌙 Iftar Time';
           final iftarBody = language == 'ar'
               ? 'اللهم لك صمت وعلى رزقك أفطرت. تقبل الله منا ومنكم.'
               : 'O Allah, for You I have fasted, and with Your provision I have broken my fast.';
           
           // Override text
           // ignore: avoid_as_null_aware_operator
           notificationText['title'] = iftarTitle;
           notificationText['body'] = iftarBody;
        }
      }

      // إذا كان الأذان مفعلاً، استخدم FlutterAthanService
      if (shouldPlayAthan) {
        await AthanAudioService().scheduleAthan(
          prayerId: id,
          prayerTime: prayerDateTime,
          prayerName: prayerName,
        );
        log('⏰ جدولة الأذان عبر Flutter لصلاة $prayerName في $prayerTime');
      } else {
        // إذا كان الأذان غير مفعل، اعرض إشعار عادي فقط
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: 'reminder_channel',
            title: notificationText['title']!,
            body: notificationText['body']!,
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
            autoDismissible: true,
            payload: {
              'prayer': prayerName,
              'type': 'prayer_time',
              'should_play_athan': 'false',
            },
          ),
          schedule: NotificationCalendar(
            year: prayerDateTime.year,
            month: prayerDateTime.month,
            day: prayerDateTime.day,
            hour: prayerDateTime.hour,
            minute: prayerDateTime.minute,
            second: 0,
            millisecond: 0,
            allowWhileIdle: true,
            preciseAlarm: true,
          ),
        );
        log('🔔 جدولة إشعار عادي لصلاة $prayerName في $prayerTime');
      }
    } catch (e) {
      log('❌ خطأ في جدولة إشعار صلاة $prayerName: $e');
    }
  }

  /// ✅ جدولة إشعارات "ذكرني بالله"
  Future<void> scheduleZikrReminders({
    required int intervalMinutes,
    String language = 'ar',
  }) async {
    try {
      // إلغاء إشعارات الذكر السابقة
      for (int i = 5000; i < 5100; i++) {
        await AwesomeNotifications().cancel(i);
      }

      final now = DateTime.now();
      final zikrList = _getZikrList(language);

      // جدولة 24 إشعار (لتغطية يوم كامل)
      for (int i = 0; i < 24; i++) {
        final scheduledTime = now.add(
          Duration(minutes: intervalMinutes * (i + 1)),
        );
        final zikr = zikrList[i % zikrList.length];

        // التحقق من وضع الخشوع قبل الجدولة
        final isKhushoo = await KhushooModeService().isKhushooModeActive();
        if (isKhushoo &&
            scheduledTime.isBefore(now.add(const Duration(minutes: 30)))) {
          log('🤫 تخطي جدولة ذكر بسبب وضع الخشوع');
          continue;
        }

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 5000 + i,
            channelKey: 'zikr_channel',
            title: zikr['title']!,
            body: zikr['body']!,
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
          ),
          schedule: NotificationCalendar(
            year: scheduledTime.year,
            month: scheduledTime.month,
            day: scheduledTime.day,
            hour: scheduledTime.hour,
            minute: scheduledTime.minute,
            second: 0,
            millisecond: 0,
            allowWhileIdle: true,
            preciseAlarm: true,
            repeats: false, // لا نستخدم repeats، بل نجدول 24 إشعار منفصل
          ),
        );
      }

      log('✅ تم جدولة 24 إشعار ذكر بفاصل $intervalMinutes دقيقة');
    } catch (e) {
      log('❌ خطأ في جدولة إشعارات الذكر: $e');
    }
  }

  /// ✅ جدولة أذكار الصباح والمساء
  Future<void> scheduleMorningEveningAzkar(String language) async {
    try {
      await AwesomeNotifications().cancel(6000);
      await AwesomeNotifications().cancel(6001);

      final now = DateTime.now();

      // أذكار الصباح (6:00 صباحاً)
      var morningTime = DateTime(now.year, now.month, now.day, 6, 0);
      if (morningTime.isBefore(now)) {
        morningTime = morningTime.add(const Duration(days: 1));
      }

      final texts = _getAzkarSabahMasaTexts(language);

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 6000,
          channelKey: 'azkar_sabah_masa_channel',
          title: texts['morning_title']!,
          body: texts['morning_body']!,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          year: morningTime.year,
          month: morningTime.month,
          day: morningTime.day,
          hour: morningTime.hour,
          minute: morningTime.minute,
          second: 0,
          millisecond: 0,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      // أذكار المساء (6:00 مساءً)
      var eveningTime = DateTime(now.year, now.month, now.day, 18, 0);
      if (eveningTime.isBefore(now)) {
        eveningTime = eveningTime.add(const Duration(days: 1));
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 6001,
          channelKey: 'azkar_sabah_masa_channel',
          title: texts['evening_title']!,
          body: texts['evening_body']!,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          year: eveningTime.year,
          month: eveningTime.month,
          day: eveningTime.day,
          hour: eveningTime.hour,
          minute: eveningTime.minute,
          second: 0,
          millisecond: 0,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      log('✅ تم جدولة أذكار الصباح والمساء');
    } catch (e) {
      log('❌ خطأ في جدولة أذكار الصباح والمساء: $e');
    }
  }

  /// 🛠️ Debug: Schedule a test Athan notification in 2 minutes
  Future<void> scheduleImmediateAthanTest() async {
    try {
      final now = DateTime.now();
      final testTime = now.add(const Duration(minutes: 1));
      
      debugPrint("🛠️ Scheduling Immediate Athan Test at $testTime...");

      // Use AthanAudioService directly to test audio + notification
      await AthanAudioService().scheduleAthan(
        prayerId: 9999, // Debug ID
        prayerTime: testTime,
        prayerName: "Test Prayer",
      );
      
      // Also schedule a fallback notification just in case audio service fails silently?
      // No, let's rely on AthanAudioService as that is what we want to test.
      // But maybe trigger a simple notification to confirm "Test Scheduled"
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 9998,
          channelKey: 'reminder_channel',
          title: '🛠️ Test Scheduled',
          body: 'Athan test scheduled for ${testTime.hour}:${testTime.minute}',
          notificationLayout: NotificationLayout.Default,
        ),
      );

    } catch (e) {
      debugPrint("❌ Error scheduling Athan Test: $e");
    }
  }

  Map<String, String> _getAzkarSabahMasaTexts(String language) {
    final texts = {
      'ar': {
        'morning_title': '☀️ أذكار الصباح',
        'morning_body': 'ابدأ يومك بذكر الله',
        'evening_title': '🌙 أذكار المساء',
        'evening_body': 'اختم يومك بذكر الله',
      },
      'en': {
        'morning_title': '☀️ Morning Azkar',
        'morning_body': 'Start your day with remembrance of Allah',
        'evening_title': '🌙 Evening Azkar',
        'evening_body': 'End your day with remembrance of Allah',
      },
      'fr': {
        'morning_title': '☀️ Azkar du Matin',
        'morning_body': 'Commencez votre journée avec le souvenir d\'Allah',
        'evening_title': '🌙 Azkar du Soir',
        'evening_body': 'Terminez votre journée avec le souvenir d\'Allah',
      },
      'id': {
        'morning_title': '☀️ Azkar Pagi',
        'morning_body': 'Mulailah hari Anda dengan mengingat Allah',
        'evening_title': '🌙 Azkar Petang',
        'evening_body': 'Akhiri hari Anda dengan mengingat Allah',
      },
      'ur': {
        'morning_title': '☀️ صبح کے اذکار',
        'morning_body': 'اپنا دن اللہ کے ذکر سے شروع کریں',
        'evening_title': '🌙 شام کے اذکار',
        'evening_body': 'اپنا دن اللہ کے ذکر سے ختم کریں',
      },
      'tr': {
        'morning_title': '☀️ Sabah Zikirleri',
        'morning_body': 'Gününüze Allah\'ı anarak başlayın',
        'evening_title': '🌙 Akşam Zikirleri',
        'evening_body': 'Gününüzü Allah\'ı anarak bitirin',
      },
      'bn': {
        'morning_title': '☀️ সকালের আযকার',
        'morning_body': 'আল্লাহর স্মরণ দিয়ে আপনার দিন শুরু করুন',
        'evening_title': '🌙 সন্ধ্যার আযকার',
        'evening_body': 'আল্লাহর স্মরণ দিয়ে আপনার দিন শেষ করুন',
      },
      'ms': {
        'morning_title': '☀️ Azkar Pagi',
        'morning_body': 'Mulakan hari anda dengan mengingati Allah',
        'evening_title': '🌙 Azkar Petang',
        'evening_body': 'Akhiri hari anda dengan mengingati Allah',
      },
      'fa': {
        'morning_title': '☀️ اذکار صبح',
        'morning_body': 'روز خود را با یاد خدا شروع کنید',
        'evening_title': '🌙 اذکار شب',
        'evening_body': 'روز خود را با یاد خدا به پایان برسانید',
      },
      'es': {
        'morning_title': '☀️ Azkar de la Mañana',
        'morning_body': 'Comienza tu día con el recuerdo de Alá',
        'evening_title': '🌙 Azkar de la Noche',
        'evening_body': 'Termina tu día con el recuerdo de Alá',
      },
      'de': {
        'morning_title': '☀️ Morgen-Azkar',
        'morning_body': 'Beginnen Sie Ihren Tag mit der Erinnerung an Allah',
        'evening_title': '🌙 Abend-Azkar',
        'evening_body': 'Beenden Sie Ihren Tag mit der Erinnerung an Allah',
      },
      'zh': {
        'morning_title': '☀️ 清晨赞词',
        'morning_body': '以纪念安拉开始你的一天',
        'evening_title': '🌙 夜晚赞词',
        'evening_body': '以纪念安拉结束你的一天',
      },
    };
    return texts[language] ?? texts['ar']!;
  }

  // ========== دوال مساعدة ==========

  String _getPrayerNameInArabic(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return 'الفجر';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return prayerName;
    }
  }

  Map<String, String> _getPrayerNotificationText(
    String prayerName,
    String language,
  ) {
    final prayerNameAr = _getPrayerNameInArabic(prayerName);
    if (language == 'ar') {
      return {
        'title': '🕌 وقت الصلاة',
        'body': 'حان الآن موعد صلاة $prayerNameAr',
      };
    } else if (language == 'en') {
      return {
        'title': '🕌 Prayer Time',
        'body': 'It is now time for $prayerName prayer',
      };
    } else if (language == 'fr') {
      return {
        'title': '🕌 Heure de Prière',
        'body': 'Il est maintenant l\'heure de la prière de $prayerName',
      };
    } else if (language == 'id') {
      return {
        'title': '🕌 Waktu Sholat',
        'body': 'Sekarang waktu sholat $prayerName',
      };
    } else if (language == 'ur') {
      return {
        'title': '🕌 نماز کا وقت',
        'body': 'اب $prayerName نماز کا وقت ہے',
      };
    } else if (language == 'tr') {
      return {
        'title': '🕌 Namaz Vakti',
        'body': 'Şimdi $prayerName namazı vakti',
      };
    } else if (language == 'bn') {
      return {
        'title': '🕌 নামাযের সময়',
        'body': 'এখন $prayerName নামাযের সময়',
      };
    } else if (language == 'ms') {
      return {
        'title': '🕌 Waktu Solat',
        'body': 'Kini waktu solat $prayerName',
      };
    } else if (language == 'fa') {
      return {'title': '🕌 وقت نماز', 'body': 'اکنون وقت نماز $prayerName است'};
    } else if (language == 'es') {
      return {
        'title': '🕌 Hora de Oración',
        'body': 'Es ahora la hora de la oración de $prayerName',
      };
    } else if (language == 'de') {
      return {
        'title': '🕌 Gebetszeit',
        'body': 'Es ist jetzt Zeit für das $prayerName Gebet',
      };
    } else if (language == 'zh') {
      return {'title': '🕌 礼拜时间', 'body': '现在是$prayerName礼拜时间'};
    } else {
      return {
        'title': '🕌 Prayer Time',
        'body': 'It is now time for $prayerName prayer',
      };
    }
  }

  List<Map<String, String>> _getZikrList(String language) {
    final azkarByLanguage = {
      'ar': [
        {
          'title': '💚 ذكر الله',
          'body': 'سبحان الله وبحمده، سبحان الله العظيم',
        },
        {'title': '💚 ذكر الله', 'body': 'لا إله إلا الله وحده لا شريك له'},
        {'title': '💚 ذكر الله', 'body': 'الحمد لله رب العالمين'},
        {'title': '💚 ذكر الله', 'body': 'اللهم صل وسلم على نبينا محمد'},
        {'title': '💚 ذكر الله', 'body': 'استغفر الله وأتوب إليه'},
        {'title': '💚 ذكر الله', 'body': 'لا حول ولا قوة إلا بالله'},
        {
          'title': '💚 ذكر الله',
          'body': 'سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر',
        },
        {'title': '💚 ذكر الله', 'body': 'حسبي الله ونعم الوكيل'},
        {'title': '💚 ذكر الله', 'body': 'اللهم إني أسألك الجنة'},
        {'title': '💚 ذكر الله', 'body': 'اللهم اغفر لي ولوالدي'},
      ],
      'en': [
        {
          'title': '💚 Remember Allah',
          'body': 'Glory be to Allah and praise be to Him',
        },
        {'title': '💚 Remember Allah', 'body': 'There is no god but Allah'},
        {'title': '💚 Remember Allah', 'body': 'All praise is due to Allah'},
        {
          'title': '💚 Remember Allah',
          'body': 'Peace and blessings upon Prophet Muhammad',
        },
        {'title': '💚 Remember Allah', 'body': 'I seek forgiveness from Allah'},
        {
          'title': '💚 Remember Allah',
          'body': 'There is no power except with Allah',
        },
        {
          'title': '💚 Remember Allah',
          'body': 'Glory be to Allah, praise be to Allah',
        },
        {'title': '💚 Remember Allah', 'body': 'Allah is sufficient for me'},
        {
          'title': '💚 Remember Allah',
          'body': 'O Allah, I ask You for Paradise',
        },
        {
          'title': '💚 Remember Allah',
          'body': 'O Allah, forgive me and my parents',
        },
      ],
      'fr': [
        {
          'title': '💚 Rappel d\'Allah',
          'body': 'Gloire à Allah et louange à Lui',
        },
        {'title': '💚 Rappel d\'Allah', 'body': 'Il n\'y a de dieu qu\'Allah'},
        {'title': '💚 Rappel d\'Allah', 'body': 'Toute louange est à Allah'},
        {
          'title': '💚 Rappel d\'Allah',
          'body': 'Paix et bénédictions sur le Prophète Muhammad',
        },
        {'title': '💚 Rappel d\'Allah', 'body': 'Je demande pardon à Allah'},
        {
          'title': '💚 Rappel d\'Allah',
          'body': 'Il n\'y a de puissance que par Allah',
        },
        {
          'title': '💚 Rappel d\'Allah',
          'body': 'Gloire à Allah, louange à Allah',
        },
        {'title': '💚 Rappel d\'Allah', 'body': 'Allah me suffit'},
        {
          'title': '💚 Rappel d\'Allah',
          'body': 'Ô Allah, je Te demande le Paradis',
        },
        {
          'title': '💚 Rappel d\'Allah',
          'body': 'Ô Allah, pardonne-moi et à mes parents',
        },
      ],
      'id': [
        {
          'title': '💚 Ingat Allah',
          'body': 'Maha Suci Allah dan segala puji bagi-Nya',
        },
        {'title': '💚 Ingat Allah', 'body': 'Tiada Tuhan selain Allah'},
        {'title': '💚 Ingat Allah', 'body': 'Segala puji bagi Allah'},
        {'title': '💚 Ingat Allah', 'body': 'Sholawat kepada Nabi Muhammad'},
        {'title': '💚 Ingat Allah', 'body': 'Aku memohon ampun kepada Allah'},
        {
          'title': '💚 Ingat Allah',
          'body': 'Tiada daya dan upaya kecuali dengan Allah',
        },
        {
          'title': '💚 Ingat Allah',
          'body': 'Maha Suci Allah, segala puji bagi Allah',
        },
        {'title': '💚 Ingat Allah', 'body': 'Allah cukup bagiku'},
        {
          'title': '💚 Ingat Allah',
          'body': 'Ya Allah, aku meminta Surga kepada-Mu',
        },
        {
          'title': '💚 Ingat Allah',
          'body': 'Ya Allah, ampunilah aku dan kedua orang tuaku',
        },
      ],
      'ur': [
        {
          'title': '💚 اللہ کی یاد',
          'body': 'سبحان اللہ وبحمدہ، سبحان اللہ العظیم',
        },
        {'title': '💚 اللہ کی یاد', 'body': 'لا الہ الا اللہ وحدہ لا شریک لہ'},
        {'title': '💚 اللہ کی یاد', 'body': 'الحمد للہ رب العالمین'},
        {'title': '💚 اللہ کی یاد', 'body': 'اللہم صل وسلم علی نبینا محمد'},
        {'title': '💚 اللہ کی یاد', 'body': 'استغفر اللہ واتوب الیہ'},
        {'title': '💚 اللہ کی یاد', 'body': 'لا حول ولا قوۃ الا باللہ'},
        {
          'title': '💚 اللہ کی یاد',
          'body': 'سبحان اللہ، والحمد للہ، ولا الہ الا اللہ، واللہ اکبر',
        },
        {'title': '💚 اللہ کی یاد', 'body': 'حسبی اللہ ونعم الوکیل'},
        {'title': '💚 اللہ کی یاد', 'body': 'اللہم انی اسئلک الجنۃ'},
        {'title': '💚 اللہ کی یاد', 'body': 'اللہم اغفر لی ولوالدی'},
      ],
      'tr': [
        {
          'title': '💚 Allah\'ı Anmak',
          'body': 'Sübhanallahi ve bihamdihi, Sübhanallahil azim',
        },
        {'title': '💚 Allah\'ı Anmak', 'body': 'Allah\'tan başka ilah yoktur'},
        {'title': '💚 Allah\'ı Anmak', 'body': 'Hamd Allah\'a mahsustur'},
        {'title': '💚 Allah\'ı Anmak', 'body': 'Allahümme salli ala Muhammed'},
        {'title': '💚 Allah\'ı Anmak', 'body': 'Estağfirullah ve etûbü ileyh'},
        {
          'title': '💚 Allah\'ı Anmak',
          'body': 'La havle vela kuvvete illa billah',
        },
        {
          'title': '💚 Allah\'ı Anmak',
          'body':
              'Sübhanallah, velhamdülillah, vela ilahe illallah, vallahü ekber',
        },
        {'title': '💚 Allah\'ı Anmak', 'body': 'Hasbiyallahü ve ni\'mel vekîl'},
        {
          'title': '💚 Allah\'ı Anmak',
          'body': 'Allahümme inni es\'elükel cennete',
        },
        {
          'title': '💚 Allah\'ı Anmak',
          'body': 'Allahümmeğfirli ve li valideyye',
        },
      ],
      'bn': [
        {
          'title': '💚 আল্লাহকে স্মরণ',
          'body': 'সুবহানাল্লাহি ওয়া বিহামদিহি, সুবহানাল্লাহিল আজিম',
        },
        {'title': '💚 আল্লাহকে স্মরণ', 'body': 'আল্লাহ ছাড়া কোন ইলাহ নেই'},
        {'title': '💚 আল্লাহকে স্মরণ', 'body': 'সমস্ত প্রশংসা আল্লাহর'},
        {
          'title': '💚 আল্লাহকে স্মরণ',
          'body': 'হে আল্লাহ, নবী মুহাম্মদের উপর দরুদ ও সালাম বর্ষণ করুন',
        },
        {
          'title': '💚 আল্লাহকে স্মরণ',
          'body': 'আমি আল্লাহর কাছে ক্ষমা চাই এবং তাঁর দিকেই ফিরে আসি',
        },
        {
          'title': '💚 আল্লাহকে স্মরণ',
          'body': 'আল্লাহ ছাড়া কোন শক্তি ও ক্ষমতা নেই',
        },
        {
          'title': '💚 আল্লাহকে স্মরণ',
          'body':
              'সুবহানাল্লাহ, আলহামদুলিল্লাহ, লা ইলাহা ইল্লাল্লাহ, আল্লাহু আকবার',
        },
        {
          'title': '💚 আল্লাহকে স্মরণ',
          'body': 'আল্লাহই আমার জন্য যথেষ্ট, তিনি কতই না উত্তম কার্যসাধক',
        },
        {
          'title': '💚 আল্লাহকে স্মরণ',
          'body': 'হে আল্লাহ, আমি আপনার কাছে জান্নাত চাই',
        },
        {
          'title': '💚 আল্লাহকে স্মরণ',
          'body': 'হে আল্লাহ, আমাকে এবং আমার পিতামাতাকে ক্ষমা করুন',
        },
      ],
      'ms': [
        {
          'title': '💚 Ingat Allah',
          'body':
              'Maha Suci Allah dan segala puji bagi-Nya, Maha Suci Allah Yang Maha Agung',
        },
        {'title': '💚 Ingat Allah', 'body': 'Tiada Tuhan melainkan Allah'},
        {'title': '💚 Ingat Allah', 'body': 'Segala puji bagi Allah'},
        {
          'title': '💚 Ingat Allah',
          'body':
              'Ya Allah, limpahkan rahmat dan kesejahteraan kepada Nabi Muhammad',
        },
        {
          'title': '💚 Ingat Allah',
          'body': 'Aku memohon ampun kepada Allah dan bertaubat kepada-Nya',
        },
        {
          'title': '💚 Ingat Allah',
          'body': 'Tiada daya dan kekuatan melainkan dengan Allah',
        },
        {
          'title': '💚 Ingat Allah',
          'body':
              'Maha Suci Allah, segala puji bagi Allah, tiada Tuhan melainkan Allah, Allah Maha Besar',
        },
        {
          'title': '💚 Ingat Allah',
          'body': 'Cukuplah Allah bagiku, Dialah sebaik-baik Pelindung',
        },
        {
          'title': '💚 Ingat Allah',
          'body': 'Ya Allah, aku memohon Syurga kepada-Mu',
        },
        {
          'title': '💚 Ingat Allah',
          'body': 'Ya Allah, ampunilah aku dan kedua ibu bapaku',
        },
      ],
      'fa': [
        {
          'title': '💚 یاد خدا',
          'body': 'سبحان الله و بحمده، سبحان الله العظیم',
        },
        {'title': '💚 یاد خدا', 'body': 'لا إله إلا الله وحده لا شریک له'},
        {'title': '💚 یاد خدا', 'body': 'الحمد لله رب العالمین'},
        {'title': '💚 یاد خدا', 'body': 'اللهم صل علی محمد وآل محمد'},
        {'title': '💚 یاد خدا', 'body': 'استغفر الله و اتوب الیه'},
        {'title': '💚 یاد خدا', 'body': 'لا حول ولا قوه الا بالله'},
        {
          'title': '💚 یاد خدا',
          'body': 'سبحان الله، الحمد لله، لا إله إلا الله، الله اکبر',
        },
        {'title': '💚 یاد خدا', 'body': 'حسبی الله و نعم الوکیل'},
        {'title': '💚 یاد خدا', 'body': 'اللهم انی اسئلک الجنّه'},
        {'title': '💚 یاد خدا', 'body': 'اللهم اغفر لی و لوالدی'},
      ],
      'es': [
        {'title': '💚 Recordar a Alá', 'body': 'Gloria a Alá y alabado sea'},
        {'title': '💚 Recordar a Alá', 'body': 'No hay más dios que Alá'},
        {'title': '💚 Recordar a Alá', 'body': 'Toda alabanza es para Alá'},
        {
          'title': '💚 Recordar a Alá',
          'body': 'Bendiciones y paz sobre el Profeta Muhammad',
        },
        {'title': '💚 Recordar a Alá', 'body': 'Busco el perdón de Alá'},
        {'title': '💚 Recordar a Alá', 'body': 'No hay poder sino con Alá'},
        {'title': '💚 Recordar a Alá', 'body': 'Gloria a Alá, alabanza a Alá'},
        {'title': '💚 Recordar a Alá', 'body': 'Alá me basta'},
        {'title': '💚 Recordar a Alá', 'body': 'Oh Alá, te pido el Paraíso'},
        {
          'title': '💚 Recordar a Alá',
          'body': 'Oh Alá, perdóname a mí y a mis padres',
        },
      ],
      'de': [
        {
          'title': '💚 Allah gedenken',
          'body': 'Gepriesen sei Allah und gelobt sei Er',
        },
        {
          'title': '💚 Allah gedenken',
          'body': 'Es gibt keinen Gott außer Allah',
        },
        {'title': '💚 Allah gedenken', 'body': 'Alles Lob gebührt Allah'},
        {
          'title': '💚 Allah gedenken',
          'body': 'Friede und Segen auf dem Propheten Muhammad',
        },
        {'title': '💚 Allah gedenken', 'body': 'Ich bitte Allah um Vergebung'},
        {
          'title': '💚 Allah gedenken',
          'body': 'Es gibt keine Macht außer durch Allah',
        },
        {
          'title': '💚 Allah gedenken',
          'body': 'Gepriesen sei Allah, gelobt sei Allah',
        },
        {'title': '💚 Allah gedenken', 'body': 'Allah genügt mir'},
        {
          'title': '💚 Allah gedenken',
          'body': 'Oh Allah, ich bitte Dich um das Paradies',
        },
        {
          'title': '💚 Allah gedenken',
          'body': 'Oh Allah, vergib mir und meinen Eltern',
        },
      ],
      'zh': [
        {'title': '💚 纪念安拉', 'body': '赞颂安拉超绝万物，一切赞颂全归安拉'},
        {'title': '💚 纪念安拉', 'body': '万物非主，唯有安拉'},
        {'title': '💚 纪念安拉', 'body': '一切赞颂全归安拉'},
        {'title': '💚 纪念安拉', 'body': '愿安拉赐福先知穆罕默德'},
        {'title': '💚 纪念安拉', 'body': '我向安拉求饶恕'},
        {'title': '💚 纪念安拉', 'body': '无法无力，唯凭安拉'},
        {'title': '💚 纪念安拉', 'body': '赞颂安拉超绝万物，一切赞颂全归安拉'},
        {'title': '💚 纪念安拉', 'body': '安拉使我满足'},
        {'title': '💚 纪念安拉', 'body': '安拉啊，我向你祈求天堂'},
        {'title': '💚 纪念安拉', 'body': '安拉啊，赦宥我和我的父母吧'},
      ],
    };

    return azkarByLanguage[language] ?? azkarByLanguage['en']!;
  }

  /// ✅ إلغاء جميع الإشعارات المجدولة
  Future<void> cancelAllNotifications() async {
    try {
      // إلغاء إشعارات الصلاة (IDs 1-100)
      for (int i = 1; i <= 100; i++) {
        await AwesomeNotifications().cancel(i);
      }

      // إلغاء تنبيهات ما قبل الأذان من AlarmManager (Android)
      if (defaultTargetPlatform == TargetPlatform.android) {
        for (int i = 1; i <= 100; i++) {
          await AthanAudioService().cancelPreAthanReminder(i);
        }
      }

      // إلغاء إشعارات ذكرني بالله (IDs 5000-5099)
      for (int i = 5000; i < 5100; i++) {
        await AwesomeNotifications().cancel(i);
      }

      // إلغاء إشعارات أذكار الصباح والمساء (IDs 6000-6001)
      await AwesomeNotifications().cancel(6000);
      await AwesomeNotifications().cancel(6001);

      // إلغاء جميع الأذانات من AlarmManager
      await AthanAudioService().cancelAllAthans();

      log('✅ تم إلغاء جميع الإشعارات المجدولة');
    } catch (e) {
      log('❌ خطأ في إلغاء الإشعارات: $e');
    }
  }
}
