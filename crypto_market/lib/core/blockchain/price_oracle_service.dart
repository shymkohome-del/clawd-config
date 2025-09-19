import 'dart:async';
import 'dart:math';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/market/models/price_conversion.dart';

/// Service for handling USD to cryptocurrency price conversions
class PriceOracleService {
  final Duration _stalenessThreshold = const Duration(minutes: 5);
  final Map<String, double> _exchangeRates = {};
  final Map<String, int> _lastUpdated = {};

  /// Get conversion amount for USD to cryptocurrency
  Future<Result<PriceConversionResponse, PriceConversionError>>
  getConversionAmount(double priceUSD, String cryptoType) async {
    try {
      Logger.instance.logDebug(
        'Getting conversion for $priceUSD USD to $cryptoType',
        tag: 'PriceOracleService',
      );

      // Validate crypto type
      if (!_isValidCryptoType(cryptoType)) {
        Logger.instance.logWarn(
          'Invalid crypto type: $cryptoType',
          tag: 'PriceOracleService',
        );
        return Result.err(PriceConversionError.invalidCryptoType);
      }

      // Check if we need to refresh rates
      final needsRefresh = _needsRateRefresh(cryptoType);
      if (needsRefresh) {
        await _refreshExchangeRate(cryptoType);
      }

      // Get the exchange rate
      final exchangeRate = _exchangeRates[cryptoType];
      if (exchangeRate == null || exchangeRate <= 0) {
        Logger.instance.logWarn(
          'No valid exchange rate for $cryptoType',
          tag: 'PriceOracleService',
        );
        return Result.err(PriceConversionError.conversionFailed);
      }

      // Calculate crypto amount
      final cryptoAmount = priceUSD / exchangeRate;
      final timestamp =
          _lastUpdated[cryptoType] ?? DateTime.now().millisecondsSinceEpoch;

      Logger.instance.logDebug(
        'Conversion result: $cryptoAmount $cryptoType (rate: $exchangeRate)',
        tag: 'PriceOracleService',
      );

      final response = PriceConversionResponse(
        cryptoAmount: cryptoAmount,
        exchangeRate: exchangeRate,
        timestamp: timestamp,
        cryptoType: cryptoType,
        stalenessThresholdMs: _stalenessThreshold.inMilliseconds,
      );

      return Result.ok(response);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to get conversion amount',
        tag: 'PriceOracleService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(PriceConversionError.networkError);
    }
  }

  /// Check if exchange rate needs refreshing
  bool _needsRateRefresh(String cryptoType) {
    final lastUpdated = _lastUpdated[cryptoType];
    if (lastUpdated == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastUpdated) > _stalenessThreshold.inMilliseconds;
  }

  /// Refresh exchange rate for a cryptocurrency
  Future<void> _refreshExchangeRate(String cryptoType) async {
    try {
      Logger.instance.logDebug(
        'Refreshing exchange rate for $cryptoType',
        tag: 'PriceOracleService',
      );

      // Simulate API call to price oracle
      // In real implementation, this would call the ICP price oracle canister
      final newRate = await _fetchExchangeRateFromOracle(cryptoType);

      if (newRate > 0) {
        _exchangeRates[cryptoType] = newRate;
        _lastUpdated[cryptoType] = DateTime.now().millisecondsSinceEpoch;

        Logger.instance.logDebug(
          'Updated exchange rate for $cryptoType: $newRate',
          tag: 'PriceOracleService',
        );
      } else {
        Logger.instance.logWarn(
          'Received invalid exchange rate for $cryptoType: $newRate',
          tag: 'PriceOracleService',
        );
      }
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to refresh exchange rate for $cryptoType',
        tag: 'PriceOracleService',
        error: error,
        stackTrace: stackTrace,
      );

      // Re-throw to let the caller handle the error
      rethrow;
    }
  }

  /// Simulate fetching exchange rate from oracle
  Future<double> _fetchExchangeRateFromOracle(String cryptoType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock exchange rates for different cryptocurrencies
    // In real implementation, this would call the ICP price oracle canister
    final mockRates = {
      'BTC': 45000.0,
      'ETH': 2500.0,
      'ICP': 8.5,
      'USDT': 1.0,
      'USDC': 1.0,
      'SOL': 120.0,
      'MATIC': 0.85,
      'DOT': 7.5,
    };

    // Add some random variation to simulate real-time prices
    final baseRate = mockRates[cryptoType.toUpperCase()];
    if (baseRate == null) {
      throw Exception('Unsupported cryptocurrency: $cryptoType');
    }

    // Add ±2% random variation
    final variation = 1.0 + (Random().nextDouble() - 0.5) * 0.04;
    return baseRate * variation;
  }

  /// Validate cryptocurrency type
  bool _isValidCryptoType(String cryptoType) {
    final supportedTypes = [
      'BTC',
      'ETH',
      'ICP',
      'USDT',
      'USDC',
      'SOL',
      'MATIC',
      'DOT',
      'btc',
      'eth',
      'icp',
      'usdt',
      'usdc',
      'sol',
      'matic',
      'dot',
    ];
    return supportedTypes.contains(cryptoType);
  }

  /// Get current exchange rate for a cryptocurrency
  Result<double, PriceConversionError> getCurrentExchangeRate(
    String cryptoType,
  ) {
    if (!_isValidCryptoType(cryptoType)) {
      return Result.err(PriceConversionError.invalidCryptoType);
    }

    final rate = _exchangeRates[cryptoType.toUpperCase()];
    if (rate == null) {
      return Result.err(PriceConversionError.oracleUnavailable);
    }

    return Result.ok(rate);
  }

  /// Check if price data is stale for a cryptocurrency
  bool isPriceStale(String cryptoType) {
    final lastUpdated = _lastUpdated[cryptoType];
    if (lastUpdated == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastUpdated) > _stalenessThreshold.inMilliseconds;
  }

  /// Force refresh all exchange rates
  Future<void> refreshAllRates() async {
    Logger.instance.logDebug(
      'Refreshing all exchange rates',
      tag: 'PriceOracleService',
    );

    final cryptoTypes = [
      'BTC',
      'ETH',
      'ICP',
      'USDT',
      'USDC',
      'SOL',
      'MATIC',
      'DOT',
    ];

    for (final cryptoType in cryptoTypes) {
      try {
        await _refreshExchangeRate(cryptoType);
      } catch (error) {
        Logger.instance.logWarn(
          'Failed to refresh rate for $cryptoType',
          tag: 'PriceOracleService',
          error: error,
        );
      }
    }
  }

  /// Clear cached exchange rates
  void clearCache() {
    Logger.instance.logDebug(
      'Clearing price oracle cache',
      tag: 'PriceOracleService',
    );

    _exchangeRates.clear();
    _lastUpdated.clear();
  }

  /// Get staleness threshold
  Duration get stalenessThreshold => _stalenessThreshold;
}
