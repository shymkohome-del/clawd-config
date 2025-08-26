import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Principal shim', () {
    AppConfig cfg({required bool shim}) => AppConfig.tryLoad(
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
        'FEATURE_PRINCIPAL_SHIM': shim ? 'true' : 'false',
      },
    );

    test('register returns user with empty id when shim disabled', () async {
      final icp = ICPService.fromConfig(cfg(shim: false));
      final res = await icp.register(
        email: 'u@e.com',
        password: 'p',
        username: 'u',
      );
      expect(res.isOk, isTrue);
      expect(res.ok.id, '');
    });

    test('register returns user with principal when shim enabled', () async {
      final icp = ICPService.fromConfig(cfg(shim: true));
      final res = await icp.register(
        email: 'u@e.com',
        password: 'p',
        username: 'u',
      );
      expect(res.isOk, isTrue);
      expect(res.ok.id.startsWith('principal-'), isTrue);
    });
  });
}
