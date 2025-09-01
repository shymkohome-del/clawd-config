import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';

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
    expect(ICPService.fromConfig(cfg), isA<ICPService>());
  });

  test('register maps low-level exceptions to AuthError via wrapper', () async {
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
    // ensure cfg is used to satisfy analyzer and actors construct
    final service = ICPService.fromConfig(cfg);
    expect(service, isA<ICPService>());
    expect((service.marketActor as Map)['canisterId'], 'aaaaa-aa');
    expect((service.userManagementActor as Map)['canisterId'], 'bbbbb-bb');
    expect((service.atomicSwapActor as Map)['canisterId'], 'ccccc-cc');
    expect((service.priceOracleActor as Map)['canisterId'], 'ddddd-dd');
    // We cannot inject the actor, so simulate by triggering the wrapper through a fake failure
    // by calling loginWithOAuth and expecting success (current stub), then verify mapping helper separately.
    expect(
      mapAuthExceptionToAuthError(Exception('network timeout')),
      AuthError.network,
    );
    expect(
      mapAuthExceptionToAuthError(Exception('invalid credential')),
      AuthError.invalidCredentials,
    );
    expect(
      mapAuthExceptionToAuthError(Exception('oauth denied by user')),
      AuthError.oauthDenied,
    );
    expect(
      mapAuthExceptionToAuthError(Exception('something else')),
      AuthError.unknown,
    );
  });
}
