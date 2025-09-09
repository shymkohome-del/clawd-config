import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/config/app_config.dart';

void main() {
  group('Auth Integration Tests', () {
    late ICPService icpService;

    setUp(() {
      final config = AppConfig(
        canisterIdMarketplace: 'local-marketplace-id',
        canisterIdUserManagement: 'local-user-management-id',
        canisterIdAtomicSwap: 'local-atomic-swap-id',
        canisterIdPriceOracle: 'local-price-oracle-id',
        featurePrincipalShim: true,
        oauthGoogleClientId: 'mock-google-client',
        oauthGoogleClientSecret: 'mock-google-secret',
        oauthAppleTeamId: 'mock-apple-team',
        oauthAppleKeyId: 'mock-apple-key',
        ipfsNodeUrl: 'http://localhost:5001',
        ipfsGatewayUrl: 'http://localhost:8080',
      );
      icpService = ICPService.fromConfig(config);
    });

    test('should register user with blockchain integration', () async {
      final result = await icpService.register(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      );

      // Debug output
      if (result.isErr) {
        print('Registration error: ${result.err}');
      }

      expect(result.isOk, isTrue);
      final user = result.ok;
      expect(user.email, equals('test@example.com'));
      expect(user.username, equals('testuser'));
      expect(user.authProvider, equals('email'));
      expect(user.id, isNotEmpty);
      expect(user.id, isNot(equals(''))); // Should not be empty with blockchain integration
    });

    test('should login user with blockchain integration', () async {
      final result = await icpService.loginWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isOk, isTrue);
      final user = result.ok;
      expect(user.email, equals('test@example.com'));
      expect(user.authProvider, equals('email'));
      expect(user.id, isNotEmpty);
      expect(user.id, isNot(equals(''))); // Should not be empty with blockchain integration
    });

    test('should handle oauth login with blockchain integration', () async {
      final result = await icpService.loginWithOAuth(
        provider: 'google',
        token: 'mock-google-token',
      );

      expect(result.isOk, isTrue);
      final user = result.ok;
      expect(user.authProvider, equals('google'));
      expect(user.id, isNotEmpty);
      expect(user.id, isNot(equals(''))); // Should not be empty with blockchain integration
    });

    test('should reject invalid oauth provider', () async {
      final result = await icpService.loginWithOAuth(
        provider: 'facebook',
        token: 'mock-facebook-token',
      );

      expect(result.isErr, isTrue);
    });

    test('should reject empty credentials', () async {
      final result = await icpService.loginWithEmailPassword(
        email: '',
        password: '',
      );

      expect(result.isErr, isTrue);
    });
  });
}
