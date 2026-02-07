import '../../domain/entities/quran_edition_entity.dart';

class QuranEditionModel extends QuranEditionEntity {
  const QuranEditionModel({
    required super.identifier,
    required super.language,
    required super.name,
    required super.englishName,
    required super.format,
    required super.type,
    super.direction,
  });

  factory QuranEditionModel.fromJson(Map<String, dynamic> json) {
    return QuranEditionModel(
      identifier: json['identifier'],
      language: json['language'],
      name: json['name'],
      englishName: json['englishName'],
      format: json['format'],
      type: json['type'],
      direction: json['direction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'language': language,
      'name': name,
      'englishName': englishName,
      'format': format,
      'type': type,
      'direction': direction,
    };
  }
}
