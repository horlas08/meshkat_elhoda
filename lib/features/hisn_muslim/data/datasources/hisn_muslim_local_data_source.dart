
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/hisn_chapter_model.dart';


abstract class HisnMuslimLocalDataSource {
  Future<List<HisnChapterModel>> getHisnCategories(String languageCode);
}

class HisnMuslimLocalDataSourceImpl implements HisnMuslimLocalDataSource {
  @override
  Future<List<HisnChapterModel>> getHisnCategories(String languageCode) async {
    String jsonString;
    try {
      jsonString = await rootBundle.loadString('assets/json/husn_$languageCode.json');
    } catch (_) {
      jsonString = await rootBundle.loadString('assets/json/husn_en.json');
    }

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    // Use the first key regardless of what it is (English, Arabic, etc.)
    final key = jsonMap.keys.isNotEmpty ? jsonMap.keys.first : 'English';
    final List<dynamic> list = jsonMap[key] as List<dynamic>? ?? [];
    
    return list
        .map((e) => HisnChapterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

