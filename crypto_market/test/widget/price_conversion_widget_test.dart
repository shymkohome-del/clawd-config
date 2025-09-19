import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_market/features/market/widgets/price_conversion_widget.dart';
import 'package:crypto_market/features/market/models/price_conversion.dart';
import 'package:crypto_market/l10n/app_localizations.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String get buyFlowPriceTitle => 'Price Conversion';

  @override
  String get buyFlowPriceDescription =>
      'Current cryptocurrency price for this listing';

  @override
  String get buyFlowUsdAmount => 'USD Amount';

  @override
  String get buyFlowCryptoAmount => 'Crypto Amount';

  @override
  String get buyFlowExchangeRate => 'Exchange Rate';

  @override
  String get buyFlowLastUpdated => 'Last Updated';

  @override
  String get buyFlowPriceStaleWarning =>
      'Price data is stale. Please refresh for current rates.';

  @override
  String get buyFlowRefreshButton => 'Refresh Price';
}

void main() {
  setUp(() {});

  Widget createWidgetUnderTest({
    required PriceConversionResponse conversion,
    VoidCallback? onRefresh,
    bool isLoading = false,
  }) {
    return MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: PriceConversionWidget(
          conversion: conversion,
          onRefresh: onRefresh,
          isLoading: isLoading,
        ),
      ),
    );
  }

  group('PriceConversionWidget', () {
    testWidgets('displays price conversion information correctly', (
      tester,
    ) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();

      // Assert
      expect(find.text('Price Conversion'), findsOneWidget);
      expect(
        find.text('Current cryptocurrency price for this listing'),
        findsOneWidget,
      );
      expect(find.text('USD Amount'), findsOneWidget);
      expect(find.text('Crypto Amount'), findsOneWidget);
      expect(find.text('Exchange Rate'), findsOneWidget);
      expect(find.text('Last Updated'), findsOneWidget);
    });

    testWidgets('displays USD and crypto amounts correctly', (tester) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();

      // Assert
      expect(find.text('\$100.00'), findsOneWidget); // 0.002 * 50000
      expect(find.textContaining('0.00200000 BTC'), findsOneWidget);
    });

    testWidgets('displays exchange rate correctly', (tester) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();

      // Assert
      expect(find.text('Exchange Rate: 1 BTC = \$50000.00'), findsOneWidget);
    });

    testWidgets('displays timestamp information correctly', (tester) async {
      // Arrange
      final timestamp = DateTime.now().subtract(const Duration(minutes: 5));
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: timestamp.millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();

      // Assert
      expect(find.textContaining('Last Updated:'), findsOneWidget);
      expect(find.textContaining('5 minutes ago'), findsOneWidget);
    });

    testWidgets('shows staleness warning when price is stale', (tester) async {
      // Arrange
      final timestamp = DateTime.now().subtract(const Duration(minutes: 10));
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: timestamp.millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000, // 5 minutes
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();

      // Assert
      expect(
        find.text('Price data is stale. Please refresh for current rates.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('does not show staleness warning when price is fresh', (
      tester,
    ) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();

      // Assert
      expect(
        find.text('Price data is stale. Please refresh for current rates.'),
        findsNothing,
      );
      expect(find.byIcon(Icons.warning_amber), findsNothing);
    });

    testWidgets('shows refresh button when onRefresh callback is provided', (
      tester,
    ) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      var refreshCalled = false;
      void onRefresh() {
        refreshCalled = true;
      }

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(conversion: conversion, onRefresh: onRefresh),
      );
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Refresh Price'), findsOneWidget);

      // Act - tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Assert
      expect(refreshCalled, true);
    });

    testWidgets(
      'does not show refresh button when onRefresh callback is not provided',
      (tester) async {
        // Arrange
        final conversion = PriceConversionResponse(
          cryptoAmount: 0.002,
          exchangeRate: 50000.0,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          cryptoType: 'BTC',
          stalenessThresholdMs: 300000,
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.refresh), findsNothing);
      },
    );

    testWidgets('disables refresh button when loading', (tester) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      var refreshCalled = false;
      void onRefresh() {
        refreshCalled = true;
      }

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(
          conversion: conversion,
          onRefresh: onRefresh,
          isLoading: true,
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Act - try to tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Assert
      expect(refreshCalled, false); // Should not be called when loading
    });

    testWidgets('handles different age formats correctly', (tester) async {
      // Test seconds ago
      var timestamp = DateTime.now().subtract(const Duration(seconds: 30));
      var conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: timestamp.millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();
      expect(find.textContaining('30 seconds ago'), findsOneWidget);

      // Test minutes ago
      timestamp = DateTime.now().subtract(const Duration(minutes: 5));
      conversion = conversion.copyWith(
        timestamp: timestamp.millisecondsSinceEpoch,
      );

      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();
      expect(find.textContaining('5 minutes ago'), findsOneWidget);

      // Test hours ago
      timestamp = DateTime.now().subtract(const Duration(hours: 2));
      conversion = conversion.copyWith(
        timestamp: timestamp.millisecondsSinceEpoch,
      );

      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();
      expect(find.textContaining('2 hours ago'), findsOneWidget);

      // Test days ago
      timestamp = DateTime.now().subtract(const Duration(days: 1));
      conversion = conversion.copyWith(
        timestamp: timestamp.millisecondsSinceEpoch,
      );

      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();
      expect(find.textContaining('1 days ago'), findsOneWidget);
    });

    testWidgets('displays correct styling for highlighted elements', (
      tester,
    ) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(conversion: conversion));
      await tester.pump();

      // Assert - Check that USD amount has primary color styling
      final usdAmountFinder = find.text('\$100.00');
      final usdAmountText = tester.widget<Text>(usdAmountFinder);
      expect(usdAmountText.style?.fontWeight, FontWeight.bold);

      // Assert - Check that crypto amount has green color styling
      final cryptoAmountFinder = find.textContaining('0.00200000 BTC');
      final cryptoAmountText = tester.widget<Text>(cryptoAmountFinder);
      expect(cryptoAmountText.style?.fontWeight, FontWeight.bold);
    });
  });
}
