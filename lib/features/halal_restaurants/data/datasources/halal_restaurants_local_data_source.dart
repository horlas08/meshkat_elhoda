import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/data/models/restaurant_model.dart';

abstract class HalalRestaurantsLocalDataSource {
  Future<void> cacheRestaurants(List<RestaurantModel> restaurants);
  Future<List<RestaurantModel>> getCachedRestaurants();
}

class HalalRestaurantsLocalDataSourceImpl
    implements HalalRestaurantsLocalDataSource {
  static const String _cacheKey = 'CACHED_HALAL_RESTAURANTS';
  final SharedPreferences sharedPreferences;

  HalalRestaurantsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheRestaurants(List<RestaurantModel> restaurants) async {
    final jsonList = restaurants.map((e) => e.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(_cacheKey, jsonString);
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
}
