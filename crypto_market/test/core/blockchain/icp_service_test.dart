import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/auth/jwt_service.dart';
import 'package:crypto_market/core/auth/secure_storage_service.dart';

// Mock classes
class MockJWTService extends Mock implements JWTService {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late ICPService icpService;
  late MockJWTService mockJWTService;
  late MockSecureStorageService mockStorageService;

  setUp(() {
    mockJWTService = MockJWTService();
    mockStorageService = MockSecureStorageService();
    icpService = ICPService(
      jwtService: mockJWTService,
      secureStorageService: mockStorageService,
    );
  });

  group('ICPService', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testUsername = 'testuser';
    const testUserId = 'test-user-id';
    const testPrincipalId = 'generated-principal-id';
    const jwtSecret = 'jwt-secret-key';

    group('User Registration', () {
      test('registers user with valid credentials', () async {
        // Mock JWT token generation
        when(
          () => mockJWTService.generateToken(
            userId: any(named: 'userId'),
            email: testEmail,
            username: testUsername,
            principalId: any(named: 'principalId'),
            secret: jwtSecret,
          ),
        ).thenAnswer((_) async => 'generated-jwt-token');

        // Mock token storage
        when(
          () => mockJWTService.storeToken('generated-jwt-token'),
        ).thenAnswer((_) async {});

        final result = await icpService.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
          jwtSecret: jwtSecret,
        );

        expect(result.isOk, isTrue);
        if (result.isOk) {
          final user = result.ok;
          expect(user.email, equals(testEmail));
          expect(user.username, equals(testUsername));
          expect(user.principalId, isNotEmpty);
          expect(user.isVerified, isFalse);
          expect(user.roles, isEmpty);
        }
      });

      test('fails registration with invalid email', () async {
        const invalidEmail = 'invalid-email';

        final result = await icpService.register(
          email: invalidEmail,
          password: testPassword,
          username: testUsername,
          jwtSecret: jwtSecret,
        );

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Invalid email format'));
        }
      });

      test('fails registration with weak password', () async {
        const weakPassword = '123';

        final result = await icpService.register(
          email: testEmail,
          password: weakPassword,
          username: testUsername,
          jwtSecret: jwtSecret,
        );

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(
            error.message,
            contains('Password must be at least 8 characters'),
          );
        }
      });

