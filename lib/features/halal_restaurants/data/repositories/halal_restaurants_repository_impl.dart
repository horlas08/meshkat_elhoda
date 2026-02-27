import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
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

  static const int _maxCacheAgeMillis = 30 * 60 * 1000;
  static const double _maxCacheDistanceMeters = 2000;

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
      // 1. Try cache first (but only use it if it matches current area and is fresh)
      final cached = await localDataSource.getCachedRestaurants();
      if (cached.isNotEmpty) {
        final meta = await localDataSource.getCachedRestaurantsMeta();
        final now = DateTime.now().millisecondsSinceEpoch;

        final isFresh = meta.cachedAtMillis != null &&
            (now - meta.cachedAtMillis!) <= _maxCacheAgeMillis;

        final isSameArea = meta.latitude != null && meta.longitude != null
            ? Geolocator.distanceBetween(
                  latitude,
                  longitude,
                  meta.latitude!,
                  meta.longitude!,
                ) <=
                _maxCacheDistanceMeters
            : false;

        if (isFresh && isSameArea) {
          return Right(cached);
        }

        // If cache exists but is stale, try remote (online). If offline, still return cache.
        if (!await networkInfo.isConnected) {
          return Right(cached);
        }
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
        await localDataSource.cacheRestaurantsMeta(
          latitude: latitude,
          longitude: longitude,
          cachedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );

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
