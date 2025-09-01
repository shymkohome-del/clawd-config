import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/error/domain_errors.dart';
import 'package:crypto_market/core/error/result.dart';

void main() {
  group('Domain Errors', () {
    group('AuthError', () {
      test('should create invalid credentials error', () {
        final error = AuthError.invalidCredentials();

        expect(error.type, equals(AuthErrorType.invalidCredentials));
        expect(error.message, equals('Invalid email or password'));
        expect(error.code, equals('AUTH_INVALID_CREDENTIALS'));
      });

      test('should create user not found error', () {
        final error = AuthError.userNotFound();

        expect(error.type, equals(AuthErrorType.userNotFound));
        expect(error.message, equals('User not found'));
        expect(error.code, equals('AUTH_USER_NOT_FOUND'));
      });

      test('should create custom message error', () {
        final error = AuthError.invalidCredentials('Custom message');

        expect(error.message, equals('Custom message'));
        expect(error.code, equals('AUTH_INVALID_CREDENTIALS'));
      });
    });

    group('NetworkError', () {
      test('should create connection timeout error', () {
        final error = NetworkError.connectionTimeout();

        expect(error.type, equals(NetworkErrorType.connectionTimeout));
        expect(error.message, contains('Connection timeout'));
        expect(error.code, equals('NETWORK_TIMEOUT'));
      });

      test('should create server error with status code', () {
        final error = NetworkError.serverError('Server error', 500);

        expect(error.type, equals(NetworkErrorType.serverError));
        expect(error.message, equals('Server error'));
        expect(error.code, equals('NETWORK_SERVER_ERROR'));
        expect(error.details?['statusCode'], equals(500));
      });
    });

    group('ValidationError', () {
      test('should create required field error', () {
        final error = ValidationError.required('email');

        expect(error.type, equals(ValidationErrorType.required));
        expect(error.field, equals('email'));
        expect(error.message, equals('email is required'));
        expect(error.code, equals('VALIDATION_REQUIRED'));
      });

      test('should create format error', () {
        final error = ValidationError.format('email');

        expect(error.type, equals(ValidationErrorType.format));
        expect(error.field, equals('email'));
        expect(error.message, equals('email format is invalid'));
        expect(error.code, equals('VALIDATION_FORMAT'));
      });
    });

    group('BusinessLogicError', () {
      test('should create insufficient balance error', () {
        final error = BusinessLogicError.insufficientBalance();

        expect(error.message, contains('Insufficient balance'));
        expect(error.code, equals('BUSINESS_INSUFFICIENT_BALANCE'));
      });

      test('should create market closed error', () {
        final error = BusinessLogicError.marketClosed();

        expect(error.message, contains('Market is currently closed'));
        expect(error.code, equals('BUSINESS_MARKET_CLOSED'));
      });
    });
  });

  group('Result', () {
    test('should create successful result', () {
      final result = Result.success('test data');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, equals('test data'));
      expect(result.dataOrNull, equals('test data'));
      expect(result.errorOrNull, isNull);
    });

    test('should create failure result', () {
      final error = AuthError.invalidCredentials();
      final result = Result.failure<String>(error);

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.error, equals(error));
      expect(result.errorOrNull, equals(error));
      expect(result.dataOrNull, isNull);
    });

    test('should map successful result', () {
      final result = Result.success(5);
      final mapped = result.map((data) => data * 2);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.data, equals(10));
    });

    test('should not map failure result', () {
      final error = AuthError.invalidCredentials();
      final result = Result.failure<int>(error);
      final mapped = result.map((data) => data * 2);

      expect(mapped.isFailure, isTrue);
      expect(mapped.error, equals(error));
    });

    test('should flatMap successful result', () {
      final result = Result.success(5);
      final flatMapped = result.flatMap(
        (data) => Result.success(data.toString()),
      );

      expect(flatMapped.isSuccess, isTrue);
      expect(flatMapped.data, equals('5'));
    });

    test('should not flatMap failure result', () {
      final error = AuthError.invalidCredentials();
      final result = Result.failure<int>(error);
      final flatMapped = result.flatMap(
        (data) => Result.success(data.toString()),
      );

      expect(flatMapped.isFailure, isTrue);
      expect(flatMapped.error, equals(error));
    });

    test('should fold results correctly', () {
      final successResult = Result.success(5);
      final failureResult = Result.failure<int>(AuthError.invalidCredentials());

      final successFolded = successResult.fold(
        (data) => 'Success: $data',
        (error) => 'Error: ${error.message}',
      );

      final failureFolded = failureResult.fold(
        (data) => 'Success: $data',
        (error) => 'Error: ${error.message}',
      );

      expect(successFolded, equals('Success: 5'));
      expect(failureFolded, contains('Error: Invalid email or password'));
    });

    test('should execute onSuccess callback for successful result', () {
      var callbackExecuted = false;
      final result = Result.success(5);

      result.onSuccess((data) {
        callbackExecuted = true;
      });

      expect(callbackExecuted, isTrue);
    });

    test('should execute onFailure callback for failure result', () {
      var callbackExecuted = false;
      final result = Result.failure<int>(AuthError.invalidCredentials());

      result.onFailure((error) {
        callbackExecuted = true;
      });

      expect(callbackExecuted, isTrue);
    });

    test('should wrap function calls with tryCall', () {
      final successResult = Result.tryCall(() => 'success');
      final failureResult = Result.tryCall(
        () => throw AuthError.invalidCredentials(),
      );

      expect(successResult.isSuccess, isTrue);
      expect(successResult.data, equals('success'));

      expect(failureResult.isFailure, isTrue);
      expect(failureResult.error, isA<AuthError>());
    });

    test('should convert unknown exceptions to domain errors', () {
      final result = Result.tryCall(() => throw Exception('Unknown error'));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessLogicError>());
      expect(result.error.code, equals('UNEXPECTED_ERROR'));
    });
  });

  group('Result Extensions', () {
    test('should get value or default', () {
      final successResult = Result.success(5);
      final failureResult = Result.failure<int>(AuthError.invalidCredentials());

      expect(successResult.getOrElse(0), equals(5));
      expect(failureResult.getOrElse(0), equals(0));
    });

    test('should get value or compute default', () {
      final successResult = Result.success(5);
      final failureResult = Result.failure<int>(AuthError.invalidCredentials());

      expect(successResult.getOrElseCompute(() => 10), equals(5));
      expect(failureResult.getOrElseCompute(() => 10), equals(10));
    });

    test('should convert to nullable', () {
      final successResult = Result.success(5);
      final failureResult = Result.failure<int>(AuthError.invalidCredentials());

      expect(successResult.toNullable(), equals(5));
      expect(failureResult.toNullable(), isNull);
    });
  });
}
