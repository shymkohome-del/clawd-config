import 'dart:io';
import 'package:dio/dio.dart';

/// Simple Result type for success/error returns.
class Result<T, E> {
  final T? _ok;
  final E? _err;

  const Result._(this._ok, this._err);

  const Result.ok(T value) : this._(value, null);
  const Result.err(E error) : this._(null, error);

  bool get isOk => _err == null;
  bool get isErr => _ok == null;

  T get ok => _ok as T;
  E get err => _err as E;
}

enum AuthError { invalidCredentials, oauthDenied, network, unknown }

/// Domain-specific exceptions used for error mapping.
class AuthInvalidCredentialsException implements Exception {}

class OAuthDeniedException implements Exception {}

/// Maps low-level exceptions to domain-specific [AuthError] values.
AuthError mapAuthException(Object error) {
  if (error is AuthInvalidCredentialsException) {
    return AuthError.invalidCredentials;
  }
  if (error is OAuthDeniedException) {
    return AuthError.oauthDenied;
  }
  if (error is DioException ||
      error is SocketException ||
      error is HttpException) {
    return AuthError.network;
  }
  return AuthError.unknown;
}
