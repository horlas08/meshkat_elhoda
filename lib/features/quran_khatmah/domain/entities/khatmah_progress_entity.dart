import 'package:equatable/equatable.dart';

class KhatmahProgressEntity extends Equatable {
  final int currentPage;
  final int currentJuz;
  final int currentHizb;
  final DateTime lastUpdated;
  final int dailyStartPage;
  final DateTime lastDailyReset;

  const KhatmahProgressEntity({
    required this.currentPage,
    required this.currentJuz,
    required this.currentHizb,
    required this.lastUpdated,
    required this.dailyStartPage,
    required this.lastDailyReset,
  });

  @override
  List<Object?> get props => [
    currentPage,
    currentJuz,
    currentHizb,
    lastUpdated,
    dailyStartPage,
    lastDailyReset,
  ];
}
