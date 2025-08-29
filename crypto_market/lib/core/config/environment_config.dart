/// Environment configuration for canister deployment
class EnvironmentConfig {
  static const String local = 'local';
  static const String mainnet = 'ic';
  
  /// Current environment - defaults to local, can be overridden with --dart-define
  static const String current = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: local,
  );
  
  /// Whether we're running in mainnet
  static bool get isMainnet => current == mainnet;
  
  /// Whether we're running locally
  static bool get isLocal => current == local;
}

/// Canister configuration with environment-based routing
class CanisterConfig {
  // Local development canister IDs (from dfx deploy)
  static const Map<String, String> local = {
    'user_management': 'umunu-kh777-77774-qaaca-cai',
    'marketplace': 'u6s2n-gx777-77774-qaaba-cai',
    'atomic_swap': 'uxrrr-q7777-77774-qaaaq-cai',
    'price_oracle': 'uzt4z-lp777-77774-qaabq-cai',
  };
  
  // Mainnet canister IDs (will be populated after deployment)
  static const Map<String, String> mainnet = {
    'user_management': String.fromEnvironment('CANISTER_ID_USER_MANAGEMENT_MAINNET', defaultValue: ''),
    'marketplace': String.fromEnvironment('CANISTER_ID_MARKETPLACE_MAINNET', defaultValue: ''),
    'atomic_swap': String.fromEnvironment('CANISTER_ID_ATOMIC_SWAP_MAINNET', defaultValue: ''),
    'price_oracle': String.fromEnvironment('CANISTER_ID_PRICE_ORACLE_MAINNET', defaultValue: ''),
  };
  
  /// Get canister ID for current environment
  static String getCanisterId(String canisterName) {
    final config = EnvironmentConfig.isMainnet ? mainnet : local;
    final canisterId = config[canisterName];
    if (canisterId == null || canisterId.isEmpty) {
      throw Exception('Canister ID not configured for $canisterName in ${EnvironmentConfig.current} environment');
    }
    return canisterId;
  }
  
  /// Get base URL for canister calls
  static String get baseUrl {
    return EnvironmentConfig.isMainnet 
        ? 'https://ic0.app'
        : 'http://127.0.0.1:8000';
  }
}
