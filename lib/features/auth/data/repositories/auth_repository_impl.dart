import 'package:meshkat_elhoda/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:meshkat_elhoda/features/auth/domain/entities/user_entity.dart';
import 'package:meshkat_elhoda/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<bool> isSignedIn() => _remoteDataSource.isSignedIn();

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String language,
    required String country,
  }) async {
    return await _remoteDataSource.signUpWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
      language: language,
    );
  }

  @override
  Future<void> sendEmailVerification() =>
      _remoteDataSource.sendEmailVerification();

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  bool isEmailVerified() => _remoteDataSource.isEmailVerified();

  @override
  Stream<UserEntity?> authStateChanges() =>
      _remoteDataSource.authStateChanges();

  @override
  Future<UserEntity> signInAnonymously() =>
      _remoteDataSource.signInAnonymously();

  @override
  Future<void> updateUserLanguage(String language) =>
      _remoteDataSource.updateUserLanguage(language);

  @override
  Future<void> resetPassword(String email) =>
      _remoteDataSource.resetPassword(email);

  @override
  Future<void> deleteAccount() => _remoteDataSource.deleteAccount();
}
