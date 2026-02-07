import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/collective_khatma_entity.dart';
import '../repositories/collective_khatma_repository.dart';

/// Use case for getting public khatmas list
class GetPublicKhatmasUseCase {
  final CollectiveKhatmaRepository repository;

  GetPublicKhatmasUseCase(this.repository);

  Future<Either<Failure, List<CollectiveKhatmaEntity>>> call() {
    return repository.getPublicKhatmas();
  }
}

/// Use case for searching khatmas
class SearchKhatmasUseCase {
  final CollectiveKhatmaRepository repository;

  SearchKhatmasUseCase(this.repository);

  Future<Either<Failure, List<CollectiveKhatmaEntity>>> call(String query) {
    return repository.searchKhatmas(query);
  }
}

/// Use case for watching real-time khatma updates
class WatchKhatmaUseCase {
  final CollectiveKhatmaRepository repository;

  WatchKhatmaUseCase(this.repository);

  Stream<Either<Failure, CollectiveKhatmaEntity>> call(String khatmaId) {
    return repository.watchKhatma(khatmaId);
  }
}

/// Use case for watching public khatmas list
class WatchPublicKhatmasUseCase {
  final CollectiveKhatmaRepository repository;

  WatchPublicKhatmasUseCase(this.repository);

  Stream<Either<Failure, List<CollectiveKhatmaEntity>>> call() {
    return repository.watchPublicKhatmas();
  }
}
