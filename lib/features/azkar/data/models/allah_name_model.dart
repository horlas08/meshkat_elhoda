import 'package:meshkat_elhoda/features/azkar/domain/entities/allah_name.dart';

class AllahNameModel extends AllahName {
  const AllahNameModel({
    required super.id,
    required super.arabicName,
    required super.transliteration,
    required super.translation,
  });

  factory AllahNameModel.fromJson(Map<String, dynamic> json) {
    return AllahNameModel(
      id: json['id'] as int,
      arabicName: json['arabicName'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabicName': arabicName,
      'transliteration': transliteration,
      'translation': translation,
    };
  }

  factory AllahNameModel.fromEntity(AllahName name) {
    return AllahNameModel(
      id: name.id,
      arabicName: name.arabicName,
      transliteration: name.transliteration,
      translation: name.translation,
    );
  }
}
