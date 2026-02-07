import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:meshkat_elhoda/features/location/domain/repositories/location_repository.dart';

class SaveLocation {
  final LocationRepository repository;

  SaveLocation(this.repository);

  Future<Either<Failure, void>> call(LocationEntity location) async {
    return await repository.saveLocation(location);
  }
}
