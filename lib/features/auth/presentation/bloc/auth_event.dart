import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String language;
  final String country;

  const SignUpRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.language,
    required this.country,
  });

  @override
  List<Object?> get props => [name, email, password, language, country];
}

class SignOutRequested extends AuthEvent {}

class SendEmailVerificationRequested extends AuthEvent {}

class RegisterAsGuestRequested extends AuthEvent {}

class UpdateLanguageRequested extends AuthEvent {
  final String language;

  const UpdateLanguageRequested(this.language);

  @override
  List<Object?> get props => [language];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final BuildContext context;

  const ResetPasswordRequested(this.email, this.context);

  @override
  List<Object?> get props => [email];
}

class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();

  @override
  List<Object?> get props => [];
}
