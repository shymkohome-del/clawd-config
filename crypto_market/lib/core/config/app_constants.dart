class AppConstants {
  static const String appName = 'Crypto Market';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.cryptomarket.com';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Blockchain Configuration
  static const List<String> supportedChains = [
    'ethereum',
    'binance-smart-chain',
    'polygon',
    'avalanche',
    'internet-computer',
    'tezos',
  ];
  
  static const Map<String, String> chainNames = {
    'ethereum': 'Ethereum',
    'binance-smart-chain': 'BSC',
    'polygon': 'Polygon',
    'avalanche': 'Avalanche',
    'internet-computer': 'Internet Computer',
    'tezos': 'Tezos',
  };
  
  // Supported Cryptocurrencies
  static const List<String> supportedCryptos = [
    'ETH',
    'BTC',
    'BNB',
    'MATIC',
    'AVAX',
    'ICP',
    'XTZ',
    'USDT',
    'USDC',
    'DAI',
  ];
}