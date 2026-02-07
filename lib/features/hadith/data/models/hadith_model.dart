import 'package:meshkat_elhoda/features/hadith/domain/entities/hadith.dart';

/// Data model for Hadith from HadeethEnc API
/// Handles JSON serialization and deserialization
class HadithModel extends Hadith {
  const HadithModel({
    required super.id,
    required super.bookName,
    required super.chapter,
    required super.hadithText,
    required super.narrator,
    required super.reference,
    super.grades = const [],
    super.translation,
    this.explanation,
    this.hints,
    this.wordsMeaning,
    this.attribution,
  });

  /// Explanation of the hadith (شرح الحديث)
  final String? explanation;

  /// Benefits/hints from the hadith (الفوائد)
  final List<String>? hints;

  /// Word meanings (معاني الكلمات)
  final List<WordMeaning>? wordsMeaning;

  /// Attribution/source (التخريج)
  final String? attribution;

  /// Creates a HadithModel from HadeethEnc API single hadith response
  factory HadithModel.fromHadeethEncJson(
    Map<String, dynamic> json, {
    String? categoryName,
  }) {
    // Parse hints
    List<String>? hints;
    if (json['hints'] != null && json['hints'] is List) {
      hints = (json['hints'] as List).map((h) => h.toString()).toList();
    }

    // Parse word meanings
    List<WordMeaning>? wordsMeaning;
    if (json['words_meaning'] != null && json['words_meaning'] is List) {
      wordsMeaning = (json['words_meaning'] as List)
          .map((w) => WordMeaning.fromJson(w as Map<String, dynamic>))
          .toList();
    }

    // The grade is a string in this API
    List<HadithGrade> grades = [];
    if (json['grade'] != null && json['grade'].toString().isNotEmpty) {
      grades = [
        HadithGrade(name: 'HadeethEnc', grade: json['grade'].toString()),
      ];
    }

    return HadithModel(
      id: json['id']?.toString() ?? '',
      bookName: categoryName ?? 'الأحاديث',
      chapter: categoryName ?? '',
      hadithText: json['hadeeth']?.toString() ?? '',
      narrator: '', // Not directly available in this API
      reference: json['attribution']?.toString() ?? '',
      grades: grades,
      translation: json['hadeeth']?.toString(),
      explanation: json['explanation']?.toString(),
      hints: hints,
      wordsMeaning: wordsMeaning,
      attribution: json['attribution']?.toString(),
    );
  }

  /// Creates a HadithModel from list item (basic info only)
  factory HadithModel.fromListItem(
    Map<String, dynamic> json, {
    String? categoryName,
  }) {
    return HadithModel(
      id: json['id']?.toString() ?? '',
      bookName: categoryName ?? 'الأحاديث',
      chapter: categoryName ?? '',
      hadithText:
          json['title']?.toString() ?? '', // Title is the hadith text preview
      narrator: '',
      reference: '',
      grades: const [],
    );
  }

