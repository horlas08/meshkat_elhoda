import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/location/domain/repositories/location_repository.dart';

class RequestLocationPermission {
  final LocationRepository repository;

  RequestLocationPermission(this.repository);

  Future<Either<Failure, PermissionStatus>> call() async {
    return await repository.requestLocationPermission();
  }
}
