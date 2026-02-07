import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/core/network/network_info.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/data/datasources/halal_restaurants_local_data_source.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/data/datasources/halal_restaurants_remote_data_source.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/domain/entities/restaurant.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/domain/repositories/halal_restaurants_repository.dart';

class HalalRestaurantsRepositoryImpl implements HalalRestaurantsRepository {
  final HalalRestaurantsRemoteDataSource remoteDataSource;
  final HalalRestaurantsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  HalalRestaurantsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Restaurant>>> getNearbyHalalRestaurants({
    required double latitude,
    required double longitude,
    int radiusInMeters = 5000,
  }) async {
    try {
      // 1. Try cache first
      final cached = await localDataSource.getCachedRestaurants();
      if (cached.isNotEmpty) {
        return Right(cached);
      }

      // 2. Load from API
      if (await networkInfo.isConnected) {
        final remote = await remoteDataSource.getNearbyHalalRestaurants(
          latitude: latitude,
          longitude: longitude,
          radiusInMeters: radiusInMeters,
        );

        // 3. Cache result
        await localDataSource.cacheRestaurants(remote);

        return Right(remote);
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      try {
        final cached = await localDataSource.getCachedRestaurants();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      } catch (_) {}
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
