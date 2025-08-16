import 'errors.dart';
import 'package:crypto_market/core/config/app_config.dart';

/// Skeleton ICPService with initialization hooks and method stubs.
class ICPService {
  final AppConfig config;
  final Map<String, String> _marketActor;
  final Map<String, String> _userManagementActor;
  final Map<String, String> _atomicSwapActor;
  final Map<String, String> _priceOracleActor;

  ICPService._(
    this.config,
    this._marketActor,
    this._userManagementActor,
    this._atomicSwapActor,
    this._priceOracleActor,
  );

  factory ICPService.fromConfig(AppConfig config) {
    // Initialize canister actors here using config.canisterId*
    final market = {'canisterId': config.canisterIdMarketplace};
    final userMgmt = {'canisterId': config.canisterIdUserManagement};
    final atomicSwap = {'canisterId': config.canisterIdAtomicSwap};
    final priceOracle = {'canisterId': config.canisterIdPriceOracle};
    return ICPService._(
      config,
      market,
      userMgmt,
      atomicSwap,
      priceOracle,
    );
  }

  Map<String, String> get marketActor => _marketActor;
  Map<String, String> get userManagementActor => _userManagementActor;
  Map<String, String> get atomicSwapActor => _atomicSwapActor;
  Map<String, String> get priceOracleActor => _priceOracleActor;

  Future<Result<T, AuthError>> _wrapAuthCall<T>(
    Future<T> Function() action,
  ) async {
    try {
      final value = await action();
      return Result.ok(value);
    } catch (e) {
      return Result.err(mapAuthExceptionToAuthError(e));
    }
  }

  Future<Result<Unit, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    // TODO: replace with actual canister actor call
    return _wrapAuthCall<Unit>(() async {
      // simulate actor call
      return const Unit();
    });
  }

  Future<Result<Unit, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    // TODO: replace with actual canister actor call
    return _wrapAuthCall<Unit>(() async {
      // simulate actor call
      return const Unit();
    });
  }

  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) async {
    // TODO: replace with actual canister actor call
    return _wrapAuthCall<Map<String, dynamic>>(() async {
      // simulate actor call
      return <String, dynamic>{'principal': principal};
    });
  }
}
