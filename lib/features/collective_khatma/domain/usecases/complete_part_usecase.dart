import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../repositories/collective_khatma_repository.dart';

/// Use case for completing a part in a collective khatma
class CompletePartUseCase {
  final CollectiveKhatmaRepository repository;

  CompletePartUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String khatmaId,
    required String userId,
    required int partNumber,
  }) {
    return repository.completePart(
      khatmaId: khatmaId,
      userId: userId,
      partNumber: partNumber,
    );
  }
}
