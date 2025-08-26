import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/features/auth/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  testWidgets(
    'Register form validates and submit button disabled while submitting',
    (tester) async {
      // Provide minimal DI
      AppConfig.tryLoad(
        defines: {
          'OAUTH_GOOGLE_CLIENT_ID': 'test',
          'OAUTH_GOOGLE_CLIENT_SECRET': 'test',
          'OAUTH_APPLE_TEAM_ID': 'test',
          'OAUTH_APPLE_KEY_ID': 'test',
          'IPFS_NODE_URL': 'http://localhost',
          'IPFS_GATEWAY_URL': 'http://localhost/ipfs',
          'CANISTER_ID_MARKETPLACE': 'market-1',
          'CANISTER_ID_USER_MANAGEMENT': 'user-1',
          'CANISTER_ID_ATOMIC_SWAP': 'swap-1',
          'CANISTER_ID_PRICE_ORACLE': 'oracle-1',
        },
      );
      // Provide a stub service that introduces a short delay to observe submitting state
      final auth = _DelayedOkAuthService();

      await tester.pumpWidget(
        RepositoryProvider<AuthService>.value(
          value: auth,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('lv')],
            routes: {
              '/home': (_) => const Scaffold(body: Center(child: Text('Home'))),
            },
            home: RegisterScreen(authServiceOverride: auth),
          ),
        ),
      );

      // Initial: button enabled but form invalid
      expect(find.text('Create account'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'username');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      await tester.tap(find.text('Create account'));
      await tester.pump(); // start submitting

      // Submitting state shows progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let it finish and navigate
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    },
  );
}

class _DelayedOkAuthService implements AuthService {
  @override
  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return Result.ok(
      User(
        id: 'principal-oauth',
        email: 'oauth@example.com',
        username: 'oauth',
        authProvider: provider,
        createdAtMillis: 0,
      ),
    );
  }

  @override
  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Result.ok(
      User(
        id: 'principal-mock',
        email: email,
        username: username,
        authProvider: 'email',
        createdAtMillis: 0,
      ),
    );
  }

  @override
  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) async => Result.ok({'principal': principal});
}
