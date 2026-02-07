import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/azkar_category_model.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/azkar_model.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/allah_name_model.dart';
import 'package:meshkat_elhoda/features/azkar/data/models/azkar_json_model.dart';

abstract class AzkarRemoteDataSource {
  Future<List<AzkarCategoryModel>> getAzkarCategories();
  Future<List<AzkarModel>> getAzkarItems(int categoryId);
  Future<List<AllahNameModel>> getAllahNames();
  Future<String?> getAudioForAzkar(int azkarId, String azkarText);
}

class AzkarRemoteDataSourceImpl implements AzkarRemoteDataSource {
  List<AzkarJsonModel>? _cachedAzkar;

  AzkarRemoteDataSourceImpl();

  /// Load azkar data from local JSON
  Future<List<AzkarJsonModel>> _loadAzkarData() async {
    if (_cachedAzkar != null) return _cachedAzkar!;

    try {
      final String jsonString = await rootBundle.loadString('assets/json/azkar.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _cachedAzkar = jsonList.map((e) => AzkarJsonModel.fromJson(e)).toList();
      return _cachedAzkar!;
    } catch (e) {
      log('Error loading azkar data: $e');
      return [];
    }
  }

  @override
  Future<List<AzkarCategoryModel>> getAzkarCategories() async {
    try {
      final azkarData = await _loadAzkarData();
      
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
  Future<List<AzkarModel>> getAzkarItems(int categoryId) async {
    try {
      final azkarData = await _loadAzkarData();
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
          audioUrl: null, // Audio not available in the JSON
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
