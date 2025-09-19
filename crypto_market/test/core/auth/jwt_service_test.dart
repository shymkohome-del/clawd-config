import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_market/core/auth/jwt_service.dart';
import 'package:crypto_market/core/auth/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Mock classes
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late JWTService jwtService;
  late MockSecureStorage mockStorage;
  late MockSecureStorageService mockSecureStorageService;

  setUp(() {
    mockStorage = MockSecureStorage();
    mockSecureStorageService = MockSecureStorageService();
    jwtService = JWTService(secureStorageService: mockSecureStorageService);
  });

  group('JWTService', () {
    const testSecret = 'test-secret-key';
    const testUserId = 'test-user-id';
    const testEmail = 'test@example.com';
    const testUsername = 'testuser';
    const testPrincipalId = 'principal-id';

    group('generateToken', () {
      test('generates valid JWT token with correct payload', () async {
        final token = await jwtService.generateToken(
          userId: testUserId,
          email: testEmail,
          username: testUsername,
          principalId: testPrincipalId,
          secret: testSecret,
        );

        expect(token, isNotEmpty);
        expect(token.split('.'), hasLength(3)); // Header.Payload.Signature
      });

      test('includes correct claims in payload', () async {
        final token = await jwtService.generateToken(
          userId: testUserId,
          email: testEmail,
          username: testUsername,
          principalId: testPrincipalId,
          secret: testSecret,
        );

        final decodedToken = jwtService.decodeToken(token);

        expect(decodedToken.sub, equals(testUserId));
        expect(decodedToken.email, equals(testEmail));
        expect(decodedToken.username, equals(testUsername));
        expect(decodedToken.principalId, equals(testPrincipalId));
        expect(decodedToken.iat, isNotNull);
        expect(decodedToken.exp, isNotNull);
        expect(decodedToken.exp, greaterThan(decodedToken.iat!));
      });

      test('sets expiration to 24 hours', () async {
        final token = await jwtService.generateToken(
          userId: testUserId,
          email: testEmail,
          username: testUsername,
          principalId: testPrincipalId,
          secret: testSecret,
        );

        final decodedToken = jwtService.decodeToken(token);
        final expirationTime = decodedToken.exp! - decodedToken.iat!;
        final twentyFourHours = 24 * 60 * 60;

        expect(expirationTime, equals(twentyFourHours));
      });
    });

    group('validateToken', () {
      test('returns true for valid token with correct secret', () async {
        final token = await jwtService.generateToken(
          userId: testUserId,
          email: testEmail,
          username: testUsername,
          principalId: testPrincipalId,
          secret: testSecret,
        );

        final isValid = await jwtService.validateToken(token, testSecret);
        expect(isValid, isTrue);
      });

      test('returns false for token with incorrect secret', () async {
        final token = await jwtService.generateToken(
          userId: testUserId,
          email: testEmail,
          username: testUsername,
          principalId: testPrincipalId,
          secret: testSecret,
        );

        final isValid = await jwtService.validateToken(token, 'wrong-secret');
        expect(isValid, isFalse);
      });

      test('returns false for expired token', () async {
        // Generate token with immediate expiration
        final token = await jwtService.generateToken(
          userId: testUserId,
          email: testEmail,
          username: testUsername,
          principalId: testPrincipalId,
          secret: testSecret,
          expirationInSeconds: -1, // Already expired
        );

        final isValid = await jwtService.validateToken(token, testSecret);
        expect(isValid, isFalse);
      });

      test('returns false for malformed token', () async {
        final isValid = await jwtService.validateToken(
          'invalid-token',
          testSecret,
        );
        expect(isValid, isFalse);
      });
    });

    group('storeToken', () {
      test('stores token securely', () async {
        const token = 'test-jwt-token';

        when(
          () => mockSecureStorageService.storeEncryptedData('jwt_token', token),
        ).thenAnswer((_) async {});

        await jwtService.storeToken(token);

        verify(
          () => mockSecureStorageService.storeEncryptedData('jwt_token', token),
        ).called(1);
      });
    });

    group('getCurrentUser', () {
      test('returns user data from valid token', () async {
        const storedToken = 'stored-jwt-token';
        when(
          () => mockSecureStorageService.getEncryptedData('jwt_token'),
        ).thenAnswer((_) async => storedToken);

        final token = await jwtService.generateToken(
          userId: testUserId,
          email: testEmail,
          username: testUsername,
          principalId: testPrincipalId,
          secret: testSecret,
        );

        when(
          () => mockSecureStorageService.getEncryptedData('jwt_token'),
        ).thenAnswer((_) async => token);

        final user = await jwtService.getCurrentUser(testSecret);

        expect(user, isNotNull);
        expect(user!.sub, equals(testUserId));
        expect(user.email, equals(testEmail));
        expect(user.username, equals(testUsername));
        expect(user.principalId, equals(testPrincipalId));
      });

      test('returns null when no token is stored', () async {
        when(
          () => mockSecureStorageService.getEncryptedData('jwt_token'),
        ).thenAnswer((_) async => null);

        final user = await jwtService.getCurrentUser(testSecret);
        expect(user, isNull);
      });

      test('returns null for invalid stored token', () async {
        when(
          () => mockSecureStorageService.getEncryptedData('jwt_token'),
        ).thenAnswer((_) async => 'invalid-token');

        final user = await jwtService.getCurrentUser(testSecret);
        expect(user, isNull);
      });
    });

    group('decodeToken', () {
      test('decodes valid token payload', () async {
        final token = await jwtService.generateToken(
          userId: testUserId,
          email: testEmail,
          username: testUsername,
          principalId: testPrincipalId,
          secret: testSecret,
        );

        final payload = jwtService.decodeToken(token);

        expect(payload.sub, equals(testUserId));
        expect(payload.email, equals(testEmail));
        expect(payload.username, equals(testUsername));
        expect(payload.principalId, equals(testPrincipalId));
      });

      test('throws exception for invalid token format', () {
        expect(
          () => jwtService.decodeToken('invalid-token'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteToken', () {
      test('deletes stored token', () async {
        when(
          () => mockSecureStorageService.deleteData('jwt_token'),
        ).thenAnswer((_) async {});

        await jwtService.deleteToken();

        verify(
          () => mockSecureStorageService.deleteData('jwt_token'),
        ).called(1);
      });
    });
  });
}
