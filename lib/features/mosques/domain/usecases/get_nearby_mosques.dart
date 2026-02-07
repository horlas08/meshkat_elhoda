import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/mosques/domain/entities/mosque.dart';
import 'package:meshkat_elhoda/features/mosques/domain/repositories/mosque_repository.dart';

class GetNearbyMosques {
  final MosqueRepository repository;
  GetNearbyMosques(this.repository);

  Future<Either<Failure, List<Mosque>>> call(Params params) {
    return repository.getNearbyMosques(
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
    this.radiusInMeters = 3000,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInMeters];
}
