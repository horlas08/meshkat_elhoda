import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/core/network/firebase_service.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_model.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_category_model.dart';
import 'dart:developer' as dev;

/// Abstract interface for remote hadith data operations using HadeethEnc API
abstract class HadithRemoteDataSource {
  /// Get all available languages
  Future<List<Map<String, String>>> getLanguages();

  /// Get all categories for a language
  Future<List<HadithCategory>> getCategories(String languageCode);

  /// Get root categories only
  Future<List<HadithCategory>> getRootCategories(String languageCode);

  /// Get sub-categories for a parent category
  List<HadithCategory> getSubCategories(
    String parentId,
    List<HadithCategory> allCategories,
  );

  /// Get hadiths list by category with pagination
  Future<HadithListResponse> getHadithsByCategory({
    required String languageCode,
    required String categoryId,
    int page = 1,
    int perPage = 20,
  });

  /// Get single hadith details
  Future<HadithModel> getHadithById({
    required String id,
    required String languageCode,
  });

  /// Get random hadith
  Future<HadithModel> getRandomHadith({String? languageCode});

  /// Get current user language
  Future<String> getCurrentUserLanguage();

  /// Clear cache
  void clearCache();
}

/// Implementation of remote data source using HadeethEnc API
class HadithRemoteDataSourceImpl implements HadithRemoteDataSource {
  final http.Client client;
  final FirebaseService _firebaseService;

  static const String _baseUrl = 'https://hadeethenc.com/api/v1';

  // Cache
  final Map<String, List<HadithCategory>> _categoriesCache = {};
  final Map<String, HadithModel> _hadithCache = {};
  final Map<String, HadithListResponse> _listCache = {};
  List<Map<String, String>>? _languagesCache;

  HadithRemoteDataSourceImpl({
    required this.client,
    required FirebaseService firebaseService,
  }) : _firebaseService = firebaseService;

  @override
  Future<String> getCurrentUserLanguage() async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) return 'ar';

      final userData = await _firebaseService.getDocument('users', user.uid);
      return userData['language'] ?? 'ar';
    } catch (e) {
      return 'ar';
    }
  }

  @override
  Future<List<Map<String, String>>> getLanguages() async {
    if (_languagesCache != null) {
      return _languagesCache!;
    }

    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/languages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _languagesCache = data
            .map(
              (lang) => {
                'code': lang['code']?.toString() ?? '',
                'native': lang['native']?.toString() ?? '',
              },
            )
            .toList();
        return _languagesCache!;
      } else {
        throw ServerException(
          message: 'Failed to fetch languages',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Error fetching languages: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<HadithCategory>> getCategories(String languageCode) async {
    final cacheKey = 'categories_$languageCode';
    if (_categoriesCache.containsKey(cacheKey)) {
      return _categoriesCache[cacheKey]!;
    }

    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/categories/list/?language=$languageCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final categories = data
            .map((cat) => HadithCategory.fromJson(cat as Map<String, dynamic>))
            .toList();
        _categoriesCache[cacheKey] = categories;
        dev.log('📚 Loaded ${categories.length} categories for $languageCode');
        return categories;
      } else {
        throw ServerException(
          message: 'Failed to fetch categories',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Error fetching categories: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<HadithCategory>> getRootCategories(String languageCode) async {
    final cacheKey = 'root_categories_$languageCode';
    if (_categoriesCache.containsKey(cacheKey)) {
      return _categoriesCache[cacheKey]!;
    }

    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/categories/roots/?language=$languageCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final categories = data
            .map((cat) => HadithCategory.fromJson(cat as Map<String, dynamic>))
            .toList();
        _categoriesCache[cacheKey] = categories;
        dev.log(
          '📚 Loaded ${categories.length} root categories for $languageCode',
        );
        return categories;
      } else {
        throw ServerException(
          message: 'Failed to fetch root categories',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Error fetching root categories: ${e.toString()}',
      );
    }
  }

  @override
  List<HadithCategory> getSubCategories(
    String parentId,
    List<HadithCategory> allCategories,
  ) {
    return allCategories.where((cat) => cat.parentId == parentId).toList();
  }

  @override
  Future<HadithListResponse> getHadithsByCategory({
    required String languageCode,
    required String categoryId,
    int page = 1,
    int perPage = 20,
  }) async {
    final cacheKey = 'hadiths_${languageCode}_${categoryId}_${page}_$perPage';
    if (_listCache.containsKey(cacheKey)) {
      return _listCache[cacheKey]!;
    }

    try {
      final url =
          '$_baseUrl/hadeeths/list/?language=$languageCode&category_id=$categoryId&page=$page&per_page=$perPage';
      dev.log('🔗 Fetching hadiths: $url');

      final response = await client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final listResponse = HadithListResponse.fromJson(data);
        _listCache[cacheKey] = listResponse;
        dev.log(
          '📖 Loaded ${listResponse.data.length} hadiths for category $categoryId',
        );
        return listResponse;
      } else {
        throw ServerException(
          message: 'Failed to fetch hadiths',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error fetching hadiths: ${e.toString()}');
    }
  }

  @override
  Future<HadithModel> getHadithById({
    required String id,
    required String languageCode,
  }) async {
    final cacheKey = 'hadith_${languageCode}_$id';
    if (_hadithCache.containsKey(cacheKey)) {
      return _hadithCache[cacheKey]!;
    }

    try {
      final url = '$_baseUrl/hadeeths/one/?language=$languageCode&id=$id';
      dev.log('🔗 Fetching hadith: $url');

      final response = await client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final hadith = HadithModel.fromHadeethEncJson(data);
        _hadithCache[cacheKey] = hadith;
        dev.log('📖 Loaded hadith $id');
        return hadith;
      } else {
        throw ServerException(
          message: 'Failed to fetch hadith',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error fetching hadith: ${e.toString()}');
    }
  }

  @override
  Future<HadithModel> getRandomHadith({String? languageCode}) async {
    try {
      final lang = languageCode ?? await getCurrentUserLanguage();

      // Get root categories first
      final rootCategories = await getRootCategories(lang);
      if (rootCategories.isEmpty) {
        throw ServerException(message: 'No categories available');
      }

      // Pick a random root category with hadiths
      final categoriesWithHadiths = rootCategories
          .where((c) => c.hadithsCount > 0)
          .toList();
      if (categoriesWithHadiths.isEmpty) {
        throw ServerException(message: 'No hadiths available');
      }

      final randomCategory =
          categoriesWithHadiths[DateTime.now().millisecond %
              categoriesWithHadiths.length];

      // Get hadiths from this category
      final hadithsResponse = await getHadithsByCategory(
        languageCode: lang,
        categoryId: randomCategory.id,
        page: 1,
        perPage: 20,
      );

      if (hadithsResponse.data.isEmpty) {
        throw ServerException(message: 'No hadiths in category');
      }

      // Pick a random hadith from the list
      final randomItem = hadithsResponse
          .data[DateTime.now().millisecond % hadithsResponse.data.length];

      // Get full hadith details
      return await getHadithById(id: randomItem.id, languageCode: lang);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Error fetching random hadith: ${e.toString()}',
      );
    }
  }

  @override
  void clearCache() {
    _categoriesCache.clear();
    _hadithCache.clear();
    _listCache.clear();
    _languagesCache = null;
    dev.log('🗑️ Hadith cache cleared');
  }
}
