import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/muezzin.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/repositories/prayer_times_repository.dart';

class GetMuezzins {
  final PrayerTimesRepository repository;

  GetMuezzins(this.repository);

  Future<Either<Failure, List<Muezzin>>> call() async {
    return await repository.loadMuezzins();
  }
}
