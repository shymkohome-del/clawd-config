// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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
  testWidgets('Base routes are navigable', (WidgetTester tester) async {
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
    final icp = ICPService.fromConfig(cfg);

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

    // Initial route: /login
    expect(find.byType(AppBar), findsOneWidget);

    // Navigate to /register
    // Tap the first ElevatedButton which navigates to Register
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);

    // Navigate to /home
    // Fill valid inputs and submit to trigger navigation
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'username');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);
  });
}
