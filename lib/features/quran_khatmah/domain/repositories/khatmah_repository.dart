import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../entities/khatmah_progress_entity.dart';

abstract class KhatmahRepository {
  Future<Either<Failure, KhatmahProgressEntity>> getUserKhatmahProgress(
    String userId,
  );
  Future<Either<Failure, void>> updateKhatmahProgress(
    String userId,
    KhatmahProgressEntity progress,
  );
  Future<Either<Failure, void>> resetKhatmahProgress(String userId);
}
