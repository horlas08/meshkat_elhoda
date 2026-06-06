import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/features/location/data/models/location_model.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class LocationRemoteDataSource {
  Future<PermissionStatus> requestLocationPermission();
  Future<PermissionStatus> checkLocationPermission();
  Future<LocationModel> getCurrentLocation();
  Future<LocationModel> getLocationFromCityCountry({
    required String city,
    required String country,
  });
  Future<String> getCityFromCoordinates({
    required double latitude,
    required double longitude,
  });
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  PermissionStatus _mapLocationPermission(LocationPermission permission) {
    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => PermissionStatus.granted,
      LocationPermission.deniedForever => PermissionStatus.permanentlyDenied,
      LocationPermission.denied ||
      LocationPermission.unableToDetermine => PermissionStatus.denied,
    };
  }

  @override
  Future<PermissionStatus> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return _mapLocationPermission(permission);
    } catch (e) {
      throw ServerException(
        message: 'Failed to request location permission: $e',
      );
    }
  }

  @override
  Future<PermissionStatus> checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return _mapLocationPermission(permission);
    } catch (e) {
      throw ServerException(message: 'Failed to check location permission: $e');
    }
  }

  @override
  Future<LocationModel> getCurrentLocation() async {
    try {
      // 1. Check permissions first
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        throw ServerException(message: 'تم رفض إذن الوصول للموقع');
      }

      if (permission == LocationPermission.deniedForever) {
        throw ServerException(
          message:
              'تم رفض إذن الوصول للموقع بشكل دائم، يرجى تفعيله من الإعدادات',
        );
      }

      // 2. Get current position directly
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw ServerException(
            message: 'خدمات الموقع غير مفعلة. يرجى تفعيل GPS من الإعدادات.',
          );
        }
        throw ServerException(message: 'فشل في تحديد الموقع: $e');
      }

      log('📍 الإحداثيات الأصلية: ${position.latitude}, ${position.longitude}');

      // Try to get city and country name
      String? city;
      String? country;

      // محاولة أولى: Native Geocoding
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          city =
              placemark.locality ??
              placemark.subLocality ??
              placemark.administrativeArea;
          country = placemark.country;
        }
      } catch (e) {
        log('❌ خطأ في Native Geocoding: $e');
      }

      // محاولة ثانية: API Geocoding (Fallback)
      if (city == null || country == null) {
        log('🔄 محاولة جلب العنوان عبر API...');
        final apiResult = await _getCityCountryFromApi(
          position.latitude,
          position.longitude,
        );
        if (apiResult['city'] != null) city = apiResult['city'];
        if (apiResult['country'] != null) country = apiResult['country'];
      }

      log('📍 النتيجة النهائية: $city, $country');

      // Check for mismatch
      if (_areCoordinatesMismatched(
        position.latitude,
        position.longitude,
        country,
      )) {
        log('⚠️ تنبيه: الإحداثيات لا تتطابق مع البلد!');
        // في حالة عدم التطابق، نفضل البيانات التي جلبناها من الـ API إذا كانت موجودة
        // أو نتركها فارغة ليتم ملؤها لاحقاً من البيانات المخزنة
      }

      return LocationModel(
        method: LocationMethod.gps,
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        country: country,
        timezone: 'UTC',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'فشل في تحديد الموقع الحالي: $e');
    }
  }

  Future<Map<String, String?>> _getCityCountryFromApi(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&accept-language=ar',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'MeshkatElhodaApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          String? city =
              address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'] ??
              address['state_district'];
          String? country = address['country'];
          return {'city': city, 'country': country};
        }
      }
    } catch (e) {
      log('❌ API Geocoding failed: $e');
    }
    return {'city': null, 'country': null};
  }

  // دالة للتحقق من تطابق الإحداثيات مع البلد
  bool _areCoordinatesMismatched(double lat, double lng, String? country) {
    // إذا الإحداثيات في مصر (30.5853431, 31.5035127) والبلد مش مصر
    if (lat >= 22.0 && lat <= 32.0 && lng >= 25.0 && lng <= 35.0) {
      // هذه الإحداثيات في مصر تقريباً
      return country != null &&
          !country.toLowerCase().contains('egypt') &&
          !country.contains('مصر');
    }

    // إذا الإحداثيات في السعودية (24.0, 45.0) والبلد مش السعودية
    if (lat >= 16.0 && lat <= 32.0 && lng >= 34.0 && lng <= 55.0) {
      // هذه الإحداثيات في السعودية تقريباً
      return country != null &&
          !country.toLowerCase().contains('saudi') &&
          !country.contains('السعودية');
    }

    return false;
  }

  @override
  Future<LocationModel> getLocationFromCityCountry({
    required String city,
    required String country,
  }) async {
    try {
      // Use geocoding to get coordinates from city/country
      List<Location> locations = await locationFromAddress('$city, $country');

      if (locations.isEmpty) {
        throw ServerException(
          message: 'Could not find location for $city, $country',
        );
      }

      final location = locations.first;

      return LocationModel(
        method: LocationMethod.manual,
        latitude: location.latitude,
        longitude: location.longitude,
        city: city,
        country: country,
        timezone: 'UTC', // Will be determined by prayer times API
        timestamp: DateTime.now(),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to get location from city/country: $e',
      );
    }
  }

  @override
  Future<String> getCityFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        throw ServerException(
          message: 'Could not determine city from coordinates',
        );
      }

      final placemark = placemarks.first;
      return placemark.locality ?? placemark.administrativeArea ?? 'Unknown';
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get city from coordinates: $e');
    }
  }
}
