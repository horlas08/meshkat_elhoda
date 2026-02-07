import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../../domain/repositories/khatmah_repository.dart';
import '../../domain/entities/khatmah_progress_entity.dart';
import '../datasources/khatmah_remote_datasource.dart';
import '../models/khatmah_progress_model.dart';

class KhatmahRepositoryImpl implements KhatmahRepository {
  final KhatmahRemoteDataSource dataSource;

  KhatmahRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, KhatmahProgressEntity>> getUserKhatmahProgress(
    String userId,
  ) async {
    try {
      final progress = await dataSource.getUserKhatmahProgress(userId);
      if (progress == null) {
        return Right(KhatmahProgressModel.initial());
      }
      return Right(progress);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateKhatmahProgress(
    String userId,
    KhatmahProgressEntity progress,
  ) async {
    try {
      // Convert entity to model
      final model = KhatmahProgressModel.fromEntity(progress);
      await dataSource.updateKhatmahProgress(userId, model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetKhatmahProgress(String userId) async {
    try {
      await dataSource.resetKhatmahProgress(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
