import 'dart:convert';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction for auth-related operations to enable mocking in tests.
abstract class AuthService {
  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  });

  Future<Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  });

  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  });

  Future<void> logout();
  Future<User?> getCurrentUser();
}

/// DI via Bloc RepositoryProvider at app root.
class AuthServiceProvider implements AuthService {
  final ICPService icpService;
  const AuthServiceProvider(this.icpService);

  @override
  Future<Result<User, AuthError>> register({
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
  Future<Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    logger.logDebug('Email/password login attempt for $email',
        tag: 'AuthService');
    final result = await icpService.loginWithEmailPassword(
      email: email,
      password: password,
    );
    if (result.isOk) {
      logger.logInfo('Login success for ${result.ok.email}',
          tag: 'AuthService');
      await _saveCurrentUser(result.ok);
    } else {
      logger.logWarn('Login failed: ${result.err}', tag: 'AuthService');
    }
    return result;
  }

  @override
  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    logger.logDebug('OAuth login attempt for $provider',
        tag: 'AuthService');
    final result = await icpService.loginWithOAuth(
      provider: provider,
      token: token,
    );
    if (result.isOk) {
      logger.logInfo('OAuth login success for ${result.ok.email}',
          tag: 'AuthService');
      await _saveCurrentUser(result.ok);
    } else {
      logger.logWarn('OAuth login failed: ${result.err}',
          tag: 'AuthService');
    }
    return result;
  }

  @override
  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) {
    return icpService.getUserProfile(principal: principal);
  }

  @override
  Future<void> logout() async {
    logger.logInfo('Logout requested', tag: 'AuthService');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  @override
  Future<User?> getCurrentUser() async {
    logger.logDebug('Attempting session restore', tag: 'AuthService');
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = User(
          id: userMap['id'] as String,
          email: userMap['email'] as String,
          username: userMap['username'] as String,
          authProvider: userMap['authProvider'] as String,
          createdAtMillis: userMap['createdAt'] as int,
        );
        logger.logDebug('Session restored for ${user.email}',
            tag: 'AuthService');
        return user;
      } catch (e) {
        logger.logWarn('Failed to parse stored session: $e',
            tag: 'AuthService');
        await prefs.remove('current_user');
      }
    } else {
      logger.logDebug('No stored session found', tag: 'AuthService');
    }
    return null;
  }

  Future<void> _saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    logger.logDebug('Persisting session for ${user.email}',
        tag: 'AuthService');
    final userJson = jsonEncode(user.toJson());
    await prefs.setString('current_user', userJson);
  }
}
