import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/core/services/prayer_notification_service_new.dart';
import 'package:meshkat_elhoda/features/prayer_times/data/models/prayer_times_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/settings/data/models/notification_settings_model.dart';
// ✅ استيراد الخدمات المطلوبة
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PrayerTimesRemoteDataSource {
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
  });

  Future<PrayerTimesModel> getPrayerTimesByCity({
    required String city,
    required String country,
  });
}

class PrayerTimesRemoteDataSourceImpl implements PrayerTimesRemoteDataSource {
  final http.Client client;
  final FirebaseFirestore firestore;
  static const String baseUrl = 'https://api.aladhan.com/v1';

  PrayerTimesRemoteDataSourceImpl({
    required this.client,
    FirebaseFirestore? firestore, // ⬅️ أضف Firestore dependency
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // ✅ حاول جلب إحداثيات المستخدم من Firebase أولاً
      final firebaseLocation = await _getUserLocationFromFirebase();
      final effectiveLatitude = firebaseLocation?.$1 ?? latitude;
      final effectiveLongitude = firebaseLocation?.$2 ?? longitude;

      // ✅ حساب أقرب method بناءً على الإحداثيات (نفس منطق PrayerNotificationService)
      final method = _getClosestCalculationMethod(
        effectiveLatitude,
        effectiveLongitude,
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final url = Uri.parse(
        '$baseUrl/timings/$timestamp?latitude=$effectiveLatitude&longitude=$effectiveLongitude&method=$method',
      );
      log(url.toString());

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final prayerTimes = PrayerTimesModel.fromJson(jsonData);

        // ✅ جدولة الإشعارات بعد نجاح جلب البيانات
        await _schedulePrayerNotifications(
          latitude: effectiveLatitude,
          longitude: effectiveLongitude,
        );

        return prayerTimes;
      } else {
        throw ServerException(
          message: 'Failed to fetch prayer times',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch prayer times: $e');
    }
  }

  @override
  Future<PrayerTimesModel> getPrayerTimesByCity({
    required String city,
    required String country,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final url = Uri.parse(
        '$baseUrl/timings/$timestamp?city=$city&country=$country&method=5',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final prayerTimes = PrayerTimesModel.fromJson(jsonData);

        log('⚠️ جدولة إشعارات بالمدينة تحتاج تحويل لإحداثيات');

        return prayerTimes;
      } else {
        throw ServerException(
          message: 'Failed to fetch prayer times',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch prayer times: $e');
    }
  }

  // ✅ دالة مساعدة لجدولة الإشعارات - تجيب اللغة من Firebase
  Future<void> _schedulePrayerNotifications({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // 🔥 جلب اللغة من Firebase User
      final String language = await _getUserLanguageFromFirebase();

      // 🔥 جلب إعدادات الإشعارات المحفوظة
      final settings = await _getNotificationSettings();

      await PrayerNotificationService().scheduleTodayPrayers(
        latitude: latitude,
        longitude: longitude,
        language: language,
        settings: settings,
      );
      log('🎯 تم جدولة إشعارات الصلاة بعد جلب الأوقات الجديدة');
    } catch (e) {
      log('⚠️ خطأ في الجدولة التلقائية: $e');
      // لا ترمي خطأ - حاول تاني بلغة افتراضية
      await _scheduleWithDefaultLanguage(latitude, longitude);
    }
  }

  // ✅ جلب إعدادات الإشعارات من SharedPreferences
  Future<NotificationSettingsModel> _getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('NOTIFICATION_SETTINGS');

      if (settingsJson != null) {
        final settings = NotificationSettingsModel.fromJson(settingsJson);
        log('⚙️ تم تحميل إعدادات الإشعارات المحفوظة');
        return settings;
      }
    } catch (e) {
      log('⚠️ خطأ في تحميل إعدادات الإشعارات: $e');
    }

    // إعدادات افتراضية
    log('ℹ️ استخدام الإعدادات الافتراضية');
    return const NotificationSettingsModel();
  }

  // ✅ جلب اللغة من مستخدم Firebase
  Future<String> _getUserLanguageFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // جلب بيانات المستخدم من Firestore
        final userDoc = await firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final language = userData?['language'] as String?;

          if (language != null && language.isNotEmpty) {
            log('🌍 تم جلب اللغة من Firebase: $language');
            return language;
          }
        }
      }

      // إذا مفيش user أو مفيش language، استخدم لغة الجهاز
      return _getDeviceLanguage();
    } catch (e) {
      log('⚠️ خطأ في جلب اللغة من Firebase: $e');
      return _getDeviceLanguage();
    }
  }

  // ✅ جلب لغة الجهاز
  String _getDeviceLanguage() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    const supportedLanguages = [
      'ar',
      'en',
      'fr',
      'id',
      'ur',
      'tr',
      'bn',
      'ms',
      'fa',
      'es',
      'de',
      'zh',
    ];

    if (supportedLanguages.contains(deviceLocale.languageCode)) {
      log('📱 استخدام لغة الجهاز: ${deviceLocale.languageCode}');
      return deviceLocale.languageCode;
    } else {
      log('🌍 لغة الجهاز غير مدعومة، استخدام العربية');
      return 'ar';
    }
  }

  // ✅ الجدولة بلغة افتراضية إذا فشلت الجدولة الأساسية
  Future<void> _scheduleWithDefaultLanguage(
    double latitude,
    double longitude,
  ) async {
    try {
      // ✅ جلب إعدادات الإشعارات حتى في حالة الـ fallback
      final settings = await _getNotificationSettings();

      await PrayerNotificationService().scheduleTodayPrayers(
        latitude: latitude,
        longitude: longitude,
        language: 'ar', // لغة افتراضية
        settings: settings, // ✅ تمرير الإعدادات المحفوظة
      );
      log('🔄 تم الجدولة بلغة افتراضية (العربية)');
    } catch (e) {
      log('❌ فشل الجدولة حتى باللغة الافتراضية: $e');
    }
  }

  // ✅ جلب إحداثيات المستخدم من Firebase (إن وُجدت)
  Future<(double, double)?> _getUserLocationFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final data = userDoc.data();
      if (data == null) return null;

      // الإحداثيات موجودة داخل حقل location كـ map
      final location = data['location'] as Map<String, dynamic>?;
      if (location == null) return null;

      final lat = (location['latitude'] as num?)?.toDouble();
      final lng = (location['longitude'] as num?)?.toDouble();

      if (lat == null || lng == null) return null;

      log('📍 تم جلب إحداثيات المستخدم من Firebase: ($lat, $lng)');
      return (lat, lng);
    } catch (e) {
      log('⚠️ خطأ في جلب الإحداثيات من Firebase: $e');
      return null;
    }
  }
}

// ==========================
// 🧮 منطق اختيار method الأقرب
// ==========================

// ✅ خريطة مواقع طرق الحساب المختلفة (منقولة من PrayerNotificationService)
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
    '📍 [RemoteDataSource] أقرب طريقة حساب: $closestMethod (ID: $methodId) - المسافة: ${minDistance.toStringAsFixed(2)} km',
  );
  return methodId;
}
