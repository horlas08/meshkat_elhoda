import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:meshkat_elhoda/features/location/domain/repositories/location_repository.dart';

class GetStoredLocation {
  final LocationRepository repository;

  GetStoredLocation(this.repository);

  Future<Either<Failure, LocationEntity?>> call() async {
    return await repository.getStoredLocation();
  }
}
