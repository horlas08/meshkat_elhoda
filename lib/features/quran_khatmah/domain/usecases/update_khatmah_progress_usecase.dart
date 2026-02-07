import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/khatmah_repository.dart';
import '../entities/khatmah_progress_entity.dart';

class UpdateKhatmahProgressUseCase {
  final KhatmahRepository repository;

  UpdateKhatmahProgressUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String userId,
    KhatmahProgressEntity progress,
  ) {
    return repository.updateKhatmahProgress(userId, progress);
  }
}
