import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/blockchain/errors.dart';

/// OAuth user data structure
class OAuthUserData {
  final String id;
  final String email;
  final String? name;
  final String? profileImage;
  final String provider;
  final String? accessToken;
  final String? idToken;
  final Map<String, dynamic> rawUserData;

  // Additional properties for compatibility
  String? get username => name?.toLowerCase().replaceAll(' ', '_') ?? '';
  String? get displayName => name;
  String? get photoUrl => profileImage;
  String? get providerId => idToken;

  const OAuthUserData({
    required this.id,
    required this.email,
    this.name,
    this.profileImage,
    required this.provider,
    this.accessToken,
    this.idToken,
    required this.rawUserData,
  });

  factory OAuthUserData.fromGoogleSignIn(GoogleSignInAccount account) {
    return OAuthUserData(
      id: account.id,
      email: account.email,
      name: account.displayName,
      profileImage: account.photoUrl,
      provider: 'google',
      accessToken: null, // Google uses serverAuthCode
      idToken: account.id,
      rawUserData: {
        'displayName': account.displayName,
        'email': account.email,
        'id': account.id,
        'photoUrl': account.photoUrl,
        'serverAuthCode': account.serverAuthCode,
      },
    );
  }

  factory OAuthUserData.fromFacebookLogin(LoginResult result) {
    return OAuthUserData(
      id:
          result.accessToken?.tokenString ??
          '', // Use tokenString as ID for now
      email: '', // Will be retrieved separately
      name: '', // Will be retrieved separately
      profileImage: null,
      provider: 'facebook',
      accessToken: result.accessToken?.tokenString,
      idToken: null,
      rawUserData: {},
    );
  }

  factory OAuthUserData.fromAppleSignIn(
    AuthorizationCredentialAppleID credential,
  ) {
    return OAuthUserData(
      id: credential.userIdentifier ?? '',
      email: credential.email ?? '',
      name:
          (credential.givenName?.isNotEmpty == true ||
              credential.familyName?.isNotEmpty == true)
          ? '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim()
          : null,
      profileImage: null,
      provider: 'apple',
      accessToken: credential.authorizationCode,
      idToken: credential.identityToken,
      rawUserData: {
        'userIdentifier': credential.userIdentifier,
        'email': credential.email,
        'givenName': credential.givenName,
        'familyName': credential.familyName,
        'identityToken': credential.identityToken,
        'authorizationCode': credential.authorizationCode,
      },
    );
  }
}

/// OAuth service for handling social authentication
class OAuthService {
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  OAuthService({GoogleSignIn? googleSignIn, FacebookAuth? facebookAuth})
    : _googleSignIn =
          googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']),
      _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  /// Initialize OAuth services
  Future<void> initialize() async {
    try {
      // Initialize Google Sign In
      await _googleSignIn.signInSilently();

      // Initialize Facebook Auth
      // Note: autoLogAppEventsEnabled() is deprecated in newer versions

      Logger.instance.logInfo(
        'OAuth services initialized',
        tag: 'OAuthService',
      );
    } catch (e) {
      Logger.instance.logError('Failed to initialize OAuth services', error: e);
    }
  }

