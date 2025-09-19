import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/auth/secure_storage_service.dart';
import 'package:crypto_market/core/auth/jwt_service.dart';
import 'package:crypto_market/core/config/app_config.dart';

void main() {
  group('ICP Service Validation', () {
    late ICPService icpService;
    late SecureStorageService secureStorage;
    late JWTService jwtService;

    setUp(() {
      // Create a minimal config for testing
      final config = AppConfig(
        featurePrincipalShim: true,
        canisterIdUserManagement: 'test-canister-id',
        // Add other required fields as needed
      );

      secureStorage = SecureStorageService();
      jwtService = JWTService();
      icpService = ICPService._(
        config,
        'test-canister-id',
        secureStorage,
        jwtService,
      );
    });

    test('ICPKeyPair generation works', () {
      final keyPair = ICPKeyPair.generate();

      expect(keyPair.principalId, isNotNull);
      expect(keyPair.principalId, startsWith('principal-'));
      expect(keyPair.privateKey, isNotNull);
      expect(keyPair.publicKey, isNotNull);
      expect(keyPair.createdAt, isNotNull);
    });

    test('ICPKeyPair serialization works', () {
      final original = ICPKeyPair.generate();
      final json = original.toJson();
      final restored = ICPKeyPair.fromJson(json);

      expect(restored.principalId, equals(original.principalId));
      expect(restored.privateKey, equals(original.privateKey));
      expect(restored.publicKey, equals(original.publicKey));
      expect(restored.createdAt, equals(original.createdAt));
    });

    test('Password validation works', () {
      expect(icpService._isValidPassword(''), isFalse);
      expect(icpService._isValidPassword('short'), isFalse);
      expect(icpService._isValidPassword('longenoughpassword'), isFalse);
      expect(icpService._isValidPassword('LongEnough123'), isTrue);
      expect(icpService._isValidPassword('LongEnough123!@#'), isTrue);
    });

    test('Email validation works', () {
      expect(icpService._isValidEmail(''), isFalse);
      expect(icpService._isValidEmail('invalid'), isFalse);
      expect(icpService._isValidEmail('invalid@'), isFalse);
      expect(icpService._isValidEmail('invalid@domain'), isFalse);
      expect(icpService._isValidEmail('valid@example.com'), isTrue);
      expect(icpService._isValidEmail('user.name+tag@domain.co.uk'), isTrue);
    });

    test('Username validation works', () {
      expect(icpService._isValidUsername(''), isFalse);
      expect(icpService._isValidUsername('a'), isFalse);
      expect(icpService._isValidUsername('ab'), isFalse);
      expect(icpService._isValidUsername('validuser123'), isTrue);
      expect(icpService._isValidUsername('valid_user'), isTrue);
      expect(icpService._isValidUsername('invalid-user'), isFalse);
      expect(icpService._isValidUsername('invalid@user'), isFalse);
    });

    test('User model creation works', () {
      final user = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        principalId: 'test-principal',
      );

      expect(user.id, equals('test-id'));
      expect(user.email, equals('test@example.com'));
      expect(user.username, equals('testuser'));
      expect(user.authProvider, equals('email'));
      expect(user.principalId, equals('test-principal'));
    });

    test('JWT token generation works', () {
      final token = jwtService.generateToken(
        userId: 'test-user-id',
        email: 'test@example.com',
        username: 'testuser',
        authProvider: 'email',
      );

      expect(token, isNotNull);
      expect(token, contains('.'));

      // Validate token format
      final parts = token.split('.');
      expect(parts.length, equals(3));
    });

    test('Secure storage service can be instantiated', () {
      expect(secureStorage, isNotNull);
      expect(secureStorage, isA<SecureStorageService>());
    });
  });
}
