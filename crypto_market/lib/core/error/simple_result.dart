/// Simple Result type for validation services
/// Matches the pattern used in tests: Result.ok(value) and Result.err(error)
class Result<T, E> {
  final T? _value;
  final E? _error;
  final bool _isSuccess;

  Result._(this._value, this._error, this._isSuccess);

  /// Create a successful result
  factory Result.ok(T value) => Result._(value, null, true);

  /// Create an error result
  factory Result.err(E error) => Result._(null, error, false);

  /// Check if result is successful
  bool isOk() => _isSuccess;

  /// Check if result is an error
  bool isErr() => !_isSuccess;

  /// Get the success value
  T unwrap() {
    if (_isSuccess) {
      return _value!;
    }
    throw StateError('Cannot unwrap error result');
  }

  /// Get the error value
  E unwrapErr() {
    if (!_isSuccess) {
      return _error!;
    }
    throw StateError('Cannot unwrap success result');
  }

  /// Get success value or null
  T? get ok => _value;

  /// Get error value or null
  E? get err => _error;
}
