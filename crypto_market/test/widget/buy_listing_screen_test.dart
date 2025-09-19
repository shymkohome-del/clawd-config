import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_market/features/market/screens/buy_listing_screen.dart';
import 'package:crypto_market/features/market/providers/buy_flow_provider.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/models/price_conversion.dart';
import 'package:crypto_market/features/market/models/atomic_swap.dart';
import 'package:crypto_market/l10n/app_localizations.dart';

class MockBuyFlowProvider extends Mock implements BuyFlowProvider {
  @override
  bool get canProceed => true;

  @override
  bool get canGoBack => true;
}

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String get appTitle => 'Crypto Market';

  @override
  String get buyFlowTitle => 'Buy Listing';

  @override
  String get buyFlowStepPrice => 'Price';

  @override
  String get buyFlowStepConfirm => 'Confirm';

  @override
  String get buyFlowStepPayment => 'Payment';

  @override
  String get buyFlowStepCompletion => 'Complete';

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

  @override
  String get buyFlowConfirmTitle => 'Confirm Purchase';

  @override
  String get buyFlowConfirmDescription =>
      'Please review your purchase details before proceeding';

  @override
  String get buyFlowConfirmListing => 'Listing';

  @override
  String get buyFlowConfirmSeller => 'Seller';

  @override
  String get buyFlowConfirmTotal => 'Total Amount';

  @override
  String get buyFlowConfirmButton => 'Confirm Purchase';

  @override
  String get buyFlowPaymentTitle => 'Payment Setup';

  @override
  String get buyFlowPaymentDescription =>
      'Setting up secure atomic swap payment';

  @override
  String get buyFlowPaymentGenerating => 'Generating secure payment details...';

  @override
  String get buyFlowPaymentSwapId => 'Swap ID';

  @override
  String get buyFlowPaymentTimeout => 'Payment Timeout';

  @override
  String get buyFlowPaymentInstructions =>
      'Please send the exact amount to the address below within the timeout period';

  @override
  String get buyFlowCompleteTitle => 'Purchase Complete!';

  @override
  String get buyFlowCompleteSuccess =>
      'Your atomic swap has been initiated successfully!';

  @override
  String buyFlowCompleteSwapCreated(Object swapId) => 'Swap ID: $swapId';

  @override
  String get buyFlowCompleteNextSteps => 'Next Steps';

  @override
  String buyFlowCompleteStep1(Object seller) =>
      'Contact $seller to confirm payment details';

  @override
  String get buyFlowCompleteStep2 => 'Wait for seller confirmation';

  @override
  String get buyFlowCompleteStep3 =>
      'Complete the transaction when both parties confirm';

  @override
  String get buyFlowCompleteTrackTransaction => 'Track Transaction';

  @override
  String get buyFlowCompleteDone => 'Done';

  @override
  String get buyFlowErrorTitle => 'Purchase Error';

  @override
  String get buyFlowErrorMessage =>
      'An error occurred during the purchase process';

  @override
  String get buyFlowErrorRetry => 'Retry';

  @override
  String get buyFlowErrorCancel => 'Cancel Purchase';

  @override
  String get buyFlowLoading => 'Processing...';

  @override
  String get buyFlowNextButton => 'Next';

  @override
  String get buyFlowBackButton => 'Back';

  @override
  String get buyFlowCancelButton => 'Cancel';

  @override
  String get ok => 'OK';
}

