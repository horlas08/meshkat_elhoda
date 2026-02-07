import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// نموذج بيانات تقدم الختمة
class KhatmaProgressModel extends Equatable {
  final int currentPage;
  final int currentJuz;
  final int currentHizb;
  final DateTime lastUpdated;

  const KhatmaProgressModel({
    required this.currentPage,
    required this.currentJuz,
    required this.currentHizb,
    required this.lastUpdated,
  });

  /// إنشاء نموذج افتراضي (بداية القرآن)
  factory KhatmaProgressModel.initial() {
    return KhatmaProgressModel(
      currentPage: 1,
      currentJuz: 1,
      currentHizb: 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// تحويل من Map (من Firebase)
  factory KhatmaProgressModel.fromMap(Map<String, dynamic> map) {
    return KhatmaProgressModel(
      currentPage: map['currentPage'] as int? ?? 1,
      currentJuz: map['currentJuz'] as int? ?? 1,
      currentHizb: map['currentHizb'] as int? ?? 1,
      lastUpdated: map['lastUpdated'] is Timestamp
          ? (map['lastUpdated'] as Timestamp).toDate()
          : DateTime.parse(map['lastUpdated'] as String),
    );
  }

  /// تحويل إلى Map (للحفظ في Firebase)
  Map<String, dynamic> toMap() {
    return {
      'currentPage': currentPage,
      'currentJuz': currentJuz,
      'currentHizb': currentHizb,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// نسخ مع تعديل بعض الحقول
  KhatmaProgressModel copyWith({
    int? currentPage,
    int? currentJuz,
    int? currentHizb,
    DateTime? lastUpdated,
  }) {
    return KhatmaProgressModel(
      currentPage: currentPage ?? this.currentPage,
      currentJuz: currentJuz ?? this.currentJuz,
      currentHizb: currentHizb ?? this.currentHizb,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// حساب نسبة التقدم (0.0 - 1.0)
  double get progressPercentage {
    return currentPage / 604.0;
  }

  /// هل اكتملت الختمة؟
  bool get isCompleted {
    return currentPage >= 604;
  }

  @override
  List<Object?> get props => [
    currentPage,
    currentJuz,
    currentHizb,
    lastUpdated,
  ];

  @override
  String toString() {
    return 'KhatmaProgress(page: $currentPage, juz: $currentJuz, hizb: $currentHizb)';
  }
}
