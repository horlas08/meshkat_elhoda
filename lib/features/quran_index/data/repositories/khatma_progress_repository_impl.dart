import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/quran_index/data/datasources/khatma_progress_data_source.dart';
import 'package:meshkat_elhoda/features/quran_index/data/models/khatma_progress_model.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/repositories/khatma_progress_repository.dart';

class KhatmaProgressRepositoryImpl implements KhatmaProgressRepository {
  final KhatmaProgressDataSource dataSource;

  KhatmaProgressRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, KhatmaProgressModel>> getUserKhatmaProgress(
    String userId,
  ) async {
    try {
      final progress = await dataSource.getUserKhatmaProgress(userId);

      // إذا لم يكن هناك تقدم محفوظ، نرجع التقدم الأولي
      if (progress == null) {
        return Right(KhatmaProgressModel.initial());
      }

      return Right(progress);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateKhatmaProgress(
    String userId,
    KhatmaProgressModel progress,
  ) async {
    try {
      await dataSource.updateKhatmaProgress(userId, progress);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetKhatmaProgress(String userId) async {
    try {
      await dataSource.resetKhatmaProgress(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
