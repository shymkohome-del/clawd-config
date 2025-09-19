import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/config/app_config.dart';

void main() {
  group('ICP Service Integration Tests', () {
    late ICPService icpService;
    late AppConfig testConfig;

    setUp(() {
      testConfig = AppConfig(
        canisterIdUserManagement: 'test-canister-id',
        featurePrincipalShim: true,
        // Add other required config fields as needed
      );
      icpService = ICPService.fromConfig(testConfig);
    });

    test('Service initializes with correct canister ID', () {
      expect(icpService.userManagementCanisterId, equals('test-canister-id'));
    });

    test('Register user with valid data succeeds', () async {
      final result = await icpService.register(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      );

      expect(result.isOk, isTrue);
      expect(result.ok.email, equals('test@example.com'));
      expect(result.ok.username, equals('testuser'));
      expect(result.ok.authProvider, equals('email'));
      expect(result.ok.id, isNotNull);
    });

    test('Register user with existing email returns error', () async {
      // Configure with principal shim disabled to test error path
      final errorConfig = AppConfig(
        canisterIdUserManagement: 'test-canister-id',
        featurePrincipalShim: false,
      );
      final errorService = ICPService.fromConfig(errorConfig);

      final result = await errorService.register(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      );

      expect(result.isErr, isTrue);
      expect(result.err, equals(AuthError.unknown));
    });

    test('Login with email and password succeeds', () async {
      final result = await icpService.loginWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isOk, isTrue);
      expect(result.ok.email, equals('test@example.com'));
      expect(result.ok.authProvider, equals('email'));
    });

    test('Login with OAuth succeeds', () async {
      final result = await icpService.loginWithOAuth(
        provider: 'google',
        token: 'valid-token',
      );

      expect(result.isOk, isTrue);
      expect(result.ok.authProvider, equals('google'));
    });

    test('Login with invalid OAuth provider fails', () async {
      final result = await icpService.loginWithOAuth(
        provider: 'invalid-provider',
        token: 'valid-token',
      );

      expect(result.isErr, isTrue);
      expect(result.err, equals(AuthError.oauthDenied));
    });

    test('Get user profile works', () async {
      final result = await icpService.getUserProfile(
        principal: 'test-principal',
      );

      expect(result.isOk, isTrue);
    });
  });
}
