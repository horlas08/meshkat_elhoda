import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, stackTrace];
}

class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    StackTrace? stackTrace,
  }) : super(message: message, stackTrace: stackTrace);
}

class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    StackTrace? stackTrace,
  }) : super(message: message, stackTrace: stackTrace);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    StackTrace? stackTrace,
  }) : super(message: message, stackTrace: stackTrace);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    StackTrace? stackTrace,
  }) : super(message: message, stackTrace: stackTrace);
}
