import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Providers resolve with injected ICPService', (tester) async {
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
      MaterialApp(
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthServiceProvider>(
              create: (_) => AuthServiceProvider(icp),
            ),
            RepositoryProvider<MarketServiceProvider>(
              create: (_) => MarketServiceProvider(icp),
            ),
          ],
          child: const _Probe(),
        ),
      ),
    );

    // If no exceptions thrown during build, providers are wired.
    expect(find.text('ok'), findsOneWidget);
  });
}

class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) {
    final auth = RepositoryProvider.of<AuthServiceProvider>(context);
    final market = RepositoryProvider.of<MarketServiceProvider>(context);
    assert(auth.icpService == market.icpService);
    return const Scaffold(body: Center(child: Text('ok')));
  }
}
