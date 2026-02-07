import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/radio_station.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/downloaded_audio.dart';

abstract class QuranAudioRepository {
  /// Get all reciters for a specific language
  Future<Either<AppException, List<Reciter>>> getReciters(String language);

  /// Get surahs for a specific reciter
  Future<Either<AppException, List<Surah>>> getSurahs();

  /// Get all radio stations
  Future<Either<AppException, List<RadioStation>>> getRadioStations();

  /// Get audio URL for a specific surah and reciter
  Future<Either<AppException, AudioTrack>> getAudioTrack(
    Reciter reciter,
    Surah surah,
  );

  /// Save favorite reciter
  Future<Either<AppException, void>> saveFavoriteReciter(Reciter reciter);

  /// Get favorite reciters
  Future<Either<AppException, List<Reciter>>> getFavoriteReciters();

  /// Remove favorite reciter
  Future<Either<AppException, void>> removeFavoriteReciter(String reciterId);

  /// Save last played track
  Future<Either<AppException, void>> saveLastPlayedTrack(
    AudioTrack track,
    Duration position,
  );

  /// Get last played track
  Future<Either<AppException, Map<String, dynamic>?>> getLastPlayedTrack();

  /// Save recently played tracks
  Future<Either<AppException, void>> addToRecentlyPlayed(AudioTrack track);

  /// Get recently played tracks
  Future<Either<AppException, List<AudioTrack>>> getRecentlyPlayedTracks();

  /// Download surah audio
  Future<Either<AppException, void>> downloadSurah(
    Surah surah,
    Reciter reciter,
  );

  /// Get all offline audios
  Future<Either<AppException, List<DownloadedAudio>>> getOfflineAudios();

  /// Delete offline audio
  Future<Either<AppException, void>> deleteOfflineAudio(String id);
}
