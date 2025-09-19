import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/blockchain/price_oracle_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/market/models/price_conversion.dart';

void main() {
  late PriceOracleService priceOracleService;

  setUp(() {
    priceOracleService = PriceOracleService();
  });

  group('PriceOracleService', () {
    group('getConversionAmount', () {
      test('should return valid conversion for supported crypto', () async {
        // Act
        final result = await priceOracleService.getConversionAmount(
          100.0,
          'BTC',
        );

        // Assert
        expect(result.isOk, true);
        final conversion = result.ok;
        expect(conversion.cryptoAmount, greaterThan(0));
        expect(conversion.exchangeRate, greaterThan(0));
        expect(conversion.cryptoType, 'BTC');
        expect(conversion.isStale, false);
      });

      test('should handle case-insensitive crypto types', () async {
        // Act
        final result = await priceOracleService.getConversionAmount(
          100.0,
          'btc',
        );

        // Assert
        expect(result.isOk, true);
        final conversion = result.ok;
        expect(conversion.cryptoType, 'btc');
      });

      test('should return error for unsupported crypto type', () async {
        // Act
        final result = await priceOracleService.getConversionAmount(
          100.0,
          'INVALID',
        );

        // Assert
        expect(result.isErr, true);
        expect(result.err, PriceConversionError.invalidCryptoType);
      });

      test('should calculate correct crypto amount', () async {
        // Act
        final result = await priceOracleService.getConversionAmount(
          100.0,
          'BTC',
        );

        // Assert
        expect(result.isOk, true);
        final conversion = result.ok;
        // Since we have mock rates, BTC should be around 45000
        // So 100 USD should be around 0.0022 BTC
        expect(conversion.cryptoAmount, closeTo(0.002, 0.003));
        expect(conversion.exchangeRate, closeTo(45000, 5000));
      });

      test('should handle different crypto types correctly', () async {
        // Act
        final btcResult = await priceOracleService.getConversionAmount(
          100.0,
          'BTC',
        );
        final ethResult = await priceOracleService.getConversionAmount(
          100.0,
          'ETH',
        );

        // Assert
        expect(btcResult.isOk, true);
        expect(ethResult.isOk, true);

        final btcConversion = btcResult.ok;
        final ethConversion = ethResult.ok;

        // ETH should be worth more than BTC for the same USD amount
        expect(
          ethConversion.cryptoAmount,
          greaterThan(btcConversion.cryptoAmount),
        );
      });
    });

    group('getCurrentExchangeRate', () {
      test('should return current rate for supported crypto', () async {
        // First get a conversion to populate the cache
        await priceOracleService.getConversionAmount(100.0, 'BTC');

        // Act
        final result = priceOracleService.getCurrentExchangeRate('BTC');

        // Assert
        expect(result.isOk, true);
        expect(result.ok, greaterThan(0));
      });

      test('should return error for unsupported crypto type', () {
        // Act
        final result = priceOracleService.getCurrentExchangeRate('INVALID');

        // Assert
        expect(result.isErr, true);
        expect(result.err, PriceConversionError.invalidCryptoType);
      });

      test('should return error when rate not available', () {
        // Act
        final result = priceOracleService.getCurrentExchangeRate(
          'NEVER_FETCHED',
        );

        // Assert
        expect(result.isErr, true);
        expect(result.err, PriceConversionError.invalidCryptoType);
      });
    });

    group('isPriceStale', () {
      test('should return true for unsupported crypto', () {
        // Act
        final isStale = priceOracleService.isPriceStale('INVALID_CRYPTO');

        // Assert
        expect(isStale, true);
      });

      test('should return false for fresh price', () async {
        // First get a conversion to populate the cache
        await priceOracleService.getConversionAmount(100.0, 'BTC');

        // Act
        final isStale = priceOracleService.isPriceStale('BTC');

        // Assert
        expect(isStale, false);
      });
    });

    group('refreshAllRates', () {
      test('should refresh all supported crypto rates', () async {
        // Act
        await priceOracleService.refreshAllRates();

        // Assert
        final btcResult = priceOracleService.getCurrentExchangeRate('BTC');
        final ethResult = priceOracleService.getCurrentExchangeRate('ETH');
        final icpResult = priceOracleService.getCurrentExchangeRate('ICP');

        expect(btcResult.isOk, true);
        expect(ethResult.isOk, true);
        expect(icpResult.isOk, true);
      });
    });

    group('clearCache', () {
      test('should clear all cached rates', () async {
        // First populate the cache
        await priceOracleService.getConversionAmount(100.0, 'BTC');
        expect(priceOracleService.getCurrentExchangeRate('BTC').isOk, true);

        // Act
        priceOracleService.clearCache();

        // Assert
        final result = priceOracleService.getCurrentExchangeRate('BTC');
        expect(result.isErr, true);
        expect(result.err, PriceConversionError.oracleUnavailable);
      });
    });

    group('stalenessThreshold', () {
      test('should have reasonable staleness threshold', () {
        // Act
        final threshold = priceOracleService.stalenessThreshold;

        // Assert
        expect(threshold.inMinutes, 5);
      });
    });
  });
}
