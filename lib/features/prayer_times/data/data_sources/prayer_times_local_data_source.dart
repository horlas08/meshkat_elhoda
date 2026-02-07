import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:meshkat_elhoda/features/prayer_times/data/models/muezzin_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/features/prayer_times/data/models/prayer_times_model.dart';

abstract class PrayerTimesLocalDataSource {
  Future<PrayerTimesModel?> getCachedPrayerTimes();
  Future<void> cachePrayerTimes(PrayerTimesModel prayerTimes);
  Future<void> clearCache();

  // Muezzin methods
  Future<List<MuezzinModel>> loadMuezzins();
  Future<String?> getSelectedMuezzinId();
  Future<void> saveSelectedMuezzinId(String id);
}

class PrayerTimesLocalDataSourceImpl implements PrayerTimesLocalDataSource {
  static const String _prayerTimesKey = 'CACHED_PRAYER_TIMES';
  static const String _cacheTimestampKey = 'PRAYER_TIMES_CACHE_TIMESTAMP';
  static const String _selectedMuezzinKey = 'SELECTED_MUEZZIN_ID';
  final SharedPreferences sharedPreferences;

  PrayerTimesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<PrayerTimesModel?> getCachedPrayerTimes() async {
    try {
      final jsonString = sharedPreferences.getString(_prayerTimesKey);
      final timestampString = sharedPreferences.getString(_cacheTimestampKey);

      if (jsonString != null && timestampString != null) {
        final cacheTime = DateTime.parse(timestampString);
        final now = DateTime.now();

        // Check if cache is still valid (same day)
        if (cacheTime.year == now.year &&
            cacheTime.month == now.month &&
            cacheTime.day == now.day) {
          final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
          return PrayerTimesModel.fromJson(jsonMap);
        }
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached prayer times: $e');
    }
  }

  @override
  Future<void> cachePrayerTimes(PrayerTimesModel prayerTimes) async {
    try {
      final jsonString = json.encode(prayerTimes.toJson());
      await sharedPreferences.setString(_prayerTimesKey, jsonString);
      await sharedPreferences.setString(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache prayer times: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_prayerTimesKey);
      await sharedPreferences.remove(_cacheTimestampKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  Future<List<MuezzinModel>> loadMuezzins() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/muezzins.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final muezzinsList = jsonMap['muezzins'] as List;
      return muezzinsList
          .map((e) => MuezzinModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to load muezzins: $e');
    }
  }

  @override
  Future<String?> getSelectedMuezzinId() async {
    try {
      return sharedPreferences.getString(_selectedMuezzinKey);
    } catch (e) {
      throw CacheException(message: 'Failed to get selected muezzin: $e');
    }
  }

  @override
  Future<void> saveSelectedMuezzinId(String id) async {
    try {
      await sharedPreferences.setString(_selectedMuezzinKey, id);
    } catch (e) {
      throw CacheException(message: 'Failed to save selected muezzin: $e');
    }
  }
}
