import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';

abstract class LocationRepository {
  Future<Either<Failure, PermissionStatus>> requestLocationPermission();
  Future<Either<Failure, PermissionStatus>> checkLocationPermission();
  Future<Either<Failure, LocationEntity>> getCurrentLocation();
  Future<Either<Failure, LocationEntity>> getLocationFromCityCountry({
    required String city,
    required String country,
  });
  Future<Either<Failure, LocationEntity?>> getStoredLocation();
  Future<Either<Failure, void>> saveLocation(LocationEntity location);
  Future<Either<Failure, void>> clearLocation();
}
