import 'domain_errors.dart';

/// A Result type that represents either success (data) or failure (error)
/// This is used throughout the service layer for error handling
sealed class Result<T> {
  const Result();

  /// Check if the result is successful
  bool get isSuccess => this is Success<T>;

  /// Check if the result is a failure
  bool get isFailure => this is Failure<T>;

  /// Get the data if successful, throws if failure
  T get data {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure<T>() => throw StateError('Cannot get data from failure result'),
    };
  }

  /// Get the error if failure, throws if successful
  DomainError get error {
    return switch (this) {
      Success<T>() => throw StateError('Cannot get error from success result'),
      Failure<T>(:final error) => error,
    };
  }

  /// Get data if successful, otherwise return null
  T? get dataOrNull {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure<T>() => null,
    };
  }

  /// Get error if failure, otherwise return null
  DomainError? get errorOrNull {
    return switch (this) {
      Success<T>() => null,
      Failure<T>(:final error) => error,
    };
  }

  /// Transform the data if successful
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Result.success(transform(data)),
      Failure<T>(:final error) => Result.failure(error),
    };
  }

  /// Chain operations that return Results
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => transform(data),
      Failure<T>(:final error) => Result.failure(error),
    };
  }

  /// Transform the error if failure
  Result<T> mapError(DomainError Function(DomainError error) transform) {
    return switch (this) {
      Success<T>() => this,
      Failure<T>(:final error) => Result.failure(transform(error)),
    };
  }

  /// Handle the result with separate callbacks for success and failure
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(DomainError error) onFailure,
  ) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Failure<T>(:final error) => onFailure(error),
    };
  }

  /// Execute side effects without transforming the result
  Result<T> onSuccess(void Function(T data) callback) {
    if (this case Success<T>(:final data)) {
      callback(data);
    }
    return this;
  }

  /// Execute side effects on failure without transforming the result
  Result<T> onFailure(void Function(DomainError error) callback) {
    if (this case Failure<T>(:final error)) {
      callback(error);
    }
    return this;
  }

  /// Create a successful result
  static Result<T> success<T>(T data) => Success._(data);

  /// Create a failure result
  static Result<T> failure<T>(DomainError error) => Failure._(error);

  /// Wrap a function call in a Result, catching exceptions
  static Result<T> tryCall<T>(T Function() callback) {
    try {
      return Result.success(callback());
    } on DomainError catch (e) {
      return Result.failure(e);
    } catch (e, stackTrace) {
      // Convert unknown exceptions to domain errors
      return Result.failure(
        BusinessLogicError(
          'Unexpected error occurred: ${e.toString()}',
          code: 'UNEXPECTED_ERROR',
          details: {
            'originalException': e.toString(),
            'stackTrace': stackTrace.toString(),
          },
        ),
      );
    }
  }

  /// Wrap an async function call in a Result, catching exceptions
  static Future<Result<T>> tryCallAsync<T>(
    Future<T> Function() callback,
  ) async {
    try {
      final data = await callback();
      return Result.success(data);
    } on DomainError catch (e) {
      return Result.failure(e);
    } catch (e, stackTrace) {
      // Convert unknown exceptions to domain errors
      return Result.failure(
        BusinessLogicError(
          'Unexpected error occurred: ${e.toString()}',
          code: 'UNEXPECTED_ERROR',
          details: {
            'originalException': e.toString(),
            'stackTrace': stackTrace.toString(),
          },
        ),
      );
    }
  }
}

/// Success result containing data
final class Success<T> extends Result<T> {
  const Success._(this.data);

  @override
  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.data == data);

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Failure result containing error
final class Failure<T> extends Result<T> {
  const Failure._(this.error);

  @override
  final DomainError error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Failure<T> && other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Extension methods for working with Results
extension ResultExtensions<T> on Result<T> {
  /// Get data or provide a default value
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure<T>() => defaultValue,
    };
  }

  /// Get data or compute a default value
  T getOrElseCompute(T Function() computeDefault) {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure<T>() => computeDefault(),
    };
  }

  /// Convert to nullable value (success -> data, failure -> null)
  T? toNullable() => dataOrNull;
}

/// Extension for working with Future Result types
extension FutureResultExtensions<T> on Future<Result<T>> {
  /// Transform data if successful
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    final result = await this;
    return switch (result) {
      Success<T>(:final data) => Result.success(await transform(data)),
      Failure<T>(:final error) => Result.failure(error),
    };
  }

  /// Chain async operations that return Results
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T data) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success<T>(:final data) => await transform(data),
      Failure<T>(:final error) => Result.failure(error),
    };
  }
}
