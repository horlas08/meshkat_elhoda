import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/collective_khatma_entity.dart';
import '../repositories/collective_khatma_repository.dart';

/// Use case for getting user's created khatmas (both public and private)
class GetUserCreatedKhatmasUseCase {
  final CollectiveKhatmaRepository repository;

  GetUserCreatedKhatmasUseCase(this.repository);

  Future<Either<Failure, List<CollectiveKhatmaEntity>>> call(String userId) {
    return repository.getUserCreatedKhatmas(userId);
  }
}
