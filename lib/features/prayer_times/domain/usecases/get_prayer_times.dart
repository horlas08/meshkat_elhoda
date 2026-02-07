import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/repositories/prayer_times_repository.dart';

class GetPrayerTimes {
  final PrayerTimesRepository repository;

  GetPrayerTimes(this.repository);

  Future<Either<Failure, PrayerTimesEntity>> call({
    required LocationEntity location,
  }) async {
    return await repository.getPrayerTimes(location: location);
  }
}
