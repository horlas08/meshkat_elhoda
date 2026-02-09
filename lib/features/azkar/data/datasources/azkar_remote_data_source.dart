import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/azkar_category_model.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/azkar_model.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/allah_name_model.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/azkar_json_model.dart';

abstract class AzkarRemoteDataSource {
  Future<List<AzkarCategoryModel>> getAzkarCategories(String languageCode);
  Future<List<AzkarModel>> getAzkarItems(int categoryId, String languageCode);
  Future<List<AllahNameModel>> getAllahNames();
  Future<String?> getAudioForAzkar(int azkarId, String azkarText);
}

class AzkarRemoteDataSourceImpl implements AzkarRemoteDataSource {
  // Cache by language code
  final Map<String, List<AzkarJsonModel>> _cachedAzkar = {};

  AzkarRemoteDataSourceImpl();

  /// Load azkar data from local JSON
  Future<List<AzkarJsonModel>> _loadAzkarData(String languageCode) async {
    if (_cachedAzkar.containsKey(languageCode)) {
      return _cachedAzkar[languageCode]!;
    }

    try {
      // Try to load localized JSON
      String jsonPath = 'assets/json/azkar_$languageCode.json';
      String jsonString;
      
      try {
        jsonString = await rootBundle.loadString(jsonPath);
      } catch (e) {
        // Fallback to default Arabic if localized file not found
        log('Localized azkar file not found for $languageCode, falling back to default.');
        jsonString = await rootBundle.loadString('assets/json/azkar.json');
      }

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final azkarList = jsonList.map((e) => AzkarJsonModel.fromJson(e)).toList();
      
      _cachedAzkar[languageCode] = azkarList;
      return azkarList;
    } catch (e) {
      log('Error loading azkar data: $e');
      return [];
    }
  }

  @override
  Future<List<AzkarCategoryModel>> getAzkarCategories(String languageCode) async {
    try {
      final azkarData = await _loadAzkarData(languageCode);
      
      return azkarData.map((category) {
        return AzkarCategoryModel(
          id: category.id,
          title: category.category,
          description: null,
        );
      }).toList();
    } catch (e) {
      log('Error getting azkar categories: $e');
      rethrow;
    }
  }

  @override
  Future<List<AzkarModel>> getAzkarItems(int categoryId, String languageCode) async {
    try {
      final azkarData = await _loadAzkarData(languageCode);
      final category = azkarData.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => throw Exception('Category not found'),
      );

      return category.azkar.map((item) {
        return AzkarModel(
          id: item.id,
          title: '',
          text: item.text,
          repeat: item.count,
          audioUrl: null,
          translation: item.translation,
          source: item.source,
        );
      }).toList();
    } catch (e) {
      log('Error getting azkar items: $e');
      rethrow;
    }
  }

  @override
  Future<List<AllahNameModel>> getAllahNames() async {
    // This will be implemented separately as it's not part of the azkar.json
    throw UnimplementedError('getAllahNames is not implemented in this data source');
  }

  @override
  Future<String?> getAudioForAzkar(int azkarId, String azkarText) async {
    // Audio functionality is not available with the local JSON
    return null;
  }
}
