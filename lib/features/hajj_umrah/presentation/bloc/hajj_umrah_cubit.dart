import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/domain/entities/guide_step.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/domain/repositories/hajj_umrah_repository.dart';

part 'hajj_umrah_state.dart';

class HajjUmrahCubit extends Cubit<HajjUmrahState> {
  final HajjUmrahRepository repository;

  HajjUmrahCubit(this.repository) : super(HajjUmrahInitial());

  Future<void> loadUmrahGuide() async {
    emit(HajjUmrahLoading());
    try {
      final steps = await repository.getUmrahSteps();
      final progressId = await repository.getProgress('umrah');
      emit(HajjUmrahLoaded(steps: steps, type: 'umrah', lastCompletedId: progressId));
    } catch (e) {
      emit(HajjUmrahError(e.toString()));
    }
  }

  Future<void> loadHajjGuide() async {
    emit(HajjUmrahLoading());
    try {
      final steps = await repository.getHajjSteps();
      final progressId = await repository.getProgress('hajj');
      emit(HajjUmrahLoaded(steps: steps, type: 'hajj', lastCompletedId: progressId));
    } catch (e) {
      emit(HajjUmrahError(e.toString()));
    }
  }

  Future<void> markStepComplete(String type, String stepId) async {
    await repository.saveProgress(type, stepId);
    if (state is HajjUmrahLoaded) {
      final currentState = state as HajjUmrahLoaded;
      emit(currentState.copyWith(lastCompletedId: stepId));
    }
  }

  /// Calculates progress percentage
  double getProgressPercentage() {
    if (state is HajjUmrahLoaded) {
      final s = state as HajjUmrahLoaded;
      if (s.lastCompletedId == null) return 0.0;
      
      final index = s.steps.indexWhere((step) => step.id == s.lastCompletedId);
      if (index == -1) return 0.0;
      
      return (index + 1) / s.steps.length;
    }
    return 0.0;
  }
}
