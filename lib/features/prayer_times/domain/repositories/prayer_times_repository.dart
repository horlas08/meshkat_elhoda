import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/muezzin.dart';

abstract class PrayerTimesRepository {
  Future<Either<Failure, PrayerTimesEntity>> getPrayerTimes({
    required LocationEntity location,
  });
  Future<Either<Failure, PrayerTimesEntity?>> getCachedPrayerTimes();

  // Muezzin methods
  Future<Either<Failure, List<Muezzin>>> loadMuezzins();
  Future<Either<Failure, String?>> getSelectedMuezzinId();
  Future<Either<Failure, void>> saveSelectedMuezzinId(String id);
  Future<Either<Failure, void>> scheduleAthan(PrayerTimesEntity prayerTimes);
}
