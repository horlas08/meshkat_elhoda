import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/repositories/prayer_times_repository.dart';

class GetSelectedMuezzinId {
  final PrayerTimesRepository repository;

  GetSelectedMuezzinId(this.repository);

  Future<Either<Failure, String?>> call() async {
    return await repository.getSelectedMuezzinId();
  }
}

class SaveSelectedMuezzinId {
  final PrayerTimesRepository repository;

  SaveSelectedMuezzinId(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.saveSelectedMuezzinId(id);
  }
}
