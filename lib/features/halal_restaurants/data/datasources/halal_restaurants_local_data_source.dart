import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/data/models/restaurant_model.dart';

abstract class HalalRestaurantsLocalDataSource {
  Future<void> cacheRestaurants(List<RestaurantModel> restaurants);
  Future<List<RestaurantModel>> getCachedRestaurants();

  Future<void> cacheRestaurantsMeta({
    required double latitude,
    required double longitude,
    required int cachedAtMillis,
  });

  Future<({double? latitude, double? longitude, int? cachedAtMillis})>
      getCachedRestaurantsMeta();
}

class HalalRestaurantsLocalDataSourceImpl
    implements HalalRestaurantsLocalDataSource {
  static const String _cacheKey = 'CACHED_HALAL_RESTAURANTS';
  static const String _cacheLatKey = 'CACHED_HALAL_RESTAURANTS_LAT';
  static const String _cacheLngKey = 'CACHED_HALAL_RESTAURANTS_LNG';
  static const String _cacheAtKey = 'CACHED_HALAL_RESTAURANTS_CACHED_AT';
  final SharedPreferences sharedPreferences;

  HalalRestaurantsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheRestaurants(List<RestaurantModel> restaurants) async {
    final jsonList = restaurants.map((e) => e.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(_cacheKey, jsonString);
  }

  @override
  Future<void> cacheRestaurantsMeta({
    required double latitude,
    required double longitude,
    required int cachedAtMillis,
  }) async {
    await sharedPreferences.setDouble(_cacheLatKey, latitude);
    await sharedPreferences.setDouble(_cacheLngKey, longitude);
    await sharedPreferences.setInt(_cacheAtKey, cachedAtMillis);
  }

  @override
  Future<List<RestaurantModel>> getCachedRestaurants() async {
    final jsonString = sharedPreferences.getString(_cacheKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<({double? latitude, double? longitude, int? cachedAtMillis})>
      getCachedRestaurantsMeta() async {
    final lat = sharedPreferences.getDouble(_cacheLatKey);
    final lng = sharedPreferences.getDouble(_cacheLngKey);
    final cachedAtMillis = sharedPreferences.getInt(_cacheAtKey);
    return (latitude: lat, longitude: lng, cachedAtMillis: cachedAtMillis);
  }
}
