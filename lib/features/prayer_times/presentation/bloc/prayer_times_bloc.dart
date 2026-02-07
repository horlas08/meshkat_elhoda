import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/usecases/get_cached_prayer_times.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/usecases/get_prayer_times.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/usecases/get_muezzins.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/usecases/manage_muezzin.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_event.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_state.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/muezzin.dart';

class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  final GetPrayerTimes getPrayerTimes;
  final GetCachedPrayerTimes getCachedPrayerTimes;
  final GetMuezzins getMuezzins;
  final GetSelectedMuezzinId getSelectedMuezzinId;
  final SaveSelectedMuezzinId saveSelectedMuezzinId;

  // Cache muezzins so they can be included when prayer times are loaded
  List<Muezzin> _cachedMuezzins = [];
  String? _cachedSelectedMuezzinId;

  PrayerTimesBloc({
    required this.getPrayerTimes,
    required this.getCachedPrayerTimes,
    required this.getMuezzins,
    required this.getSelectedMuezzinId,
    required this.saveSelectedMuezzinId,
  }) : super(PrayerTimesInitial()) {
    on<FetchPrayerTimes>(_onFetchPrayerTimes);
    on<LoadCachedPrayerTimes>(_onLoadCachedPrayerTimes);
    on<SwitchCalendarType>(_onSwitchCalendarType);
    on<LoadMuezzins>(_onLoadMuezzins);
    on<SetMuezzin>(_onSetMuezzin);
    on<ScheduleAthan>(_onScheduleAthan);

    add(LoadMuezzins());
  }

  Future<void> _onFetchPrayerTimes(
    FetchPrayerTimes event,
    Emitter<PrayerTimesState> emit,
  ) async {
    // Only emit loading if we don't have data already
    // Or if we have data but it's null (e.g. only muezzins loaded)
    final currentState = state;
    if (currentState is! PrayerTimesLoaded ||
        currentState.prayerTimes == null) {
      emit(PrayerTimesLoading());
    }

    final result = await getPrayerTimes(location: event.location);

    result.fold(
      (failure) {
        emit(PrayerTimesError(message: failure.message));
      },
      (prayerTimes) {
        emit(
          PrayerTimesLoaded(
            prayerTimes: prayerTimes,
            muezzins: _cachedMuezzins,
            selectedMuezzinId: _cachedSelectedMuezzinId,
          ),
        );
      },
    );
  }

  Future<void> _onLoadCachedPrayerTimes(
    LoadCachedPrayerTimes event,
    Emitter<PrayerTimesState> emit,
  ) async {
    final result = await getCachedPrayerTimes();

    result.fold(
      (failure) {
        // Silently fail, just keep initial state
      },
      (prayerTimes) {
        if (prayerTimes != null) {
          emit(
            PrayerTimesLoaded(
              prayerTimes: prayerTimes,
              isFromCache: true,
              muezzins: _cachedMuezzins,
              selectedMuezzinId: _cachedSelectedMuezzinId,
            ),
          );
        }
      },
    );
  }

  void _onSwitchCalendarType(
    SwitchCalendarType event,
    Emitter<PrayerTimesState> emit,
  ) {
    if (state is PrayerTimesLoaded) {
      final currentState = state as PrayerTimesLoaded;
      emit(currentState.copyWith(calendarType: event.type));
    }
  }

  Future<void> _onLoadMuezzins(
    LoadMuezzins event,
    Emitter<PrayerTimesState> emit,
  ) async {
    final muezzinsResult = await getMuezzins();
    final selectedIdResult = await getSelectedMuezzinId();

    muezzinsResult.fold((failure) => null, (muezzins) {
      String? selectedId;
      selectedIdResult.fold((failure) => null, (id) => selectedId = id);

      // Default to first muezzin if none selected
      if (selectedId == null && muezzins.isNotEmpty) {
        selectedId = muezzins.first.id;
        saveSelectedMuezzinId(selectedId!);
      }

      // Cache the muezzins and selected ID
      _cachedMuezzins = muezzins;
      _cachedSelectedMuezzinId = selectedId;

      if (state is PrayerTimesLoaded) {
        emit(
          (state as PrayerTimesLoaded).copyWith(
            muezzins: muezzins,
            selectedMuezzinId: selectedId,
          ),
        );
      } else {
        // If prayer times aren't loaded yet, emit loaded state with null prayerTimes
        // so that settings page can show muezzins
        emit(
          PrayerTimesLoaded(
            prayerTimes: null,
            muezzins: muezzins,
            selectedMuezzinId: selectedId,
          ),
        );
      }
    });
  }

  Future<void> _onSetMuezzin(
    SetMuezzin event,
    Emitter<PrayerTimesState> emit,
  ) async {
    await saveSelectedMuezzinId(event.muezzinId);
    if (state is PrayerTimesLoaded) {
      emit(
        (state as PrayerTimesLoaded).copyWith(
          selectedMuezzinId: event.muezzinId,
        ),
      );
    }
  }

  Future<void> _onScheduleAthan(
    ScheduleAthan event,
    Emitter<PrayerTimesState> emit,
  ) async {
    // Scheduling is handled by main.dart listener, but we can call repository if needed
    // await repository.scheduleAthan(event.prayerTimes);
  }
}
