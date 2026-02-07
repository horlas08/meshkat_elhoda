
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/hisn_chapter.dart';
import '../../domain/repositories/hisn_repository.dart';

// Events
abstract class HisnMuslimEvent extends Equatable {
  const HisnMuslimEvent();
  @override
  List<Object?> get props => [];
}

class LoadHisnChapters extends HisnMuslimEvent {}

// States
abstract class HisnMuslimState extends Equatable {
  const HisnMuslimState();
  @override
  List<Object?> get props => [];
}

class HisnMuslimInitial extends HisnMuslimState {}
class HisnMuslimLoading extends HisnMuslimState {}
class HisnMuslimLoaded extends HisnMuslimState {
  final List<HisnChapter> chapters;
  const HisnMuslimLoaded(this.chapters);
  @override
  List<Object?> get props => [chapters];
}
class HisnMuslimError extends HisnMuslimState {
  final String message;
  const HisnMuslimError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class HisnMuslimBloc extends Bloc<HisnMuslimEvent, HisnMuslimState> {
  final HisnMuslimRepository repository;

  HisnMuslimBloc({required this.repository}) : super(HisnMuslimInitial()) {
    on<LoadHisnChapters>((event, emit) async {
      emit(HisnMuslimLoading());
      final result = await repository.getChapters();
      result.fold(
        (failure) => emit(const HisnMuslimError("Failed to load Hisn al-Muslim chapters")),
        (chapters) => emit(HisnMuslimLoaded(chapters)),
      );
    });
  }
}
