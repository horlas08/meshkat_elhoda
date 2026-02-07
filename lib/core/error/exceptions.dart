// Custom exceptions for the application

class ServerException implements Exception {
  final String message;
  final int statusCode;

  const ServerException({
    required this.message,
    this.statusCode = 500,
  });

  @override
  String toString() => 'ServerException: $message (Status code: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const CacheException({
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const NetworkException({
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() => 'NetworkException: $message';
}
