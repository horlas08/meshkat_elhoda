import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';

class SurahModel extends Surah {
  const SurahModel({
    required super.number,
    required super.name,
    required super.nameEnglish,
    required super.nameArabic,
    required super.ayahCount,
    required super.type,
    super.audioUrl,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: int.tryParse(json['number'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      nameEnglish: json['englishName'] as String? ?? '',
      nameArabic: json['name'] as String? ?? '',
      ayahCount: int.tryParse(json['numberOfAyahs'].toString()) ?? 0,
      type: json['revelationType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': nameArabic,
      'englishName': nameEnglish,
      'numberOfAyahs': ayahCount,
      'revelationType': type,
    };
  }

  SurahModel copyWith({
    int? number,
    String? name,
    String? nameEnglish,
    String? nameArabic,
    int? ayahCount,
    String? type,
    String? audioUrl,
  }) {
    return SurahModel(
      number: number ?? this.number,
      name: name ?? this.name,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameArabic: nameArabic ?? this.nameArabic,
      ayahCount: ayahCount ?? this.ayahCount,
      type: type ?? this.type,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}
