import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/khatmah_progress_entity.dart';

class KhatmahProgressModel extends KhatmahProgressEntity {
  const KhatmahProgressModel({
    required super.currentPage,
    required super.currentJuz,
    required super.currentHizb,
    required super.lastUpdated,
    required super.dailyStartPage,
    required super.lastDailyReset,
  });

  factory KhatmahProgressModel.initial() {
    final now = DateTime.now();
    return KhatmahProgressModel(
      currentPage: 1,
      currentJuz: 1,
      currentHizb: 1,
      lastUpdated: now,
      dailyStartPage: 1,
      lastDailyReset: now,
    );
  }

  factory KhatmahProgressModel.fromMap(Map<String, dynamic> map) {
    return KhatmahProgressModel(
      currentPage: map['currentPage'] as int? ?? 1,
      currentJuz: map['currentJuz'] as int? ?? 1,
      currentHizb: map['currentHizb'] as int? ?? 1,
      lastUpdated: map['lastUpdated'] is Timestamp
          ? (map['lastUpdated'] as Timestamp).toDate()
          : DateTime.parse(map['lastUpdated'] as String),
      dailyStartPage: map['dailyStartPage'] as int? ?? 1,
      lastDailyReset: map['lastDailyReset'] is Timestamp
          ? (map['lastDailyReset'] as Timestamp).toDate()
          : (map['lastDailyReset'] != null
                ? DateTime.parse(map['lastDailyReset'] as String)
                : DateTime.now()), // Fallback for old data
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentPage': currentPage,
      'currentJuz': currentJuz,
      'currentHizb': currentHizb,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'dailyStartPage': dailyStartPage,
      'lastDailyReset': Timestamp.fromDate(lastDailyReset),
    };
  }

  KhatmahProgressModel copyWith({
    int? currentPage,
    int? currentJuz,
    int? currentHizb,
    DateTime? lastUpdated,
    int? dailyStartPage,
    DateTime? lastDailyReset,
  }) {
    return KhatmahProgressModel(
      currentPage: currentPage ?? this.currentPage,
      currentJuz: currentJuz ?? this.currentJuz,
      currentHizb: currentHizb ?? this.currentHizb,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      dailyStartPage: dailyStartPage ?? this.dailyStartPage,
      lastDailyReset: lastDailyReset ?? this.lastDailyReset,
    );
  }

  // Create from entity
  factory KhatmahProgressModel.fromEntity(KhatmahProgressEntity entity) {
    return KhatmahProgressModel(
      currentPage: entity.currentPage,
      currentJuz: entity.currentJuz,
      currentHizb: entity.currentHizb,
      lastUpdated: entity.lastUpdated,
      dailyStartPage: entity.dailyStartPage,
      lastDailyReset: entity.lastDailyReset,
    );
  }
}
