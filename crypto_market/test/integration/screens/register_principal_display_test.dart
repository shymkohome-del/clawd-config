import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/core/i18n/locale_controller.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:crypto_market/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Register -> Home principal display (shim on)', () {
    late ICPService icp;

    setUp(() {
      final cfg = AppConfig.tryLoad(
        defines: {
          'OAUTH_GOOGLE_CLIENT_ID': 'x',
          'OAUTH_GOOGLE_CLIENT_SECRET': 'x',
          'OAUTH_APPLE_TEAM_ID': 'x',
          'OAUTH_APPLE_KEY_ID': 'x',
          'IPFS_NODE_URL': 'http://node',
          'IPFS_GATEWAY_URL': 'http://gateway',
          'CANISTER_ID_MARKETPLACE': 'aaaaa-aa',
          'CANISTER_ID_USER_MANAGEMENT': 'bbbbb-bb',
          'CANISTER_ID_ATOMIC_SWAP': 'ccccc-cc',
          'CANISTER_ID_PRICE_ORACLE': 'ddddd-dd',
          'FEATURE_PRINCIPAL_SHIM': 'true',
        },
      );
      icp = ICPService.fromConfig(cfg);
    });

    testWidgets('principal is shown on Home after register', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthService>(
              create: (_) => AuthServiceProvider(icp),
            ),
            RepositoryProvider<MarketServiceProvider>(
              create: (_) => MarketServiceProvider(icp),
            ),
            RepositoryProvider<LocaleController>(
              create: (_) => LocaleController(),
            ),
          ],
          child: const MyApp(),
        ),
      );

      // On login screen; go to register
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // Fill register form
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'username');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      // Submit
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      // Verify Home and principal visible
      expect(find.text('Home'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) {
          return w is Text &&
              w.data != null &&
              w.data!.startsWith('Principal: principal-');
        }),
        findsOneWidget,
      );
    });
  });

  group('Register -> Home principal display (shim off)', () {
    late ICPService icp;

    setUp(() {
      final cfg = AppConfig.tryLoad(
        defines: {
          'OAUTH_GOOGLE_CLIENT_ID': 'x',
          'OAUTH_GOOGLE_CLIENT_SECRET': 'x',
          'OAUTH_APPLE_TEAM_ID': 'x',
          'OAUTH_APPLE_KEY_ID': 'x',
          'IPFS_NODE_URL': 'http://node',
          'IPFS_GATEWAY_URL': 'http://gateway',
          'CANISTER_ID_MARKETPLACE': 'aaaaa-aa',
          'CANISTER_ID_USER_MANAGEMENT': 'bbbbb-bb',
          'CANISTER_ID_ATOMIC_SWAP': 'ccccc-cc',
          'CANISTER_ID_PRICE_ORACLE': 'ddddd-dd',
          'FEATURE_PRINCIPAL_SHIM': 'false',
        },
      );
      icp = ICPService.fromConfig(cfg);
    });

    testWidgets('principal is not shown on Home when shim disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthService>(
              create: (_) => AuthServiceProvider(icp),
            ),
            RepositoryProvider<MarketServiceProvider>(
              create: (_) => MarketServiceProvider(icp),
            ),
            RepositoryProvider<LocaleController>(
              create: (_) => LocaleController(),
            ),
          ],
          child: const MyApp(),
        ),
      );

      // On login screen; go to register
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // Fill register form
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'username');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      // Submit
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      // Verify Home and principal not visible
      expect(find.text('Home'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) {
          return w is Text &&
              w.data != null &&
              w.data!.startsWith('Principal: ');
        }),
        findsNothing,
      );
    });
  });
}
