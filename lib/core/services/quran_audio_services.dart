import 'package:audio_service/audio_service.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/services/meshkat_audio_handler.dart';

class QuranAudioService {
  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;
  QuranAudioService._internal();

  MeshkatAudioHandler get _handler {
    return getIt<AudioHandler>() as MeshkatAudioHandler;
  }

  Future<void> initialize() async {
    // No-op: Initialization is handled in main.dart
    print(
      '⚠️ QuranAudioService.initialize called but it is now handled in main.dart',
    );
  }

  Future<void> loadAyah({
    required String audioUrl,
    required String ayahText,
    required String surahName,
    int ayahNumber = 1,
  }) async {
    await _handler.loadAyah(
      audioUrl: audioUrl,
      ayahText: ayahText,
      surahName: surahName,
      ayahNumber: ayahNumber,
    );
    print('🔄 Ayah loaded successfully');
  }

  Future<void> play() async {
    return _handler.play();
  }

  Future<void> pause() async {
    return _handler.pause();
  }

  Future<void> stop() async {
    await _handler.stop();
  }

  Future<void> replay() async {
    await _handler.replay();
  }

  Future<void> seek(Duration position) async {
    return _handler.seek(position);
  }

  Stream<MediaItem?> get currentMediaItem => _handler.mediaItem;

  Stream<PlaybackState> get playbackState => _handler.playbackState;

  Stream<Duration> get position => _handler.playerPositionStream;

  Stream<Duration?> get duration => _handler.playerDurationStream;

  bool get isPlaying => _handler.playbackState.value.playing;

  bool get isCompleted {
    final state = _handler.playbackState.value;
    return state.processingState == AudioProcessingState.completed;
  }
}
