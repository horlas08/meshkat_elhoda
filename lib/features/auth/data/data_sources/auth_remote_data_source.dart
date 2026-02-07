import 'package:meshkat_elhoda/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  // Check if user is signed in
  Future<bool> isSignedIn();

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String language,
  });

  // Send email verification
  Future<void> sendEmailVerification();

  // Sign out
  Future<void> signOut();

  // Get current user
  Future<UserModel?> getCurrentUser();

  // Check if email is verified
  bool isEmailVerified();

  // Get auth state changes
  Stream<UserModel?> authStateChanges();

  // Sign in anonymously
  Future<UserModel> signInAnonymously();

  // Update user language
  Future<void> updateUserLanguage(String language);

  // Reset password
  Future<void> resetPassword(String email);

  // Delete account
  Future<void> deleteAccount();
}
