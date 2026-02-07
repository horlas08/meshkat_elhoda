import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/network/network_info.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/datasources/quran_audio_data_source.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/audio_track_model.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/reciter_model.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/radio_station.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';

import 'package:meshkat_elhoda/features/quran_audio/data/datasources/audio_download_service.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/downloaded_audio.dart';

class QuranAudioRepositoryImpl implements QuranAudioRepository {
  final QuranAudioRemoteDataSource remoteDataSource;
  final QuranAudioLocalDataSource localDataSource;
  final AudioDownloadService audioDownloadService;
  final NetworkInfo networkInfo;

  static const List<String> supportedLanguages = [
    'ar',
    'en',
    'fr',
    'id',
    'ur',
    'tr',
    'bn',
    'ms',
    'fa',
    'es',
    'de',
    'zh',
  ];

  QuranAudioRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.audioDownloadService,
    required this.networkInfo,
  });

  @override
  Future<Either<AppException, List<Reciter>>> getReciters(
    String language,
  ) async {
    try {
      // Validate language is supported, fallback to English
      final validLanguage = supportedLanguages.contains(language)
          ? language
          : 'en';

      List<Reciter> reciters = [];

      // ✅ 1. Try to load from cache first
      final cachedReciters = await localDataSource.getCachedReciters(
        validLanguage,
      );
      if (cachedReciters.isNotEmpty) {
        reciters = cachedReciters;
        log('✅ Loaded ${cachedReciters.length} reciters from cache');
      } else if (await networkInfo.isConnected) {
        // ✅ 2. If cache is empty, load from API
        try {
          log('🌐 Loading reciters from API...');
          final remoteReciters = await remoteDataSource.getReciters(
            validLanguage,
          );
          // ✅ 3. Cache the results
          await localDataSource.cacheReciters(remoteReciters, validLanguage);
          reciters = remoteReciters;
          log('💾 Cached ${remoteReciters.length} reciters');
        } catch (e) {
          log('⚠️ Failed to fetch remote reciters: $e');
          return Left(AppException(message: 'Failed to load reciters: $e'));
        }
      } else {
        return Left(
          AppException(
            message: 'No internet connection and no cached data available',
          ),
        );
      }

      // ✅ Return all reciters - UI will handle access control based on subscription
      log('✅ Loaded ${reciters.length} reciters');
      return Right(reciters);
    } catch (e) {
      return Left(AppException(message: 'Error loading reciters: $e'));
    }
  }

  @override
  Future<Either<AppException, List<Surah>>> getSurahs() async {
    try {
      // ✅ 1. Try to load from cache first
      final cachedSurahs = await localDataSource.getCachedSurahs();
      if (cachedSurahs.isNotEmpty) {
        log('✅ Loaded ${cachedSurahs.length} surahs from cache');
        return Right(cachedSurahs);
      }

      // ✅ 2. If cache is empty, load from API
      if (await networkInfo.isConnected) {
        try {
          log('🌐 Loading surahs from API...');
          final remoteSurahs = await remoteDataSource.getSurahs();
          // ✅ 3. Cache the results
          await localDataSource.cacheSurahs(remoteSurahs);
          log('💾 Cached ${remoteSurahs.length} surahs');
          return Right(remoteSurahs);
        } catch (e) {
          log('⚠️ Failed to fetch remote surahs: $e');
          return Left(AppException(message: 'Failed to load surahs: $e'));
        }
      } else {
        return Left(
          AppException(
            message: 'No internet connection and no cached data available',
          ),
        );
      }
    } catch (e) {
      return Left(AppException(message: 'Error loading surahs: $e'));
    }
  }

  @override
  Future<Either<AppException, List<RadioStation>>> getRadioStations() async {
    try {
      // ✅ 1. Try to load from cache first
      final cachedStations = await localDataSource.getCachedRadioStations();
      if (cachedStations.isNotEmpty) {
        log('✅ Loaded ${cachedStations.length} radio stations from cache');
        return Right(cachedStations);
      }

      // ✅ 2. If cache is empty, load from API
      if (await networkInfo.isConnected) {
        try {
          log('🌐 Loading radio stations from API...');
          final remoteStations = await remoteDataSource.getRadioStations();
          // ✅ 3. Cache the results
          await localDataSource.cacheRadioStations(remoteStations);
          log('💾 Cached ${remoteStations.length} radio stations');
          return Right(remoteStations);
        } catch (e) {
          log('⚠️ Failed to fetch remote radio stations: $e');
          return Left(
            AppException(message: 'Failed to load radio stations: $e'),
          );
        }
      } else {
        return Left(
          AppException(
            message: 'No internet connection and no cached data available',
          ),
        );
      }
    } catch (e) {
      return Left(AppException(message: 'Error loading radio stations: $e'));
    }
  }

  @override
  Future<Either<AppException, AudioTrack>> getAudioTrack(
    Reciter reciter,
    Surah surah,
  ) async {
    try {
      // Format surah number with leading zeros (001, 002, etc.)
      final surahNumber = surah.number.toString().padLeft(3, '0');
      final audioUrl = '${reciter.server}/$surahNumber.mp3';

      final audioTrack = AudioTrackModel(
        surahNumber: surah.number.toString(),
        surahName: surah.name,
        reciterName: reciter.name,
        audioUrl: audioUrl,
        ayahCount: surah.ayahCount,
      );

      return Right(audioTrack);
    } catch (e) {
      return Left(AppException(message: 'Error creating audio track: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> saveFavoriteReciter(
    Reciter reciter,
  ) async {
    try {
      final reciterModel = ReciterModel(
        id: reciter.id,
        name: reciter.name,
        server: reciter.server,
        rewaya: reciter.rewaya,
        count: reciter.count,
        letter: reciter.letter,
        suras: reciter.suras,
        isFavorite: true,
      );
      await localDataSource.saveFavoriteReciter(reciterModel);
      return const Right(null);
    } catch (e) {
      return Left(AppException(message: 'Error saving favorite: $e'));
    }
  }

  @override
  Future<Either<AppException, List<Reciter>>> getFavoriteReciters() async {
    try {
      final favorites = await localDataSource.getFavoriteReciters();
      return Right(favorites);
    } catch (e) {
      return Left(AppException(message: 'Error loading favorites: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> removeFavoriteReciter(
    String reciterId,
  ) async {
    try {
      await localDataSource.removeFavoriteReciter(reciterId);
      return const Right(null);
    } catch (e) {
      return Left(AppException(message: 'Error removing favorite: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> saveLastPlayedTrack(
    AudioTrack track,
    Duration position,
  ) async {
    try {
      await localDataSource.saveLastPlayedTrack(
        track.surahNumber,
        track.surahName,
        track.reciterName,
        track.audioUrl,
        position.inMilliseconds,
      );
      return const Right(null);
    } catch (e) {
      return Left(AppException(message: 'Error saving last played: $e'));
    }
  }

  @override
  Future<Either<AppException, Map<String, dynamic>?>>
  getLastPlayedTrack() async {
    try {
      final lastPlayed = await localDataSource.getLastPlayedTrack();
      return Right(lastPlayed);
    } catch (e) {
      return Left(AppException(message: 'Error loading last played: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> addToRecentlyPlayed(
    AudioTrack track,
  ) async {
    try {
      await localDataSource.addToRecentlyPlayed(
        track.surahNumber,
        track.surahName,
        track.reciterName,
        track.audioUrl,
      );
      return const Right(null);
    } catch (e) {
      return Left(AppException(message: 'Error adding to recently played: $e'));
    }
  }

  @override
  Future<Either<AppException, List<AudioTrack>>>
  getRecentlyPlayedTracks() async {
    try {
      final recentlyPlayed = await localDataSource.getRecentlyPlayedTracks();
      final tracks = recentlyPlayed
          .map(
            (track) => AudioTrackModel(
              surahNumber: track['surahNumber'] as String? ?? '',
              surahName: track['surahName'] as String? ?? '',
              reciterName: track['reciterName'] as String? ?? '',
              audioUrl: track['audioUrl'] as String? ?? '',
            ),
          )
          .toList();
      return Right(tracks);
    } catch (e) {
      return Left(AppException(message: 'Error loading recently played: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> downloadSurah(
    Surah surah,
    Reciter reciter,
  ) async {
    try {
      final surahNumber = surah.number.toString().padLeft(3, '0');
      final audioUrl = '${reciter.server}/$surahNumber.mp3';

      await audioDownloadService.downloadSurah(
        url: audioUrl,
        reciterName: reciter.name,
        surahNumber: surah.number,
        surahName: surah.name,
      );
      return const Right(null);
    } catch (e) {
      return Left(AppException(message: 'Error downloading surah: $e'));
    }
  }

  @override
  Future<Either<AppException, List<DownloadedAudio>>> getOfflineAudios() async {
    try {
      final audios = await audioDownloadService.getOfflineAudios();
      return Right(audios);
    } catch (e) {
      return Left(AppException(message: 'Error loading offline audios: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> deleteOfflineAudio(String id) async {
    try {
      await audioDownloadService.deleteOfflineAudio(id);
      return const Right(null);
    } catch (e) {
      return Left(AppException(message: 'Error deleting offline audio: $e'));
    }
  }
}
