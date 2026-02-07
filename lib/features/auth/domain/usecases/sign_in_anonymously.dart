import 'package:meshkat_elhoda/core/error/exceptions.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/features/auth/domain/entities/user_entity.dart';
import 'package:meshkat_elhoda/features/auth/domain/repositories/auth_repository.dart';

class SignInAnonymously {
  final AuthRepository repository;

  SignInAnonymously(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    try {
      final user = await repository.signInAnonymously();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }
}
