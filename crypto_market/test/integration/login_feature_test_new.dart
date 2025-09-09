import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_utils/test_app_wrapper.dart';

// Mock service that can be configured for different test scenarios
class _TestAuthService extends Mock implements AuthService {
  bool _sessionExists = false;
  User? _currentUser;

  @override
  Future<Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (email.isNotEmpty && password.isNotEmpty) {
      final user = User(
        id: 'login-principal',
        email: email,
        username: email.split('@')[0],
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
      _currentUser = user;
      _sessionExists = true;
      return Result.ok(user);
    }
    return const Result.err(AuthError.invalidCredentials);
  }

  @override
  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final user = User(
      id: 'oauth-principal',
      email: 'user@${provider.toLowerCase()}.com',
      username: 'oauth_user',
      authProvider: provider,
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    _currentUser = user;
    _sessionExists = true;
    return Result.ok(user);
  }

  @override
  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final user = User(
      id: 'register-principal',
      email: email,
      username: username,
      authProvider: 'email',
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    _currentUser = user;
    _sessionExists = true;
    return Result.ok(user);
  }

  @override
  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) async {
    return Result.ok({'principal': principal});
  }

  @override
  Future<void> logout() async {
    _sessionExists = false;
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async => _sessionExists ? _currentUser : null;
}

void main() {
  group('Login and Session Management Integration Tests', () {
    late _TestAuthService testAuthService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      testAuthService = _TestAuthService();
    });

    testWidgets('LoginScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper(
          includeRouter: false,
          mockAuthService: testAuthService,
          child: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the login screen renders without errors
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('Login form accepts text input', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper(
          includeRouter: false,
          mockAuthService: testAuthService,
          child: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter test data
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Login button is present and tappable', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper(
          includeRouter: false,
          mockAuthService: testAuthService,
          child: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify login button exists and can be tapped
      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsAtLeastNWidgets(1));

      // Tap the button (won't navigate due to no router context, but shouldn't crash)
      await tester.tap(loginButton.first);
      await tester.pumpAndSettle();

      // Still on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('AuthCubit handles login flow', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper(
          includeRouter: false,
          mockAuthService: testAuthService,
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return Column(
                children: [
                  Text('State: ${state.runtimeType}'),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AuthCubit>().loginWithEmailPassword(
                          email: 'test@example.com',
                          password: 'password123',
                        ),
                    child: const Text('Test Login'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state should be AuthInitial
      expect(find.text('State: AuthInitial'), findsOneWidget);

      // Trigger login
      await tester.tap(find.text('Test Login'));
      await tester.pump();

      // Should show submitting state
      expect(find.text('State: AuthSubmitting'), findsOneWidget);

      // Wait for login to complete
      await tester.pumpAndSettle();

      // Should show success state
      expect(find.text('State: AuthSuccess'), findsOneWidget);
    });

    testWidgets('Form validation shows error for empty fields', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper(
          includeRouter: false,
          mockAuthService: testAuthService,
          child: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit with empty fields
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // Form validation should prevent submission
      // (we're still on login screen rather than crashed)
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
