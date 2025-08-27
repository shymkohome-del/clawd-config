import 'errors.dart';
import 'package:crypto_market/core/config/app_config.dart';

class User {
  final String id; // Principal text repr in shim mode
  final String email;
  final String username;
  final String authProvider; // e.g., 'email', 'google', 'apple'
  final int createdAtMillis;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.authProvider,
    required this.createdAtMillis,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'authProvider': authProvider,
    'createdAt': createdAtMillis,
  };
}

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
    return ICPService._(config, market, userMgmt, atomicSwap, priceOracle);
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

  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    // TODO: replace with actual canister actor call
    return _wrapAuthCall<User>(() async {
      // simulate actor call and principal mapping when feature flag is on
      if (config.featurePrincipalShim) {
        final principal = _deriveDeterministicPrincipal(email);
        return User(
          id: principal,
          email: email,
          username: username,
          authProvider: 'email',
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
      }
      // Without shim, return a user with empty id to indicate missing mapping
      return User(
        id: '',
        email: email,
        username: username,
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
    });
  }

  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    // TODO: replace with actual canister actor call
    return _wrapAuthCall<User>(() async {
      // Validate provider basic set
      if (provider != 'google' && provider != 'apple') {
        throw OAuthDeniedException();
      }
      if (config.featurePrincipalShim) {
        final email = 'social-user@example.com';
        final username = provider == 'google' ? 'g_user' : 'a_user';
        final principal = _deriveDeterministicPrincipal('$provider:$token');
        return User(
          id: principal,
          email: email,
          username: username,
          authProvider: provider,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
      }
      return User(
        id: '',
        email: 'social-user@example.com',
        username: provider == 'google' ? 'g_user' : 'a_user',
        authProvider: provider,
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
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

String _deriveDeterministicPrincipal(String seed) {
  // Cheap deterministic stand-in for Principal text. DO NOT use in production.
  // e.g., principal-<simple-hash>
  final codeUnits = seed.codeUnits;
  int hash = 0;
  for (final c in codeUnits) {
    hash = (hash * 31 + c) & 0x7fffffff;
  }
  return 'principal-${hash.toRadixString(16)}';
}
