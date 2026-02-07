import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/khatmah_progress_entity.dart';
import '../../data/models/khatmah_progress_model.dart';
import '../../domain/usecases/get_user_khatmah_progress_usecase.dart';
import '../../domain/usecases/update_khatmah_progress_usecase.dart';
import '../../domain/usecases/get_page_details_usecase.dart';
import 'khatmah_event.dart';
import 'khatmah_state.dart';

class KhatmahBloc extends Bloc<KhatmahEvent, KhatmahState> {
  final GetUserKhatmahProgressUseCase getUserKhatmahProgress;
  final UpdateKhatmahProgressUseCase updateKhatmahProgress;
  final GetPageDetailsUseCase getPageDetails;
  final AudioPlayer _audioPlayer;

  KhatmahBloc({
    required this.getUserKhatmahProgress,
    required this.updateKhatmahProgress,
    required this.getPageDetails,
  }) : _audioPlayer = AudioPlayer(),
       super(KhatmahInitial()) {
    on<LoadKhatmah>(_onLoadKhatmah);
    on<UpdatePage>(_onUpdatePage);
    on<ToggleAudio>(_onToggleAudio);
    on<NextAyahAudio>(_onNextAyahAudio);
    on<PauseAudio>(_onPauseAudio);

    // Listen to player state to auto-advance
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        add(NextAyahAudio());
      }
    });
  }

  Future<void> _onLoadKhatmah(
    LoadKhatmah event,
    Emitter<KhatmahState> emit,
  ) async {
    emit(KhatmahLoading());
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const KhatmahError('User not authenticated'));
      return;
    }

    final result = await getUserKhatmahProgress(user.uid);
    await result.fold((failure) async => emit(KhatmahError(failure.message)), (
      progress,
    ) async {
      // Daily reset logic
      final now = DateTime.now();
      final lastReset = progress.lastDailyReset;
      final isDifferentDay =
          lastReset.year != now.year ||
          lastReset.month != now.month ||
          lastReset.day != now.day;

      KhatmahProgressEntity currentProgress = progress;

      if (isDifferentDay) {
        // Create new object manually since Entity doesn't have copyWith
        currentProgress = KhatmahProgressModel(
          currentPage: progress.currentPage,
          currentJuz: progress.currentJuz,
          currentHizb: progress.currentHizb,
          lastUpdated: progress.lastUpdated,
          dailyStartPage: progress.currentPage,
          lastDailyReset: now,
        );

        // Update remote
        await updateKhatmahProgress(user.uid, currentProgress);
      }

      // Fetch details for the current page
      final detailsResult = await getPageDetails(currentProgress.currentPage);
      detailsResult.fold(
        (failure) => emit(KhatmahError(failure.message)),
        (details) => emit(
          KhatmahReflecting(progress: currentProgress, pageDetails: details),
        ),
      );
    });
  }

  Future<void> _onUpdatePage(
    UpdatePage event,
    Emitter<KhatmahState> emit,
  ) async {
    // Logic to update page (e.g. from UI picker or completion)
    // For now, mostly used if we implemented a page picker or synced from reading view
  }

  Future<void> _onToggleAudio(
    ToggleAudio event,
    Emitter<KhatmahState> emit,
  ) async {
    if (state is! KhatmahReflecting) return;
    final currentState = state as KhatmahReflecting;

    if (currentState.isPlaying) {
      await _audioPlayer.pause();
      emit(currentState.copyWith(isPlaying: false));
    } else {
      await _playAyah(currentState.currentAyahIndex, currentState, emit);
    }
  }

  Future<void> _onNextAyahAudio(
    NextAyahAudio event,
    Emitter<KhatmahState> emit,
  ) async {
    if (state is! KhatmahReflecting) return;
    final currentState = state as KhatmahReflecting;

    final nextIndex = currentState.currentAyahIndex + 1;
    if (nextIndex < currentState.pageDetails.ayahs.length) {
      await _playAyah(nextIndex, currentState, emit);
    } else {
      // Stop at end of page
      await _audioPlayer.stop();
      emit(currentState.copyWith(isPlaying: false, currentAyahIndex: 0));
    }
  }

  Future<void> _onPauseAudio(
    PauseAudio event,
    Emitter<KhatmahState> emit,
  ) async {
    if (state is! KhatmahReflecting) return;
    await _audioPlayer.pause();
    emit((state as KhatmahReflecting).copyWith(isPlaying: false));
  }

  Future<void> _playAyah(
    int index,
    KhatmahReflecting currentState,
    Emitter<KhatmahState> emit,
  ) async {
    final ayahs = currentState.pageDetails.ayahs;
    if (index < 0 || index >= ayahs.length) return;

    final ayah = ayahs[index];
    // Fallback to audioSecondary if audio is empty?? API usually has one.
    // AyahEntity has 'audio'.
    // Note: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3'

    try {
      if (ayah.audio.isNotEmpty) {
        await _audioPlayer.setUrl(ayah.audio);
        await _audioPlayer.play();
        emit(currentState.copyWith(isPlaying: true, currentAyahIndex: index));
      }
    } catch (e) {
      // Handle error (maybe emit failure or toast?)
      print("Error playing audio: $e");
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
