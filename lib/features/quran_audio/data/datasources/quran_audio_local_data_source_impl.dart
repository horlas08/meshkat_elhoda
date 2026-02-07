import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/datasources/quran_audio_data_source.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/radio_station_model.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/reciter_model.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/surah_model.dart';

class QuranAudioLocalDataSourceImpl implements QuranAudioLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _recentersPrefix = 'cached_reciters_';
  static const String _surahsKey = 'cached_surahs';
  static const String _radioStationsKey = 'cached_radio_stations';
  static const String _favoritesRecitersKey = 'favorite_reciters';
  static const String _lastPlayedKey = 'last_played_track';
  static const String _recentlyPlayedKey = 'recently_played_tracks';

  QuranAudioLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ReciterModel>> getCachedReciters(String language) async {
    try {
      final key = '$_recentersPrefix$language';
      final jsonString = sharedPreferences.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        log('⚠️ No cached reciters for language: $language');
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(jsonString);
      final reciters = decodedList
          .map(
            (reciter) => ReciterModel.fromJson(reciter as Map<String, dynamic>),
          )
          .toList();

      log(
        '✅ Loaded ${reciters.length} cached reciters for language: $language',
      );
      return reciters;
    } catch (e) {
      log('❌ Error loading cached reciters: $e');
      return [];
    }
  }

  @override
  Future<void> cacheReciters(
    List<ReciterModel> reciters,
    String language,
  ) async {
    try {
      final key = '$_recentersPrefix$language';
      final jsonString = jsonEncode(reciters.map((r) => r.toJson()).toList());
      await sharedPreferences.setString(key, jsonString);
      log('✅ Cached ${reciters.length} reciters for language: $language');
    } catch (e) {
      log('❌ Error caching reciters: $e');
    }
  }

  @override
  Future<List<SurahModel>> getCachedSurahs() async {
    try {
      final jsonString = sharedPreferences.getString(_surahsKey);

      if (jsonString == null || jsonString.isEmpty) {
        log('⚠️ No cached surahs');
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(jsonString);
      final surahs = decodedList
          .map((surah) => SurahModel.fromJson(surah as Map<String, dynamic>))
          .toList();

      log('✅ Loaded ${surahs.length} cached surahs');
      return surahs;
    } catch (e) {
      log('❌ Error loading cached surahs: $e');
      return [];
    }
  }

  @override
  Future<void> cacheSurahs(List<SurahModel> surahs) async {
    try {
      final jsonString = jsonEncode(surahs.map((s) => s.toJson()).toList());
      await sharedPreferences.setString(_surahsKey, jsonString);
      log('✅ Cached ${surahs.length} surahs');
    } catch (e) {
      log('❌ Error caching surahs: $e');
    }
  }

  @override
  Future<List<RadioStationModel>> getCachedRadioStations() async {
    try {
      final jsonString = sharedPreferences.getString(_radioStationsKey);

      if (jsonString == null || jsonString.isEmpty) {
        log('⚠️ No cached radio stations');
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(jsonString);
      final stations = decodedList
          .map(
            (station) =>
                RadioStationModel.fromJson(station as Map<String, dynamic>),
          )
          .toList();

      log('✅ Loaded ${stations.length} cached radio stations');
      return stations;
    } catch (e) {
      log('❌ Error loading cached radio stations: $e');
      return [];
    }
  }

  @override
  Future<void> cacheRadioStations(List<RadioStationModel> stations) async {
    try {
      final jsonString = jsonEncode(stations.map((s) => s.toJson()).toList());
      await sharedPreferences.setString(_radioStationsKey, jsonString);
      log('✅ Cached ${stations.length} radio stations');
    } catch (e) {
      log('❌ Error caching radio stations: $e');
    }
  }

  @override
  Future<void> saveFavoriteReciter(ReciterModel reciter) async {
    try {
      final favorites = await getFavoriteReciters();
      if (!favorites.any((r) => r.id == reciter.id)) {
        favorites.add(reciter);
        final jsonString = jsonEncode(
          favorites.map((r) => r.toJson()).toList(),
        );
        await sharedPreferences.setString(_favoritesRecitersKey, jsonString);
        log('✅ Saved favorite reciter: ${reciter.name}');
      }
    } catch (e) {
      log('❌ Error saving favorite reciter: $e');
    }
  }

  @override
  Future<List<ReciterModel>> getFavoriteReciters() async {
    try {
      final jsonString = sharedPreferences.getString(_favoritesRecitersKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList
          .map(
            (reciter) => ReciterModel.fromJson(reciter as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      log('❌ Error loading favorite reciters: $e');
      return [];
    }
  }

  @override
  Future<void> removeFavoriteReciter(String reciterId) async {
    try {
      final favorites = await getFavoriteReciters();
      favorites.removeWhere((r) => r.id == reciterId);
      final jsonString = jsonEncode(favorites.map((r) => r.toJson()).toList());
      await sharedPreferences.setString(_favoritesRecitersKey, jsonString);
      log('✅ Removed favorite reciter: $reciterId');
    } catch (e) {
      log('❌ Error removing favorite reciter: $e');
    }
  }

  @override
  Future<void> saveLastPlayedTrack(
    String surahNumber,
    String surahName,
    String reciterName,
    String audioUrl,
    int positionMillis,
  ) async {
    try {
      final lastPlayed = {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'reciterName': reciterName,
        'audioUrl': audioUrl,
        'positionMillis': positionMillis,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await sharedPreferences.setString(_lastPlayedKey, jsonEncode(lastPlayed));
      log('✅ Saved last played track: $surahName');
    } catch (e) {
      log('❌ Error saving last played track: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getLastPlayedTrack() async {
    try {
      final jsonString = sharedPreferences.getString(_lastPlayedKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      log('❌ Error loading last played track: $e');
      return null;
    }
  }

  @override
  Future<void> addToRecentlyPlayed(
    String surahNumber,
    String surahName,
    String reciterName,
    String audioUrl,
  ) async {
    try {
      final recentlyPlayed = await getRecentlyPlayedTracks();

      // Remove if already exists
      recentlyPlayed.removeWhere((r) => r['audioUrl'] == audioUrl);

      // Add new track to the beginning
      recentlyPlayed.insert(0, {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'reciterName': reciterName,
        'audioUrl': audioUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Keep only last 20 tracks
      if (recentlyPlayed.length > 20) {
        recentlyPlayed.removeRange(20, recentlyPlayed.length);
      }

      await sharedPreferences.setString(
        _recentlyPlayedKey,
        jsonEncode(recentlyPlayed),
      );
      log('✅ Added to recently played: $surahName');
    } catch (e) {
      log('❌ Error adding to recently played: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentlyPlayedTracks() async {
    try {
      final jsonString = sharedPreferences.getString(_recentlyPlayedKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.cast<Map<String, dynamic>>();
    } catch (e) {
      log('❌ Error loading recently played tracks: $e');
      return [];
    }
  }
}
