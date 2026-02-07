import 'package:equatable/equatable.dart';

class Surah extends Equatable {
  final int number;
  final String name;
  final String nameEnglish;
  final String nameArabic;
  final int ayahCount;
  final String type;
  final String? audioUrl;

  const Surah({
    required this.number,
    required this.name,
    required this.nameEnglish,
    required this.nameArabic,
    required this.ayahCount,
    required this.type,
    this.audioUrl,
  });

  @override
  List<Object?> get props => [
    number,
    name,
    nameEnglish,
    nameArabic,
    ayahCount,
    type,
    audioUrl,
  ];

  Surah copyWith({
    int? number,
    String? name,
    String? nameEnglish,
    String? nameArabic,
    int? ayahCount,
    String? type,
    String? audioUrl,
  }) {
    return Surah(
      number: number ?? this.number,
      name: name ?? this.name,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameArabic: nameArabic ?? this.nameArabic,
      ayahCount: ayahCount ?? this.ayahCount,
      type: type ?? this.type,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}
