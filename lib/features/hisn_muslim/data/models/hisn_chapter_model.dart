
import '../../domain/entities/hisn_chapter.dart';
import 'hisn_dhikr_model.dart';

class HisnChapterModel extends HisnChapter {
  const HisnChapterModel({
    required super.id,
    required super.title,
    required super.audioUrl,
    required super.dhikrs,
  });

  factory HisnChapterModel.fromJson(Map<String, dynamic> json) {
    final textList = json['TEXT'] as List<dynamic>? ?? [];
    return HisnChapterModel(
      id: json['ID'] as int? ?? 0,
      title: json['TITLE'] as String? ?? '',
      audioUrl: json['AUDIO_URL'] as String? ?? '',
      dhikrs: textList.map((e) => HisnDhikrModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TITLE': title,
      'AUDIO_URL': audioUrl,
      'TEXT': dhikrs.map((e) => (e as HisnDhikrModel).toJson()).toList(),
    };
  }
}
