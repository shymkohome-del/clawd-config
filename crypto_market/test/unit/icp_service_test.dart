import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';

void main() {
  test('ICPService.fromConfig constructs', () {
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
    final service = ICPService.fromConfig(cfg);
    expect(service, isA<ICPService>());
  });
}
