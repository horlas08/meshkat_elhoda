import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_model.dart';

/// Abstract interface for local hadith data operations
abstract class HadithLocalDataSource {
  /// Retrieves the last cached hadith from local storage
  Future<HadithModel> getLastHadith();

  /// Caches a hadith to local storage
  Future<void> cacheHadith(HadithModel hadith);

  /// Retrieves all cached hadiths from local storage
  Future<List<HadithModel>> getCachedHadiths();

  /// Caches multiple hadiths to local storage
  Future<void> cacheHadiths(List<HadithModel> hadiths);

  /// Cache grades info to avoid re-downloading
  Future<void> cacheGradesInfo(Map<String, dynamic> gradesInfo);

  /// Get cached grades info
  Future<Map<String, dynamic>?> getCachedGradesInfo();

  /// Clear all cached data
  Future<void> clearCache();

  // الوظائف الجديدة المضافة
  Future<void> cacheBookHadiths(String book, List<HadithModel> hadiths);
  Future<List<HadithModel>> getCachedBookHadiths(String book);
  Future<void> cacheUserLanguage(String language);
  String? getCachedUserLanguage();

  // ✅ NEW: Pagination Cache Support
  Future<void> cacheHadithsPage(
    String book,
    int page,
    List<HadithModel> hadiths,
  );
  Future<List<HadithModel>> getCachedHadithsPage(String book, int page);
}

/// Implementation of local data source using SharedPreferences
class HadithLocalDataSourceImpl implements HadithLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Keys for SharedPreferences storage
  static const String _lastHadithKey = 'CACHED_LAST_HADITH';
  static const String _allHadithsKey = 'CACHED_ALL_HADITHS';
  static const String _gradesInfoKey = 'CACHED_GRADES_INFO';
  static const String _gradesTimestampKey = 'CACHED_GRADES_TIMESTAMP';
  static const String _bookCacheKey = 'CACHED_BOOK_'; // سيضاف اسم الكتاب
  static const String _userLanguageKey = 'USER_LANGUAGE';

  // Cache duration for grades info (7 days)
  static const Duration _gradesCacheDuration = Duration(days: 7);

  HadithLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<HadithModel> getLastHadith() async {
    try {
      final jsonString = sharedPreferences.getString(_lastHadithKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return HadithModel.fromCachedJson(jsonMap);
      } else {
        throw const CacheException(message: 'No cached hadith found');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Error retrieving cached hadith: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheHadith(HadithModel hadith) async {
    try {
      final jsonString = json.encode(hadith.toJson());
      await sharedPreferences.setString(_lastHadithKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Error caching hadith: ${e.toString()}');
    }
  }

  @override
  Future<List<HadithModel>> getCachedHadiths() async {
    try {
      final jsonString = sharedPreferences.getString(_allHadithsKey);
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        return jsonList
            .map(
              (json) =>
                  HadithModel.fromCachedJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw const CacheException(message: 'No cached hadiths found');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Error retrieving cached hadiths: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheHadiths(List<HadithModel> hadiths) async {
    try {
      final jsonList = hadiths.map((hadith) => hadith.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_allHadithsKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Error caching hadiths: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheGradesInfo(Map<String, dynamic> gradesInfo) async {
    try {
      final jsonString = json.encode(gradesInfo);
      await sharedPreferences.setString(_gradesInfoKey, jsonString);

      // Save timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await sharedPreferences.setInt(_gradesTimestampKey, timestamp);
    } catch (e) {
      throw CacheException(
        message: 'Error caching grades info: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedGradesInfo() async {
    try {
      // Check if cache is expired
      final timestamp = sharedPreferences.getInt(_gradesTimestampKey);
      if (timestamp != null) {
        final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();

        if (now.difference(cacheDate) > _gradesCacheDuration) {
          // Cache expired, clear it
          await sharedPreferences.remove(_gradesInfoKey);
          await sharedPreferences.remove(_gradesTimestampKey);
          return null;
        }
      }

      final jsonString = sharedPreferences.getString(_gradesInfoKey);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // If there's any error, return null and let it re-fetch
      return null;
    }
  }

  @override
  Future<void> cacheBookHadiths(String book, List<HadithModel> hadiths) async {
    try {
      final jsonList = hadiths.map((hadith) => hadith.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString('$_bookCacheKey$book', jsonString);
    } catch (e) {
      throw CacheException(
        message: 'Error caching book hadiths: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<HadithModel>> getCachedBookHadiths(String book) async {
    try {
      final jsonString = sharedPreferences.getString('$_bookCacheKey$book');
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        return jsonList
            .map(
              (json) =>
                  HadithModel.fromCachedJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheUserLanguage(String language) async {
    await sharedPreferences.setString(_userLanguageKey, language);
  }

  @override
  String? getCachedUserLanguage() {
    return sharedPreferences.getString(_userLanguageKey);
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = sharedPreferences.getKeys();
      final bookCacheKeys = keys.where((key) => key.startsWith(_bookCacheKey));

      for (final key in bookCacheKeys) {
        await sharedPreferences.remove(key);
      }

      await sharedPreferences.remove(_lastHadithKey);
      await sharedPreferences.remove(_allHadithsKey);
      await sharedPreferences.remove(_gradesInfoKey);
      await sharedPreferences.remove(_gradesTimestampKey);
      await sharedPreferences.remove(_userLanguageKey);
    } catch (e) {
      throw CacheException(message: 'Error clearing cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheHadithsPage(
    String book,
    int page,
    List<HadithModel> hadiths,
  ) async {
    try {
      final jsonList = hadiths.map((hadith) => hadith.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(
        '${_bookCacheKey}${book}_page_$page',
        jsonString,
      );
    } catch (e) {
      throw CacheException(
        message: 'Error caching hadiths page: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<HadithModel>> getCachedHadithsPage(String book, int page) async {
    try {
      final jsonString = sharedPreferences.getString(
        '${_bookCacheKey}${book}_page_$page',
      );
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        return jsonList
            .map(
              (json) =>
                  HadithModel.fromCachedJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
