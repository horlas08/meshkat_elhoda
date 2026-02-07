import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/quran_index/data/models/khatma_progress_model.dart';

/// واجهة مستودع تقدم الختمة
abstract class KhatmaProgressRepository {
  Future<Either<Failure, KhatmaProgressModel>> getUserKhatmaProgress(
    String userId,
  );

  Future<Either<Failure, void>> updateKhatmaProgress(
    String userId,
    KhatmaProgressModel progress,
  );

  Future<Either<Failure, void>> resetKhatmaProgress(String userId);
}