void main() {
  late MockBuyFlowProvider mockBuyFlowProvider;

  setUp(() {
    mockBuyFlowProvider = MockBuyFlowProvider();
  });

  Widget createWidgetUnderTest({BuyFlowState? initialState}) {
    return MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<BuyFlowProvider>.value(
        value: mockBuyFlowProvider,
        child: BuyListingScreen(
          listing: Listing(
            id: '1',
            seller: 'seller-principal',
            title: 'Test Listing',
            description: 'Test Description',
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
          ),
        ),
      ),
    );
  }

  group('BuyListingScreen', () {
    testWidgets('displays loading indicator when initializing', (tester) async {
      // Arrange
      when(
        () => mockBuyFlowProvider.state,
      ).thenReturn(BuyFlowState(status: BuyFlowStatus.loading));
      whenListen(
        mockBuyFlowProvider,
        Stream.fromIterable([
          BuyFlowState(status: BuyFlowStatus.initial),
          BuyFlowState(status: BuyFlowStatus.loading),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays price step content', (tester) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      when(() => mockBuyFlowProvider.state).thenReturn(
        BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
          listing: Listing(
            id: '1',
            seller: 'seller-principal',
            title: 'Test Listing',
            description: 'Test Description',
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
          ),
          priceConversion: conversion,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
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
    });

    testWidgets('displays confirm step content', (tester) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      when(() => mockBuyFlowProvider.state).thenReturn(
        BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.confirm,
          listing: Listing(
            id: '1',
            seller: 'seller-principal',
            title: 'Test Listing',
            description: 'Test Description',
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
          ),
          priceConversion: conversion,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Confirm Purchase'), findsOneWidget);
      expect(
        find.text('Please review your purchase details before proceeding'),
        findsOneWidget,
      );
      expect(find.text('Listing'), findsOneWidget);
      expect(find.text('Seller'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
    });

    testWidgets('displays payment step content', (tester) async {
      // Arrange
      when(() => mockBuyFlowProvider.state).thenReturn(
        BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.payment,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Payment Setup'), findsOneWidget);
      expect(
        find.text('Setting up secure atomic swap payment'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(find.text('Confirm Purchase'), findsOneWidget);
    });

    testWidgets('displays completion step content', (tester) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      final atomicSwap = AtomicSwap(
        id: 123,
        listingId: 1,
        buyer: 'buyer-principal',
        seller: 'seller-principal',
        secretHash: [1, 2, 3, 4, 5],
        amount: BigInt.from(200000),
        cryptoType: 'BTC',
        timeout: BigInt.from(const Duration(hours: 24).inMilliseconds),
        status: AtomicSwapStatus.pending,
        createdAt: BigInt.from(DateTime.now().millisecondsSinceEpoch),
      );

      when(() => mockBuyFlowProvider.state).thenReturn(
        BuyFlowState(
          status: BuyFlowStatus.completed,
          currentStep: BuyFlowStep.completion,
          listing: Listing(
            id: '1',
            seller: 'seller-principal',
            title: 'Test Listing',
            description: 'Test Description',
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
          ),
          priceConversion: conversion,
          atomicSwap: atomicSwap,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Purchase Complete!'), findsOneWidget);
      expect(
        find.text('Your atomic swap has been initiated successfully!'),
        findsOneWidget,
      );
      expect(find.text('Swap ID: 123'), findsOneWidget);
      expect(find.text('Next Steps'), findsOneWidget);
    });

    testWidgets('displays error view when error occurs', (tester) async {
      // Arrange
      when(() => mockBuyFlowProvider.state).thenReturn(
        BuyFlowState(
          status: BuyFlowStatus.error,
          errorMessage: 'Test error message',
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Purchase Error'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Cancel Purchase'), findsOneWidget);
    });

    testWidgets('shows progress indicators correctly', (tester) async {
      // Arrange
      final conversion = PriceConversionResponse(
        cryptoAmount: 0.002,
        exchangeRate: 50000.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        cryptoType: 'BTC',
        stalenessThresholdMs: 300000,
      );

      when(() => mockBuyFlowProvider.state).thenReturn(
        BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
          listing: Listing(
            id: '1',
            seller: 'seller-principal',
            title: 'Test Listing',
            description: 'Test Description',
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
          ),
          priceConversion: conversion,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
    });

    testWidgets('calls nextStep when next button is tapped', (tester) async {
      // Arrange
      when(() => mockBuyFlowProvider.state).thenReturn(
        BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
        ),
      );
      when(() => mockBuyFlowProvider.canProceed).thenReturn(true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.text('Next'));

      // Assert
      verify(() => mockBuyFlowProvider.nextStep()).called(1);
    });

    testWidgets('calls previousStep when back button is tapped', (
      tester,
    ) async {
      // Arrange
      when(() => mockBuyFlowProvider.state).thenReturn(
        BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.confirm,
        ),
      );
      when(() => mockBuyFlowProvider.canGoBack).thenReturn(true);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.text('Back'));

      // Assert
      verify(() => mockBuyFlowProvider.previousStep()).called(1);
    });

    testWidgets(
      'calls confirmPurchase when confirm button is tapped on payment step',
      (tester) async {
        // Arrange
        when(() => mockBuyFlowProvider.state).thenReturn(
          BuyFlowState(
            status: BuyFlowStatus.ready,
            currentStep: BuyFlowStep.payment,
          ),
        );
        when(() => mockBuyFlowProvider.canProceed).thenReturn(true);

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();
        await tester.tap(find.text('Confirm Purchase'));

        // Assert
        verify(() => mockBuyFlowProvider.confirmPurchase()).called(1);
      },
    );

    testWidgets('calls reset when close button is tapped', (tester) async {
      // Arrange
      when(() => mockBuyFlowProvider.state).thenReturn(
        BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));

      // Assert
      verify(() => mockBuyFlowProvider.reset()).called(1);
    });
  });
}
