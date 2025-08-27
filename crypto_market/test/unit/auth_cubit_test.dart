import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockAuthService implements AuthService {
  @override
  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    return Result.ok(
      User(
        id: 'principal-mock',
        email: email,
        username: username,
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return Result.ok(
      User(
        id: 'principal-mock',
        email: email,
        username: email.split('@')[0],
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    // Return failure for unknown providers
    if (provider == 'unknown') {
      return const Result.err(AuthError.unknown);
    }
    
    return Result.ok(
      User(
        id: 'oauth-principal-mock',
        email: 'oauth@example.com',
        username: 'oauth_user',
        authProvider: provider,
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) async {
    return Result.ok({'principal': principal});
  }

  @override
  Future<void> logout() async {}

  @override
  Future<User?> getCurrentUser() async => null;
}

void main() {
  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'emits [submitting, success] on register success',
      build: () => AuthCubit(authService: _MockAuthService()),
      act: (cubit) => cubit.register(
        email: 'u@e.com',
        password: 'password123',
        username: 'user',
      ),
      expect: () => [isA<AuthSubmitting>(), isA<AuthSuccess>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [submitting, success] on OAuth success',
      build: () => AuthCubit(authService: _MockAuthService()),
      act: (cubit) => cubit.loginWithOAuth(provider: 'google', token: 'x'),
      expect: () => [isA<AuthSubmitting>(), isA<AuthSuccess>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [submitting, failure] on OAuth unknown provider',
      build: () => AuthCubit(authService: _MockAuthService()),
      act: (cubit) => cubit.loginWithOAuth(provider: 'unknown', token: 'x'),
      expect: () => [isA<AuthSubmitting>(), isA<AuthFailure>()],
    );
  });
}
