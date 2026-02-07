import 'package:equatable/equatable.dart';

class AppException extends Equatable {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  List<Object?> get props => [message, code, originalException];

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}
