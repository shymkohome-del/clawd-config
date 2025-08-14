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

/// Represents a successful result with no meaningful value.
class Unit {
  const Unit();
}

/// Maps low-level exceptions to domain-level [AuthError] values.
AuthError mapAuthExceptionToAuthError(Object error) {
  // Network-like exceptions
  final lower = error.toString().toLowerCase();
  if (lower.contains('socket') ||
      lower.contains('network') ||
      lower.contains('timeout')) {
    return AuthError.network;
  }

  // Common auth failure patterns
  if (lower.contains('invalid') && lower.contains('credential')) {
    return AuthError.invalidCredentials;
  }
  if (lower.contains('oauth') &&
      (lower.contains('denied') || lower.contains('cancel'))) {
    return AuthError.oauthDenied;
  }

  return AuthError.unknown;
}
