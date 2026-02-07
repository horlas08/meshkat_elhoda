import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meshkat_elhoda/core/services/quran_audio_services.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal();

  late AudioPlayer _audioPlayer;
  late QuranAudioService _quranAudioService;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isPlaying {
    if (!_isInitialized) return false;
    return _audioPlayer.playing;
  }

  Stream<bool> get playingStream {
    if (!_isInitialized) return Stream.value(false);
    return _audioPlayer.playingStream;
  }

  Stream<Duration> get positionStream {
    if (!_isInitialized) return Stream.value(Duration.zero);
    return _audioPlayer.positionStream;
  }

  Stream<Duration?> get durationStream {
    if (!_isInitialized) return Stream.value(null);
    return _audioPlayer.durationStream;
  }

  Duration get position {
    if (!_isInitialized) return Duration.zero;
    return _audioPlayer.position;
  }

  Duration? get duration {
    if (!_isInitialized) return null;
    return _audioPlayer.duration;
  }

  AudioTrack? _currentTrack;
  AudioTrack? get currentTrack => _currentTrack;

  List<AudioTrack> _playlist = [];
  List<AudioTrack> get playlist => _playlist;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Future<void> initialize() async {
    try {
      if (_isInitialized) {
        log('⚠️ Audio player already initialized');
        return;
      }
      _audioPlayer = AudioPlayer();
      _quranAudioService = QuranAudioService();
      _isInitialized = true;
      log('✅ Audio player initialized');
    } catch (e) {
      log('❌ Error initializing audio player: $e');
      rethrow;
    }
  }

  Future<void> playTrack(AudioTrack track, {int retryCount = 0}) async {
    try {
      if (!isInitialized) {
        await initialize();
      }

      _currentTrack = track;

      log('⏳ Loading: ${track.surahName} (attempt ${retryCount + 1})');

      // تحديث الـ Media Item في الخدمة الخلفية (non-blocking)
      try {
        // ابدأ تحميل الخلفية دون انتظار
        _quranAudioService
            .loadAyah(
              audioUrl: track.audioUrl,
              ayahText: track.surahName,
              surahName: track.surahName,
              ayahNumber: int.tryParse(track.surahNumber) ?? 1,
            )
            .onError((error, stackTrace) {
              log('⚠️ Background service error: $error');
            });
      } catch (e) {
        log('⚠️ Error starting background service: $e');
      }

      // تشغيل الصوت محلياً مع timeout
      try {
        await _audioPlayer
            .setUrl(track.audioUrl)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => throw Exception('Audio URL loading timeout'),
            );
        await _audioPlayer.play();
        // انتظر حتى تتحدث duration فعلاً
        int attempts = 0;
        while (attempts < 30 &&
            (duration == null || duration == Duration.zero)) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
        log('▶️ Playing: ${track.surahName} - ${track.reciterName}');
        log('🔎 duration after play: ${duration}');
      } catch (audioError) {
        log('⚠️ Audio loading error: $audioError');
        // إعادة المحاولة مرة واحدة
        if (retryCount < 1) {
          log('🔄 Retrying to play track...');
          await Future.delayed(const Duration(seconds: 1));
          return playTrack(track, retryCount: retryCount + 1);
        } else {
          throw audioError;
        }
      }
    } catch (e) {
      log('❌ Error playing track: $e');
      rethrow;
    }
  }

  Future<void> playPlaylist(
    List<AudioTrack> tracks, [
    int startIndex = 0,
  ]) async {
    try {
      if (!isInitialized) {
        await initialize();
      }

      _playlist = tracks;
      _currentIndex = startIndex;

      if (_playlist.isNotEmpty) {
        await playTrack(_playlist[_currentIndex]);
      }
    } catch (e) {
      log('❌ Error playing playlist: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      if (!_isInitialized) return;
      await _audioPlayer.pause();
      try {
        await _quranAudioService.pause();
      } catch (e) {
        log('⚠️ Error pausing background service: $e');
      }
      log('⏸️ Paused');
    } catch (e) {
      log('❌ Error pausing: $e');
      rethrow;
    }
  }

  Future<void> resume() async {
    try {
      if (!_isInitialized) return;
      await _audioPlayer.play();
      try {
        await _quranAudioService.play();
      } catch (e) {
        log('⚠️ Error resuming background service: $e');
      }
      log('▶️ Resumed');
    } catch (e) {
      log('❌ Error resuming: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      if (!_isInitialized) return;
      await _audioPlayer.stop();
      await _quranAudioService.stop();
      _currentTrack = null;
      log('⏹️ Stopped');
    } catch (e) {
      log('❌ Error stopping: $e');
      rethrow;
    }
  }

  Future<void> seek(Duration position) async {
    try {
      if (!_isInitialized) return;
      await _audioPlayer.seek(position);
      try {
        await _quranAudioService.seek(position);
      } catch (e) {
        log('⚠️ Error seeking in background service: $e');
      }
      log('⏩ Seeked to: ${position.inSeconds}s');
    } catch (e) {
      log('❌ Error seeking: $e');
      rethrow;
    }
  }

  Future<void> nextTrack() async {
    try {
      if (_playlist.isEmpty) return;

      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      await playTrack(_playlist[_currentIndex]);
      log('⏭️ Next track: ${_playlist[_currentIndex].surahName}');
    } catch (e) {
      log('❌ Error playing next track: $e');
      rethrow;
    }
  }

  Future<void> previousTrack() async {
    try {
      if (_playlist.isEmpty) return;

      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _playlist.length - 1;
      }

      await playTrack(_playlist[_currentIndex]);
      log('⏮️ Previous track: ${_playlist[_currentIndex].surahName}');
    } catch (e) {
      log('❌ Error playing previous track: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      if (!_isInitialized) {
        log('⚠️ Audio player not initialized, skipping dispose');
        return;
      }
      await _audioPlayer.dispose();
      await _quranAudioService.stop();
      _currentTrack = null;
      _playlist = [];
      _isInitialized = false;
      log('🔌 Audio player disposed');
    } catch (e) {
      log('❌ Error disposing audio player: $e');
      rethrow;
    }
  }

  // Stream-based listeners
  void Function()? _onPlayStateChanged;

  void onPlayStateChanged(void Function() callback) {
    _onPlayStateChanged = callback;
    _audioPlayer.playingStream.listen((_) {
      _onPlayStateChanged?.call();
    });
  }
}
