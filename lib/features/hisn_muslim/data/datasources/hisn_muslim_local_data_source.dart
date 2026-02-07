
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/hisn_chapter_model.dart';

abstract class HisnMuslimLocalDataSource {
  Future<List<HisnChapterModel>> getHisnCategories();
}

class HisnMuslimLocalDataSourceImpl implements HisnMuslimLocalDataSource {
  @override
  Future<List<HisnChapterModel>> getHisnCategories() async {
    final String jsonString = await rootBundle.loadString('assets/json/husn_en.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final List<dynamic> englishList = jsonMap['English'] as List<dynamic>? ?? [];
    
    return englishList
        .map((e) => HisnChapterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
