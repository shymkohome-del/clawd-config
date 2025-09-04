import 'dart:convert';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/auth/auth_guard.dart';
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
  Future<Result<User, AuthError>> loginWithOAuth({
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
  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) {
    return icpService.getUserProfile(principal: principal);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('current_user');
    if (sessionJson != null) {
      try {

        final data = jsonDecode(sessionJson) as Map<String, dynamic>;
        final expiry = data['expiry'] as int?;
        if (expiry != null &&
            DateTime.now().millisecondsSinceEpoch > expiry) {
          logger.logWarn('Stored session expired', tag: 'AuthService');
          await prefs.remove('current_user');
          return null;
        }
        final userMap = data['user'] as Map<String, dynamic>;
        final user = User(
          id: userMap['id'] as String,
          email: userMap['email'] as String,
          username: userMap['username'] as String,
          authProvider: userMap['authProvider'] as String,
          createdAtMillis: userMap['createdAt'] as int,
       );
        logger.logDebug(
          'Session restored for ${user.email}',
          tag: 'AuthService',
        );
        return user;
      } catch (e) {
        logger.logWarn(
          'Failed to parse stored session: $e',
          tag: 'AuthService',
        );
        await prefs.remove('current_user');
      }
    } else {
      logger.logDebug('No stored session found', tag: 'AuthService');
    }
    return null;
  }

  Future<void> _saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    logger.logDebug('Persisting session for ${user.email}', tag: 'AuthService');
    final sessionData = {
      'user': user.toJson(),
      'expiry': DateTime.now()
          .add(SecurityPolicy.sessionTimeout)
          .millisecondsSinceEpoch,
    };
    await prefs.setString('current_user', jsonEncode(sessionData));
  }
}
