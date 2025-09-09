// Development configuration with sensible defaults for local testing

import 'app_config.dart';

/// Development configuration with defaults suitable for local testing.
/// This bypasses the need for environment variables during development.
class DevelopmentConfig {
  static AppConfig load() {
    return AppConfig.tryLoad(defines: {
      // OAuth (development values - not functional but prevent config errors)
      'OAUTH_GOOGLE_CLIENT_ID': 'dev-google-client-id',
      'OAUTH_GOOGLE_CLIENT_SECRET': 'dev-google-client-secret',
      'OAUTH_APPLE_TEAM_ID': 'dev-apple-team-id', 
      'OAUTH_APPLE_KEY_ID': 'dev-apple-key-id',
      
      // IPFS (development values)
      'IPFS_NODE_URL': 'http://localhost:5001',
      'IPFS_GATEWAY_URL': 'http://localhost:8080',
      
      // Canisters (will be overridden by CanisterConfig but needed for legacy compatibility)
      'CANISTER_ID_MARKETPLACE': 'u6s2n-gx777-77774-qaaba-cai',
      'CANISTER_ID_USER_MANAGEMENT': 'umunu-kh777-77774-qaaca-cai', 
      'CANISTER_ID_ATOMIC_SWAP': 'uxrrr-q7777-77774-qaaaq-cai',
      'CANISTER_ID_PRICE_ORACLE': 'uzt4z-lp777-77774-qaabq-cai',
      
      // Optional (empty is fine)
      'CHAINLINK_API_KEY': '',
      'COINGECKO_API_KEY': '',
      'KYC_PROVIDER_API_KEY': '',
      
      // Feature flags
      'FEATURE_PRINCIPAL_SHIM': 'false',
    });
  }
}
