import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/core/network/network_info.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/juz_entity.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/tafsir_entity.dart';
import '../../domain/entities/quran_edition_entity.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';
import '../datasources/quran_remote_data_source.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteDataSource remoteDataSource;
  final QuranLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  QuranRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SurahEntity>>> getAllSurahs() async {
    // ✅ 1. Try to load from cache first
    try {
      final cachedSurahs = await localDataSource.getCachedSurahs();
      if (cachedSurahs != null && cachedSurahs.isNotEmpty) {
        print('✅ Loaded ${cachedSurahs.length} surahs from cache');
        return Right(cachedSurahs);
      }
    } catch (e) {
      print('⚠️ Cache read failed: $e');
    }

    // ✅ 2. If cache is empty, load from API
    if (await networkInfo.isConnected) {
      try {
        print('🌐 Loading surahs from API...');
        final surahs = await remoteDataSource.getAllSurahs();

        // ✅ 3. Save to cache for next time
        try {
          await localDataSource.cacheSurahs(surahs);
          print('💾 Cached ${surahs.length} surahs');
        } catch (e) {
          print('⚠️ Cache write failed: $e');
        }

        return Right(surahs);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<AyahEntity>>> getSurahByNumber(
    int number, {
    String? reciterId,
    String? language,
  }) async {
    // ✅ 1. Try to load from cache first (including reciterId and language in cache key)
    try {
      final cachedAyahs = await localDataSource.getCachedSurahDetails(
        number,
        reciterId: reciterId,
        language: language,
      );
      if (cachedAyahs != null && cachedAyahs.isNotEmpty) {
        // ✅ تحقق من وجود الترجمة إذا كانت اللغة غير عربية
        final needsTranslation = language != null && language != 'ar';
        final hasTranslation = cachedAyahs.any(
          (a) => a.translation != null && a.translation!.isNotEmpty,
        );

        if (!needsTranslation || hasTranslation) {
          print(
            '✅ Loaded Surah $number details from cache (reciter: $reciterId, language: $language)',
          );
          return Right(cachedAyahs);
        } else {
          print(
            '⚠️ Cache exists but missing translation, fetching from API...',
          );
        }
      }
    } catch (e) {
      print('⚠️ Cache read failed for Surah $number: $e');
    }

    // ✅ 2. If cache is empty or missing translation, load from API
    if (await networkInfo.isConnected) {
      try {
        final ayahs = await remoteDataSource.getSurahByNumber(
          number,
          reciterId: reciterId,
        );

        // ✅ 3. Save to cache for next time (including reciterId and language in cache key)
        try {
          await localDataSource.cacheSurahDetails(
            number,
            ayahs,
            reciterId: reciterId,
            language: language,
          );
          print(
            '💾 Cached Surah $number details (reciter: $reciterId, language: $language)',
          );
        } catch (e) {
          print('⚠️ Cache write failed for Surah $number: $e');
        }

        return Right(ayahs);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, JuzEntity>> getJuzSurahs(int number) async {
    if (await networkInfo.isConnected) {
      try {
        final juz = await remoteDataSource.getJuzSurahs(number);
        return Right(juz);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, TafsirEntity>> getAyahTafsir(
    int surahNumber,
    int ayahNumber, {
    String? tafsirId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final tafsir = await remoteDataSource.getAyahTafsir(
          surahNumber,
          ayahNumber,
          tafsirId: tafsirId,
        );
        return Right(tafsir);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ReciterEntity>>> getReciters() async {
    if (await networkInfo.isConnected) {
      try {
        final reciters = await remoteDataSource.getReciters();
        return Right(reciters);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> getAudioUrl(
    int surahNumber,
    String reciterId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final audioUrl = await remoteDataSource.getAudioUrl(
          surahNumber,
          reciterId,
        );
        return Right(audioUrl);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLastPosition(
    int surahNumber,
    int ayahNumber,
  ) async {
    try {
      await localDataSource.saveLastPosition(surahNumber, ayahNumber);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({int surahNumber, int ayahNumber})>>
  getLastPosition() async {
    try {
      final position = await localDataSource.getLastPosition();
      if (position != null) {
        return Right(position);
      } else {
        return Left(CacheFailure(message: 'No last position found'));
      }
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuranEditionEntity>>> getAvailableTafsirs(
    String language,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final tafsirs = await remoteDataSource.getAvailableTafsirs(language);
        return Right(tafsirs);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<QuranEditionEntity>>> getAvailableReciters(
    String language,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final reciters = await remoteDataSource.getAvailableReciters(language);
        return Right(reciters);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
