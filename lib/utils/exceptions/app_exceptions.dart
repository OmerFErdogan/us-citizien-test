/// Custom exception classes for better error handling
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Data loading/parsing exceptions
class DataException extends AppException {
  const DataException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Storage related exceptions (SharedPreferences, etc.)
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Service initialization exceptions
class ServiceException extends AppException {
  const ServiceException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// User input validation exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// AdMob/Revenue related exceptions
class MonetizationException extends AppException {
  const MonetizationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Localization related exceptions
class LocalizationException extends AppException {
  const LocalizationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Unknown/Unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.originalError,
  });
}
