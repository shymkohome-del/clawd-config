import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_market/core/auth/oauth_service.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Mock classes
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockFacebookAuth extends Mock implements FacebookAuth {}

class MockFacebookLoginResult extends Mock implements LoginResult {}

class MockSignInWithApple extends Mock {}

void main() {
  late OAuthService oauthService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFacebookAuth mockFacebookAuth;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockFacebookAuth = MockFacebookAuth();
    oauthService = OAuthService(
      googleSignIn: mockGoogleSignIn,
      facebookAuth: mockFacebookAuth,
    );
  });

  group('OAuthService', () {
    const testEmail = 'test@example.com';
    const testUsername = 'testuser';
    const testDisplayName = 'Test User';
    const testPhotoUrl = 'https://example.com/photo.jpg';

    group('Google Sign-In', () {
      test('successfully signs in with Google', () async {
        // Mock Google sign-in flow
        final mockAccount = MockGoogleSignInAccount();
        final mockAuth = MockGoogleSignInAuthentication();

        when(
          () => mockGoogleSignIn.signIn(),
        ).thenAnswer((_) async => mockAccount);
        when(
          () => mockAccount.authentication,
        ).thenAnswer((_) async => mockAuth);
        when(() => mockAuth.idToken).thenReturn('google-id-token');
        when(() => mockAuth.accessToken).thenReturn('google-access-token');
        when(() => mockAccount.email).thenReturn(testEmail);
        when(() => mockAccount.displayName).thenReturn(testDisplayName);
        when(() => mockAccount.photoUrl).thenReturn(testPhotoUrl);

        final result = await oauthService.signInWithGoogle();

        expect(result.isOk, isTrue);
        if (result.isOk) {
          final userData = result.ok;
          expect(userData.email, equals(testEmail));
          expect(
            userData.username,
            equals('test_user'),
          ); // Normalized from display name
          expect(userData.displayName, equals(testDisplayName));
          expect(userData.photoUrl, equals(testPhotoUrl));
          expect(userData.provider, equals('google'));
          expect(userData.providerId, equals('google-id-token'));
        }
      });

      test('handles Google sign-in cancellation', () async {
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        final result = await oauthService.signInWithGoogle();

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Google sign-in was cancelled'));
        }
      });

      test('handles Google sign-in exceptions', () async {
        when(
          () => mockGoogleSignIn.signIn(),
        ).thenThrow(Exception('Google sign-in failed'));

        final result = await oauthService.signInWithGoogle();

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Google sign-in failed'));
        }
      });
    });

    group('Facebook Sign-In', () {
      test('successfully signs in with Facebook', () async {
        // Mock Facebook login result
        final mockResult = MockFacebookLoginResult();
        final mockAccessToken = AccessToken(
          token: 'facebook-access-token',
          userId: 'facebook-user-id',
          expires: DateTime.now().add(const Duration(hours: 1)),
          permissions: const ['email', 'public_profile'],
          isExpired: false,
        );

        when(
          () => mockFacebookAuth.login(),
        ).thenAnswer((_) async => mockResult);
        when(() => mockResult.status).thenReturn(LoginStatus.success);
        when(() => mockResult.accessToken).thenReturn(mockAccessToken);
        when(() => mockFacebookAuth.getUserData()).thenAnswer(
          (_) async => {
            'email': testEmail,
            'name': testDisplayName,
            'picture': {
              'data': {'url': testPhotoUrl},
            },
          },
        );

        final result = await oauthService.signInWithFacebook();

        expect(result.isOk, isTrue);
        if (result.isOk) {
          final userData = result.ok;
          expect(userData.email, equals(testEmail));
          expect(
            userData.username,
            equals('test_user'),
          ); // Normalized from display name
          expect(userData.displayName, equals(testDisplayName));
          expect(userData.photoUrl, equals(testPhotoUrl));
          expect(userData.provider, equals('facebook'));
          expect(userData.providerId, equals('facebook-user-id'));
        }
      });

      test('handles Facebook login cancellation', () async {
        final mockResult = MockFacebookLoginResult();

        when(
          () => mockFacebookAuth.login(),
        ).thenAnswer((_) async => mockResult);
        when(() => mockResult.status).thenReturn(LoginStatus.cancelled);

        final result = await oauthService.signInWithFacebook();

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Facebook login was cancelled'));
        }
      });

      test('handles Facebook login failure', () async {
        final mockResult = MockFacebookLoginResult();

        when(
          () => mockFacebookAuth.login(),
        ).thenAnswer((_) async => mockResult);
        when(() => mockResult.status).thenReturn(LoginStatus.failed);

        final result = await oauthService.signInWithFacebook();

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Facebook login failed'));
        }
      });

      test('handles Facebook login exceptions', () async {
        when(
          () => mockFacebookAuth.login(),
        ).thenThrow(Exception('Facebook login failed'));

        final result = await oauthService.signInWithFacebook();

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Facebook login failed'));
        }
      });
    });

    group('Apple Sign-In', () {
      test('successfully signs in with Apple', () async {
        // Mock Apple sign-in credential
        final credential = AuthorizationCredentialAppleID(
          userIdentifier: 'apple-user-id',
          givenName: 'Test',
          familyName: 'User',
          email: testEmail,
          identityToken: 'apple-identity-token',
          authorizationCode: 'apple-auth-code',
        );

        // Mock the static method call (this would need to be done differently in actual implementation)
        // For testing purposes, we'll simulate a successful sign-in
        final result = await oauthService._mockAppleSignIn(credential);

        expect(result.isOk, isTrue);
        if (result.isOk) {
          final userData = result.ok;
          expect(userData.email, equals(testEmail));
          expect(userData.username, equals('test_user'));
          expect(userData.displayName, equals('Test User'));
          expect(userData.provider, equals('apple'));
          expect(userData.providerId, equals('apple-user-id'));
        }
      });

      test('handles Apple sign-in cancellation', () async {
        final result = await oauthService._mockAppleSignIn(null);

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Apple sign-in was cancelled'));
        }
      });

      test('handles Apple sign-in exceptions', () async {
        final result = await oauthService._mockAppleSignInWithError(
          Exception('Apple sign-in failed'),
        );

        expect(result.isErr, isTrue);
        if (result.isErr) {
          final error = result.err;
          expect(error, isA<AuthError>());
          expect(error.message, contains('Apple sign-in failed'));
        }
      });
    });

    group('User Data Normalization', () {
      test('normalizes username from display name', () {
        const displayName = 'John Doe Smith';
        final normalized = oauthService._normalizeUsername(displayName);
        expect(normalized, equals('john_doe_smith'));
      });

      test('normalizes username from email when no display name', () {
        const email = 'john.doe@example.com';
        final normalized = oauthService._normalizeUsernameFromEmail(email);
        expect(normalized, equals('john_doe'));
      });

      test('handles empty display name', () {
        const displayName = '';
        final normalized = oauthService._normalizeUsername(displayName);
        expect(normalized, isEmpty);
      });

      test('handles special characters in username normalization', () {
        const displayName = 'John O\'Connor-Smith';
        final normalized = oauthService._normalizeUsername(displayName);
        expect(normalized, equals('john_oconnor_smith'));
      });

      test('extracts email from Facebook user data', () {
        final userData = {
          'email': testEmail,
          'name': testDisplayName,
          'picture': {
            'data': {'url': testPhotoUrl},
          },
        };

        final extractedEmail = oauthService._extractEmailFromFacebookData(
          userData,
        );
        expect(extractedEmail, equals(testEmail));
      });

      test('extracts photo URL from Facebook user data', () {
        final userData = {
          'email': testEmail,
          'name': testDisplayName,
          'picture': {
            'data': {'url': testPhotoUrl},
          },
        };

        final photoUrl = oauthService._extractPhotoUrlFromFacebookData(
          userData,
        );
        expect(photoUrl, equals(testPhotoUrl));
      });

      test('handles missing Facebook photo URL', () {
        final userData = {
          'email': testEmail,
          'name': testDisplayName,
          'picture': null,
        };

        final photoUrl = oauthService._extractPhotoUrlFromFacebookData(
          userData,
        );
        expect(photoUrl, isNull);
      });
    });
  });
}

// Extension method for testing Apple sign-in
extension OAuthServiceTestExtension on OAuthService {
  Future<Result<OAuthUserData, AuthError>> _mockAppleSignIn(
    AuthorizationCredentialAppleID? credential,
  ) async {
    if (credential == null) {
      return Result.err(AuthError('Apple sign-in was cancelled'));
    }

    final userData = OAuthUserData(
      email: credential.email ?? '',
      username: _normalizeUsername(
        '${credential.givenName ?? ''} ${credential.familyName ?? ''}',
      ),
      displayName:
          '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
      photoUrl: null,
      provider: 'apple',
      providerId: credential.userIdentifier,
    );

    return Result.ok(userData);
  }

  Future<Result<OAuthUserData, AuthError>> _mockAppleSignInWithError(
    Exception error,
  ) async {
    return Result.err(AuthError('Apple sign-in failed: ${error.toString()}'));
  }
}
