import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/collective_khatma_entity.dart';
import '../repositories/collective_khatma_repository.dart';

/// Use case for creating a new collective khatma
class CreateKhatmaUseCase {
  final CollectiveKhatmaRepository repository;

  CreateKhatmaUseCase(this.repository);

  Future<Either<Failure, CollectiveKhatmaEntity>> call({
    required String title,
    required String userId,
    required String userName,
    required KhatmaType type,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.createKhatma(
      title: title,
      userId: userId,
      userName: userName,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
