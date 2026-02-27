import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/mosques/data/models/mosque_model.dart';

abstract class MosquesLocalDataSource {
  Future<void> cacheMosques(List<MosqueModel> mosques);
  Future<List<MosqueModel>> getCachedMosques();

  Future<void> cacheMosquesMeta({
    required double latitude,
    required double longitude,
    required int cachedAtMillis,
  });

  Future<({double? latitude, double? longitude, int? cachedAtMillis})>
      getCachedMosquesMeta();
}

class MosquesLocalDataSourceImpl implements MosquesLocalDataSource {
  static const String _cacheKey = 'CACHED_MOSQUES';
  static const String _cacheLatKey = 'CACHED_MOSQUES_LAT';
  static const String _cacheLngKey = 'CACHED_MOSQUES_LNG';
  static const String _cacheAtKey = 'CACHED_MOSQUES_CACHED_AT';
  final SharedPreferences sharedPreferences;

  MosquesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheMosques(List<MosqueModel> mosques) async {
    final jsonList = mosques.map((e) => e.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(_cacheKey, jsonString);
  }

  @override
  Future<void> cacheMosquesMeta({
    required double latitude,
    required double longitude,
    required int cachedAtMillis,
  }) async {
    await sharedPreferences.setDouble(_cacheLatKey, latitude);
    await sharedPreferences.setDouble(_cacheLngKey, longitude);
    await sharedPreferences.setInt(_cacheAtKey, cachedAtMillis);
  }

  @override
  Future<List<MosqueModel>> getCachedMosques() async {
    final jsonString = sharedPreferences.getString(_cacheKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => MosqueModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<({double? latitude, double? longitude, int? cachedAtMillis})>
      getCachedMosquesMeta() async {
    final lat = sharedPreferences.getDouble(_cacheLatKey);
    final lng = sharedPreferences.getDouble(_cacheLngKey);
    final cachedAtMillis = sharedPreferences.getInt(_cacheAtKey);
    return (latitude: lat, longitude: lng, cachedAtMillis: cachedAtMillis);
  }
}
