import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/auth/secure_storage_service.dart';
import 'package:crypto_market/core/auth/jwt_service.dart';

void main() {
  group('Registration Validation Tests', () {
    late SecureStorageService secureStorage;
    late JWTService jwtService;

    setUp(() {
      secureStorage = SecureStorageService();
      jwtService = JWTService();
    });

    test('ICPKeyPair generation works correctly', () {
      final keyPair = ICPKeyPair.generate();

      expect(keyPair.principalId, isNotNull);
      expect(keyPair.principalId, startsWith('principal-'));
      expect(keyPair.principalId.length, greaterThan(10));

      expect(keyPair.privateKey, isNotNull);
      expect(keyPair.privateKey, startsWith('private-'));
      expect(keyPair.privateKey.length, greaterThan(10));

      expect(keyPair.publicKey, isNotNull);
      expect(keyPair.publicKey, startsWith('public-'));
      expect(keyPair.publicKey.length, greaterThan(10));

      expect(keyPair.createdAt, isNotNull);
      expect(keyPair.createdAt.isBefore(DateTime.now()), isTrue);
      expect(
        keyPair.createdAt.isAfter(DateTime.now().subtract(Duration(hours: 1))),
        isTrue,
      );
    });

    test('ICPKeyPair serialization and deserialization works', () {
      final original = ICPKeyPair.generate();
      final json = original.toJson();
      final restored = ICPKeyPair.fromJson(json);

      expect(restored.principalId, equals(original.principalId));
      expect(restored.privateKey, equals(original.privateKey));
      expect(restored.publicKey, equals(original.publicKey));
      expect(restored.createdAt, equals(original.createdAt));
    });

    test('Different ICPKeyPairs generate different principals', () {
      final keyPair1 = ICPKeyPair.generate();
      final keyPair2 = ICPKeyPair.generate();

      expect(keyPair1.principalId, isNot(equals(keyPair2.principalId)));
      expect(keyPair1.privateKey, isNot(equals(keyPair2.privateKey)));
      expect(keyPair1.publicKey, isNot(equals(keyPair2.publicKey)));
    });

    test('JWT token generation works correctly', () {
      final token = jwtService.generateToken(
        userId: 'test-user-id',
        email: 'test@example.com',
        username: 'testuser',
        authProvider: 'email',
      );

      expect(token, isNotNull);
      expect(token, contains('.'));

      // Validate token format (header.payload.signature)
      final parts = token.split('.');
      expect(parts.length, equals(3));

      // Validate parts are not empty
      expect(parts[0], isNotEmpty);
      expect(parts[1], isNotEmpty);
      expect(parts[2], isNotEmpty);
    });

    test('JWT token validation works correctly', () {
      final token = jwtService.generateToken(
        userId: 'test-user-id',
        email: 'test@example.com',
        username: 'testuser',
        authProvider: 'email',
      );

      final result = jwtService.validateToken(token);
      expect(result.isOk, isTrue);

      final payload = result.ok;
      expect(payload.sub, equals('test-user-id'));
      expect(payload.email, equals('test@example.com'));
      expect(payload.username, equals('testuser'));
      expect(payload.authProvider, equals('email'));
      expect(payload.roles, isEmpty);
      expect(payload.isExpired, isFalse);
    });

    test('JWT token with invalid signature fails validation', () {
      final validToken = jwtService.generateToken(
        userId: 'test-user-id',
        email: 'test@example.com',
      );

      // Tamper with the signature
      final parts = validToken.split('.');
      final tamperedToken = '${parts[0]}.${parts[1]}.tampered-signature';

      final result = jwtService.validateToken(tamperedToken);
      expect(result.isErr, isTrue);
      expect(result.err, contains('Invalid token signature'));
    });

    test('JWT token validation handles malformed tokens', () {
      final malformedTokens = [
        '',
        'invalid.token',
        'invalid.token.format',
        'header.payload.',
        '.payload.signature',
        'header..signature',
      ];

      for (final token in malformedTokens) {
        final result = jwtService.validateToken(token);
        expect(
          result.isErr,
          isTrue,
          reason: 'Token "$token" should fail validation',
        );
      }
    });

    test('JWT service handles token storage and retrieval', () async {
      final token = jwtService.generateToken(
        userId: 'test-user-id',
        email: 'test@example.com',
      );

      // Store token
      await jwtService.storeToken(token);

      // Retrieve token
      final retrievedToken = await jwtService.getToken();
      expect(retrievedToken, equals(token));

      // Delete token
      await jwtService.deleteToken();

      // Verify token is deleted
      final deletedToken = await jwtService.getToken();
      expect(deletedToken, isNull);
    });

    test('Secure storage service can be instantiated', () {
      expect(secureStorage, isNotNull);
      expect(secureStorage, isA<SecureStorageService>());
    });

    test('Email validation regex works correctly', () {
      final validEmails = [
        'test@example.com',
        'user.name+tag@domain.co.uk',
        'user123@test.domain.com',
        'test@localhost',
      ];

      final invalidEmails = [
        '',
        'invalid',
        'invalid@',
        'invalid@domain',
        '@domain.com',
        'test@.com',
        'test@domain.',
      ];

      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      for (final email in validEmails) {
        expect(
          emailRegex.hasMatch(email),
          isTrue,
          reason: '$email should be valid',
        );
      }

      for (final email in invalidEmails) {
        expect(
          emailRegex.hasMatch(email),
          isFalse,
          reason: '$email should be invalid',
        );
      }
    });

    test('Password validation requirements work correctly', () {
      // Valid passwords
      final validPasswords = [
        'LongEnough123',
        'Password123!',
        'MySecurePass123',
        'Test1234',
      ];

      // Invalid passwords
      final invalidPasswords = [
        '', // empty
        'short', // too short
        'longenoughpassword', // no numbers
        'longenoughpassword123', // no uppercase
        'LONGENOUGH123', // no lowercase
        'Long Enough 123', // spaces not allowed
      ];

      for (final password in validPasswords) {
        final isValid =
            password.length >= 8 &&
            password.length <= 128 &&
            password.contains(RegExp(r'[A-Z]')) &&
            password.contains(RegExp(r'[a-z]')) &&
            password.contains(RegExp(r'[0-9]'));
        expect(isValid, isTrue, reason: '$password should be valid');
      }

      for (final password in invalidPasswords) {
        final isValid =
            password.length >= 8 &&
            password.length <= 128 &&
            password.contains(RegExp(r'[A-Z]')) &&
            password.contains(RegExp(r'[a-z]')) &&
            password.contains(RegExp(r'[0-9]'));
        expect(isValid, isFalse, reason: '$password should be invalid');
      }
    });

    test('Username validation works correctly', () {
      // Valid usernames
      final validUsernames = [
        'testuser',
        'test_user',
        'user123',
        'test_user_123',
        'a'.padRight(20, 'b'), // max length
      ];

      // Invalid usernames
      final invalidUsernames = [
        '', // empty
        'ab', // too short
        'a'.padRight(21, 'b'), // too long
        'invalid-user', // contains dash
        'invalid@user', // contains @
        'invalid.user', // contains dot
        'user name', // contains space
      ];

      for (final username in validUsernames) {
        final isValid =
            username.length >= 3 &&
            username.length <= 20 &&
            RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
        expect(isValid, isTrue, reason: '$username should be valid');
      }

      for (final username in invalidUsernames) {
        final isValid =
            username.length >= 3 &&
            username.length <= 20 &&
            RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
        expect(isValid, isFalse, reason: '$username should be invalid');
      }
    });
  });
}
