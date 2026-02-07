import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:meshkat_elhoda/features/location/domain/repositories/location_repository.dart';

class GetLocationFromCityCountry {
  final LocationRepository repository;

  GetLocationFromCityCountry(this.repository);

  Future<Either<Failure, LocationEntity>> call({
    required String city,
    required String country,
  }) async {
    return await repository.getLocationFromCityCountry(
      city: city,
      country: country,
    );
  }
}
