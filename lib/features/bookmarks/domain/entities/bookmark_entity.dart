import 'package:equatable/equatable.dart';

class BookmarkEntity extends Equatable {
  final String id;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final DateTime createdAt;
  final String? note;

  const BookmarkEntity({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.createdAt,
    this.note,
  });

  @override
  List<Object?> get props => [
        id,
        surahNumber,
        surahName,
        ayahNumber,
        ayahText,
        createdAt,
        note,
      ];
}
