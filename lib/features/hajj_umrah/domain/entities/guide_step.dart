class GuideStep {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final List<GuideDua> duas;

  const GuideStep({
    required this.id,
    required this.title,
    required this.description,
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
