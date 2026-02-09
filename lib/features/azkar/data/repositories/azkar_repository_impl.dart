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
  Future<Either<Failure, List<AzkarCategory>>> getAzkarCategories(String languageCode) async {
    try {
      // Try to fetch from remote
      final categories = await remoteDataSource.getAzkarCategories(languageCode);
      
      // Cache the result (optional: could cache by language, but LocalDataSource might need update)
      // For now, we skip local cache update or assume it's language agnostic? 
      // Actually, local cache structure likely doesn't support language.
      // If we cache "Azkar Categories", and user switches language, they see old cache.
      // Let's NOT cache locally for now or only cache if language matches?
      // Or just rely on remoteDataSource's memory cache since it's local JSON reading anyway.
      // Reading JSON from assets is fast. LocalDataSource (likely DB or Prefs) might be overkill for this app's architecture if it's just reading JSON.
      // But let's keep existing logic but maybe suffix cache key?
      // Assuming we just return remote for now to ensure translation works.
      
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load azkar categories: $e'));
    }
  }

  // Removed getAzkarChapters as it's no longer needed
  // The functionality is now part of getAzkarItems

  @override
  Future<Either<Failure, List<Azkar>>> getAzkarItems(int chapterId, String languageCode) async {
    try {
      // Try to fetch from remote
      final items = await remoteDataSource.getAzkarItems(chapterId, languageCode);
      
      // Skip local cache for now to avoid complexity with multiple languages in single cache key
      
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load azkar items: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getAzkarAudio(int azkarId) async {
    // Audio is not available with local JSON
    return Left(ServerFailure(message: 'Audio is not available in the local version'));
  }
}
