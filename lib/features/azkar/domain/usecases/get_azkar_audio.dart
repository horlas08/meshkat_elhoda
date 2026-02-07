import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/azkar/domain/repositories/azkar_repository.dart';

class GetAzkarAudio {
  final AzkarRepository repository;

  GetAzkarAudio(this.repository);

  Future<Either<Failure, String>> call(int azkarId) async {
    return await repository.getAzkarAudio(azkarId);
  }
}
