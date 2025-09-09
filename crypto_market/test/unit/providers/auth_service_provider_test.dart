import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/auth/auth_guard.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';

class MockICPService extends Mock implements ICPService {}

void main() {
  group('AuthServiceProvider Session Management Tests', () {
    late MockICPService mockICPService;
    late AuthServiceProvider authService;

    const testUser = User(
      id: 'test-principal-id',
      email: 'test@example.com',
      username: 'testuser',
      authProvider: 'email',
      createdAtMillis: 1234567890,
    );

    setUp(() async {
      mockICPService = MockICPService();
      authService = AuthServiceProvider(mockICPService);

      // Initialize shared preferences
      SharedPreferences.setMockInitialValues({});
    });

    group('loginWithEmailPassword', () {
      test('should save user to storage when login succeeds', () async {
        // Arrange
        when(
          () => mockICPService.loginWithEmailPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => const Result.ok(testUser));

        // Act
        final result = await authService.loginWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isOk, isTrue);
        expect(result.ok, equals(testUser));

        // Verify user is saved in storage
        final savedUser = await authService.getCurrentUser();
        expect(savedUser, equals(testUser));
      });

      test('should store session with expiry', () async {
        when(
          () => mockICPService.loginWithEmailPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => const Result.ok(testUser));

        final before = DateTime.now().millisecondsSinceEpoch;
        await authService.loginWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        final prefs = await SharedPreferences.getInstance();
        final data =
            jsonDecode(prefs.getString('current_user')!)
                as Map<String, dynamic>;
        final expiry = data['expiry'] as int;
        final minExpected =
            before + SecurityPolicy.sessionTimeout.inMilliseconds;
        final maxExpected =
            DateTime.now().millisecondsSinceEpoch +
            SecurityPolicy.sessionTimeout.inMilliseconds;
        expect(expiry, greaterThanOrEqualTo(minExpected));
        expect(expiry, lessThanOrEqualTo(maxExpected));
      });

      test('should not save user when login fails', () async {
        // Arrange
        when(
          () => mockICPService.loginWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => const Result.err(AuthError.invalidCredentials),
        );

        // Act
        final result = await authService.loginWithEmailPassword(
          email: 'invalid@example.com',
          password: 'wrongpassword',
        );

        // Assert
        expect(result.isErr, isTrue);
        expect(result.err, equals(AuthError.invalidCredentials));

        // Verify no user is saved
        final savedUser = await authService.getCurrentUser();
        expect(savedUser, isNull);
      });
    });

    group('loginWithOAuth', () {
      test('should save user to storage when OAuth login succeeds', () async {
        // Arrange
        const oauthUser = User(
          id: 'oauth-principal-id',
          email: 'oauth@example.com',
          username: 'g_user',
          authProvider: 'google',
          createdAtMillis: 1234567890,
        );

        when(
          () => mockICPService.loginWithOAuth(
            provider: 'google',
            token: 'mock-token',
          ),
        ).thenAnswer((_) async => const Result.ok(oauthUser));

        // Act
        final result = await authService.loginWithOAuth(
          provider: 'google',
          token: 'mock-token',
        );

        // Assert
        expect(result.isOk, isTrue);
        expect(result.ok, equals(oauthUser));

        // Verify user is saved in storage
        final savedUser = await authService.getCurrentUser();
        expect(savedUser, equals(oauthUser));
      });
    });

    group('register', () {
      test('should save user to storage when registration succeeds', () async {
        // Arrange
        when(
          () => mockICPService.register(
            email: 'test@example.com',
            password: 'password123',
            username: 'testuser',
          ),
        ).thenAnswer((_) async => const Result.ok(testUser));

        // Act
        final result = await authService.register(
          email: 'test@example.com',
          password: 'password123',
          username: 'testuser',
        );

        // Assert
        expect(result.isOk, isTrue);
        expect(result.ok, equals(testUser));

        // Verify user is saved in storage
        final savedUser = await authService.getCurrentUser();
        expect(savedUser, equals(testUser));
      });
    });

    group('logout', () {
      test('should clear user from storage', () async {
        // Arrange - First save a user
        when(
          () => mockICPService.loginWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => const Result.ok(testUser));

        await authService.loginWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Verify user is saved
        var savedUser = await authService.getCurrentUser();
        expect(savedUser, equals(testUser));

        // Act - Logout
        await authService.logout();

        // Assert - User should be cleared
        savedUser = await authService.getCurrentUser();
        expect(savedUser, isNull);
      });
    });

    group('getCurrentUser', () {
      test('should return null when no user is stored', () async {
        // Act
        final user = await authService.getCurrentUser();

        // Assert
        expect(user, isNull);
      });

      test('should return user when valid user data is stored', () async {
        // Arrange - Save a user first
        when(
          () => mockICPService.loginWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Result.ok(testUser));

        await authService.loginWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Act
        final user = await authService.getCurrentUser();

        // Assert
        expect(user, equals(testUser));
        expect(user!.email, equals('test@example.com'));
        expect(user.username, equals('testuser'));
        expect(user.id, equals('test-principal-id'));
        expect(user.authProvider, equals('email'));
      });

      test(
        'should return null and clear storage when corrupted data exists',
        () async {
          // Arrange - Manually add corrupted data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', 'invalid-json');

          // Act
          final user = await authService.getCurrentUser();

          // Assert
          expect(user, isNull);

          // Verify corrupted data was cleared
          expect(prefs.getString('current_user'), isNull);
        },
      );

      test('should return null and clear expired session', () async {
        when(
          () => mockICPService.loginWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Result.ok(testUser));

        await authService.loginWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        final prefs = await SharedPreferences.getInstance();
        final data =
            jsonDecode(prefs.getString('current_user')!)
                as Map<String, dynamic>;
        data['expiry'] = DateTime.now()
            .subtract(const Duration(hours: 1))
            .millisecondsSinceEpoch;
        await prefs.setString('current_user', jsonEncode(data));

        final user = await authService.getCurrentUser();
        expect(user, isNull);
        expect(prefs.getString('current_user'), isNull);
      });
    });
  });
}
