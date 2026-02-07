part of 'quran_audio_cubit.dart';

abstract class QuranAudioEvent extends Equatable {
  const QuranAudioEvent();

  @override
  List<Object?> get props => [];
}

// Reciter Events
class LoadRecitersEvent extends QuranAudioEvent {
  final String language;

  const LoadRecitersEvent({required this.language});

  @override
  List<Object?> get props => [language];
}

class SearchRecitersEvent extends QuranAudioEvent {
  final String query;

  const SearchRecitersEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class SelectReciterEvent extends QuranAudioEvent {
  final Reciter reciter;

  const SelectReciterEvent({required this.reciter});

  @override
  List<Object?> get props => [reciter];
}

// Surah Events
class LoadSurahsEvent extends QuranAudioEvent {
  final Reciter reciter;

  const LoadSurahsEvent({required this.reciter});

  @override
  List<Object?> get props => [reciter];
}

// Radio Events
class LoadRadioStationsEvent extends QuranAudioEvent {
  const LoadRadioStationsEvent();
}

// Playback Events
class PlayTrackEvent extends QuranAudioEvent {
  final AudioTrack track;
  final List<AudioTrack> playlist;
  final int index;

  const PlayTrackEvent({
    required this.track,
    this.playlist = const [],
    this.index = 0,
  });

  @override
  List<Object?> get props => [track, playlist, index];
}

class LoadPlaylistEvent extends QuranAudioEvent {
  final List<AudioTrack> playlist;
  final int startIndex;

  const LoadPlaylistEvent({required this.playlist, this.startIndex = 0});

  @override
  List<Object?> get props => [playlist, startIndex];
}

class PlayPlaylistEvent extends QuranAudioEvent {
  final List<AudioTrack> playlist;
  final int startIndex;

  const PlayPlaylistEvent({required this.playlist, this.startIndex = 0});

  @override
  List<Object?> get props => [playlist, startIndex];
}

class PauseAudioEvent extends QuranAudioEvent {
  const PauseAudioEvent();
}

class ResumeAudioEvent extends QuranAudioEvent {
  const ResumeAudioEvent();
}

class StopAudioEvent extends QuranAudioEvent {
  const StopAudioEvent();
}

class SeekAudioEvent extends QuranAudioEvent {
  final Duration position;

  const SeekAudioEvent({required this.position});

  @override
  List<Object?> get props => [position];
}

class NextTrackEvent extends QuranAudioEvent {
  const NextTrackEvent();
}

class PreviousTrackEvent extends QuranAudioEvent {
  const PreviousTrackEvent();
}

// Favorites Events
class LoadFavoritesEvent extends QuranAudioEvent {
  const LoadFavoritesEvent();
}

class SaveFavoriteReciterEvent extends QuranAudioEvent {
  final Reciter reciter;

  const SaveFavoriteReciterEvent({required this.reciter});

  @override
  List<Object?> get props => [reciter];
}

class RemoveFavoriteReciterEvent extends QuranAudioEvent {
  final String reciterId;

  const RemoveFavoriteReciterEvent({required this.reciterId});

  @override
  List<Object?> get props => [reciterId];
}

// Recently Played Events
class LoadRecentlyPlayedEvent extends QuranAudioEvent {
  const LoadRecentlyPlayedEvent();
}

class AddToRecentlyPlayedEvent extends QuranAudioEvent {
  final AudioTrack track;

  const AddToRecentlyPlayedEvent({required this.track});

  @override
  List<Object?> get props => [track];
}

class ClearRecentlyPlayedEvent extends QuranAudioEvent {
  const ClearRecentlyPlayedEvent();
}

// Position Update Event
class UpdatePositionEvent extends QuranAudioEvent {
  final Duration position;

  const UpdatePositionEvent({required this.position});

  @override
  List<Object?> get props => [position];
}

class ReplayAudioEvent extends QuranAudioEvent {
  const ReplayAudioEvent();

  @override
  List<Object?> get props => [];
}

class DownloadSurahEvent extends QuranAudioEvent {
  final Surah surah;
  final Reciter reciter;

  const DownloadSurahEvent({required this.surah, required this.reciter});

  @override
  List<Object?> get props => [surah, reciter];
}

class PlayOfflineTrackEvent extends QuranAudioEvent {
  final DownloadedAudio audio;

  const PlayOfflineTrackEvent({required this.audio});

  @override
  List<Object?> get props => [audio];
}
