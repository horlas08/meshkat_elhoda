import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/location/data/data_sources/location_local_data_source.dart';
import 'package:meshkat_elhoda/features/location/data/data_sources/location_remote_data_source.dart';
import 'package:meshkat_elhoda/features/location/data/models/location_model.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:meshkat_elhoda/features/location/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final LocationLocalDataSource localDataSource;

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, PermissionStatus>> requestLocationPermission() async {
    try {
      final status = await remoteDataSource.requestLocationPermission();
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PermissionStatus>> checkLocationPermission() async {
    try {
      final status = await remoteDataSource.checkLocationPermission();
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      final location = await remoteDataSource.getCurrentLocation();
      // Cache the location
      await localDataSource.cacheLocation(location);
      return Right(location);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LocationEntity>> getLocationFromCityCountry({
    required String city,
    required String country,
  }) async {
    try {
      final location = await remoteDataSource.getLocationFromCityCountry(
        city: city,
        country: country,
      );
      log(location.toString());
      // Cache the location
      await localDataSource.cacheLocation(location);
      return Right(location);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LocationEntity?>> getStoredLocation() async {
    try {
      final location = await localDataSource.getStoredLocation();
      return Right(location);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocation(LocationEntity location) async {
    try {
      final locationModel = LocationModel.fromEntity(location);
      await localDataSource.cacheLocation(locationModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocation() async {
    try {
      await localDataSource.clearLocation();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
