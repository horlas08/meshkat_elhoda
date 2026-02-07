import 'package:dartz/dartz.dart';
import 'package:meshkat_elhoda/core/error/failures.dart';
import 'package:meshkat_elhoda/features/auth/domain/entities/user_entity.dart';
import 'package:meshkat_elhoda/features/auth/domain/repositories/auth_repository.dart';

class SignUpWithEmailAndPassword {
  final AuthRepository repository;

  SignUpWithEmailAndPassword(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required String language,
    required String country,
  }) async {
    try {
      final user = await repository.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        language: language,
        country: country,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
