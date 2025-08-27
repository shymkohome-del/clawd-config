import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthService extends Mock implements AuthService {}

void main() {
  group('AuthCubit', () {
    late AuthCubit authCubit;
    late _MockAuthService mockAuthService;
    late User testUser;

    setUp(() {
      mockAuthService = _MockAuthService();
      authCubit = AuthCubit(authService: mockAuthService);
      testUser = const User(
        id: 'test-principal',
        email: 'test@example.com',
        username: 'test',
        authProvider: 'email',
        createdAtMillis: 0,
      );
    });

    tearDown(() {
      authCubit.close();
    });

    test('initial state should be AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    group('Login Tests', () {
      blocTest<AuthCubit, AuthState>(
        'loginWithEmailPassword should emit success when login succeeds',
        build: () => authCubit,
        setUp: () {
          when(
            () => mockAuthService.loginWithEmailPassword(
              email: 'test@example.com',
              password: 'password123',
            ),
          ).thenAnswer((_) async => Result.ok(testUser));
        },
        act: (cubit) => cubit.loginWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        expect: () => [
          isA<AuthSubmitting>(),
          isA<AuthSuccess>().having((s) => s.user, 'user', testUser),
        ],
        verify: (_) {
          verify(
            () => mockAuthService.loginWithEmailPassword(
              email: 'test@example.com',
              password: 'password123',
            ),
          ).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'loginWithEmailPassword should emit failure when login fails',
        build: () => authCubit,
        setUp: () {
          when(
            () => mockAuthService.loginWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer(
            (_) async => const Result.err(AuthError.invalidCredentials),
          );
        },
        act: (cubit) => cubit.loginWithEmailPassword(
          email: 'invalid@email.com',
          password: 'wrongpassword',
        ),
        expect: () => [
          isA<AuthSubmitting>(),
          isA<AuthFailure>().having(
            (s) => s.error,
            'error',
            AuthError.invalidCredentials,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'loginWithOAuth should emit success when OAuth login succeeds',
        build: () => authCubit,
        setUp: () {
          when(
            () => mockAuthService.loginWithOAuth(
              provider: 'google',
              token: 'mock-token',
            ),
          ).thenAnswer((_) async => Result.ok(testUser));
        },
        act: (cubit) =>
            cubit.loginWithOAuth(provider: 'google', token: 'mock-token'),
        expect: () => [
          isA<AuthSubmitting>(),
          isA<AuthSuccess>().having((s) => s.user, 'user', testUser),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'logout should call logout service and emit initial state',
        build: () => authCubit,
        setUp: () {
          when(() => mockAuthService.logout()).thenAnswer((_) async {});
        },
        act: (cubit) => cubit.logout(),
        expect: () => [isA<AuthInitial>()],
        verify: (_) {
          verify(() => mockAuthService.logout()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'checkSession should emit success when session exists',
        build: () => authCubit,
        setUp: () {
          when(
            () => mockAuthService.getCurrentUser(),
          ).thenAnswer((_) async => testUser);
        },
        act: (cubit) => cubit.checkSession(),
        expect: () => [
          isA<AuthSuccess>().having((s) => s.user, 'user', testUser),
        ],
        verify: (_) {
          verify(() => mockAuthService.getCurrentUser()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'checkSession should emit initial state when no session exists',
        build: () => authCubit,
        setUp: () {
          when(
            () => mockAuthService.getCurrentUser(),
          ).thenAnswer((_) async => null);
        },
        act: (cubit) => cubit.checkSession(),
        expect: () => [isA<AuthInitial>()],
      );
    });

    group('Register Tests', () {
      blocTest<AuthCubit, AuthState>(
        'register should emit success when registration succeeds',
        build: () => authCubit,
        setUp: () {
          when(
            () => mockAuthService.register(
              email: 'new@example.com',
              password: 'password123',
              username: 'newuser',
            ),
          ).thenAnswer((_) async => Result.ok(testUser));
        },
        act: (cubit) => cubit.register(
          email: 'new@example.com',
          password: 'password123',
          username: 'newuser',
        ),
        expect: () => [
          isA<AuthSubmitting>(),
          isA<AuthSuccess>().having((s) => s.user, 'user', testUser),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'register should emit failure when registration fails',
        build: () => authCubit,
        setUp: () {
          when(
            () => mockAuthService.register(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
            ),
          ).thenAnswer((_) async => Result.err(AuthError.unknown));
        },
        act: (cubit) => cubit.register(
          email: 'existing@example.com',
          password: 'password123',
          username: 'existing',
        ),
        expect: () => [
          isA<AuthSubmitting>(),
          isA<AuthFailure>().having((s) => s.error, 'error', AuthError.unknown),
        ],
      );
    });
  });
}
