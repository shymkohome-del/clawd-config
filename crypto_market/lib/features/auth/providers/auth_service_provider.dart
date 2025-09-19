import 'dart:convert';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/auth/oauth_service.dart';
import 'package:crypto_market/core/auth/jwt_service.dart' as jwt_service;
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction for auth-related operations to enable mocking in tests.
abstract class AuthService {
  Future<jwt_service.Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  });

  Future<jwt_service.Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<jwt_service.Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  });

  Future<jwt_service.Result<User, AuthError>> signInWithGoogle();
  Future<jwt_service.Result<User, AuthError>> signInWithFacebook();
  Future<jwt_service.Result<User, AuthError>> signInWithApple();

  Future<jwt_service.Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  });

  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<void> signOutOAuth();
  Future<Map<String, bool>> getAvailableOAuthProviders();
}

/// DI via Bloc RepositoryProvider at app root.
class AuthServiceProvider implements AuthService {
  final ICPService icpService;
  final OAuthService oauthService;

  AuthServiceProvider(this.icpService, {OAuthService? oauthService})
    : oauthService = oauthService ?? OAuthService() {
    // Initialize OAuth services
    this.oauthService.initialize();
  }

  @override
  Future<jwt_service.Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final result = await icpService.register(
      email: email,
      password: password,
      username: username,
    );
    if (result.isOk) {
      await _saveCurrentUser(result.ok);
    }
    return result;
  }

  @override
  Future<jwt_service.Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final result = await icpService.loginWithEmailPassword(
      email: email,
      password: password,
    );
    if (result.isOk) {
      await _saveCurrentUser(result.ok);
    }
    return result;
  }

  @override
  Future<jwt_service.Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    final result = await icpService.loginWithOAuth(
      provider: provider,
      token: token,
    );
    if (result.isOk) {
      await _saveCurrentUser(result.ok);
    }
    return result;
  }

  @override
  Future<jwt_service.Result<User, AuthError>> signInWithGoogle() async {
    final oauthResult = await oauthService.signInWithGoogle();
    if (oauthResult.isErr) {
      return jwt_service.Result.err(oauthResult.err);
    }

    final oauthData = oauthResult.ok;
    return await icpService.loginWithOAuth(
      provider: 'google',
      token: oauthData.idToken ?? oauthData.accessToken!,
    );
  }

  @override
  Future<jwt_service.Result<User, AuthError>> signInWithFacebook() async {
    final oauthResult = await oauthService.signInWithFacebook();
    if (oauthResult.isErr) {
      return jwt_service.Result.err(oauthResult.err);
    }

    final oauthData = oauthResult.ok;
    return await icpService.loginWithOAuth(
      provider: 'facebook',
      token: oauthData.accessToken!,
    );
  }

  @override
  Future<jwt_service.Result<User, AuthError>> signInWithApple() async {
    final oauthResult = await oauthService.signInWithApple();
    if (oauthResult.isErr) {
      return jwt_service.Result.err(oauthResult.err);
    }

    final oauthData = oauthResult.ok;
    return await icpService.loginWithOAuth(
      provider: 'apple',
      token: oauthData.accessToken!,
    );
  }

  @override
  Future<jwt_service.Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) async {
    return await icpService.getUserProfile(principal: principal);
  }

  @override
  Future<void> logout() async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      await icpService.logout(currentUser.id);
    }
    await signOutOAuth();
    await _clearCurrentUser();
  }

  @override
  Future<void> signOutOAuth() async {
    await oauthService.signOutAll();
  }

  @override
  Future<User?> getCurrentUser() async {
    // Try to get user from ICP service first (JWT-based)
    final user = await icpService.getCurrentUser();
    if (user != null) {
      return user;
    }

    // Fallback to SharedPreferences for backward compatibility
    return _getCurrentUserFromPrefs();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await icpService.isAuthenticated();
  }

  @override
  Future<Map<String, bool>> getAvailableOAuthProviders() async {
    return await oauthService.getAvailableProviders();
  }

  Future<void> _saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString('current_user', userJson);
  }

  Future<User?> _getCurrentUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User(
          id: userMap['id'] as String,
          email: userMap['email'] as String,
          username: userMap['username'] as String,
          authProvider: userMap['authProvider'] as String,
          createdAtMillis: userMap['createdAt'] as int,
          principalId: userMap['principalId'] as String?,
          isVerified: userMap['isVerified'] as bool? ?? false,
          roles: List<String>.from(userMap['roles'] ?? ['user']),
          metadata: Map<String, dynamic>.from(userMap['metadata'] ?? {}),
        );
      } catch (e) {
        // If parsing fails, clear the corrupted data
        await prefs.remove('current_user');
        return null;
      }
    }
    return null;
  }

  Future<void> _clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }
}
