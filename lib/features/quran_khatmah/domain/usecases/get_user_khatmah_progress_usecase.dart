import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/khatmah_repository.dart';
import '../entities/khatmah_progress_entity.dart';

class GetUserKhatmahProgressUseCase {
  final KhatmahRepository repository;

  GetUserKhatmahProgressUseCase(this.repository);

  Future<Either<Failure, KhatmahProgressEntity>> call(String userId) {
    return repository.getUserKhatmahProgress(userId);
  }
}
