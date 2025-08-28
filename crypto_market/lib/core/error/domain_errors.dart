/// Base class for all domain errors in the application
abstract class DomainError implements Exception {
  const DomainError(this.message, {this.code, this.details});

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  @override
  String toString() =>
      'DomainError: $message${code != null ? ' (code: $code)' : ''}';
}

/// Authentication related errors
enum AuthErrorType {
  invalidCredentials,
  userNotFound,
  emailAlreadyExists,
  weakPassword,
  accountLocked,
  sessionExpired,
  invalidToken,
  principalMismatch,
  registrationFailed,
  loginFailed,
}

class AuthError extends DomainError {
  const AuthError(
    this.type,
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  final AuthErrorType type;

  factory AuthError.invalidCredentials([String? message]) => AuthError(
    AuthErrorType.invalidCredentials,
    message ?? 'Invalid email or password',
    code: 'AUTH_INVALID_CREDENTIALS',
  );

  factory AuthError.userNotFound([String? message]) => AuthError(
    AuthErrorType.userNotFound,
    message ?? 'User not found',
    code: 'AUTH_USER_NOT_FOUND',
  );

  factory AuthError.emailAlreadyExists([String? message]) => AuthError(
    AuthErrorType.emailAlreadyExists,
    message ?? 'An account with this email already exists',
    code: 'AUTH_EMAIL_EXISTS',
  );

  factory AuthError.weakPassword([String? message]) => AuthError(
    AuthErrorType.weakPassword,
    message ?? 'Password is too weak',
    code: 'AUTH_WEAK_PASSWORD',
  );

  factory AuthError.accountLocked([String? message]) => AuthError(
    AuthErrorType.accountLocked,
    message ?? 'Account is temporarily locked',
    code: 'AUTH_ACCOUNT_LOCKED',
  );

  factory AuthError.sessionExpired([String? message]) => AuthError(
    AuthErrorType.sessionExpired,
    message ?? 'Your session has expired. Please log in again',
    code: 'AUTH_SESSION_EXPIRED',
  );

  factory AuthError.invalidToken([String? message]) => AuthError(
    AuthErrorType.invalidToken,
    message ?? 'Invalid authentication token',
    code: 'AUTH_INVALID_TOKEN',
  );

  factory AuthError.principalMismatch([String? message]) => AuthError(
    AuthErrorType.principalMismatch,
    message ?? 'Principal mismatch in ICP authentication',
    code: 'AUTH_PRINCIPAL_MISMATCH',
  );

  factory AuthError.registrationFailed([String? message]) => AuthError(
    AuthErrorType.registrationFailed,
    message ?? 'Registration failed. Please try again',
    code: 'AUTH_REGISTRATION_FAILED',
  );

  factory AuthError.loginFailed([String? message]) => AuthError(
    AuthErrorType.loginFailed,
    message ?? 'Login failed. Please try again',
    code: 'AUTH_LOGIN_FAILED',
  );
}

/// Network related errors
enum NetworkErrorType {
  connectionTimeout,
  noInternet,
  serverError,
  canisterUnavailable,
  rateLimitExceeded,
  invalidResponse,
  requestFailed,
}

class NetworkError extends DomainError {
  const NetworkError(
    this.type,
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  final NetworkErrorType type;

  factory NetworkError.connectionTimeout([String? message]) => NetworkError(
    NetworkErrorType.connectionTimeout,
    message ?? 'Connection timeout. Please check your internet connection',
    code: 'NETWORK_TIMEOUT',
  );

  factory NetworkError.noInternet([String? message]) => NetworkError(
    NetworkErrorType.noInternet,
    message ?? 'No internet connection available',
    code: 'NETWORK_NO_INTERNET',
  );

  factory NetworkError.serverError([String? message, int? statusCode]) =>
      NetworkError(
        NetworkErrorType.serverError,
        message ?? 'Server error occurred',
        code: 'NETWORK_SERVER_ERROR',
        details: statusCode != null ? {'statusCode': statusCode} : null,
      );

  factory NetworkError.canisterUnavailable([String? message]) => NetworkError(
    NetworkErrorType.canisterUnavailable,
    message ?? 'ICP canister is currently unavailable',
    code: 'NETWORK_CANISTER_UNAVAILABLE',
  );

  factory NetworkError.rateLimitExceeded([String? message]) => NetworkError(
    NetworkErrorType.rateLimitExceeded,
    message ?? 'Too many requests. Please wait and try again',
    code: 'NETWORK_RATE_LIMIT',
  );

  factory NetworkError.invalidResponse([String? message]) => NetworkError(
    NetworkErrorType.invalidResponse,
    message ?? 'Invalid response from server',
    code: 'NETWORK_INVALID_RESPONSE',
  );

  factory NetworkError.requestFailed([String? message]) => NetworkError(
    NetworkErrorType.requestFailed,
    message ?? 'Request failed',
    code: 'NETWORK_REQUEST_FAILED',
  );
}

/// Validation related errors
enum ValidationErrorType { required, format, length, range, custom }

class ValidationError extends DomainError {
  const ValidationError(
    this.type,
    this.field,
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  final ValidationErrorType type;
  final String field;

  factory ValidationError.required(String field, [String? message]) =>
      ValidationError(
        ValidationErrorType.required,
        field,
        message ?? '$field is required',
        code: 'VALIDATION_REQUIRED',
      );

  factory ValidationError.format(String field, [String? message]) =>
      ValidationError(
        ValidationErrorType.format,
        field,
        message ?? '$field format is invalid',
        code: 'VALIDATION_FORMAT',
      );

  factory ValidationError.length(String field, [String? message]) =>
      ValidationError(
        ValidationErrorType.length,
        field,
        message ?? '$field length is invalid',
        code: 'VALIDATION_LENGTH',
      );

  factory ValidationError.range(String field, [String? message]) =>
      ValidationError(
        ValidationErrorType.range,
        field,
        message ?? '$field is out of range',
        code: 'VALIDATION_RANGE',
      );

  factory ValidationError.custom(
    String field,
    String message, [
    String? code,
  ]) => ValidationError(
    ValidationErrorType.custom,
    field,
    message,
    code: code ?? 'VALIDATION_CUSTOM',
  );
}

/// Business logic related errors
class BusinessLogicError extends DomainError {
  const BusinessLogicError(super.message, {super.code, super.details});

  factory BusinessLogicError.insufficientBalance([String? message]) =>
      BusinessLogicError(
        message ?? 'Insufficient balance for this transaction',
        code: 'BUSINESS_INSUFFICIENT_BALANCE',
      );

  factory BusinessLogicError.marketClosed([String? message]) =>
      BusinessLogicError(
        message ?? 'Market is currently closed',
        code: 'BUSINESS_MARKET_CLOSED',
      );

  factory BusinessLogicError.invalidOperation([String? message]) =>
      BusinessLogicError(
        message ?? 'This operation is not allowed',
        code: 'BUSINESS_INVALID_OPERATION',
      );
}
