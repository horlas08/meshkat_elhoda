import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/collective_khatma_entity.dart';
import '../repositories/collective_khatma_repository.dart';

/// Use case for getting user's collective khatmas
class GetUserCollectiveKhatmasUseCase {
  final CollectiveKhatmaRepository repository;

  GetUserCollectiveKhatmasUseCase(this.repository);

  Future<Either<Failure, List<UserCollectiveKhatmaEntity>>> call(
    String userId,
  ) {
    return repository.getUserKhatmas(userId);
  }
}

/// Use case for getting user's completed khatmas count
class GetUserCompletedKhatmasCountUseCase {
  final CollectiveKhatmaRepository repository;

  GetUserCompletedKhatmasCountUseCase(this.repository);

  Future<Either<Failure, int>> call(String userId) {
    return repository.getUserCompletedKhatmasCount(userId);
  }
}

/// Use case for checking user's reserved part in a khatma
class GetUserReservedPartUseCase {
  final CollectiveKhatmaRepository repository;

  GetUserReservedPartUseCase(this.repository);

  Future<Either<Failure, int?>> call({
    required String khatmaId,
    required String userId,
  }) {
    return repository.getUserReservedPart(khatmaId: khatmaId, userId: userId);
  }
}
