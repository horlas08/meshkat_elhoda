import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/domain/entities/restaurant.dart';
import 'package:meshkat_elhoda/features/halal_restaurants/domain/repositories/halal_restaurants_repository.dart';

class GetNearbyHalalRestaurants {
  final HalalRestaurantsRepository repository;
  GetNearbyHalalRestaurants(this.repository);

  Future<Either<Failure, List<Restaurant>>> call(Params params) {
    return repository.getNearbyHalalRestaurants(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusInMeters: params.radiusInMeters,
    );
  }
}

class Params extends Equatable {
  final double latitude;
  final double longitude;
  final int radiusInMeters;

  const Params({
    required this.latitude,
    required this.longitude,
    this.radiusInMeters = 5000,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInMeters];
}
