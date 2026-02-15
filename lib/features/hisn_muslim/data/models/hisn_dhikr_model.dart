
import '../../domain/entities/hisn_dhikr.dart';

class HisnDhikrModel extends HisnDhikr {
  const HisnDhikrModel({
    required super.id,
    required super.arabicText,
    required super.translatedText,
    required super.repeat,
    required super.audio,
  });

  factory HisnDhikrModel.fromJson(Map<String, dynamic> json) {
    return HisnDhikrModel(
      id: json['ID'] as int? ?? 0,
      arabicText: json['ARABIC_TEXT'] as String? ?? json['Text'] as String? ?? '',
      translatedText: json['TRANSLATED_TEXT'] as String? ?? '',
      repeat: json['REPEAT'] as int? ?? 1,
      audio: json['AUDIO'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ARABIC_TEXT': arabicText,
      'TRANSLATED_TEXT': translatedText,
      'REPEAT': repeat,
      'AUDIO': audio,
    };
  }
}
