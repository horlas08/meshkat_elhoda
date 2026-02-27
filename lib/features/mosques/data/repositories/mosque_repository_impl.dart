import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/core/network/network_info.dart';
import 'package:meshkat_elhoda/features/mosques/data/datasources/mosques_local_data_source.dart';
import 'package:meshkat_elhoda/features/mosques/data/datasources/mosques_remote_data_source.dart';
import 'package:meshkat_elhoda/features/mosques/domain/entities/mosque.dart';
import 'package:meshkat_elhoda/features/mosques/domain/repositories/mosque_repository.dart';

class MosqueRepositoryImpl implements MosqueRepository {
  final MosquesRemoteDataSource remoteDataSource;
  final MosquesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  static const int _maxCacheAgeMillis = 30 * 60 * 1000;
  static const double _maxCacheDistanceMeters = 2000;

  MosqueRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Mosque>>> getNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusInMeters = 3000,
  }) async {
    try {
      // ✅ 1. Try to load from cache first (only if it matches current area and is fresh)
      final cached = await localDataSource.getCachedMosques();
      if (cached.isNotEmpty) {
        final meta = await localDataSource.getCachedMosquesMeta();
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
          print('✅ Loaded ${cached.length} mosques from cache');
          return Right(cached);
        }

        // If cache exists but is stale, try remote (online). If offline, still return cache.
        if (!await networkInfo.isConnected) {
          print('⚠️ Offline, using stale cached mosques');
          return Right(cached);
        }
      }

      // ✅ 2. If cache is empty, load from API
      if (await networkInfo.isConnected) {
        print('🌐 Loading mosques from API...');
        final remote = await remoteDataSource.getNearbyMosques(
          latitude: latitude,
          longitude: longitude,
          radiusInMeters: radiusInMeters,
        );

        // ✅ 3. Save to cache for next time
        await localDataSource.cacheMosques(remote);
        await localDataSource.cacheMosquesMeta(
          latitude: latitude,
          longitude: longitude,
          cachedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        print('💾 Cached ${remote.length} mosques');

        return Right(remote);
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      // Try cache on error
      try {
        final cached = await localDataSource.getCachedMosques();
        if (cached.isNotEmpty) {
          print('⚠️ API failed, using cached data');
          return Right(cached);
        }
      } catch (_) {}
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
