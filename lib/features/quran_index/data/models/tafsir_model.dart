import '../../domain/entities/tafsir_entity.dart';

class TafsirModel extends TafsirEntity {
  const TafsirModel({
    required super.number,
    required super.text,
    required super.tafsirName,
    required super.language,
  });

  factory TafsirModel.fromJson(Map<String, dynamic> json) {
    return TafsirModel(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      tafsirName: json['edition']?['name'] ?? 'تفسير غير معروف',
      language: json['edition']?['language'] ?? 'ar',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'tafsirName': tafsirName,
      'language': language,
    };
  }
}
