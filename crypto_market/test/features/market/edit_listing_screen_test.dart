import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:crypto_market/features/market/screens/edit_listing_screen.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _TestMarketService extends MarketServiceProvider {
  _TestMarketService(super.icp);
  bool called = false;
  @override
  Future<void> updateListing({
    required String listingId,
    required String title,
    required int priceInUsd,
    String? imagePath,
  }) async {
    called = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('prepopulates fields and updates listing on save', (
    tester,
  ) async {
    final cfg = AppConfig.tryLoad(
      defines: {
        'OAUTH_GOOGLE_CLIENT_ID': 'x',
        'OAUTH_GOOGLE_CLIENT_SECRET': 'x',
        'OAUTH_APPLE_TEAM_ID': 'x',
        'OAUTH_APPLE_KEY_ID': 'x',
        'IPFS_NODE_URL': 'node',
        'IPFS_GATEWAY_URL': 'gateway',
        'CANISTER_ID_MARKETPLACE': 'aaaaa-aa',
        'CANISTER_ID_USER_MANAGEMENT': 'bbbbb-bb',
        'CANISTER_ID_ATOMIC_SWAP': 'ccccc-cc',
        'CANISTER_ID_PRICE_ORACLE': 'ddddd-dd',
      },
    );
    final icp = ICPService.fromConfig(cfg);
    final service = _TestMarketService(icp);

    await tester.pumpWidget(
      RepositoryProvider<MarketServiceProvider>.value(
        value: service,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const EditListingScreen(
            listingId: '1',
            initialTitle: 'Old',
            initialPrice: 10,
          ),
        ),
      ),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(EditListingScreen)),
    );

    expect(find.byKey(const Key('editTitleField')), findsOneWidget);
    expect(find.byKey(const Key('editPriceField')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('editTitleField')), 'New');
    await tester.enterText(find.byKey(const Key('editPriceField')), '20');
    await tester.tap(find.text(l10n.saveChanges));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.confirmUpdateYes));
    await tester.pumpAndSettle();

    expect(service.called, isTrue);
  });
}
