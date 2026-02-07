import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/quran_index/data/models/khatma_progress_model.dart';

abstract class KhatmaProgressState extends Equatable {
  const KhatmaProgressState();

  @override
  List<Object?> get props => [];
}

class KhatmaInitial extends KhatmaProgressState {}

class KhatmaLoading extends KhatmaProgressState {}

class KhatmaLoaded extends KhatmaProgressState {
  final KhatmaProgressModel progress;

  const KhatmaLoaded({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class KhatmaError extends KhatmaProgressState {
  final String message;

  const KhatmaError({required this.message});

  @override
  List<Object?> get props => [message];
}