  /// Converts the model to JSON format for caching
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hadeeth': hadithText,
      'bookName': bookName,
      'chapter': chapter,
      'narrator': narrator,
      'reference': reference,
      'grades': grades.map((g) => g.toJson()).toList(),
      'translation': translation,
      'explanation': explanation,
      'hints': hints,
      'words_meaning': wordsMeaning?.map((w) => w.toJson()).toList(),
      'attribution': attribution,
    };
  }

  /// Creates a HadithModel from cached JSON
  factory HadithModel.fromCachedJson(Map<String, dynamic> json) {
    // Parse grades from cached JSON
    List<HadithGrade> grades = [];
    if (json['grades'] != null && json['grades'] is List) {
      grades = (json['grades'] as List)
          .where((g) => g != null)
          .map((g) => HadithGrade.fromJson(g as Map<String, dynamic>))
          .toList();
    }

    // Parse hints
    List<String>? hints;
    if (json['hints'] != null && json['hints'] is List) {
      hints = (json['hints'] as List).map((h) => h.toString()).toList();
    }

    // Parse word meanings
    List<WordMeaning>? wordsMeaning;
    if (json['words_meaning'] != null && json['words_meaning'] is List) {
      wordsMeaning = (json['words_meaning'] as List)
          .map((w) => WordMeaning.fromJson(w as Map<String, dynamic>))
          .toList();
    }

    return HadithModel(
      id: json['id']?.toString() ?? '0',
      bookName: json['bookName']?.toString() ?? 'الأحاديث',
      chapter: json['chapter']?.toString() ?? '',
      hadithText:
          json['hadeeth']?.toString() ?? json['hadithText']?.toString() ?? '',
      narrator: json['narrator']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      grades: grades,
      translation: json['translation']?.toString(),
      explanation: json['explanation']?.toString(),
      hints: hints,
      wordsMeaning: wordsMeaning,
      attribution: json['attribution']?.toString(),
    );
  }

  /// Converts the model to a domain entity
  Hadith toEntity() {
    return Hadith(
      id: id,
      bookName: bookName,
      chapter: chapter,
      hadithText: hadithText,
      narrator: narrator,
      reference: reference,
      grades: grades,
      translation: translation,
    );
  }

  /// Creates a model from a domain entity
  factory HadithModel.fromEntity(Hadith hadith) {
    return HadithModel(
      id: hadith.id,
      bookName: hadith.bookName,
      chapter: hadith.chapter,
      hadithText: hadith.hadithText,
      narrator: hadith.narrator,
      reference: hadith.reference,
      grades: hadith.grades,
      translation: hadith.translation,
    );
  }

  // ========== Helper methods for grades ==========

  /// Get grade by scholar name
  HadithGrade? getGradeByScholar(String scholarName) {
    try {
      return grades.firstWhere((g) => g.name == scholarName);
    } catch (e) {
      return null;
    }
  }

  /// Check if hadith is Sahih
  bool get isSahih {
    return grades.any(
      (g) =>
          g.grade.toLowerCase().contains('sahih') || g.grade.contains('صحيح'),
    );
  }

  /// Check if hadith is Hasan
  bool get isHasan {
    return grades.any(
      (g) => g.grade.toLowerCase().contains('hasan') || g.grade.contains('حسن'),
    );
  }

  /// Check if hadith is Daif
  bool get isDaif {
    return grades.any(
      (g) => g.grade.toLowerCase().contains('daif') || g.grade.contains('ضعيف'),
    );
  }

  /// Get the strongest grade
  String get strongestGrade {
    if (isSahih) return 'صحيح';
    if (isHasan) return 'حسن';
    if (isDaif) return 'ضعيف';
    if (grades.isNotEmpty) return grades.first.grade;
    return '';
  }

  /// Get all scholar names
  List<String> get scholarNames {
    return grades.map((g) => g.name).toList();
  }

  /// Check if there are multiple scholars
  bool get hasMultipleScholars {
    return grades.length > 1;
  }

  /// Get grades summary as String
  String get gradesSummary {
    if (grades.isEmpty) return '';
    return grades.map((g) => '${g.name}: ${g.grade}').join('\n');
  }

  @override
  HadithModel copyWith({
    String? id,
    String? bookName,
    String? chapter,
    String? hadithText,
    String? narrator,
    String? reference,
    List<HadithGrade>? grades,
    String? translation,
    String? explanation,
    List<String>? hints,
    List<WordMeaning>? wordsMeaning,
    String? attribution,
  }) {
    return HadithModel(
      id: id ?? this.id,
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      hadithText: hadithText ?? this.hadithText,
      narrator: narrator ?? this.narrator,
      reference: reference ?? this.reference,
      grades: grades ?? this.grades,
      translation: translation ?? this.translation,
      explanation: explanation ?? this.explanation,
      hints: hints ?? this.hints,
      wordsMeaning: wordsMeaning ?? this.wordsMeaning,
      attribution: attribution ?? this.attribution,
    );
  }
}

/// Model for word meaning in hadith explanation
class WordMeaning {
  final String word;
  final String meaning;

  const WordMeaning({required this.word, required this.meaning});

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    return WordMeaning(
      word: json['word']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'word': word, 'meaning': meaning};
  }
}
