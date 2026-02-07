part of 'hajj_umrah_cubit.dart';

abstract class HajjUmrahState extends Equatable {
  const HajjUmrahState();

  @override
  List<Object?> get props => [];
}

class HajjUmrahInitial extends HajjUmrahState {}

class HajjUmrahLoading extends HajjUmrahState {}

class HajjUmrahLoaded extends HajjUmrahState {
  final List<GuideStep> steps;
  final String type; // 'hajj' or 'umrah'
  final String? lastCompletedId;

  const HajjUmrahLoaded({
    required this.steps,
    required this.type,
    this.lastCompletedId,
  });

  HajjUmrahLoaded copyWith({
    List<GuideStep>? steps,
    String? type,
    String? lastCompletedId,
  }) {
    return HajjUmrahLoaded(
      steps: steps ?? this.steps,
      type: type ?? this.type,
      lastCompletedId: lastCompletedId ?? this.lastCompletedId,
    );
  }

  @override
  List<Object?> get props => [steps, type, lastCompletedId];
}

class HajjUmrahError extends HajjUmrahState {
  final String message;
  const HajjUmrahError(this.message);
}
