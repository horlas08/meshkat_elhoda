class GuideStep {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final List<Map<String, String>> steps; // New field for detailed steps
  final Map<String, String>? tips;       // New field for tips
  final List<GuideDua> duas;

  GuideStep({
    required this.id,
    required this.title,
    required this.description,
    this.steps = const [],
    this.tips,
    required this.duas,
  });

  String getTitle(String langCode) => title[langCode] ?? title['en'] ?? '';
  String getDescription(String langCode) => description[langCode] ?? description['en'] ?? '';
}

class GuideDua {
  final Map<String, String> title;
  final String arabic;
  final Map<String, String> translation;

  GuideDua({
    required this.title,
    required this.arabic,
    required this.translation,
  });

  String getTitle(String langCode) => title[langCode] ?? title['en'] ?? '';
  String getTranslation(String langCode) => translation[langCode] ?? translation['en'] ?? '';
}
