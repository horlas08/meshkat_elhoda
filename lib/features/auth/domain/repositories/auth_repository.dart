import 'package:meshkat_elhoda/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  // Check if user is signed in
  Future<bool> isSignedIn();

  // Sign in with email and password
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Sign up with email and password
  Future<UserEntity> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String language,
    required String country,
  });

  // Send email verification
  Future<void> sendEmailVerification();

  // Sign out
  Future<void> signOut();

  // Get current user
  Future<UserEntity?> getCurrentUser();

  // Check if email is verified
  bool isEmailVerified();

  // Get auth state changes
  Stream<UserEntity?> authStateChanges();

  // Sign in anonymously
  Future<UserEntity> signInAnonymously();

  // Update user language
  Future<void> updateUserLanguage(String language);

  // Reset password
  Future<void> resetPassword(String email);

  // Delete account
  Future<void> deleteAccount();
}
