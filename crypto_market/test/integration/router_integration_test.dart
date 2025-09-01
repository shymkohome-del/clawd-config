import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/core/routing/app_router.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/l10n/app_localizations.dart';

void main() {
  group('AppRouter Integration Tests', () {
    testWidgets(
      'navigation to protected route redirects to login when unauthenticated',
      (tester) async {
        final mockAuthService = MockAuthService();

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MultiRepositoryProvider(
              providers: [
                RepositoryProvider<AuthService>.value(value: mockAuthService),
              ],
              child: BlocProvider<AuthCubit>(
                create: (_) => AuthCubit(authService: mockAuthService),
                child: child!,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should redirect to login when accessing protected /home route
        expect(find.text('Email'), findsWidgets);
        expect(find.text('Password'), findsWidgets);
        expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      },
    );

    testWidgets('can navigate between login and register screens', (
      tester,
    ) async {
      final mockAuthService = MockAuthService();

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MultiRepositoryProvider(
            providers: [
              RepositoryProvider<AuthService>.value(value: mockAuthService),
            ],
            child: BlocProvider<AuthCubit>(
              create: (_) => AuthCubit(authService: mockAuthService),
              child: child!,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be on login screen initially (verify by presence of login-specific elements)
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);

      // Navigate to register screen
      final registerButton = find.text('Go to Register');
      expect(registerButton, findsOneWidget);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Should now be on register screen (verify by presence of username field)
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
    });
  });
}

/// Mock AuthService for testing
class MockAuthService implements AuthService {
  @override
  Future<Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return const Result.err(AuthError.invalidCredentials);
  }

  @override
  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    return const Result.err(AuthError.oauthDenied);
  }

  @override
  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    return const Result.err(AuthError.invalidCredentials);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<User?> getCurrentUser() async {
    return null;
  }

  @override
  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) async {
    return const Result.err(AuthError.network);
  }
}
