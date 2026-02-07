import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/collective_khatma_entity.dart';
import '../repositories/collective_khatma_repository.dart';

/// Use case for getting khatma details by ID
class GetKhatmaDetailsUseCase {
  final CollectiveKhatmaRepository repository;

  GetKhatmaDetailsUseCase(this.repository);

  Future<Either<Failure, CollectiveKhatmaEntity>> call(String khatmaId) {
    return repository.getKhatmaById(khatmaId);
  }
}

/// Use case for getting khatma by invite link
class GetKhatmaByInviteLinkUseCase {
  final CollectiveKhatmaRepository repository;

  GetKhatmaByInviteLinkUseCase(this.repository);

  Future<Either<Failure, CollectiveKhatmaEntity>> call(String inviteLink) {
    return repository.getKhatmaByInviteLink(inviteLink);
  }
}
