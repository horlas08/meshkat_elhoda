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
    } catch (e) {
      throw CacheException(message: 'Failed to cache location: $e');
    }
  }

  @override
  Future<void> clearLocation() async {
    try {
      await sharedPreferences.remove(_locationKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear location: $e');
    }
  }
}
