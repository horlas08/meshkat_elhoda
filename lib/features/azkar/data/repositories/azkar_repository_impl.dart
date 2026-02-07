import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/azkar/data/datasources/azkar_local_data_source.dart';
import 'package:meshkat_elhoda/features/azkar/data/datasources/azkar_remote_data_source.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';
import 'package:meshkat_elhoda/features/azkar/domain/repositories/azkar_repository.dart';

class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarRemoteDataSource remoteDataSource;
  final AzkarLocalDataSource localDataSource;

  AzkarRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AzkarCategory>>> getAzkarCategories() async {
    try {
      // Try to fetch from remote
      final categories = await remoteDataSource.getAzkarCategories();
      
      // Cache the result
      await localDataSource.cacheAzkarCategories(categories);
      
      return Right(categories);
    } catch (e) {
      // If remote fails, try to get from cache
      try {
        final cachedCategories = await localDataSource.getCachedAzkarCategories();
        return Right(cachedCategories);
      } catch (cacheError) {
        return Left(ServerFailure(message: 'Failed to fetch azkar categories: $e'));
      }
    }
  }

  // Removed getAzkarChapters as it's no longer needed
  // The functionality is now part of getAzkarItems

  @override
  Future<Either<Failure, List<Azkar>>> getAzkarItems(int chapterId) async {
    try {
      // Try to fetch from remote
      final items = await remoteDataSource.getAzkarItems(chapterId);
      
      // Cache the result
      await localDataSource.cacheAzkarItems(chapterId, items);
      
      return Right(items);
    } catch (e) {
      // If remote fails, try to get from cache
      try {
        final cachedItems = await localDataSource.getCachedAzkarItems(chapterId);
        return Right(cachedItems);
      } catch (cacheError) {
        return Left(ServerFailure(message: 'Failed to fetch azkar items: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, String>> getAzkarAudio(int azkarId) async {
    // Audio is not available with local JSON
    return Left(ServerFailure(message: 'Audio is not available in the local version'));
  }
}
