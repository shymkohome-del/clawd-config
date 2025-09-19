import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/core/routing/protected_route.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/screens/login_screen.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/l10n/app_localizations.dart';

void main() {
  group('ProtectedRoute', () {
    Widget createWidgetUnderTest({
      required AuthState authState,
      required Widget child,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AuthCubit>(
          create: (_) => TestAuthCubit(authState),
          child: ProtectedRoute(child: child),
        ),
      );
    }

    testWidgets('shows loading spinner when auth state is submitting', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          authState: const AuthSubmitting(),
          child: Container(
            key: const Key('protected_content'),
            child: const Text('Protected Content'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('protected_content')), findsNothing);
    });

    testWidgets('shows LoginScreen when user is not authenticated', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          authState: const AuthInitial(),
          child: Container(
            key: const Key('protected_content'),
            child: const Text('Protected Content'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byKey(const Key('protected_content')), findsNothing);
    });

    testWidgets('shows protected content when user is authenticated', (
      tester,
    ) async {
      final mockUser = User(
        id: '1',
        email: 'test@example.com',
        username: 'testuser',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          authState: AuthSuccess(mockUser),
          child: Container(
            key: const Key('protected_content'),
            child: const Text('Protected Content'),
          ),
        ),
      );

      expect(find.byKey(const Key('protected_content')), findsOneWidget);
      expect(find.text('Protected Content'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}

/// Test implementation of AuthCubit for testing purposes
class TestAuthCubit extends AuthCubit {
  final AuthState _testState;

  TestAuthCubit(this._testState)
    : super(
        authService: MockAuthService(),
        navigatorKey: GlobalKey<NavigatorState>(),
      );

  @override
  AuthState get state => _testState;
}

/// Mock AuthService for testing
class MockAuthService implements AuthService {
  @override
  Future<Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    throw UnimplementedError();
  }

  @override
  Future<User?> getCurrentUser() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) async {
    throw UnimplementedError();
  }
}
