import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_market/features/market/providers/buy_flow_provider.dart';
import 'package:crypto_market/core/blockchain/price_oracle_service.dart';
import 'package:crypto_market/core/blockchain/atomic_swap_service.dart';
import 'package:crypto_market/core/services/notification_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/models/price_conversion.dart';
import 'package:crypto_market/features/market/models/atomic_swap.dart';

class MockPriceOracleService extends Mock implements PriceOracleService {}

class MockAtomicSwapService extends Mock implements AtomicSwapService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockPriceOracleService mockPriceOracleService;
  late MockAtomicSwapService mockAtomicSwapService;
  late MockNotificationService mockNotificationService;
  late BuyFlowProvider buyFlowProvider;

  setUpAll(() {
    registerFallbackValue(BigInt.from(0));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockPriceOracleService = MockPriceOracleService();
    mockAtomicSwapService = MockAtomicSwapService();
    mockNotificationService = MockNotificationService();

    buyFlowProvider = BuyFlowProvider(
      priceOracleService: mockPriceOracleService,
      atomicSwapService: mockAtomicSwapService,
      notificationService: mockNotificationService,
    );
  });

  tearDown(() {
    buyFlowProvider.close();
  });

  group('BuyFlowProvider', () {
    final mockListing = Listing(
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
    );

    final mockConversion = PriceConversionResponse(
      cryptoAmount: 0.002,
      exchangeRate: 50000.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      cryptoType: 'BTC',
      stalenessThresholdMs: 300000, // 5 minutes
    );

    final mockAtomicSwap = AtomicSwap(
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

    group('initializeBuyFlow', () {
      test('initial state is correct', () {
        // Assert
        expect(buyFlowProvider.state.status, BuyFlowStatus.initial);
        expect(buyFlowProvider.state.currentStep, BuyFlowStep.price);
        expect(buyFlowProvider.state.listing, isNull);
        expect(buyFlowProvider.state.priceConversion, isNull);
      });

      blocTest<BuyFlowProvider, BuyFlowState>(
        'emits loading and ready states when initialization succeeds',
        setUp: () {
          when(
            () => mockPriceOracleService.getConversionAmount(100, 'BTC'),
          ).thenAnswer((_) async => Result.ok(mockConversion));
        },
        build: () => buyFlowProvider,
        act: (provider) => provider.initializeBuyFlow(mockListing),
        expect: () => [
          BuyFlowState(
            status: BuyFlowStatus.loading,
            currentStep: BuyFlowStep.price,
            listing: mockListing,
          ),
          BuyFlowState(
            status: BuyFlowStatus.ready,
            currentStep: BuyFlowStep.price,
            listing: mockListing,
            priceConversion: mockConversion,
          ),
        ],
      );

      blocTest<BuyFlowProvider, BuyFlowState>(
        'emits error state when price oracle fails',
        setUp: () {
          when(
            () => mockPriceOracleService.getConversionAmount(100, 'BTC'),
          ).thenAnswer(
            (_) async => Result.err(PriceConversionError.oracleUnavailable),
          );
        },
        build: () => buyFlowProvider,
        act: (provider) => provider.initializeBuyFlow(mockListing),
        expect: () => [
          BuyFlowState(
            status: BuyFlowStatus.loading,
            currentStep: BuyFlowStep.price,
            listing: mockListing,
          ),
          BuyFlowState(
            status: BuyFlowStatus.error,
            currentStep: BuyFlowStep.price,
            listing: mockListing,
            errorMessage: 'Price oracle is currently unavailable',
          ),
        ],
      );
    });

    group('nextStep', () {
      blocTest<BuyFlowProvider, BuyFlowState>(
        'moves from price to confirm step',
        setUp: () {
          when(
            () => mockPriceOracleService.getConversionAmount(100, 'BTC'),
          ).thenAnswer((_) async => Result.ok(mockConversion));
        },
        build: () => buyFlowProvider,
        seed: () => BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
          listing: mockListing,
          priceConversion: mockConversion,
        ),
        act: (provider) => provider.nextStep(),
        expect: () => [
          BuyFlowState(
            status: BuyFlowStatus.ready,
            currentStep: BuyFlowStep.confirm,
            listing: mockListing,
            priceConversion: mockConversion,
          ),
        ],
      );

      blocTest<BuyFlowProvider, BuyFlowState>(
        'moves from confirm to payment step',
        setUp: () {
          when(
            () => mockPriceOracleService.getConversionAmount(100, 'BTC'),
          ).thenAnswer((_) async => Result.ok(mockConversion));
        },
        build: () => buyFlowProvider,
        seed: () => BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.confirm,
          listing: mockListing,
          priceConversion: mockConversion,
        ),
        act: (provider) => provider.nextStep(),
        expect: () => [
          BuyFlowState(
            status: BuyFlowStatus.ready,
            currentStep: BuyFlowStep.payment,
            listing: mockListing,
            priceConversion: mockConversion,
          ),
        ],
      );

      blocTest<BuyFlowProvider, BuyFlowState>(
        'does not move when already at completion step',
        setUp: () {
          when(
            () => mockPriceOracleService.getConversionAmount(100, 'BTC'),
          ).thenAnswer((_) async => Result.ok(mockConversion));
        },
        build: () => buyFlowProvider,
        seed: () => BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.completion,
          listing: mockListing,
          priceConversion: mockConversion,
        ),
        act: (provider) => provider.nextStep(),
        expect: () => [],
      );
    });

    group('previousStep', () {
      blocTest<BuyFlowProvider, BuyFlowState>(
        'moves from confirm to price step',
        setUp: () {
          when(
            () => mockPriceOracleService.getConversionAmount(100, 'BTC'),
          ).thenAnswer((_) async => Result.ok(mockConversion));
        },
        build: () => buyFlowProvider,
        seed: () => BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.confirm,
          listing: mockListing,
          priceConversion: mockConversion,
        ),
        act: (provider) => provider.previousStep(),
        expect: () => [
          BuyFlowState(
            status: BuyFlowStatus.ready,
            currentStep: BuyFlowStep.price,
            listing: mockListing,
            priceConversion: mockConversion,
          ),
        ],
      );

      blocTest<BuyFlowProvider, BuyFlowState>(
        'does not move when already at price step',
        setUp: () {
          when(
            () => mockPriceOracleService.getConversionAmount(100, 'BTC'),
          ).thenAnswer((_) async => Result.ok(mockConversion));
        },
        build: () => buyFlowProvider,
        seed: () => BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
          listing: mockListing,
          priceConversion: mockConversion,
        ),
        act: (provider) => provider.previousStep(),
        expect: () => [],
      );
    });

    group('refreshPriceConversion', () {
      blocTest<BuyFlowProvider, BuyFlowState>(
        'refreshes price conversion successfully',
        setUp: () {
          when(
            () => mockPriceOracleService.getConversionAmount(100, 'BTC'),
          ).thenAnswer((_) async => Result.ok(mockConversion));
        },
        build: () => buyFlowProvider,
        seed: () => BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
          listing: mockListing,
          priceConversion: mockConversion,
        ),
        act: (provider) => provider.refreshPriceConversion(),
        expect: () => [
          BuyFlowState(
            status: BuyFlowStatus.loading,
            currentStep: BuyFlowStep.price,
            listing: mockListing,
            priceConversion: mockConversion,
          ),
          BuyFlowState(
            status: BuyFlowStatus.ready,
            currentStep: BuyFlowStep.price,
            listing: mockListing,
            priceConversion: mockConversion,
          ),
        ],
      );
    });

    group('confirmPurchase', () {
      setUp(() {
        when(
          () => mockPriceOracleService.getConversionAmount(100, 'BTC'),
        ).thenAnswer((_) async => Result.ok(mockConversion));
        when(() => mockAtomicSwapService.generateSecureSecret()).thenAnswer(
          (_) async => Result.ok(Uint8List.fromList([1, 2, 3, 4, 5])),
        );
        when(
          () => mockAtomicSwapService.initiateSwap(
            listingId: any(named: 'listingId'),
            secretHash: any(named: 'secretHash'),
            amount: any(named: 'amount'),
            cryptoType: any(named: 'cryptoType'),
            timeout: any(named: 'timeout'),
          ),
        ).thenAnswer((_) async => Result.ok(mockAtomicSwap));
        when(
          () => mockAtomicSwapService.storeSwapSecret(
            swapId: any(named: 'swapId'),
            secret: any(named: 'secret'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockNotificationService.sendSwapCreatedNotification(
            swapId: any(named: 'swapId'),
            sellerId: any(named: 'sellerId'),
            listingTitle: any(named: 'listingTitle'),
            amount: any(named: 'amount'),
            cryptoType: any(named: 'cryptoType'),
          ),
        ).thenAnswer((_) async {});
      });

      blocTest<BuyFlowProvider, BuyFlowState>(
        'completes purchase successfully',
        build: () => buyFlowProvider,
        seed: () => BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.payment,
          listing: mockListing,
          priceConversion: mockConversion,
        ),
        act: (provider) => provider.confirmPurchase(),
        expect: () => [
          BuyFlowState(
            status: BuyFlowStatus.loading,
            currentStep: BuyFlowStep.payment,
            listing: mockListing,
            priceConversion: mockConversion,
          ),
          BuyFlowState(
            status: BuyFlowStatus.completed,
            currentStep: BuyFlowStep.completion,
            listing: mockListing,
            priceConversion: mockConversion,
            atomicSwap: mockAtomicSwap,
            secret: Uint8List.fromList([1, 2, 3, 4, 5]),
          ),
        ],
      );

      blocTest<BuyFlowProvider, BuyFlowState>(
        'handles secret generation failure',
        setUp: () {
          when(
            () => mockAtomicSwapService.generateSecureSecret(),
          ).thenAnswer((_) async => Result.err(SwapError.invalidSecret));
        },
        build: () => buyFlowProvider,
        seed: () => BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.payment,
          listing: mockListing,
          priceConversion: mockConversion,
        ),
        act: (provider) => provider.confirmPurchase(),
        expect: () => [
          BuyFlowState(
            status: BuyFlowStatus.loading,
            currentStep: BuyFlowStep.payment,
            listing: mockListing,
            priceConversion: mockConversion,
          ),
          BuyFlowState(
            status: BuyFlowStatus.error,
            currentStep: BuyFlowStep.payment,
            listing: mockListing,
            priceConversion: mockConversion,
            errorMessage: 'Failed to generate secure secret',
          ),
        ],
      );
    });

    group('reset', () {
      blocTest<BuyFlowProvider, BuyFlowState>(
        'resets to initial state',
        build: () => buyFlowProvider,
        seed: () => BuyFlowState(
          status: BuyFlowStatus.completed,
          currentStep: BuyFlowStep.completion,
          listing: mockListing,
          priceConversion: mockConversion,
          atomicSwap: mockAtomicSwap,
        ),
        act: (provider) => provider.reset(),
        expect: () => [const BuyFlowState()],
      );
    });

    group('state properties', () {
      test('canProceed returns correct values', () {
        // Price step with valid conversion
        var state = BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
          priceConversion: mockConversion,
        );
        expect(state.canProceed, true);

        // Price step with stale conversion
        state = BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
          priceConversion: mockConversion.copyWith(
            timestamp:
                DateTime.now().millisecondsSinceEpoch -
                600000, // 10 minutes ago
          ),
        );
        expect(state.canProceed, false);

        // Confirm step
        state = BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.confirm,
          priceConversion: mockConversion,
        );
        expect(state.canProceed, true);
      });

      test('canGoBack returns correct values', () {
        // Price step
        var state = BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.price,
        );
        expect(state.canGoBack, false);

        // Confirm step
        state = BuyFlowState(
          status: BuyFlowStatus.ready,
          currentStep: BuyFlowStep.confirm,
        );
        expect(state.canGoBack, true);
      });

      test('progress returns correct values', () {
        expect(BuyFlowState(currentStep: BuyFlowStep.price).progress, 0.25);
        expect(BuyFlowState(currentStep: BuyFlowStep.confirm).progress, 0.5);
        expect(BuyFlowState(currentStep: BuyFlowStep.payment).progress, 0.75);
        expect(BuyFlowState(currentStep: BuyFlowStep.completion).progress, 1.0);
      });
    });
  });
}
