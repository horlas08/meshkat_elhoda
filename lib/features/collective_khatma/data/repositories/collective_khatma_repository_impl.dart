import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import '../../domain/entities/collective_khatma_entity.dart';
import '../../domain/repositories/collective_khatma_repository.dart';
import '../datasources/collective_khatma_remote_datasource.dart';
import '../models/collective_khatma_model.dart';

class CollectiveKhatmaRepositoryImpl implements CollectiveKhatmaRepository {
  final CollectiveKhatmaRemoteDataSource dataSource;

  CollectiveKhatmaRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, CollectiveKhatmaEntity>> createKhatma({
    required String title,
    required String userId,
    required String userName,
    required KhatmaType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final khatma = CollectiveKhatmaModel.create(
        title: title,
        createdBy: userId,
        creatorName: userName,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      final result = await dataSource.createKhatma(khatma);
      return Right(result);
    } catch (e) {
      log('❌ Error in createKhatma: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CollectiveKhatmaEntity>> getKhatmaById(
    String khatmaId,
  ) async {
    try {
      final khatma = await dataSource.getKhatmaById(khatmaId);
      if (khatma == null) {
        return const Left(ServerFailure(message: 'الختمة غير موجودة'));
      }
      return Right(khatma);
    } catch (e) {
      log('❌ Error in getKhatmaById: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CollectiveKhatmaEntity>> getKhatmaByInviteLink(
    String inviteLink,
  ) async {
    try {
      final khatma = await dataSource.getKhatmaByInviteLink(inviteLink);
      if (khatma == null) {
        return const Left(ServerFailure(message: 'رابط الدعوة غير صالح'));
      }
      return Right(khatma);
    } catch (e) {
      log('❌ Error in getKhatmaByInviteLink: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinKhatma({
    required String khatmaId,
    required String userId,
    required String userName,
    required int partNumber,
  }) async {
    try {
      // Get current khatma data
      final khatma = await dataSource.getKhatmaById(khatmaId);
      if (khatma == null) {
        return const Left(ServerFailure(message: 'الختمة غير موجودة'));
      }

      // Allow users to reserve multiple parts (removed restriction)

      // Check if part is available
      final partIndex = partNumber - 1;
      if (partIndex < 0 || partIndex >= khatma.parts.length) {
        return const Left(ServerFailure(message: 'رقم الجزء غير صالح'));
      }

      final part = khatma.parts[partIndex] as KhatmaPartModel;
      if (part.isReserved) {
        return const Left(ServerFailure(message: 'هذا الجزء محجوز بالفعل'));
      }

      // Update the part
      final updatedPart = part.copyWith(userId: userId, userName: userName);

      // Create updated parts list
      final updatedParts = List<KhatmaPartEntity>.from(khatma.parts);
      updatedParts[partIndex] = updatedPart;

      // Update khatma
      final updatedKhatma = khatma.copyWith(parts: updatedParts);
      await dataSource.updateKhatma(updatedKhatma);

      // Add user record
      final userRecord = UserCollectiveKhatmaModel(
        khatmaId: khatmaId,
        khatmaTitle: khatma.title,
        assignedPart: partNumber,
        status: PartStatus.notRead,
        joinedAt: DateTime.now(),
      );
      await dataSource.addUserKhatmaRecord(userId, userRecord);

      return const Right(null);
    } catch (e) {
      log('❌ Error in joinKhatma: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveKhatma({
    required String khatmaId,
    required String userId,
    required int partNumber,
  }) async {
    try {
      final khatma = await dataSource.getKhatmaById(khatmaId);
      if (khatma == null) {
        return const Left(ServerFailure(message: 'الختمة غير موجودة'));
      }

      final partIndex = partNumber - 1;
      if (partIndex < 0 || partIndex >= khatma.parts.length) {
        return const Left(ServerFailure(message: 'رقم الجزء غير صالح'));
      }

      final part = khatma.parts[partIndex] as KhatmaPartModel;
      if (part.userId != userId) {
        return const Left(ServerFailure(message: 'هذا الجزء ليس محجوزاً لك'));
      }

      // Release the part
      final updatedPart = KhatmaPartModel.initial(partNumber);

      final updatedParts = List<KhatmaPartEntity>.from(khatma.parts);
      updatedParts[partIndex] = updatedPart;

      final updatedKhatma = khatma.copyWith(parts: updatedParts);
      await dataSource.updateKhatma(updatedKhatma);

      return const Right(null);
    } catch (e) {
      log('❌ Error in leaveKhatma: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completePart({
    required String khatmaId,
    required String userId,
    required int partNumber,
  }) async {
    try {
      final khatma = await dataSource.getKhatmaById(khatmaId);
      if (khatma == null) {
        return const Left(ServerFailure(message: 'الختمة غير موجودة'));
      }

      final partIndex = partNumber - 1;
      if (partIndex < 0 || partIndex >= khatma.parts.length) {
        return const Left(ServerFailure(message: 'رقم الجزء غير صالح'));
      }

      final part = khatma.parts[partIndex] as KhatmaPartModel;
      if (part.userId != userId) {
        return const Left(ServerFailure(message: 'هذا الجزء ليس محجوزاً لك'));
      }

      // Mark as completed
      final updatedPart = part.copyWith(status: PartStatus.read);

      final updatedParts = List<KhatmaPartEntity>.from(khatma.parts);
      updatedParts[partIndex] = updatedPart;

      final updatedKhatma = khatma.copyWith(parts: updatedParts);
      await dataSource.updateKhatma(updatedKhatma);

      // Update user record
      final userRecord = UserCollectiveKhatmaModel(
        khatmaId: khatmaId,
        khatmaTitle: khatma.title,
        assignedPart: partNumber,
        status: PartStatus.read,
        joinedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
      await dataSource.updateUserKhatmaRecord(userId, userRecord);

      return const Right(null);
    } catch (e) {
      log('❌ Error in completePart: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CollectiveKhatmaEntity>>>
  getPublicKhatmas() async {
    try {
      final khatmas = await dataSource.getPublicKhatmas();
      return Right(khatmas);
    } catch (e) {
      log('❌ Error in getPublicKhatmas: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CollectiveKhatmaEntity>>> searchKhatmas(
    String query,
  ) async {
    try {
      final khatmas = await dataSource.searchKhatmas(query);
      return Right(khatmas);
    } catch (e) {
      log('❌ Error in searchKhatmas: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserCollectiveKhatmaEntity>>> getUserKhatmas(
    String userId,
  ) async {
    try {
      final khatmas = await dataSource.getUserKhatmas(userId);
      return Right(khatmas);
    } catch (e) {
      log('❌ Error in getUserKhatmas: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUserCompletedKhatmasCount(
    String userId,
  ) async {
    try {
      final count = await dataSource.getUserCompletedKhatmasCount(userId);
      return Right(count);
    } catch (e) {
      log('❌ Error in getUserCompletedKhatmasCount: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, CollectiveKhatmaEntity>> watchKhatma(String khatmaId) {
    return dataSource.watchKhatma(khatmaId).map((khatma) {
      if (khatma == null) {
        return const Left(ServerFailure(message: 'الختمة غير موجودة'));
      }
      return Right(khatma);
    });
  }

  @override
  Stream<Either<Failure, List<CollectiveKhatmaEntity>>> watchPublicKhatmas() {
    return dataSource.watchPublicKhatmas().map((khatmas) => Right(khatmas));
  }

  @override
  Future<Either<Failure, int?>> getUserReservedPart({
    required String khatmaId,
    required String userId,
  }) async {
    try {
      final khatma = await dataSource.getKhatmaById(khatmaId);
      if (khatma == null) {
        return const Left(ServerFailure(message: 'الختمة غير موجودة'));
      }

      final userPart = khatma.parts.where((p) => p.userId == userId);
      if (userPart.isEmpty) {
        return const Right(null);
      }

      return Right(userPart.first.partNumber);
    } catch (e) {
      log('❌ Error in getUserReservedPart: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteKhatma({
    required String khatmaId,
    required String userId,
  }) async {
    try {
      final khatma = await dataSource.getKhatmaById(khatmaId);
      if (khatma == null) {
        return const Left(ServerFailure(message: 'الختمة غير موجودة'));
      }

      if (khatma.createdBy != userId) {
        return const Left(
          ServerFailure(message: 'لا يمكنك حذف ختمة لم تنشئها'),
        );
      }

      await dataSource.deleteKhatma(khatmaId);
      return const Right(null);
    } catch (e) {
      log('❌ Error in deleteKhatma: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CollectiveKhatmaEntity>>> getUserCreatedKhatmas(
    String userId,
  ) async {
    try {
      final khatmas = await dataSource.getUserCreatedKhatmas(userId);
      return Right(khatmas);
    } catch (e) {
      log('❌ Error in getUserCreatedKhatmas: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
