import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/cubit/auth_state.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/core/auth/auth_error_handler.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/auth/jwt_service.dart';
import 'package:crypto_market/core/auth/secure_storage_service.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}

class MockAuthErrorHandler extends Mock implements AuthErrorHandler {}

class MockJWTService extends Mock implements JWTService {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockNavigatorState extends Mock implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockNavigatorState';
  }
}

class MockGlobalKey extends Mock implements GlobalKey<NavigatorState> {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockGlobalKey';
  }
}

void main() {
  group('Authentication Flow Integration Tests', () {
    late AuthCubit authCubit;
    late MockAuthService mockAuthService;
    late MockAuthErrorHandler mockErrorHandler;
    late MockJWTService mockJWTService;
    late MockSecureStorageService mockStorageService;
    late MockGlobalKey navigatorKey;
    late MockNavigatorState mockNavigatorState;

    setUp(() {
      mockAuthService = MockAuthService();
      mockErrorHandler = MockAuthErrorHandler();
      mockJWTService = MockJWTService();
      mockStorageService = MockSecureStorageService();
      navigatorKey = MockGlobalKey();
      mockNavigatorState = MockNavigatorState();
      when(() => navigatorKey.currentState).thenReturn(mockNavigatorState);

      authCubit = AuthCubit(
        authService: mockAuthService,
        navigatorKey: navigatorKey,
      );
    });

    tearDown(() {
      authCubit.close();
    });

    testWidgets('Complete registration flow', (WidgetTester tester) async {
      // Setup test data
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testUsername = 'testuser';
      const testUser = User(
        id: 'test-id',
        email: testEmail,
        username: testUsername,
        authProvider: 'email',
        principalId: 'principal-id',
        isVerified: false,
        roles: [],
        metadata: {},
      );

      // Mock successful registration
      when(
        () => mockAuthService.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        ),
      ).thenAnswer((_) async => Result.ok(testUser));

      // Mock successful JWT token generation and storage
      when(
        () => mockJWTService.generateToken(
          userId: testUser.id,
          email: testUser.email,
          username: testUser.username,
          principalId: testUser.principalId,
          secret: any(named: 'secret'),
        ),
      ).thenAnswer((_) async => 'test-jwt-token');

      when(
        () => mockJWTService.storeToken('test-jwt-token'),
      ).thenAnswer((_) async {});

      // Mock ICP key pair storage
      when(
        () => mockStorageService.storeICPKeyPair(testUser.id, any()),
      ).thenAnswer((_) async {});

      // Execute registration
      await authCubit.register(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Verify state transitions
      expect(authCubit.state, isA<AuthSuccess>());
      final successState = authCubit.state as AuthSuccess;
      expect(successState.user.email, equals(testEmail));
      expect(successState.user.username, equals(testUsername));

      // Verify service calls
      verify(
        () => mockAuthService.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        ),
      ).called(1);
    });

    testWidgets('Registration with validation errors', (
      WidgetTester tester,
    ) async {
      const invalidEmail = 'invalid-email';
      const weakPassword = '123';
      const shortUsername = 'ab';

      // Mock failed registration
      when(
        () => mockAuthService.register(
          email: invalidEmail,
          password: weakPassword,
          username: shortUsername,
        ),
      ).thenAnswer(
        (_) async => Result.err(ValidationError('Invalid input data')),
      );

      // Execute registration with invalid data
      await authCubit.register(
        email: invalidEmail,
        password: weakPassword,
        username: shortUsername,
      );

      // Verify error state
      expect(authCubit.state, isA<AuthFailure>());
      final failureState = authCubit.state as AuthFailure;
      expect(failureState.error, isA<ValidationError>());

      // Verify error handler was called
      verify(() => mockErrorHandler.handleAuthError(any())).called(1);
    });

    testWidgets('Email login flow', (WidgetTester tester) async {
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
      );

      // Mock successful login
      when(
        () => mockAuthService.loginWithEmailPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => Result.ok(testUser));

      // Mock session validation
      when(
        () => mockAuthService.getCurrentUser(),
      ).thenAnswer((_) async => testUser);

      // Execute login
      await authCubit.loginWithEmailPassword(
        email: testEmail,
        password: testPassword,
      );

      // Verify success state
      expect(authCubit.state, isA<AuthSuccess>());
      final successState = authCubit.state as AuthSuccess;
      expect(successState.user.email, equals(testEmail));

      // Verify service calls
      verify(
        () => mockAuthService.loginWithEmailPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
    });

    testWidgets('OAuth login flow - Google', (WidgetTester tester) async {
      const testUser = User(
        id: 'google-user-id',
        email: 'google@example.com',
        username: 'google_user',
        principalId: 'principal-id',
        isVerified: false,
        roles: [],
        metadata: {},
      );

      // Mock successful Google sign-in
      when(
        () => mockAuthService.signInWithGoogle(),
      ).thenAnswer((_) async => Result.ok(testUser));

      // Execute Google sign-in
      await authCubit.signInWithGoogle();

      // Verify success state
      expect(authCubit.state, isA<AuthSuccess>());
      final successState = authCubit.state as AuthSuccess;
      expect(successState.user.email, equals('google@example.com'));
      expect(successState.user.username, equals('google_user'));

      // Verify service calls
      verify(() => mockAuthService.signInWithGoogle()).called(1);
    });

    testWidgets('OAuth login flow - Facebook', (WidgetTester tester) async {
      const testUser = User(
        id: 'facebook-user-id',
        email: 'facebook@example.com',
        username: 'facebook_user',
        principalId: 'principal-id',
        isVerified: false,
        roles: [],
        metadata: {},
      );

      // Mock successful Facebook sign-in
      when(
        () => mockAuthService.signInWithFacebook(),
      ).thenAnswer((_) async => Result.ok(testUser));

      // Execute Facebook sign-in
      await authCubit.signInWithFacebook();

      // Verify success state
      expect(authCubit.state, isA<AuthSuccess>());
      final successState = authCubit.state as AuthSuccess;
      expect(successState.user.email, equals('facebook@example.com'));
      expect(successState.user.username, equals('facebook_user'));

      // Verify service calls
      verify(() => mockAuthService.signInWithFacebook()).called(1);
    });

    testWidgets('OAuth login flow - Apple', (WidgetTester tester) async {
      const testUser = User(
        id: 'apple-user-id',
        email: 'apple@example.com',
        username: 'apple_user',
        principalId: 'principal-id',
        isVerified: false,
        roles: [],
        metadata: {},
      );

      // Mock successful Apple sign-in
      when(
        () => mockAuthService.signInWithApple(),
      ).thenAnswer((_) async => Result.ok(testUser));

      // Execute Apple sign-in
      await authCubit.signInWithApple();

      // Verify success state
      expect(authCubit.state, isA<AuthSuccess>());
      final successState = authCubit.state as AuthSuccess;
      expect(successState.user.email, equals('apple@example.com'));
      expect(successState.user.username, equals('apple_user'));

      // Verify service calls
      verify(() => mockAuthService.signInWithApple()).called(1);
    });

    testWidgets('Session persistence after login', (WidgetTester tester) async {
      const testUser = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        principalId: 'principal-id',
        isVerified: false,
        roles: [],
        metadata: {},
      );

      // Mock login
      when(
        () => mockAuthService.loginWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => Result.ok(testUser));

      // Mock session check
      when(
        () => mockAuthService.isAuthenticated(),
      ).thenAnswer((_) async => true);
      when(
        () => mockAuthService.getCurrentUser(),
      ).thenAnswer((_) async => testUser);

      // Login first
      await authCubit.loginWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      // Check session
      await authCubit.checkSession();

      // Verify session persists
      expect(authCubit.state, isA<AuthSuccess>());
      final successState = authCubit.state as AuthSuccess;
      expect(successState.user.email, equals('test@example.com'));

      // Verify session check calls
      verify(() => mockAuthService.isAuthenticated()).called(1);
      verify(() => mockAuthService.getCurrentUser()).called(1);
    });

    testWidgets('Logout flow', (WidgetTester tester) async {
      // Mock logout
      when(() => mockAuthService.logout()).thenAnswer((_) async {});

      // Execute logout
      await authCubit.logout();

      // Verify initial state
      expect(authCubit.state, isA<AuthInitial>());

      // Verify logout call
      verify(() => mockAuthService.logout()).called(1);
    });

    testWidgets('Error handling during registration', (
      WidgetTester tester,
    ) async {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testUsername = 'testuser';

      // Mock network error
      when(
        () => mockAuthService.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        ),
      ).thenAnswer((_) async => Result.err(NetworkError('Connection timeout')));

      // Execute registration
      await authCubit.register(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Verify error state
      expect(authCubit.state, isA<AuthFailure>());
      final failureState = authCubit.state as AuthFailure;
      expect(failureState.error, isA<NetworkError>());

      // Verify error handler was called
      verify(() => mockErrorHandler.handleAuthError(any())).called(1);
    });

    testWidgets('Concurrent operation prevention', (WidgetTester tester) async {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testUsername = 'testuser';

      // Mock slow registration
      when(
        () => mockAuthService.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return Result.ok(
          const User(
            id: 'test-id',
            email: testEmail,
            username: testUsername,
            principalId: 'principal-id',
            isVerified: false,
            roles: [],
            metadata: {},
          ),
        );
      });

      // Start registration
      unawaited(
        authCubit.register(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        ),
      );

      // Verify state is submitting
      expect(authCubit.state, isA<AuthSubmitting>());

      // Try to start another registration immediately
      await authCubit.register(
        email: 'another@example.com',
        password: 'password123',
        username: 'anotheruser',
      );

      // Verify state is still submitting (second call should be ignored)
      expect(authCubit.state, isA<AuthSubmitting>());

      // Wait for first registration to complete
      await Future.delayed(const Duration(milliseconds: 150));

      // Verify final state is success
      expect(authCubit.state, isA<AuthSuccess>());
    });
  });
}
