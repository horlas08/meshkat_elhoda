import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/repositories/prayer_times_repository.dart';

class GetCachedPrayerTimes {
  final PrayerTimesRepository repository;

  GetCachedPrayerTimes(this.repository);

  Future<Either<Failure, PrayerTimesEntity?>> call() async {
    return await repository.getCachedPrayerTimes();
  }
}
