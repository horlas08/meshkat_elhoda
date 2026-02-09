import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/azkar/domain/usecases/get_allah_names.dart';
import 'package:meshkat_elhoda/features/azkar/domain/usecases/get_azkar_audio.dart';
import 'package:meshkat_elhoda/features/azkar/domain/usecases/get_azkar_categories.dart';
import 'package:meshkat_elhoda/features/azkar/domain/usecases/get_azkar_items.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_state.dart';

class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  final GetAzkarCategories getAzkarCategories;
  final GetAzkarItems getAzkarItems;
  final GetAzkarAudio getAzkarAudio;
  final GetAllahNames getAllahNames;

  AzkarBloc({
    required this.getAzkarCategories,
    required this.getAzkarItems,
    required this.getAzkarAudio,
    required this.getAllahNames,
  }) : super(const AzkarInitial()) {
    on<FetchAzkarCategories>(_onFetchAzkarCategories);
    on<FetchAzkarItems>(_onFetchAzkarItems);
    on<FetchAllahNames>(_onFetchAllahNames);
    on<PlayAzkarAudio>(_onPlayAzkarAudio);
  }

  Future<void> _onFetchAzkarCategories(
    FetchAzkarCategories event,
    Emitter<AzkarState> emit,
  ) async {
    emit(const AzkarLoading());

    final result = await getAzkarCategories(event.languageCode);

    result.fold(
      (failure) => emit(AzkarError(failure.message)),
      (categories) => emit(AzkarCategoriesLoaded(categories)),
    );
  }

  Future<void> _onFetchAzkarItems(
    FetchAzkarItems event,
    Emitter<AzkarState> emit,
  ) async {
    emit(const AzkarLoading());

    final result = await getAzkarItems(event.chapterId, event.languageCode);

    result.fold(
      (failure) => emit(AzkarError(failure.message)),
      (items) => emit(AzkarItemsLoaded(items)),
    );
  }

  Future<void> _onFetchAllahNames(
    FetchAllahNames event,
    Emitter<AzkarState> emit,
  ) async {
    emit(const AzkarLoading());

    final result = await getAllahNames();

    result.fold(
      (failure) => emit(AzkarError(failure.message)),
      (names) => emit(AllahNamesLoaded(names)),
    );
  }

  Future<void> _onPlayAzkarAudio(
    PlayAzkarAudio event,
    Emitter<AzkarState> emit,
  ) async {
    final result = await getAzkarAudio(event.azkarId);

    result.fold(
      (failure) => emit(AzkarError(failure.message)),
      (audioUrl) => emit(AzkarAudioLoaded(audioUrl)),
    );
  }
}
