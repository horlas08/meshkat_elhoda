part of 'quran_audio_cubit.dart';

abstract class QuranAudioState extends Equatable {
  const QuranAudioState();

  @override
  List<Object?> get props => [];
}

// Reciters States
class RecitersInitial extends QuranAudioState {
  const RecitersInitial();
}

class RecitersLoading extends QuranAudioState {
  const RecitersLoading();
}

class RecitersLoaded extends QuranAudioState {
  final List<Reciter> reciters;
  final List<Reciter> filteredReciters;

  const RecitersLoaded({
    required this.reciters,
    this.filteredReciters = const [],
  });

  @override
  List<Object?> get props => [reciters, filteredReciters];
}

class RecitersError extends QuranAudioState {
  final String message;

  const RecitersError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Surahs States
class SurahsInitial extends QuranAudioState {
  const SurahsInitial();
}

class SurahsLoading extends QuranAudioState {
  const SurahsLoading();
}

class SurahsLoaded extends QuranAudioState {
  final List<Surah> surahs;
  final Reciter reciter;

  const SurahsLoaded({required this.surahs, required this.reciter});

  @override
  List<Object?> get props => [surahs, reciter];
}

class SurahsError extends QuranAudioState {
  final String message;

  const SurahsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Radio States
class RadioStationsInitial extends QuranAudioState {
  const RadioStationsInitial();
}

class RadioStationsLoading extends QuranAudioState {
  const RadioStationsLoading();
}

class RadioStationsLoaded extends QuranAudioState {
  final List<RadioStation> stations;

  const RadioStationsLoaded({required this.stations});

  @override
  List<Object?> get props => [stations];
}

class RadioStationsError extends QuranAudioState {
  final String message;

  const RadioStationsError({required this.message});

  @override
  List<Object?> get props => [message];
}

enum AudioMode { online, offline }

// Audio Playback States
class AudioPlayerInitial extends QuranAudioState {
  const AudioPlayerInitial();
}

class AudioPlayerLoading extends QuranAudioState {
  const AudioPlayerLoading();
}

class AudioPlayerPlaying extends QuranAudioState {
  final AudioTrack track;
  final Duration position;
  final Duration duration;
  final AudioMode mode;

  const AudioPlayerPlaying({
    required this.track,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.mode = AudioMode.online,
  });

  @override
  List<Object?> get props => [track, position, duration, mode];
}

class AudioPlayerPaused extends QuranAudioState {
  final AudioTrack track;
  final Duration position;
  final Duration duration;
  final AudioMode mode;

  const AudioPlayerPaused({
    required this.track,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.mode = AudioMode.online,
  });

  @override
  List<Object?> get props => [track, position, duration, mode];
}

class AudioPlayerStopped extends QuranAudioState {
  const AudioPlayerStopped();
}

class AudioPlayerError extends QuranAudioState {
  final String message;

  const AudioPlayerError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Favorites States
class FavoritesLoading extends QuranAudioState {
  const FavoritesLoading();
}

class FavoritesLoaded extends QuranAudioState {
  final List<Reciter> favorites;

  const FavoritesLoaded({required this.favorites});

  @override
  List<Object?> get props => [favorites];
}

class FavoritesError extends QuranAudioState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Recently Played States
class RecentlyPlayedLoading extends QuranAudioState {
  const RecentlyPlayedLoading();
}

class RecentlyPlayedLoaded extends QuranAudioState {
  final List<AudioTrack> tracks;

  const RecentlyPlayedLoaded({required this.tracks});

  @override
  List<Object?> get props => [tracks];
}

class RecentlyPlayedError extends QuranAudioState {
  final String message;

  const RecentlyPlayedError({required this.message});

  @override
  List<Object?> get props => [message];
}

// أضف هذه الـ State بعد الـ States الأخرى
class AudioPlayerCompleted extends QuranAudioState {
  final AudioTrack track;
  final Duration duration;

  const AudioPlayerCompleted({required this.track, required this.duration});

  @override
  List<Object> get props => [track, duration];
}
