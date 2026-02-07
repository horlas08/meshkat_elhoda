import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/mosques/domain/entities/mosque.dart';

abstract class MosqueRepository {
  Future<Either<Failure, List<Mosque>>> getNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusInMeters = 3000,
  });
}
