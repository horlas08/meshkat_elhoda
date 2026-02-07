import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/azkar/data/datasources/azkar_local_data_source.dart';
import 'package:meshkat_elhoda/features/azkar/data/datasources/azkar_remote_data_source.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/allah_name.dart';
import 'package:meshkat_elhoda/features/azkar/domain/repositories/allah_names_repository.dart';

class AllahNamesRepositoryImpl implements AllahNamesRepository {
  final AzkarRemoteDataSource remoteDataSource;
  final AzkarLocalDataSource localDataSource;

  AllahNamesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AllahName>>> getAllahNames() async {
    try {
      // Try to fetch from remote
      final names = await remoteDataSource.getAllahNames();
      
      // Cache the result
      await localDataSource.cacheAllahNames(names);
      
      return Right(names);
    } catch (e) {
      // If remote fails, try to get from cache
      try {
        final cachedNames = await localDataSource.getCachedAllahNames();
        return Right(cachedNames);
      } catch (cacheError) {
        return Left(ServerFailure(message: 'Failed to fetch Allah names: $e'));
      }
    }
  }
}
