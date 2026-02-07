import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/domain/entities/guide_step.dart';

abstract class HajjUmrahLocalDataSource {
  Future<List<GuideStep>> getUmrahSteps();
  Future<List<GuideStep>> getHajjSteps();
}

class HajjUmrahLocalDataSourceImpl implements HajjUmrahLocalDataSource {
  @override
  Future<List<GuideStep>> getUmrahSteps() async {
    final Map<String, dynamic> data = await _loadJson();
    final List<dynamic> list = data['umrah'];
    return list.map((e) => _mapToGuideStep(e)).toList();
  }

  @override
  Future<List<GuideStep>> getHajjSteps() async {
    final Map<String, dynamic> data = await _loadJson();
    final List<dynamic> list = data['hajj'];
    return list.map((e) => _mapToGuideStep(e)).toList();
  }

  Future<Map<String, dynamic>> _loadJson() async {
    final String response = await rootBundle.loadString('assets/json/hajj_umrah_data.json');
    return json.decode(response);
  }

  GuideStep _mapToGuideStep(Map<String, dynamic> map) {
    return GuideStep(
      id: map['id'],
      title: Map<String, String>.from(map['title']),
      description: Map<String, String>.from(map['description']),
      duas: (map['duas'] as List<dynamic>)
          .map((d) => GuideDua(
                title: Map<String, String>.from(d['title']),
                arabic: d['arabic'],
                translation: Map<String, String>.from(d['translation']),
              ))
          .toList(),
    );
  }
}
