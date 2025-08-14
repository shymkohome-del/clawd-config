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
