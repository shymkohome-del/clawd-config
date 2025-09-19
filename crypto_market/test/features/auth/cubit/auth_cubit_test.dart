import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/core/auth/auth_error_handler.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}

class MockAuthErrorHandler extends Mock implements AuthErrorHandler {}

void main() {
  late AuthCubit authCubit;
  late MockAuthService mockAuthService;
  late MockAuthErrorHandler mockErrorHandler;
  late GlobalKey<NavigatorState> mockNavigatorKey;

  setUp(() {
    mockAuthService = MockAuthService();
    mockErrorHandler = MockAuthErrorHandler();
    mockNavigatorKey = GlobalKey<NavigatorState>();
    authCubit = AuthCubit(
      authService: mockAuthService,
      navigatorKey: mockNavigatorKey,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit Initial State', () {
    test('initial state is AuthState.initial()', () {
      expect(authCubit.state, AuthState.initial());
    });
  });

  group('Registration', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testUsername = 'testuser';
    const testUser = User(
      id: 'test-id',
      email: testEmail,
      username: testUsername,
      principalId: 'principal-id',
      isVerified: false,
      roles: [],
      metadata: {},
      authProvider: 'email',
      createdAtMillis: 1234567890,
    );

    blocTest<AuthCubit, AuthState>(
      'emits [submitting, success] when registration is successful',
      build: () => authCubit,
      act: (cubit) async {
        when(
          () => mockAuthService.register(
            email: testEmail,
            password: testPassword,
            username: testUsername,
          ),
        ).thenAnswer((_) async => Result.ok(testUser));

        await cubit.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        );
      },
      expect: () => [AuthState.submitting(), AuthState.success(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [submitting, failure] when registration fails',
      build: () => authCubit,
      act: (cubit) async {
        final error = AuthError('Registration failed');
        when(
          () => mockAuthService.register(
            email: testEmail,
            password: testPassword,
            username: testUsername,
          ),
        ).thenAnswer((_) async => Result.err(error));

        await cubit.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        );
      },
      expect: () => [AuthState.submitting(), AuthState.failure(error)],
    );

    blocTest<AuthCubit, AuthState>(
      'calls error handler when registration fails',
      build: () => authCubit,
      act: (cubit) async {
        final error = AuthError('Registration failed');
        when(
          () => mockAuthService.register(
            email: testEmail,
            password: testPassword,
            username: testUsername,
          ),
        ).thenAnswer((_) async => Result.err(error));

        await cubit.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        );

        verify(() => mockErrorHandler.handleAuthError(error)).called(1);
      },
    );
  });

  group('Email/Password Login', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testUser = User(
      id: 'test-id',
      email: testEmail,
      username: 'testuser',
      principalId: 'principal-id',
      isVerified: false,
      roles: [],
      metadata: {},
      authProvider: 'email',
      createdAtMillis: 1234567890,
    );

    blocTest<AuthCubit, AuthState>(
      'emits [submitting, success] when login is successful',
      build: () => authCubit,
      act: (cubit) async {
        when(
          () => mockAuthService.loginWithEmailPassword(
            email: testEmail,
            password: testPassword,
          ),
        ).thenAnswer((_) async => Result.ok(testUser));

        await cubit.loginWithEmailPassword(
          email: testEmail,
          password: testPassword,
        );
      },
      expect: () => [AuthState.submitting(), AuthState.success(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [submitting, failure] when login fails',
      build: () => authCubit,
      act: (cubit) async {
        final error = AuthError('Login failed');
        when(
          () => mockAuthService.loginWithEmailPassword(
            email: testEmail,
            password: testPassword,
          ),
        ).thenAnswer((_) async => Result.err(error));

        await cubit.loginWithEmailPassword(
          email: testEmail,
          password: testPassword,
        );
      },
      expect: () => [AuthState.submitting(), AuthState.failure(error)],
    );
  });

  group('OAuth Login', () {
    const testUser = User(
      id: 'test-id',
      email: 'test@example.com',
      username: 'testuser',
      principalId: 'principal-id',
      isVerified: false,
      roles: [],
      metadata: {},
    );

    blocTest<AuthCubit, AuthState>(
      'emits [submitting, success] when Google sign-in is successful',
      build: () => authCubit,
      act: (cubit) async {
        when(
          () => mockAuthService.signInWithGoogle(),
        ).thenAnswer((_) async => Result.ok(testUser));

        await cubit.signInWithGoogle();
      },
      expect: () => [AuthState.submitting(), AuthState.success(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [submitting, success] when Facebook sign-in is successful',
      build: () => authCubit,
      act: (cubit) async {
        when(
          () => mockAuthService.signInWithFacebook(),
        ).thenAnswer((_) async => Result.ok(testUser));

        await cubit.signInWithFacebook();
      },
      expect: () => [AuthState.submitting(), AuthState.success(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [submitting, success] when Apple sign-in is successful',
      build: () => authCubit,
      act: (cubit) async {
        when(
          () => mockAuthService.signInWithApple(),
        ).thenAnswer((_) async => Result.ok(testUser));

        await cubit.signInWithApple();
      },
      expect: () => [AuthState.submitting(), AuthState.success(testUser)],
    );
  });

  group('Session Management', () {
    const testUser = User(
      id: 'test-id',
      email: 'test@example.com',
      username: 'testuser',
      principalId: 'principal-id',
      isVerified: false,
      roles: [],
      metadata: {},
    );

    blocTest<AuthCubit, AuthState>(
      'emits success when user is authenticated',
      build: () => authCubit,
      act: (cubit) async {
        when(
          () => mockAuthService.isAuthenticated(),
        ).thenAnswer((_) async => true);
        when(
          () => mockAuthService.getCurrentUser(),
        ).thenAnswer((_) async => testUser);

        await cubit.checkSession();
      },
      expect: () => [AuthState.success(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits initial when user is not authenticated',
      build: () => authCubit,
      act: (cubit) async {
        when(
          () => mockAuthService.isAuthenticated(),
        ).thenAnswer((_) async => false);

        await cubit.checkSession();
      },
      expect: () => [AuthState.initial()],
    );
  });

  group('Logout', () {
    blocTest<AuthCubit, AuthState>(
      'emits initial after logout',
      build: () => authCubit,
      act: (cubit) async {
        when(() => mockAuthService.logout()).thenAnswer((_) async {});

        await cubit.logout();
      },
      expect: () => [AuthState.initial()],
      verify: (_) {
        verify(() => mockAuthService.logout()).called(1);
      },
    );
  });

  group('Reset', () {
    blocTest<AuthCubit, AuthState>(
      'emits initial state when reset',
      build: () => authCubit,
      act: (cubit) => cubit.reset(),
      expect: () => [AuthState.initial()],
    );
  });
}
