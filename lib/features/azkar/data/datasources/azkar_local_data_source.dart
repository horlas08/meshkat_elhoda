import 'dart:convert';
import 'package:meshkat_elhoda/features/azkar/data/models/azkar_category_model.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/azkar_model.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/allah_name_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AzkarLocalDataSource {
  Future<List<AzkarCategoryModel>> getCachedAzkarCategories();
  Future<void> cacheAzkarCategories(List<AzkarCategoryModel> categories);
  
  Future<List<AzkarModel>> getCachedAzkarItems(int chapterId);
  Future<void> cacheAzkarItems(int chapterId, List<AzkarModel> items);
  
  Future<List<AllahNameModel>> getCachedAllahNames();
  Future<void> cacheAllahNames(List<AllahNameModel> names);
}

class AzkarLocalDataSourceImpl implements AzkarLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _azkarCategoriesKey = 'CACHED_AZKAR_CATEGORIES';
  static const String _azkarItemsKeyPrefix = 'CACHED_AZKAR_ITEMS_';
  static const String _allahNamesKey = 'CACHED_ALLAH_NAMES';

  AzkarLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<AzkarCategoryModel>> getCachedAzkarCategories() async {
    final jsonString = sharedPreferences.getString(_azkarCategoriesKey);
    if (jsonString == null) {
      throw Exception('No cached azkar categories found');
    }

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => AzkarCategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheAzkarCategories(List<AzkarCategoryModel> categories) async {
    final jsonList = categories.map((category) => category.toJson()).toList();
    await sharedPreferences.setString(_azkarCategoriesKey, json.encode(jsonList));
  }

  @override
  Future<List<AzkarModel>> getCachedAzkarItems(int chapterId) async {
    final key = '$_azkarItemsKeyPrefix$chapterId';
    final jsonString = sharedPreferences.getString(key);
    
    if (jsonString == null) {
      throw Exception('No cached azkar items found for chapter $chapterId');
    }

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => AzkarModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheAzkarItems(int chapterId, List<AzkarModel> items) async {
    final key = '$_azkarItemsKeyPrefix$chapterId';
    final jsonList = items.map((item) => item.toJson()).toList();
    await sharedPreferences.setString(key, json.encode(jsonList));
  }

  @override
  Future<List<AllahNameModel>> getCachedAllahNames() async {
    final jsonString = sharedPreferences.getString(_allahNamesKey);
    if (jsonString == null) {
      throw Exception('No cached Allah names found');
    }

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => AllahNameModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheAllahNames(List<AllahNameModel> names) async {
    final jsonList = names.map((name) => name.toJson()).toList();
    await sharedPreferences.setString(_allahNamesKey, json.encode(jsonList));
  }
}
