import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/config/app_config.dart';

void main() {
  group('AppConfig.tryLoad', () {
    Map<String, String> minimalValid() => {
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
        };

    test('throws when a required key is missing', () {
      final defines = minimalValid();
      defines.remove('OAUTH_GOOGLE_CLIENT_ID');
      expect(
        () => AppConfig.tryLoad(defines: defines),
        throwsA(isA<AppConfigValidationError>()),
      );
    });

    test('loads when all required keys are present', () {
      final cfg = AppConfig.tryLoad(defines: minimalValid());
      expect(cfg.ipfsGatewayUrl, 'http://gateway');
      expect(cfg.canisterIdMarketplace, 'aaaaa-aa');
    });

    test('optional keys can be absent and resolve to null', () {
      final cfg = AppConfig.tryLoad(defines: minimalValid());
      expect(cfg.chainlinkApiKey, isNull);
      expect(cfg.coingeckoApiKey, isNull);
      expect(cfg.kycProviderApiKey, isNull);
    });
  });
}


