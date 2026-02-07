import '../../domain/entities/surah_entity.dart';
import 'ayah_model.dart';

class SurahModel extends SurahEntity {
  final List<AyahModel> ayahs;

  const SurahModel({
    required super.number,
    required super.name,
    required super.englishName,
    required super.englishNameTranslation,
    required super.numberOfAyahs,
    required super.revelationType,
    required super.juzNumber,
    required this.ayahs,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    final List<AyahModel> ayahs = (json['ayahs'] as List)
        .map((ayah) => AyahModel.fromJson(ayah))
        .toList();

    return SurahModel(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'] ?? ayahs.length,
      revelationType: json['revelationType'],
      juzNumber: ayahs.first.juz, // نأخذ رقم الجزء من أول آية في السورة
      ayahs: ayahs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'numberOfAyahs': numberOfAyahs,
      'revelationType': revelationType,
      'juzNumber': juzNumber,
      'ayahs': ayahs.map((ayah) => ayah.toJson()).toList(),
    };
  }
}
