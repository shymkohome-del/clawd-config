import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';

/// Abstraction for auth-related operations to enable mocking in tests.
abstract class AuthService {
  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  });

  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  });

  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  });
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
  }) {
    return icpService.register(
      email: email,
      password: password,
      username: username,
    );
  }

  @override
  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) {
    return icpService.loginWithOAuth(provider: provider, token: token);
  }

  @override
  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) {
    return icpService.getUserProfile(principal: principal);
  }
}
