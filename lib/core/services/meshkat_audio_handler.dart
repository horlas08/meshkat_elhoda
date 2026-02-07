import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MeshkatAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  bool _isCompleted = false;

  // Streams for position and duration
  Stream<Duration> get playerPositionStream => _player.positionStream;
  Stream<Duration?> get playerDurationStream => _player.durationStream;

  MeshkatAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isCompleted = true;
        // Don't automatically stop, let the UI or logic decide,
        // but for Athan we might want to stop.
        // For Quran, we might want to play next ayah.
        // Existing QuranAudioHandler logic:
        // if (state.processingState == ProcessingState.completed) { _isCompleted = true; print('🎵 Playback completed'); }
        // Existing AthanAudioHandler logic:
        // if (state.processingState == ProcessingState.completed) { stop(); }

        // We need to know what we are playing to decide.
        // We can check mediaItem extras or id.
        final currentId = mediaItem.value?.id ?? '';
        if (currentId.startsWith('assets/') || currentId.contains('athan')) {
          stop();
        }
      } else if (state.processingState == ProcessingState.ready) {
        _isCompleted = false;
      }
    });
  }

  // --- Quran Methods ---

  Future<void> loadAyah({
    required String audioUrl,
    required String ayahText,
    required String surahName,
    required int ayahNumber,
  }) async {
    try {
      final item = MediaItem(
        id: audioUrl,
        title: 'سورة $surahName - آية $ayahNumber',
        artist: 'القرآن الكريم',
        extras: {'ayahText': ayahText, 'type': 'quran'},
      );

      await updateMediaItem(item);
      await _player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));

      _isCompleted = false;
    } catch (e) {
      print('❌ Error loading ayah: $e');
      rethrow;
    }
  }

  Future<void> replay() async {
    try {
      await _player.seek(Duration.zero);
      await _player.play();
      _isCompleted = false;
    } catch (e) {
      print('❌ Error replaying audio: $e');
      rethrow;
    }
  }

  // --- Athan Methods ---

  Future<void> playAthan(String audioPath) async {
    try {
      final finalPath = audioPath.startsWith('assets/')
          ? audioPath
          : 'assets/$audioPath';

      // Prevent reloading if already playing the same athan
      if (_player.playing && mediaItem.value?.id == finalPath) {
        print('⚠️ Already playing this Athan, ignoring request.');
        return;
      }

      // Stop current playback to avoid "Loading interrupted"
      if (_player.playing) {
        await _player.stop();
      }

      final item = MediaItem(
        id: finalPath,
        title: 'أذان الصلاة',
        artist: 'المؤذن',
        extras: {'type': 'athan'},
      );

      await updateMediaItem(item);

      // Small delay to ensure state is clean
      await Future.delayed(const Duration(milliseconds: 100));

      await _player.setAudioSource(AudioSource.asset(finalPath));
      await _player.play();
    } catch (e) {
      if (e.toString().contains('Loading interrupted')) {
        print('⚠️ Loading interrupted, retrying...');
        // Optional: Retry logic could go here, but usually it's because of rapid calls.
        // We'll just log it for now as the "stop" above should handle most cases.
      }
      print('❌ Error in MeshkatAudioHandler (Athan): $e');
      // Don't rethrow to avoid crashing the isolate loop if multiple come in
    }
  }

  // --- Base Methods ---

  @override
  Future<void> play() async {
    if (_isCompleted) {
      await replay();
    } else {
      await _player.play();
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    _isCompleted = false;
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _isCompleted = false;
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        if (_isCompleted)
          MediaControl.play
        else if (_player.playing)
          MediaControl.pause
        else
          MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }
}