      test('fails registration with invalid username', () async {
        const invalidUsername = '';

        final result = await icpService.register(
          email: testEmail,
          password: testPassword,
          username: invalidUsername,
          jwtSecret: jwtSecret,
        );

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(
            error.message,
            contains('Username must be at least 3 characters'),
          );
        }
      });

      test('fails registration with duplicate email', () async {
        // Simulate existing user check
        when(
          () => mockStorageService.getEncryptedData(any()),
        ).thenAnswer((_) async => 'existing-user-data');

        final result = await icpService.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
          jwtSecret: jwtSecret,
        );

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(
            error.message,
            contains('User with this email already exists'),
          );
        }
      });
    });

    group('Email/Password Login', () {
      test('logs in user with correct credentials', () async {
        const testUser = User(
          id: testUserId,
          email: testEmail,
          username: testUsername,
          principalId: testPrincipalId,
          isVerified: false,
          roles: [],
          metadata: {},
        );

        // Mock existing user data
        when(
          () => mockStorageService.getEncryptedData('user_$testEmail'),
        ).thenAnswer((_) async => 'stored-user-data');

        // Mock password verification
        when(
          () => mockStorageService.getEncryptedData('password_$testEmail'),
        ).thenAnswer((_) async => 'hashed-password');

        // Mock JWT token generation
        when(
          () => mockJWTService.generateToken(
            userId: testUserId,
            email: testEmail,
            username: testUsername,
            principalId: testPrincipalId,
            secret: jwtSecret,
          ),
        ).thenAnswer((_) async => 'generated-jwt-token');

        // Mock token storage
        when(
          () => mockJWTService.storeToken('generated-jwt-token'),
        ).thenAnswer((_) async {});

        final result = await icpService.loginWithEmailPassword(
          email: testEmail,
          password: testPassword,
          jwtSecret: jwtSecret,
        );

        expect(result.isOk, isTrue);
        if (result.isOk) {
          final user = result.ok;
          expect(user.email, equals(testEmail));
          expect(user.username, equals(testUsername));
        }
      });

      test('fails login with incorrect email', () async {
        when(
          () => mockStorageService.getEncryptedData(
            'user_nonexistent@example.com',
          ),
        ).thenAnswer((_) async => null);

        final result = await icpService.loginWithEmailPassword(
          email: 'nonexistent@example.com',
          password: testPassword,
          jwtSecret: jwtSecret,
        );

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Invalid email or password'));
        }
      });

      test('fails login with incorrect password', () async {
        when(
          () => mockStorageService.getEncryptedData('user_$testEmail'),
        ).thenAnswer((_) async => 'stored-user-data');

        when(
          () => mockStorageService.getEncryptedData('password_$testEmail'),
        ).thenAnswer((_) async => 'incorrect-hash');

        final result = await icpService.loginWithEmailPassword(
          email: testEmail,
          password: 'wrong-password',
          jwtSecret: jwtSecret,
        );

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Invalid email or password'));
        }
      });
    });

    group('User Management', () {
      const testUser = User(
        id: testUserId,
        email: testEmail,
        username: testUsername,
        principalId: testPrincipalId,
        isVerified: false,
        roles: [],
        metadata: {},
      );

      test('getCurrentUser returns user from JWT token', () async {
        when(() => mockJWTService.getCurrentUser(jwtSecret)).thenAnswer(
          (_) async => const JWTPayload(
            sub: testUserId,
            email: testEmail,
            username: testUsername,
            principalId: testPrincipalId,
            iat: 1234567890,
            exp: 1234567890 + 86400,
          ),
        );

        final user = await icpService.getCurrentUser(jwtSecret);

        expect(user, isNotNull);
        if (user != null) {
          expect(user.id, equals(testUserId));
          expect(user.email, equals(testEmail));
          expect(user.username, equals(testUsername));
          expect(user.principalId, equals(testPrincipalId));
        }
      });

      test('getCurrentUser returns null when no valid token', () async {
        when(
          () => mockJWTService.getCurrentUser(jwtSecret),
        ).thenAnswer((_) async => null);

        final user = await icpService.getCurrentUser(jwtSecret);
        expect(user, isNull);
      });

      test('isAuthenticated returns true when token is valid', () async {
        when(() => mockJWTService.getCurrentUser(jwtSecret)).thenAnswer(
          (_) async => const JWTPayload(
            sub: testUserId,
            email: testEmail,
            username: testUsername,
            principalId: testPrincipalId,
            iat: 1234567890,
            exp: 1234567890 + 86400,
          ),
        );

        final isAuthenticated = await icpService.isAuthenticated(jwtSecret);
        expect(isAuthenticated, isTrue);
      });

      test('isAuthenticated returns false when token is invalid', () async {
        when(
          () => mockJWTService.getCurrentUser(jwtSecret),
        ).thenAnswer((_) async => null);

        final isAuthenticated = await icpService.isAuthenticated(jwtSecret);
        expect(isAuthenticated, isFalse);
      });

      test('logout clears session and deletes token', () async {
        when(() => mockJWTService.deleteToken()).thenAnswer((_) async {});

        await icpService.logout();

        verify(() => mockJWTService.deleteToken()).called(1);
      });
    });

    group('Validation Methods', () {
      test('validates email format correctly', () {
        expect(icpService._isValidEmail('test@example.com'), isTrue);
        expect(icpService._isValidEmail('user@domain.com'), isTrue);
        expect(icpService._isValidEmail('invalid-email'), isFalse);
        expect(icpService._isValidEmail('@domain.com'), isFalse);
        expect(icpService._isValidEmail('user@'), isFalse);
        expect(icpService._isValidEmail(''), isFalse);
      });

      test('validates password strength correctly', () {
        expect(icpService._isValidPassword('password123'), isTrue);
        expect(icpService._isValidPassword('Password123!'), isTrue);
        expect(icpService._isValidPassword('123'), isFalse);
        expect(icpService._isValidPassword(''), isFalse);
        expect(icpService._isValidPassword('short'), isFalse);
      });

      test('validates username correctly', () {
        expect(icpService._isValidUsername('testuser'), isTrue);
        expect(icpService._isValidUsername('user123'), isTrue);
        expect(icpService._isValidUsername(''), isFalse);
        expect(icpService._isValidUsername('ab'), isFalse);
        expect(icpService._isValidUsername('valid_user'), isTrue);
      });
    });
  });
}
