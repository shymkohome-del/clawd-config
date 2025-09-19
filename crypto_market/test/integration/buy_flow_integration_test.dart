import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/features/market/screens/buy_listing_screen.dart';
import 'package:crypto_market/features/market/providers/buy_flow_provider.dart';
import 'package:crypto_market/core/blockchain/price_oracle_service.dart';
import 'package:crypto_market/core/blockchain/atomic_swap_service.dart';
import 'package:crypto_market/core/services/notification_service.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/models/atomic_swap.dart';
import 'package:crypto_market/l10n/app_localizations.dart';

void main() {
  group('Buy Flow Integration Tests', () {
    late BuyFlowProvider buyFlowProvider;
    late PriceOracleService priceOracleService;
    late AtomicSwapService atomicSwapService;
    late NotificationService notificationService;

    setUp(() {
      priceOracleService = PriceOracleService();
      atomicSwapService = AtomicSwapService();
      notificationService = NotificationService();

      buyFlowProvider = BuyFlowProvider(
        priceOracleService: priceOracleService,
        atomicSwapService: atomicSwapService,
        notificationService: notificationService,
      );
    });

    tearDown(() {
      buyFlowProvider.close();
      atomicSwapService.clearStoredSecrets();
    });

    Widget createBuyListingScreen({required Listing listing}) {
      return MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: const [Locale('en')],
        home: BlocProvider<BuyFlowProvider>.value(
          value: buyFlowProvider,
          child: BuyListingScreen(listing: listing),
        ),
      );
    }

    testWidgets('complete buy flow from start to finish', (tester) async {
      // Arrange
      final listing = Listing(
        id: '1',
        seller: 'seller-principal',
        title: 'Test Crypto Item',
        description: 'A great crypto item for sale',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: [],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'Test Location',
        shippingOptions: ['shipping'],
        status: ListingStatus.active,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Act - Initialize the buy flow
      await tester.pumpWidget(createBuyListingScreen(listing: listing));
      await tester.pumpAndSettle();

      // Assert - Should be on price step with loading state
      expect(find.text('Buy Listing'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(buyFlowProvider.state.status, BuyFlowStatus.loading);

      // Wait for price conversion to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Should be on price step with conversion data
      expect(buyFlowProvider.state.status, BuyFlowStatus.ready);
      expect(buyFlowProvider.state.currentStep, BuyFlowStep.price);
      expect(buyFlowProvider.state.priceConversion, isNotNull);
      expect(
        buyFlowProvider.state.priceConversion!.cryptoAmount,
        greaterThan(0),
      );
      expect(find.text('Price Conversion'), findsOneWidget);

      // Act - Navigate to confirm step
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert - Should be on confirm step
      expect(buyFlowProvider.state.currentStep, BuyFlowStep.confirm);
      expect(find.text('Confirm Purchase'), findsOneWidget);
      expect(find.text('Test Crypto Item'), findsOneWidget);
      expect(find.text('seller-principal'), findsOneWidget);

      // Act - Navigate to payment step
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert - Should be on payment step
      expect(buyFlowProvider.state.currentStep, BuyFlowStep.payment);
      expect(find.text('Payment Setup'), findsOneWidget);
      expect(
        find.text('Setting up secure atomic swap payment'),
        findsOneWidget,
      );

      // Act - Confirm purchase
      await tester.tap(find.text('Confirm Purchase'));
      await tester.pump(); // Start loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating secure payment details...'), findsOneWidget);

      // Wait for purchase to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Should be on completion step
      expect(buyFlowProvider.state.status, BuyFlowStatus.completed);
      expect(buyFlowProvider.state.currentStep, BuyFlowStep.completion);
      expect(buyFlowProvider.state.atomicSwap, isNotNull);
      expect(buyFlowProvider.state.secret, isNotNull);
      expect(find.text('Purchase Complete!'), findsOneWidget);
      expect(find.textContaining('Swap ID:'), findsOneWidget);
      expect(find.text('Next Steps'), findsOneWidget);

      // Verify atomic swap was created
      final atomicSwap = buyFlowProvider.state.atomicSwap!;
      expect(atomicSwap.listingId, 1);
      expect(atomicSwap.status, AtomicSwapStatus.pending);
      expect(atomicSwap.buyer, isNotNull);
      expect(atomicSwap.seller, 'seller-principal');
      expect(atomicSwap.cryptoType, 'BTC');

      // Verify secret was stored
      final secretResult = await atomicSwapService.getSwapSecret(atomicSwap.id);
      expect(secretResult.isOk, true);
      expect(secretResult.ok, buyFlowProvider.state.secret);
    });

    testWidgets('handles price oracle errors gracefully', (tester) async {
      // Arrange - Create listing with invalid crypto type to trigger error
      final listing = Listing(
        id: '1',
        seller: 'seller-principal',
        title: 'Test Crypto Item',
        description: 'A great crypto item for sale',
        priceUSD: 100,
        cryptoType: 'INVALID_CRYPTO', // This should cause an error
        images: [],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'Test Location',
        shippingOptions: ['shipping'],
        status: ListingStatus.active,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Act - Initialize the buy flow
      await tester.pumpWidget(createBuyListingScreen(listing: listing));
      await tester.pumpAndSettle();

      // Wait for initialization to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Should show error state
      expect(buyFlowProvider.state.status, BuyFlowStatus.error);
      expect(buyFlowProvider.state.errorMessage, isNotNull);
      expect(find.text('Purchase Error'), findsOneWidget);
      expect(
        find.textContaining('Invalid cryptocurrency type'),
        findsOneWidget,
      );

      // Act - Retry from error state
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Should still be in error state (since crypto type is still invalid)
      expect(buyFlowProvider.state.status, BuyFlowStatus.error);
    });

    testWidgets('handles staleness warning and refresh', (tester) async {
      // Arrange
      final listing = Listing(
        id: '1',
        seller: 'seller-principal',
        title: 'Test Crypto Item',
        description: 'A great crypto item for sale',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: [],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'Test Location',
        shippingOptions: ['shipping'],
        status: ListingStatus.active,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Act - Initialize the buy flow
      await tester.pumpWidget(createBuyListingScreen(listing: listing));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Should have fresh price data initially
      expect(buyFlowProvider.state.priceConversion!.isStale, false);
      expect(find.text('Price data is stale'), findsNothing);

      // Manually make the price stale by setting old timestamp
      final staleConversion = buyFlowProvider.state.priceConversion!.copyWith(
        timestamp:
            DateTime.now().millisecondsSinceEpoch - 600000, // 10 minutes ago
      );

      // Update the provider state to simulate staleness
      buyFlowProvider.updateState(
        buyFlowProvider.state.copyWith(priceConversion: staleConversion),
      );
      await tester.pump();

      // Assert - Should show staleness warning
      expect(
        find.text('Price data is stale. Please refresh for current rates.'),
        findsOneWidget,
      );

      // Act - Refresh the price
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Should have fresh price data again
      expect(buyFlowProvider.state.priceConversion!.isStale, false);
      expect(find.text('Price data is stale'), findsNothing);
    });

    testWidgets('handles navigation between steps correctly', (tester) async {
      // Arrange
      final listing = Listing(
        id: '1',
        seller: 'seller-principal',
        title: 'Test Crypto Item',
        description: 'A great crypto item for sale',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: [],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'Test Location',
        shippingOptions: ['shipping'],
        status: ListingStatus.active,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Act - Initialize the buy flow
      await tester.pumpWidget(createBuyListingScreen(listing: listing));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Start at price step
      expect(buyFlowProvider.state.currentStep, BuyFlowStep.price);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsNothing); // No back button on first step

      // Act - Go to confirm step
      await tester.tap(find.text('Next'));
      await tester.pump();

      // Assert - On confirm step
      expect(buyFlowProvider.state.currentStep, BuyFlowStep.confirm);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Act - Go back to price step
      await tester.tap(find.text('Back'));
      await tester.pump();

      // Assert - Back to price step
      expect(buyFlowProvider.state.currentStep, BuyFlowStep.price);
      expect(find.text('Back'), findsNothing);

      // Act - Go through all steps again
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pump();

      // Assert - On payment step
      expect(buyFlowProvider.state.currentStep, BuyFlowStep.payment);
      expect(
        find.text('Confirm Purchase'),
        findsOneWidget,
      ); // Different button text
      expect(find.text('Back'), findsOneWidget);

      // Act - Go back to confirm step
      await tester.tap(find.text('Back'));
      await tester.pump();

      // Assert - Back to confirm step
      expect(buyFlowProvider.state.currentStep, BuyFlowStep.confirm);
    });

    testWidgets('persists state through navigation', (tester) async {
      // Arrange
      final listing = Listing(
        id: '1',
        seller: 'seller-principal',
        title: 'Test Crypto Item',
        description: 'A great crypto item for sale',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: [],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'Test Location',
        shippingOptions: ['shipping'],
        status: ListingStatus.active,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Act - Initialize the buy flow and navigate to confirm step
      await tester.pumpWidget(createBuyListingScreen(listing: listing));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify initial state
      final initialConversion = buyFlowProvider.state.priceConversion;
      expect(initialConversion, isNotNull);

      // Navigate to confirm step
      await tester.tap(find.text('Next'));
      await tester.pump();

      // Verify state is preserved
      expect(buyFlowProvider.state.priceConversion, same(initialConversion));
      expect(buyFlowProvider.state.listing, same(listing));

      // Navigate back to price step
      await tester.tap(find.text('Back'));
      await tester.pump();

      // Verify state is still preserved
      expect(buyFlowProvider.state.priceConversion, same(initialConversion));
      expect(buyFlowProvider.state.listing, same(listing));
    });

    testWidgets('handles cancellation correctly', (tester) async {
      // Arrange
      final listing = Listing(
        id: '1',
        seller: 'seller-principal',
        title: 'Test Crypto Item',
        description: 'A great crypto item for sale',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: [],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'Test Location',
        shippingOptions: ['shipping'],
        status: ListingStatus.active,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Act - Initialize the buy flow
      await tester.pumpWidget(createBuyListingScreen(listing: listing));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify state has data
      expect(buyFlowProvider.state.listing, isNotNull);
      expect(buyFlowProvider.state.priceConversion, isNotNull);

      // Act - Cancel by tapping close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Verify state is reset
      expect(buyFlowProvider.state.status, BuyFlowStatus.initial);
      expect(buyFlowProvider.state.listing, isNull);
      expect(buyFlowProvider.state.priceConversion, isNull);
    });
  });
}
