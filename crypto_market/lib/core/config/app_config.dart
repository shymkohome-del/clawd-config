// Centralized application config; relies on --dart-define values at build time.

/// Error thrown when a required configuration key is missing.
class AppConfigValidationError implements Exception {
  final String missingKey;

  const AppConfigValidationError(this.missingKey);

  @override
  String toString() => 'AppConfigValidationError(missingKey: $missingKey)';
}

/// Centralized application configuration with required key enforcement.
///
/// Values are primarily sourced from --dart-define at build time. If a required
/// key is missing, [AppConfigValidationError] is thrown by [load].
class AppConfig {
  // OAuth
  final String oauthGoogleClientId;
  final String oauthGoogleClientSecret;
  final String oauthAppleTeamId;
  final String oauthAppleKeyId;

  // IPFS
  final String ipfsNodeUrl;
  final String ipfsGatewayUrl;

  // Canisters
  final String canisterIdMarketplace;
  final String canisterIdUserManagement;
  final String canisterIdAtomicSwap;
  final String canisterIdPriceOracle;

  // Optional
  final String? chainlinkApiKey;
  final String? coingeckoApiKey;
  final String? kycProviderApiKey;

  const AppConfig({
    required this.oauthGoogleClientId,
    required this.oauthGoogleClientSecret,
    required this.oauthAppleTeamId,
    required this.oauthAppleKeyId,
    required this.ipfsNodeUrl,
    required this.ipfsGatewayUrl,
    required this.canisterIdMarketplace,
    required this.canisterIdUserManagement,
    required this.canisterIdAtomicSwap,
    required this.canisterIdPriceOracle,
    this.chainlinkApiKey,
    this.coingeckoApiKey,
    this.kycProviderApiKey,
  });

  /// Load config from compile-time environment defines.
  ///
  /// Precedence: --dart-define overrides defaults. Secrets are never committed.
  static AppConfig load() {
    final Map<String, String> defines = {
      // OAuth
      'OAUTH_GOOGLE_CLIENT_ID': const String.fromEnvironment(
        'OAUTH_GOOGLE_CLIENT_ID',
        defaultValue: '',
      ),
      'OAUTH_GOOGLE_CLIENT_SECRET': const String.fromEnvironment(
        'OAUTH_GOOGLE_CLIENT_SECRET',
        defaultValue: '',
      ),
      'OAUTH_APPLE_TEAM_ID': const String.fromEnvironment(
        'OAUTH_APPLE_TEAM_ID',
        defaultValue: '',
      ),
      'OAUTH_APPLE_KEY_ID': const String.fromEnvironment(
        'OAUTH_APPLE_KEY_ID',
        defaultValue: '',
      ),
      // IPFS
      'IPFS_NODE_URL': const String.fromEnvironment(
        'IPFS_NODE_URL',
        defaultValue: '',
      ),
      'IPFS_GATEWAY_URL': const String.fromEnvironment(
        'IPFS_GATEWAY_URL',
        defaultValue: '',
      ),
      // Canisters
      'CANISTER_ID_MARKETPLACE': const String.fromEnvironment(
        'CANISTER_ID_MARKETPLACE',
        defaultValue: '',
      ),
      'CANISTER_ID_USER_MANAGEMENT': const String.fromEnvironment(
        'CANISTER_ID_USER_MANAGEMENT',
        defaultValue: '',
      ),
      'CANISTER_ID_ATOMIC_SWAP': const String.fromEnvironment(
        'CANISTER_ID_ATOMIC_SWAP',
        defaultValue: '',
      ),
      'CANISTER_ID_PRICE_ORACLE': const String.fromEnvironment(
        'CANISTER_ID_PRICE_ORACLE',
        defaultValue: '',
      ),
      // Optional
      'CHAINLINK_API_KEY': const String.fromEnvironment(
        'CHAINLINK_API_KEY',
        defaultValue: '',
      ),
      'COINGECKO_API_KEY': const String.fromEnvironment(
        'COINGECKO_API_KEY',
        defaultValue: '',
      ),
      'KYC_PROVIDER_API_KEY': const String.fromEnvironment(
        'KYC_PROVIDER_API_KEY',
        defaultValue: '',
      ),
    };

    return tryLoad(defines: defines);
  }

  /// Testable loader that accepts a map of defines (simulating --dart-define).
  /// This allows unit tests to validate required key enforcement and defaults.
  static AppConfig tryLoad({required Map<String, String> defines}) {
    String requireKey(String key) {
      final value = defines[key] ?? '';
      if (value.isEmpty) {
        throw AppConfigValidationError(key);
      }
      return value;
    }

    // Build the config, throwing for missing required keys
    return AppConfig(
      oauthGoogleClientId: requireKey('OAUTH_GOOGLE_CLIENT_ID'),
      oauthGoogleClientSecret: requireKey('OAUTH_GOOGLE_CLIENT_SECRET'),
      oauthAppleTeamId: requireKey('OAUTH_APPLE_TEAM_ID'),
      oauthAppleKeyId: requireKey('OAUTH_APPLE_KEY_ID'),
      ipfsNodeUrl: requireKey('IPFS_NODE_URL'),
      ipfsGatewayUrl: requireKey('IPFS_GATEWAY_URL'),
      canisterIdMarketplace: requireKey('CANISTER_ID_MARKETPLACE'),
      canisterIdUserManagement: requireKey('CANISTER_ID_USER_MANAGEMENT'),
      canisterIdAtomicSwap: requireKey('CANISTER_ID_ATOMIC_SWAP'),
      canisterIdPriceOracle: requireKey('CANISTER_ID_PRICE_ORACLE'),
      chainlinkApiKey: (defines['CHAINLINK_API_KEY'] ?? '').isEmpty
          ? null
          : defines['CHAINLINK_API_KEY'],
      coingeckoApiKey: (defines['COINGECKO_API_KEY'] ?? '').isEmpty
          ? null
          : defines['COINGECKO_API_KEY'],
      kycProviderApiKey: (defines['KYC_PROVIDER_API_KEY'] ?? '').isEmpty
          ? null
          : defines['KYC_PROVIDER_API_KEY'],
    );
  }
}
