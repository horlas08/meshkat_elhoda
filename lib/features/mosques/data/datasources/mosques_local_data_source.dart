import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/mosques/data/models/mosque_model.dart';

abstract class MosquesLocalDataSource {
  Future<void> cacheMosques(List<MosqueModel> mosques);
  Future<List<MosqueModel>> getCachedMosques();
}

class MosquesLocalDataSourceImpl implements MosquesLocalDataSource {
  static const String _cacheKey = 'CACHED_MOSQUES';
  final SharedPreferences sharedPreferences;

  MosquesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheMosques(List<MosqueModel> mosques) async {
    final jsonList = mosques.map((e) => e.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(_cacheKey, jsonString);
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
}
