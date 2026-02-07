import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/hadith/data/datasources/hadith_local_data_source.dart';
import 'package:meshkat_elhoda/features/hadith/data/datasources/hadith_remote_data_source.dart';
import 'package:meshkat_elhoda/features/hadith/data/models/hadith_category_model.dart';
import 'package:meshkat_elhoda/features/hadith/domain/entities/hadith.dart';
import 'package:meshkat_elhoda/features/hadith/domain/repositories/hadith_repository.dart';

class HadithRepositoryImpl implements HadithRepository {
  final HadithRemoteDataSource remoteDataSource;
  final HadithLocalDataSource localDataSource;

  HadithRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Map<String, String>>>> getLanguages() async {
    try {
      final languages = await remoteDataSource.getLanguages();
      return Right(languages);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<HadithCategory>>> getRootCategories({
    String? languageCode,
  }) async {
    try {
      final lang =
          languageCode ?? await remoteDataSource.getCurrentUserLanguage();
      final categories = await remoteDataSource.getRootCategories(lang);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<HadithCategory>>> getCategories({
    String? languageCode,
  }) async {
    try {
      final lang =
          languageCode ?? await remoteDataSource.getCurrentUserLanguage();
      final categories = await remoteDataSource.getCategories(lang);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<HadithCategory>>> getSubCategories({
    required String parentId,
    String? languageCode,
  }) async {
    try {
      final lang =
          languageCode ?? await remoteDataSource.getCurrentUserLanguage();
      final allCategories = await remoteDataSource.getCategories(lang);
      final subCategories = remoteDataSource.getSubCategories(
        parentId,
        allCategories,
      );
      return Right(subCategories);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, HadithListResponse>> getHadithsByCategory({
    required String categoryId,
    int page = 1,
    int perPage = 20,
    String? languageCode,
  }) async {
    try {
      final lang =
          languageCode ?? await remoteDataSource.getCurrentUserLanguage();
      final response = await remoteDataSource.getHadithsByCategory(
        languageCode: lang,
        categoryId: categoryId,
        page: page,
        perPage: perPage,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Hadith>> getHadithById({
    required String id,
    String? languageCode,
  }) async {
    try {
      final lang =
          languageCode ?? await remoteDataSource.getCurrentUserLanguage();
      final hadith = await remoteDataSource.getHadithById(
        id: id,
        languageCode: lang,
      );

      // Cache the hadith
      try {
        await localDataSource.cacheHadith(hadith);
      } catch (e) {
        // Ignore cache errors
      }

      return Right(hadith);
    } on ServerException catch (e) {
      // Try to get from cache
      try {
        final cachedHadith = await localDataSource.getLastHadith();
        if (cachedHadith.id == id) {
          return Right(cachedHadith);
        }
      } catch (_) {}
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Hadith>> getRandomHadith({
    String? languageCode,
  }) async {
    try {
      final lang =
          languageCode ?? await remoteDataSource.getCurrentUserLanguage();
      final hadith = await remoteDataSource.getRandomHadith(languageCode: lang);

      // Cache the hadith
      try {
        await localDataSource.cacheHadith(hadith);
      } catch (e) {
        // Ignore cache errors
      }

      return Right(hadith);
    } on ServerException catch (e) {
      // Try to get from cache
      try {
        final cachedHadith = await localDataSource.getLastHadith();
        return Right(cachedHadith);
      } on CacheException catch (cacheError) {
        return Left(
          CacheFailure(
            message:
                'No internet connection and no cached data: ${cacheError.message}',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<String> getCurrentUserLanguage() async {
    return await remoteDataSource.getCurrentUserLanguage();
  }

  @override
  void clearCache() {
    remoteDataSource.clearCache();
  }
}
