import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/collective_khatma_entity.dart';

/// Repository interface for collective khatma operations
abstract class CollectiveKhatmaRepository {
  /// Create a new collective khatma
  Future<Either<Failure, CollectiveKhatmaEntity>> createKhatma({
    required String title,
    required String userId,
    required String userName,
    required KhatmaType type,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get khatma by ID
  Future<Either<Failure, CollectiveKhatmaEntity>> getKhatmaById(
    String khatmaId,
  );

  /// Get khatma by invite link
  Future<Either<Failure, CollectiveKhatmaEntity>> getKhatmaByInviteLink(
    String inviteLink,
  );

  /// Join a khatma by selecting a part
  Future<Either<Failure, void>> joinKhatma({
    required String khatmaId,
    required String userId,
    required String userName,
    required int partNumber,
  });

  /// Leave a khatma (release the reserved part)
  Future<Either<Failure, void>> leaveKhatma({
    required String khatmaId,
    required String userId,
    required int partNumber,
  });

  /// Mark a part as completed
  Future<Either<Failure, void>> completePart({
    required String khatmaId,
    required String userId,
    required int partNumber,
  });

  /// Get all public khatmas
  Future<Either<Failure, List<CollectiveKhatmaEntity>>> getPublicKhatmas();

  /// Search khatmas by title
  Future<Either<Failure, List<CollectiveKhatmaEntity>>> searchKhatmas(
    String query,
  );

  /// Get user's collective khatmas (participated)
  Future<Either<Failure, List<UserCollectiveKhatmaEntity>>> getUserKhatmas(
    String userId,
  );

  /// Get user's completed collective khatmas count
  Future<Either<Failure, int>> getUserCompletedKhatmasCount(String userId);

  /// Stream real-time updates for a khatma
  Stream<Either<Failure, CollectiveKhatmaEntity>> watchKhatma(String khatmaId);

  /// Stream real-time updates for public khatmas list
  Stream<Either<Failure, List<CollectiveKhatmaEntity>>> watchPublicKhatmas();

  /// Check if user has already reserved a part in the khatma
  Future<Either<Failure, int?>> getUserReservedPart({
    required String khatmaId,
    required String userId,
  });

  /// Delete a khatma (only by creator)
  Future<Either<Failure, void>> deleteKhatma({
    required String khatmaId,
    required String userId,
  });

  /// Get user's created khatmas (both public and private)
  Future<Either<Failure, List<CollectiveKhatmaEntity>>> getUserCreatedKhatmas(
    String userId,
  );
}
