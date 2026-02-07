import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SignInLoading extends AuthState {}

class GuestSignInLoading extends AuthState {}

class SignUpLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmailVerificationSent extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final bool isGuest;

  const AuthSuccess(this.message, {this.isGuest = false});

  @override
  List<Object?> get props => [message, isGuest];
}

class SignUpSuccess extends AuthState {
  final String message;

  const SignUpSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetPasswordLoading extends AuthState {}

class PasswordResetEmailSent extends AuthState {
  final String message;

  const PasswordResetEmailSent(this.message);

  @override
  List<Object?> get props => [message];
}
