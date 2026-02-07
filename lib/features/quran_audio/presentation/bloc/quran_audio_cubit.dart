import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/audio_player/audio_player_service.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/radio_station.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/downloaded_audio.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/add_to_recently_played.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_radio_stations.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_reciters.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_surahs.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/save_favorite_reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/download_surah.dart';

part 'quran_audio_event.dart';
part 'quran_audio_state.dart';

class QuranAudioBloc extends Bloc<QuranAudioEvent, QuranAudioState> {
  final GetReciters getReciters;
  final GetSurahs getSurahs;
  final GetRadioStations getRadioStations;
  final GetAudioTrack getAudioTrack;
  final SaveFavoriteReciter saveFavoriteReciter;
  final AddToRecentlyPlayed addToRecentlyPlayed;
  final DownloadSurah downloadSurah;
  final AudioPlayerService audioPlayerService;

  List<Reciter> _allReciters = [];
  List<Surah> _allSurahs = [];
  Reciter? _selectedReciter;

  StreamSubscription<PlaybackState>? _playbackStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  QuranAudioBloc({
    required this.getReciters,
    required this.getSurahs,
    required this.getRadioStations,
    required this.getAudioTrack,
    required this.saveFavoriteReciter,
    required this.addToRecentlyPlayed,
    required this.downloadSurah,
    required this.audioPlayerService,
  }) : super(const RecitersInitial()) {
    on<LoadRecitersEvent>(_onLoadReciters);
    on<SearchRecitersEvent>(_onSearchReciters);
    on<SelectReciterEvent>(_onSelectReciter);
    on<LoadSurahsEvent>(_onLoadSurahs);
    on<LoadRadioStationsEvent>(_onLoadRadioStations);
    on<PlayTrackEvent>(_onPlayTrack);
    on<LoadPlaylistEvent>(_onLoadPlaylist);
    on<PlayPlaylistEvent>(_onPlayPlaylist);
    on<PauseAudioEvent>(_onPauseAudio);
    on<ResumeAudioEvent>(_onResumeAudio);
    on<StopAudioEvent>(_onStopAudio);
    on<SeekAudioEvent>(_onSeekAudio);
    on<NextTrackEvent>(_onNextTrack);
    on<PreviousTrackEvent>(_onPreviousTrack);
    on<ReplayAudioEvent>(_onReplayAudio);
    on<SaveFavoriteReciterEvent>(_onSaveFavoriteReciter);
    on<AddToRecentlyPlayedEvent>(_onAddToRecentlyPlayed);
    on<UpdatePositionEvent>(_onUpdatePosition);
    on<DownloadSurahEvent>(_onDownloadSurah);
    on<PlayOfflineTrackEvent>(_onPlayOfflineTrack);

    // إعداد المستمعين لتحديثات التشغيل
    _setupPositionListener();
  }

  // ... existing methods ...

