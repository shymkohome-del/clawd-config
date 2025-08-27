import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:crypto_market/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/i18n/locale_controller.dart';

void main() {
  group('RegisterScreen integration', () {
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
        },
      );
      icp = ICPService.fromConfig(cfg);
    });

    testWidgets('successful email registration navigates to home', (
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

      // Ensure we're on login then navigate to register
      expect(find.byType(AppBar), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // Fill out form
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'username');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      // Submit
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      // Should navigate to Home
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('OAuth initiation buttons are present and tappable', (
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

      // Navigate to register
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // Buttons visible
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);

      // Tap them (these trigger cubit, remain on screen due to placeholder token)
      await tester.tap(find.text('Continue with Google'), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.text('Continue with Apple'), warnIfMissed: false);
      await tester.pump();
    });
  });
}
