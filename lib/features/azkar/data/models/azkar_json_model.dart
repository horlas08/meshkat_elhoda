class AzkarJsonModel {
  final int id;
  final String category;
  final List<AzkarItemJson> azkar;

  AzkarJsonModel({
    required this.id,
    required this.category,
    required this.azkar,
  });

  factory AzkarJsonModel.fromJson(Map<String, dynamic> json) {
    return AzkarJsonModel(
      id: json['id'] as int,
      category: json['category'] as String,
      azkar: (json['array'] as List<dynamic>)
          .map((item) => AzkarItemJson.fromJson(item))
          .toList(),
    );
  }
}

class AzkarItemJson {
  final int id;
  final String text;
  final int count;
  final String? translation;
  final String? source;

  AzkarItemJson({
    required this.id,
    required this.text,
    required this.count,
    this.translation,
    this.source,
  });

  factory AzkarItemJson.fromJson(Map<String, dynamic> json) {
    return AzkarItemJson(
      id: json['id'] as int,
      text: json['text'] as String,
      count: json['count'] as int,
      translation: json['translation'] as String?,
      source: json['source'] as String?,
    );
  }
}
