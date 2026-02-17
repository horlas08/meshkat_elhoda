import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/features/location/data/models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<LocationModel?> getStoredLocation();
  Future<void> cacheLocation(LocationModel location);
  Future<void> clearLocation();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  static const String _locationKey = 'CACHED_LOCATION';
  static const String _latitudeKey = 'latitude';
  static const String _longitudeKey = 'longitude';
  final SharedPreferences sharedPreferences;

  LocationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<LocationModel?> getStoredLocation() async {
    try {
      final jsonString = sharedPreferences.getString(_locationKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return LocationModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get stored location: $e');
    }
  }

  @override
  Future<void> cacheLocation(LocationModel location) async {
    try {
      final jsonString = json.encode(location.toJson());
      await sharedPreferences.setString(_locationKey, jsonString);

      // Keep legacy keys in sync.
      // Prayer notification scheduling on startup reads these keys directly.
      if (location.latitude != null) {
        await sharedPreferences.setDouble(_latitudeKey, location.latitude!);
      }
      if (location.longitude != null) {
        await sharedPreferences.setDouble(_longitudeKey, location.longitude!);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to cache location: $e');
    }
  }

  @override
  Future<void> clearLocation() async {
    try {
      await sharedPreferences.remove(_locationKey);
      await sharedPreferences.remove(_latitudeKey);
      await sharedPreferences.remove(_longitudeKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear location: $e');
    }
  }
}
