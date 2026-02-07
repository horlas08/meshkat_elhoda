import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/collective_khatma_repository.dart';

/// Use case for joining a collective khatma by selecting a part
class JoinKhatmaUseCase {
  final CollectiveKhatmaRepository repository;

  JoinKhatmaUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String khatmaId,
    required String userId,
    required String userName,
    required int partNumber,
  }) {
    return repository.joinKhatma(
      khatmaId: khatmaId,
      userId: userId,
      userName: userName,
      partNumber: partNumber,
    );
  }
}
