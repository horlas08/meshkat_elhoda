// In lib/features/hadith/domain/entities/hadith.dart
import 'package:equatable/equatable.dart';

/// Hadith entity representing a single hadith
/// This is the core domain model used across the application
class Hadith extends Equatable {
  final String id;
  final String bookName;
  final String chapter;
  final String hadithText;
  final String narrator;
  final String reference;
  final List<HadithGrade> grades;
  final String? translation; // Translation text (null if not available)

  const Hadith({
    required this.id,
    required this.bookName,
    required this.chapter,
    required this.hadithText,
    required this.narrator,
    required this.reference,
    this.grades = const [],
    this.translation,
  });

  @override
  List<Object?> get props => [
    id,
    bookName,
    chapter,
    hadithText,
    narrator,
    reference,
    grades,
    translation,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'chapter': chapter,
      'hadithText': hadithText,
      'narrator': narrator,
      'reference': reference,
      'grades': grades.map((g) => g.toJson()).toList(),
      'translation': translation,
    };
  }

  /// Creates a copy of the Hadith with updated values
  Hadith copyWith({
    String? id,
    String? bookName,
    String? chapter,
    String? hadithText,
    String? narrator,
    String? reference,
    List<HadithGrade>? grades,
    String? translation,
  }) {
    return Hadith(
      id: id ?? this.id,
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      hadithText: hadithText ?? this.hadithText,
      narrator: narrator ?? this.narrator,
      reference: reference ?? this.reference,
      grades: grades ?? this.grades,
      translation: translation ?? this.translation,
    );
  }
}

/// Grade model for hadith authentication
class HadithGrade extends Equatable {
  final String name;
  final String grade;

  const HadithGrade({required this.name, required this.grade});

  factory HadithGrade.fromJson(Map<String, dynamic> json) {
    return HadithGrade(
      name: json['name']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'grade': grade};
  }

  @override
  List<Object?> get props => [name, grade];

  /// Creates a copy of the HadithGrade with updated values
  HadithGrade copyWith({String? name, String? grade}) {
    return HadithGrade(name: name ?? this.name, grade: grade ?? this.grade);
  }
}
