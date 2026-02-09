import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar.dart';

class AzkarModel extends Azkar {
  const AzkarModel({
    required super.id,
    required super.title,
    required super.text,
    super.repeat,
    super.audioUrl,
    super.translation,
    super.source,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      repeat: json['repeat'] as int?,
      audioUrl: json['audioUrl'] as String?,
      translation: json['translation'] as String?,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'repeat': repeat,
      'audioUrl': audioUrl,
      'translation': translation,
      'source': source,
    };
  }

  factory AzkarModel.fromEntity(Azkar azkar) {
    return AzkarModel(
      id: azkar.id,
      title: azkar.title,
      text: azkar.text,
      repeat: azkar.repeat,
      audioUrl: azkar.audioUrl,
    );
  }
}
