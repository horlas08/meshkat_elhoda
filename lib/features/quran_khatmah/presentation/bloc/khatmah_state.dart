import 'package:equatable/equatable.dart';
import '../../domain/entities/khatmah_progress_entity.dart';
import '../../domain/entities/page_details_entity.dart';

abstract class KhatmahState extends Equatable {
  const KhatmahState();

  @override
  List<Object?> get props => [];
}

class KhatmahInitial extends KhatmahState {}

class KhatmahLoading extends KhatmahState {}

class KhatmahReflecting extends KhatmahState {
  final KhatmahProgressEntity progress;
  final PageDetailsEntity pageDetails;
  final bool isPlaying;
  final int currentAyahIndex; // Index in pageDetails.ayahs

  const KhatmahReflecting({
    required this.progress,
    required this.pageDetails,
    this.isPlaying = false,
    this.currentAyahIndex = 0,
  });

  KhatmahReflecting copyWith({
    KhatmahProgressEntity? progress,
    PageDetailsEntity? pageDetails,
    bool? isPlaying,
    int? currentAyahIndex,
  }) {
    return KhatmahReflecting(
      progress: progress ?? this.progress,
      pageDetails: pageDetails ?? this.pageDetails,
      isPlaying: isPlaying ?? this.isPlaying,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
    );
  }

  @override
  List<Object?> get props => [
    progress,
    pageDetails,
    isPlaying,
    currentAyahIndex,
  ];
}

class KhatmahError extends KhatmahState {
  final String message;
  const KhatmahError(this.message);
  @override
  List<Object> get props => [message];
}