  /// Sign in with Google
  Future<Result<OAuthUserData, AuthError>> signInWithGoogle() async {
    try {
      Logger.instance.logDebug('Starting Google Sign In', tag: 'OAuthService');

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        Logger.instance.logWarn(
          'Google Sign In cancelled by user',
          tag: 'OAuthService',
        );
        return Result.err(AuthError.oauthDenied);
      }

      final userData = OAuthUserData.fromGoogleSignIn(account);

      Logger.instance.logInfo(
        'Google Sign In successful: ${userData.email}',
        tag: 'OAuthService',
      );

      return Result.ok(userData);
    } catch (e) {
      Logger.instance.logError('Google Sign In failed', error: e);
      return Result.err(_mapOAuthExceptionToError(e));
    }
  }

  /// Sign in with Facebook
  Future<Result<OAuthUserData, AuthError>> signInWithFacebook() async {
    try {
      Logger.instance.logDebug(
        'Starting Facebook Sign In',
        tag: 'OAuthService',
      );

      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        Logger.instance.logWarn(
          'Facebook Sign In cancelled by user',
          tag: 'OAuthService',
        );
        return Result.err(AuthError.oauthDenied);
      }

      if (result.status != LoginStatus.success) {
        Logger.instance.logError(
          'Facebook Sign In failed: ${result.status}',
          tag: 'OAuthService',
        );
        return Result.err(AuthError.oauthDenied);
      }

      final userData = OAuthUserData.fromFacebookLogin(result);

      Logger.instance.logInfo(
        'Facebook Sign In successful: ${userData.email}',
        tag: 'OAuthService',
      );

      return Result.ok(userData);
    } catch (e) {
      Logger.instance.logError('Facebook Sign In failed', error: e);
      return Result.err(_mapOAuthExceptionToError(e));
    }
  }

  /// Sign in with Apple
  Future<Result<OAuthUserData, AuthError>> signInWithApple() async {
    try {
      Logger.instance.logDebug('Starting Apple Sign In', tag: 'OAuthService');

      // Check if Apple Sign In is available
      if (!await SignInWithApple.isAvailable()) {
        Logger.instance.logWarn(
          'Apple Sign In not available on this device',
          tag: 'OAuthService',
        );
        return Result.err(AuthError.oauthDenied);
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final userData = OAuthUserData.fromAppleSignIn(credential);

      Logger.instance.logInfo(
        'Apple Sign In successful: ${userData.email}',
        tag: 'OAuthService',
      );

      return Result.ok(userData);
    } catch (e) {
      Logger.instance.logError('Apple Sign In failed', error: e);
      return Result.err(_mapOAuthExceptionToError(e));
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      Logger.instance.logDebug('Signed out from Google', tag: 'OAuthService');
    } catch (e) {
      Logger.instance.logError('Failed to sign out from Google', error: e);
    }
  }

  /// Sign out from Facebook
  Future<void> signOutFacebook() async {
    try {
      await _facebookAuth.logOut();
      Logger.instance.logDebug('Signed out from Facebook', tag: 'OAuthService');
    } catch (e) {
      Logger.instance.logError('Failed to sign out from Facebook', error: e);
    }
  }

  /// Sign out from all OAuth providers
  Future<void> signOutAll() async {
    try {
      await signOutGoogle();
      await signOutFacebook();
      Logger.instance.logDebug(
        'Signed out from all OAuth providers',
        tag: 'OAuthService',
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to sign out from all OAuth providers',
        error: e,
      );
    }
  }

  /// Check if Google Sign In is available
  Future<bool> isGoogleSignInAvailable() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  /// Check if Facebook Sign In is available
  Future<bool> isFacebookSignInAvailable() async {
    try {
      // Check if Facebook app is installed
      // Note: getLoginBehavior() method may not be available in all versions
      return true; // Assume available for now
    } catch (e) {
      return false;
    }
  }

  /// Check if Apple Sign In is available
  Future<bool> isAppleSignInAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      return false;
    }
  }

  /// Get available OAuth providers
  Future<Map<String, bool>> getAvailableProviders() async {
    return {
      'google': await isGoogleSignInAvailable(),
      'facebook': await isFacebookSignInAvailable(),
      'apple': await isAppleSignInAvailable(),
    };
  }

  /// Map OAuth exception to AuthError
  AuthError _mapOAuthExceptionToError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('cancel') ||
        errorString.contains('denied') ||
        errorString.contains('user')) {
      return AuthError.oauthDenied;
    }

    if (errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection')) {
      return AuthError.network;
    }

    return AuthError.unknown;
  }

  /// Get current Google user
  Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      return null;
    }
  }

  /// Get Facebook access token
  Future<AccessToken?> getFacebookAccessToken() async {
    try {
      return await _facebookAuth.accessToken;
    } catch (e) {
      return null;
    }
  }

  /// Refresh Facebook token
  Future<bool> refreshFacebookToken() async {
    try {
      final result = await _facebookAuth.login();
      return result.status == LoginStatus.success;
    } catch (e) {
      return false;
    }
  }
}
