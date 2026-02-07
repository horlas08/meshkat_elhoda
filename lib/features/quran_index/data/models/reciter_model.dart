import '../../domain/entities/reciter_entity.dart';

class ReciterModel extends ReciterEntity {
  const ReciterModel({
    required super.identifier,
    required super.name,
    required super.englishName,
    required super.style,
    required super.format,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      identifier: json['identifier'],
      name: json['name'],
      englishName: json['englishName'],
      style: json['style'],
      format: json['format'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'name': name,
      'englishName': englishName,
      'style': style,
      'format': format,
    };
  }
}
