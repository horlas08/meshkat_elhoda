import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bookmark_entity.dart';

class BookmarkModel extends BookmarkEntity {
  const BookmarkModel({
    required super.id,
    required super.surahNumber,
    required super.surahName,
    required super.ayahNumber,
    required super.ayahText,
    required super.createdAt,
    super.note,
  });

  // Convert from Firestore document to model
  factory BookmarkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookmarkModel(
      id: doc.id,
      surahNumber: data['surahNumber'] as int,
      surahName: data['surahName'] as String,
      ayahNumber: data['ayahNumber'] as int,
      ayahText: data['ayahText'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      note: data['note'] as String?,
    );
  }

  // Convert from JSON to model (for Hive caching)
  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      surahNumber: json['surahNumber'] as int,
      surahName: json['surahName'] as String,
      ayahNumber: json['ayahNumber'] as int,
      ayahText: json['ayahText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }

  // Convert model to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'createdAt': Timestamp.fromDate(createdAt),
      'note': note,
    };
  }

  // Convert model to JSON (for Hive caching)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  // Convert entity to model
  factory BookmarkModel.fromEntity(BookmarkEntity entity) {
    return BookmarkModel(
      id: entity.id,
      surahNumber: entity.surahNumber,
      surahName: entity.surahName,
      ayahNumber: entity.ayahNumber,
      ayahText: entity.ayahText,
      createdAt: entity.createdAt,
      note: entity.note,
    );
  }
}
