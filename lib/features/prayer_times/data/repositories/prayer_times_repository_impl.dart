import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/data/data_sources/prayer_times_local_data_source.dart';
import 'package:meshkat_elhoda/features/prayer_times/data/data_sources/prayer_times_remote_data_source.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/muezzin.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/repositories/prayer_times_repository.dart';

class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  final PrayerTimesRemoteDataSource remoteDataSource;
  final PrayerTimesLocalDataSource localDataSource;

  PrayerTimesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, PrayerTimesEntity>> getPrayerTimes({
    required LocationEntity location,
  }) async {
    try {
      late final prayerTimes;

      if (location.isGPS &&
          location.latitude != null &&
          location.longitude != null) {
        prayerTimes = await remoteDataSource.getPrayerTimesByCoordinates(
          latitude: location.latitude!,
          longitude: location.longitude!,
        );
      } else if (location.isManual &&
          location.city != null &&
          location.country != null) {
        prayerTimes = await remoteDataSource.getPrayerTimesByCity(
          city: location.city!,
          country: location.country!,
        );
      } else {
        return const Left(ValidationFailure(message: 'Invalid location data'));
      }

      // Cache the prayer times
      await localDataSource.cachePrayerTimes(prayerTimes);

      return Right(prayerTimes);
    } on ServerException catch (e) {
      // Try to return cached data on network failure
      try {
        final cachedData = await localDataSource.getCachedPrayerTimes();
        if (cachedData != null) {
          return Right(cachedData);
        }
      } catch (_) {}

      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrayerTimesEntity?>> getCachedPrayerTimes() async {
    try {
      final cachedData = await localDataSource.getCachedPrayerTimes();
      return Right(cachedData);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Muezzin>>> loadMuezzins() async {
    try {
      final muezzins = await localDataSource.loadMuezzins();
      return Right(muezzins);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getSelectedMuezzinId() async {
    try {
      final id = await localDataSource.getSelectedMuezzinId();
      return Right(id);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSelectedMuezzinId(String id) async {
    try {
      await localDataSource.saveSelectedMuezzinId(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleAthan(
    PrayerTimesEntity prayerTimes,
  ) async {
    // Scheduling is currently handled by PrayerNotificationService via main.dart listener
    // This method is kept for future expansion or direct scheduling if needed
    return const Right(null);
  }
}