  Future<void> _onDownloadSurah(
    DownloadSurahEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      log('📥 Downloading surah: ${event.surah.name}');
      final result = await downloadSurah(event.surah, event.reciter);

      result.fold(
        (failure) {
          log('❌ Download failed: ${failure.message}');
          // Optionally emit error state or show snackbar via listener
        },
        (_) {
          log('✅ Download completed: ${event.surah.name}');
          // Optionally emit success state
        },
      );
    } catch (e) {
      log('❌ Exception downloading surah: $e');
    }
  }

  Future<void> _onPlayOfflineTrack(
    PlayOfflineTrackEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      log('▶️ Playing offline track: ${event.audio.surahName}');

      final track = AudioTrack(
        surahNumber: event.audio.surahNumber.toString(),
        surahName: event.audio.surahName,
        reciterName: event.audio.reciterName,
        audioUrl: event.audio.localPath, // Local path
        ayahCount: 0, // Not available in offline model
      );

      emit(AudioPlayerLoading());

      // Use playTrack but we might need to tell AudioPlayerService it's a file
      // Assuming AudioPlayerService handles file:// or paths correctly
      await audioPlayerService.playTrack(track);

      if (audioPlayerService.isPlaying) {
        emit(
          AudioPlayerPlaying(
            track: track,
            position: audioPlayerService.position,
            duration: audioPlayerService.duration ?? Duration.zero,
            mode: AudioMode.offline,
          ),
        );
      } else {
        throw Exception('Failed to start offline playback');
      }
    } catch (e) {
      log('❌ Error playing offline track: $e');
      emit(AudioPlayerError(message: 'Failed to play offline track: $e'));
    }
  }

  // ... rest of the file ...

  // داخل QuranAudioBloc class
  AudioTrack? getCurrentTrack() {
    try {
      return audioPlayerService.currentTrack;
    } catch (e) {
      log('❌ Error getting current track: $e');
      return null;
    }
  }

  List<AudioTrack> getCurrentPlaylist() {
    try {
      return audioPlayerService.playlist;
    } catch (e) {
      log('❌ Error getting current playlist: $e');
      return [];
    }
  }

  int getCurrentTrackIndex() {
    try {
      final playlist = audioPlayerService.playlist;
      final currentTrack = audioPlayerService.currentTrack;

      if (playlist.isEmpty || currentTrack == null) return -1;

      final index = playlist.indexWhere(
        (track) => track.audioUrl == currentTrack.audioUrl,
      );
      return index;
    } catch (e) {
      log('❌ Error getting current track index: $e');
      return -1;
    }
  }

  /// الاستماع إلى تحديثات الموضع من خدمة التشغيل - مع throttle لتجنب إعادة البناء المتكررة
  void _setupPositionListener() {
    DateTime? lastEmit;
    const throttleDuration = Duration(milliseconds: 250);

    _positionSubscription = audioPlayerService.positionStream.listen((
      position,
    ) {
      final now = DateTime.now();

      if (lastEmit == null || now.difference(lastEmit!) >= throttleDuration) {
        lastEmit = now;

        // تحديث Duration أيضاً
        if (state is AudioPlayerPlaying) {
          final currentState = state as AudioPlayerPlaying;
          final newDuration =
              audioPlayerService.duration ?? currentState.duration;

          // التحقق مما إذا وصلنا لنهاية المقطع
          if (newDuration.inSeconds > 0 &&
              position.inSeconds >= newDuration.inSeconds - 1) {
            // إشعار اكتمال التشغيل
            add(UpdatePositionEvent(position: newDuration));
          } else {
            emit(
              AudioPlayerPlaying(
                track: currentState.track,
                position: position,
                duration: newDuration,
              ),
            );
          }
        } else if (state is AudioPlayerPaused) {
          final currentState = state as AudioPlayerPaused;
          final newDuration =
              audioPlayerService.duration ?? currentState.duration;

          emit(
            AudioPlayerPaused(
              track: currentState.track,
              position: position,
              duration: newDuration,
            ),
          );
        }
      }
    });

    // الاستماع لتحديثات المدة
    _durationSubscription = audioPlayerService.durationStream.listen((
      duration,
    ) {
      if (duration != null) {
        // تحديث الحالة إذا كانت المدة متاحة
        if (state is AudioPlayerPlaying) {
          final currentState = state as AudioPlayerPlaying;
          emit(
            AudioPlayerPlaying(
              track: currentState.track,
              position: currentState.position,
              duration: duration,
            ),
          );
        } else if (state is AudioPlayerPaused) {
          final currentState = state as AudioPlayerPaused;
          emit(
            AudioPlayerPaused(
              track: currentState.track,
              position: currentState.position,
              duration: duration,
            ),
          );
        }
      }
    });
  }

  /// ✅ معالجة إعادة التشغيل
  Future<void> _onReplayAudio(
    ReplayAudioEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      log('🔄 ReplayAudioEvent received');

      // إذا كان هناك مسار نشط، أعد تشغيله من البداية
      final currentTrack = audioPlayerService.currentTrack;
      if (currentTrack != null) {
        emit(AudioPlayerLoading());

        await audioPlayerService.seek(Duration.zero);
        await audioPlayerService.resume();

        // انتظر حتى يبدأ التشغيل
        int attempts = 0;
        while (attempts < 30 && !audioPlayerService.isPlaying) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }

        if (audioPlayerService.isPlaying) {
          emit(
            AudioPlayerPlaying(
              track: currentTrack,
              position: Duration.zero,
              duration: audioPlayerService.duration ?? Duration.zero,
            ),
          );
          log('🔁 Track replayed: ${currentTrack.surahName}');
        } else {
          throw Exception('فشل إعادة التشغيل');
        }
      } else if (state is AudioPlayerCompleted) {
        // إذا كان في حالة اكتمال، أعد تشغيل المسار الأخير
        final completedState = state as AudioPlayerCompleted;
        emit(AudioPlayerLoading());

        await audioPlayerService.playTrack(completedState.track);

        int attempts = 0;
        while (attempts < 30 && !audioPlayerService.isPlaying) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }

        if (audioPlayerService.isPlaying) {
          emit(
            AudioPlayerPlaying(
              track: completedState.track,
              position: Duration.zero,
              duration: audioPlayerService.duration ?? Duration.zero,
            ),
          );
          log('🔁 Completed track replayed: ${completedState.track.surahName}');
        } else {
          throw Exception('فشل إعادة التشغيل');
        }
      } else {
        log('⚠️ No track to replay');
      }
    } catch (e) {
      log('❌ Error replaying audio: $e');
      emit(AudioPlayerError(message: 'Failed to replay: $e'));
    }
  }

  Future<void> _onLoadReciters(
    LoadRecitersEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      emit(const RecitersLoading());

      final result = await getReciters(event.language);

      result.fold(
        (error) {
          log('❌ Error loading reciters: ${error.message}');
          emit(RecitersError(message: error.message));
        },
        (reciters) {
          _allReciters = reciters;
          log('✅ Loaded ${reciters.length} reciters');
          emit(RecitersLoaded(reciters: reciters));
        },
      );
    } catch (e) {
      log('❌ Exception loading reciters: $e');
      emit(RecitersError(message: 'Failed to load reciters: $e'));
    }
  }

  void _onSearchReciters(
    SearchRecitersEvent event,
    Emitter<QuranAudioState> emit,
  ) {
    try {
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(RecitersLoaded(reciters: _allReciters));
      } else {
        final filtered = _allReciters
            .where(
              (reciter) =>
                  reciter.name.toLowerCase().contains(query) ||
                  reciter.rewaya.toLowerCase().contains(query),
            )
            .toList();

        log('🔍 Filtered to ${filtered.length} reciters for query: "$query"');
        emit(
          RecitersLoaded(reciters: _allReciters, filteredReciters: filtered),
        );
      }
    } catch (e) {
      log('❌ Error searching reciters: $e');
    }
  }

  void _onSelectReciter(
    SelectReciterEvent event,
    Emitter<QuranAudioState> emit,
  ) {
    _selectedReciter = event.reciter;
    log('✅ Selected reciter: ${event.reciter.name}');
  }

  Future<void> _onLoadSurahs(
    LoadSurahsEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      emit(const SurahsLoading());

      final result = await getSurahs();

      result.fold(
        (error) {
          log('❌ Error loading surahs: ${error.message}');
          emit(SurahsError(message: error.message));
        },
        (surahs) {
          _allSurahs = surahs;
          _selectedReciter = event.reciter;
          log('✅ Loaded ${surahs.length} surahs');
          emit(SurahsLoaded(surahs: surahs, reciter: event.reciter));
        },
      );
    } catch (e) {
      log('❌ Exception loading surahs: $e');
      emit(SurahsError(message: 'Failed to load surahs: $e'));
    }
  }

  Future<void> _onLoadRadioStations(
    LoadRadioStationsEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      emit(const RadioStationsLoading());

      final result = await getRadioStations();

      result.fold(
        (error) {
          log('❌ Error loading radio stations: ${error.message}');
          emit(RadioStationsError(message: error.message));
        },
        (stations) {
          log('✅ Loaded ${stations.length} radio stations');
          emit(RadioStationsLoaded(stations: stations));
        },
      );
    } catch (e) {
      log('❌ Exception loading radio stations: $e');
      emit(RadioStationsError(message: 'Failed to load radio stations: $e'));
    }
  }

  Future<void> _onPlayTrack(
    PlayTrackEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      log('🟡 [BLOC] PlayTrackEvent received for: ${event.track.surahName}');

      // إصدار حالة البداية فوراً - AudioPlayerLoading
      emit(AudioPlayerLoading());

      await audioPlayerService.playTrack(event.track);
      log(
        '🟡 [BLOC] playTrack finished, isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
      );

      await addToRecentlyPlayed(event.track);

      int attempts = 0;
      // انتظر حتى يبدأ الصوت فعلياً (isPlaying == true)
      while (attempts < 30 && !audioPlayerService.isPlaying) {
        log(
          '🟡 [BLOC] Waiting for isPlaying... attempt=$attempts, isPlaying=${audioPlayerService.isPlaying}',
        );
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      log(
        '🟡 [BLOC] After waiting: isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
      );

      if (audioPlayerService.isPlaying) {
        log(
          '🔔 Emit AudioPlayerPlaying: track=${event.track.surahName}, position=${audioPlayerService.position}, duration=${audioPlayerService.duration}',
        );
        emit(
          AudioPlayerPlaying(
            track: event.track,
            position: audioPlayerService.position,
            duration: audioPlayerService.duration ?? Duration.zero,
          ),
        );
        log('▶️ Playing track: ${event.track.surahName}');
      } else {
        log(
          '🔴 [BLOC] Failed to start playback, isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
        );
        throw Exception('فشل بدء التشغيل');
      }
    } catch (e) {
      log('❌ Error playing track: $e');
      emit(AudioPlayerError(message: 'Failed to play track: $e'));
    }
  }

  /// تحميل الـ playlist دون تشغيل - للإعداد الأولي
  Future<void> _onLoadPlaylist(
    LoadPlaylistEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      log(
        '📋 Loading playlist with ${event.playlist.length} tracks (no auto-play)',
      );

      // فقط نحفظ الـ playlist في الحالة بدون تشغيل
      final track = event.playlist[event.startIndex];

      emit(
        AudioPlayerPaused(
          track: track,
          position: Duration.zero,
          duration: Duration.zero,
        ),
      );

      log('✅ Playlist loaded successfully (ready for playback)');
    } catch (e) {
      log('❌ Error loading playlist: $e');
      emit(AudioPlayerError(message: 'Failed to load playlist: $e'));
    }
  }

  Future<void> _onPlayPlaylist(
    PlayPlaylistEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      log(
        '🟡 [BLOC] PlayPlaylistEvent received, playlist length: ${event.playlist.length}, startIndex: ${event.startIndex}',
      );

      // إصدار حالة البداية فوراً
      emit(AudioPlayerLoading());

      await audioPlayerService.playPlaylist(event.playlist, event.startIndex);
      final track = event.playlist[event.startIndex];
      log(
        '🟡 [BLOC] playPlaylist finished, isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
      );

      int attempts = 0;
      while (attempts < 30 && !audioPlayerService.isPlaying) {
        log(
          '🟡 [BLOC] Waiting for isPlaying... attempt=$attempts, isPlaying=${audioPlayerService.isPlaying}',
        );
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      log(
        '🟡 [BLOC] After waiting: isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
      );

      if (audioPlayerService.isPlaying) {
        log(
          '🔔 Emit AudioPlayerPlaying: track=${track.surahName}, position=${audioPlayerService.position}, duration=${audioPlayerService.duration}',
        );
        emit(
          AudioPlayerPlaying(
            track: track,
            position: audioPlayerService.position,
            duration: audioPlayerService.duration ?? Duration.zero,
          ),
        );
        log(
          '▶️ Playing playlist: ${event.playlist.length} tracks from index ${event.startIndex}',
        );
      } else {
        log(
          '🔴 [BLOC] Failed to start playlist playback, isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
        );
        throw Exception('فشل بدء التشغيل');
      }
    } catch (e) {
      log('❌ Error playing playlist: $e');
      emit(AudioPlayerError(message: 'جاري تحميل الصوت... يرجى الانتظار'));

      // محاولة أخرى بعد تأخير
      await Future.delayed(const Duration(seconds: 2));
      try {
        await audioPlayerService.playPlaylist(event.playlist, event.startIndex);
        final track = event.playlist[event.startIndex];

        int attempts = 0;
        while (attempts < 30 && !audioPlayerService.isPlaying) {
          log(
            '🟡 [BLOC] Waiting for isPlaying (retry)... attempt=$attempts, isPlaying=${audioPlayerService.isPlaying}',
          );
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
        log(
          '🟡 [BLOC] After waiting (retry): isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
        );

        if (audioPlayerService.isPlaying) {
          log(
            '🔔 Emit AudioPlayerPlaying (retry): track=${track.surahName}, position=${audioPlayerService.position}, duration=${audioPlayerService.duration}',
          );
          emit(
            AudioPlayerPlaying(
              track: track,
              position: audioPlayerService.position,
              duration: audioPlayerService.duration ?? Duration.zero,
            ),
          );
          log('▶️ Retry successful: Playing playlist');
        } else {
          log(
            '🔴 [BLOC] Retry failed, isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
          );
          throw Exception('فشل بدء التشغيل');
        }
      } catch (retryError) {
        log('❌ Retry failed: $retryError');
        emit(
          AudioPlayerError(message: 'خطأ في التشغيل. تأكد من اتصال الإنترنت'),
        );
      }
    }
  }

  Future<void> _onPauseAudio(
    PauseAudioEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      await audioPlayerService.pause();

      if (state is AudioPlayerPlaying) {
        final currentState = state as AudioPlayerPlaying;
        emit(
          AudioPlayerPaused(
            track: currentState.track,
            position: audioPlayerService.position,
            duration: currentState.duration,
          ),
        );
      }

      log('⏸️ Audio paused');
    } catch (e) {
      log('❌ Error pausing audio: $e');
      emit(AudioPlayerError(message: 'Failed to pause audio: $e'));
    }
  }

  Future<void> _onResumeAudio(
    ResumeAudioEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      log('🟡 [BLOC] ResumeAudioEvent received');
      if (state is AudioPlayerPaused) {
        final currentState = state as AudioPlayerPaused;

        if (audioPlayerService.isPlaying ||
            audioPlayerService.currentTrack != null) {
          // إصدار حالة Playing فوراً قبل الاستدعاء
          emit(
            AudioPlayerPlaying(
              track: currentState.track,
              position: currentState.position,
              duration: currentState.duration,
            ),
          );

          await audioPlayerService.resume();
          int attempts = 0;
          while (attempts < 30 && !audioPlayerService.isPlaying) {
            log(
              '🟡 [BLOC] Waiting for isPlaying (resume)... attempt=$attempts, isPlaying=${audioPlayerService.isPlaying}',
            );
            await Future.delayed(const Duration(milliseconds: 100));
            attempts++;
          }
          log(
            '🟡 [BLOC] After waiting (resume): isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
          );
          emit(
            AudioPlayerPlaying(
              track: currentState.track,
              position: audioPlayerService.position,
              duration: audioPlayerService.duration ?? Duration.zero,
            ),
          );
          log('▶️ Audio resumed');
        } else {
          emit(AudioPlayerLoading());
          log(
            '📋 First time play - loading and playing track: ${currentState.track.surahName}',
          );
          await audioPlayerService.playTrack(currentState.track);
          int attempts = 0;
          while (attempts < 30 && !audioPlayerService.isPlaying) {
            log(
              '🟡 [BLOC] Waiting for isPlaying (first play)... attempt=$attempts, isPlaying=${audioPlayerService.isPlaying}',
            );
            await Future.delayed(const Duration(milliseconds: 100));
            attempts++;
          }
          log(
            '🟡 [BLOC] After waiting (first play): isPlaying=${audioPlayerService.isPlaying}, duration=${audioPlayerService.duration}',
          );
          emit(
            AudioPlayerPlaying(
              track: currentState.track,
              position: audioPlayerService.position,
              duration: audioPlayerService.duration ?? Duration.zero,
            ),
          );
          log('▶️ Track started playing');
        }
      }
    } catch (e) {
      log('❌ Error resuming audio: $e');
      emit(AudioPlayerError(message: 'Failed to resume audio: $e'));
    }
  }

  Future<void> _onStopAudio(
    StopAudioEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      await audioPlayerService.stop();
      emit(const AudioPlayerStopped());
      log('⏹️ Audio stopped');
    } catch (e) {
      log('❌ Error stopping audio: $e');
      emit(AudioPlayerError(message: 'Failed to stop audio: $e'));
    }
  }

  Future<void> _onSeekAudio(
    SeekAudioEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      await audioPlayerService.seek(event.position);

      if (state is AudioPlayerPlaying) {
        final currentState = state as AudioPlayerPlaying;
        emit(
          AudioPlayerPlaying(
            track: currentState.track,
            position: event.position,
            duration: currentState.duration,
          ),
        );
      }

      log('⏩ Seeked to ${event.position.inSeconds}s');
    } catch (e) {
      log('❌ Error seeking audio: $e');
      emit(AudioPlayerError(message: 'Failed to seek: $e'));
    }
  }

  Future<void> _onNextTrack(
    NextTrackEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      await audioPlayerService.nextTrack();

      if (audioPlayerService.currentTrack != null) {
        emit(
          AudioPlayerPlaying(
            track: audioPlayerService.currentTrack!,
            position: Duration.zero,
            duration: audioPlayerService.duration ?? Duration.zero,
          ),
        );
      }

      log('⏭️ Next track');
    } catch (e) {
      log('❌ Error playing next track: $e');
      emit(AudioPlayerError(message: 'Failed to play next track: $e'));
    }
  }

  Future<void> _onPreviousTrack(
    PreviousTrackEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      await audioPlayerService.previousTrack();

      if (audioPlayerService.currentTrack != null) {
        emit(
          AudioPlayerPlaying(
            track: audioPlayerService.currentTrack!,
            position: Duration.zero,
            duration: audioPlayerService.duration ?? Duration.zero,
          ),
        );
      }

      log('⏮️ Previous track');
    } catch (e) {
      log('❌ Error playing previous track: $e');
      emit(AudioPlayerError(message: 'Failed to play previous track: $e'));
    }
  }

  Future<void> _onSaveFavoriteReciter(
    SaveFavoriteReciterEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      final result = await saveFavoriteReciter(event.reciter);

      result.fold(
        (error) {
          log('❌ Error saving favorite: ${error.message}');
        },
        (_) {
          log('❤️ Saved favorite reciter: ${event.reciter.name}');
        },
      );
    } catch (e) {
      log('❌ Exception saving favorite: $e');
    }
  }

  Future<void> _onAddToRecentlyPlayed(
    AddToRecentlyPlayedEvent event,
    Emitter<QuranAudioState> emit,
  ) async {
    try {
      final result = await addToRecentlyPlayed(event.track);

      result.fold(
        (error) {
          log('❌ Error adding to recently played: ${error.message}');
        },
        (_) {
          log('📝 Added to recently played: ${event.track.surahName}');
        },
      );
    } catch (e) {
      log('❌ Exception adding to recently played: $e');
    }
  }

  /// تحديث موضع التشغيل
  void _onUpdatePosition(
    UpdatePositionEvent event,
    Emitter<QuranAudioState> emit,
  ) {
    try {
      if (state is AudioPlayerPlaying) {
        final currentState = state as AudioPlayerPlaying;

        // التحقق مما إذا وصلنا لنهاية المقطع
        if (currentState.duration.inSeconds > 0 &&
            event.position.inSeconds >= currentState.duration.inSeconds - 1) {
          // الانتقال لحالة الاكتمال
          emit(
            AudioPlayerCompleted(
              track: currentState.track,
              duration: currentState.duration,
            ),
          );
          log('✅ Track completed: ${currentState.track.surahName}');
        } else {
          emit(
            AudioPlayerPlaying(
              track: currentState.track,
              position: event.position,
              duration: currentState.duration,
            ),
          );
        }
      } else if (state is AudioPlayerPaused) {
        final currentState = state as AudioPlayerPaused;
        emit(
          AudioPlayerPaused(
            track: currentState.track,
            position: event.position,
            duration: currentState.duration,
          ),
        );
      }
    } catch (e) {
      log('❌ Error updating position: $e');
    }
  }

  @override
  Future<void> close() async {
    await _playbackStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await audioPlayerService.dispose();
    return super.close();
  }
}
