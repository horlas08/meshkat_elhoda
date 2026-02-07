import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/domain/entities/restaurant.dart';

abstract class HalalRestaurantsRepository {
  Future<Either<Failure, List<Restaurant>>> getNearbyHalalRestaurants({
    required double latitude,
    required double longitude,
    int radiusInMeters = 5000,
  });
}
