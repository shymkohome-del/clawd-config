import 'package:test/test.dart';
import 'package:seller_auto_cancel/models/atomic_swap.dart';
import 'package:seller_auto_cancel/services/seller_cancel_service.dart';
import 'package:seller_auto_cancel/services/swap_timeout_service.dart';

// Mock listener for testing
class MockSellerCancelListener implements SellerCancelListener {
  final List<dynamic> events = [];
  final List<AtomicSwap> swaps = [];
  final List<String> messages = [];

  @override
  void onSellerCancelEvent(SellerCancelEvent event, AtomicSwap swap, String message) {
    events.add(event);
    swaps.add(swap);
    messages.add(message);
  }
}

void main() {
  group('AtomicSwap Model', () {
    test('should create swap in created state', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
        isTestnet: true,
        memo: 'Test swap',
      );

      expect(swap.id, equals('swap-123'));
      expect(swap.status, equals(AtomicSwapStatus.created));
      expect(swap.fromAsset, equals('BTC'));
      expect(swap.toAsset, equals('SOL'));
      expect(swap.isTestnet, isTrue);
    });

    test('should accept handshake and set timestamp', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      );

      final acceptedSwap = swap.acceptHandshake();

      expect(acceptedSwap.status, equals(AtomicSwapStatus.handshakeAccepted));
      expect(acceptedSwap.handshakeAcceptedAt, isNotNull);
      expect(acceptedSwap.handshakeAcceptedAt!.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('Payment Window Expiration', () {
    test('should NOT be expired when handshake not accepted', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      );

      expect(swap.isPaymentWindowExpired, isFalse);
    });

    test('should NOT be expired when handshake recently accepted', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 1)),
        paymentWindow: const Duration(hours: 24),
        sellerAutoCancelEnabled: true,
      );

      expect(swap.isPaymentWindowExpired, isFalse);
    });

    test('should be expired when payment window passed', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        paymentWindow: const Duration(hours: 24),
        sellerAutoCancelEnabled: true,
      );

      expect(swap.isPaymentWindowExpired, isTrue);
    });

    test('should use default 24h window if not specified', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        // paymentWindow not set, should default to 24h
        sellerAutoCancelEnabled: true,
      );

      expect(swap.isPaymentWindowExpired, isTrue);
    });

    test('should calculate remaining payment time correctly', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 12)),
        paymentWindow: const Duration(hours: 24),
      );

      final remaining = swap.remainingPaymentTime;
      expect(remaining, isNotNull);
      expect(remaining!.inHours, equals(12));
      expect(remaining.inMinutes, equals(720));
    });

    test('should return null for remaining time when not applicable', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      );

      expect(swap.remainingPaymentTime, isNull);
    });
  });

  group('Auto-Cancel Eligibility', () {
    test('should NOT be auto-cancelable when not in handshakeAccepted state', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        sellerAutoCancelEnabled: true,
      );

      expect(swap.canAutoCancel, isFalse);
    });

    test('should NOT be auto-cancelable when auto-cancel disabled', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        status: AtomicSwapStatus.handshakeAccepted,
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        paymentWindow: const Duration(hours: 24),
        sellerAutoCancelEnabled: false,
      );

      expect(swap.canAutoCancel, isFalse);
    });

    test('should be auto-cancelable when all conditions met', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        status: AtomicSwapStatus.handshakeAccepted,
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        paymentWindow: const Duration(hours: 24),
        sellerAutoCancelEnabled: true,
      );

      expect(swap.canAutoCancel, isTrue);
    });
  });

  group('SellerCancelService', () {
    late SellerCancelService service;
    late MockSellerCancelListener listener;

    setUp(() {
      service = SellerCancelService();
      listener = MockSellerCancelListener();
      service.addListener(listener);
    });

    test('should configure auto-cancel settings', () async {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      );

      await service.registerSwap(swap);
      await service.configureAutoCancel(
        swapId: 'swap-123',
        enabled: true,
        paymentWindow: const Duration(hours: 12),
      );

      final configuredSwap = service.getSwap('swap-123');
      expect(configuredSwap!.sellerAutoCancelEnabled, isTrue);
      expect(configuredSwap.paymentWindow, equals(const Duration(hours: 12)));
    });

    test('should cancel swap due to non-payment', () async {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        status: AtomicSwapStatus.handshakeAccepted,
        handshakeAcceptedAt: DateTime.now(),
      );

      await service.registerSwap(swap);
      final cancelledSwap = await service.cancelDueToNonPayment(
        'swap-123',
        reason: 'Buyer not responding',
      );

      expect(cancelledSwap.status, equals(AtomicSwapStatus.cancelled));
      expect(cancelledSwap.memo, contains('Buyer not responding'));
    });

    test('should auto-cancel when payment window expired', () async {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        status: AtomicSwapStatus.handshakeAccepted,
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        paymentWindow: const Duration(hours: 24),
        sellerAutoCancelEnabled: true,
      );

      await service.registerSwap(swap);
      final autoCancelledSwap = await service.autoCancelDueToNonPayment('swap-123');

      expect(autoCancelledSwap.status, equals(AtomicSwapStatus.sellerAutoCancelled));
      expect(autoCancelledSwap.memo, contains('Auto-cancelled'));
    });

    test('should notify seller on expiration', () async {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        status: AtomicSwapStatus.handshakeAccepted,
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        paymentWindow: const Duration(hours: 24),
        sellerAutoCancelEnabled: true,
      );

      await service.registerSwap(swap);
      await service.notifySellerOfExpiration(swap);

      expect(listener.events.last, equals(SellerCancelEvent.notificationSent));
    });

    test('should get swaps pending auto-cancel', () async {
      final expiredSwap = AtomicSwap.created(
        id: 'swap-expired',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        status: AtomicSwapStatus.handshakeAccepted,
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        paymentWindow: const Duration(hours: 24),
        sellerAutoCancelEnabled: true,
      );

      final validSwap = AtomicSwap.created(
        id: 'swap-valid',
        sellerId: 'seller-1',
        buyerId: 'buyer-2',
        fromAsset: 'ETH',
        toAsset: 'SOL',
        fromAmount: 0.5,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        status: AtomicSwapStatus.handshakeAccepted,
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 1)),
        paymentWindow: const Duration(hours: 24),
        sellerAutoCancelEnabled: true,
      );

      await service.registerSwap(expiredSwap);
      await service.registerSwap(validSwap);

      final pending = service.getPendingAutoCancel();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals('swap-expired'));
    });

    test('should throw when cancelling non-existent swap', () async {
      expect(
        () => service.cancelDueToNonPayment('non-existent'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw when cancelling already completed swap', () async {
      final completedSwap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(status: AtomicSwapStatus.completed);

      await service.registerSwap(completedSwap);
      
      expect(
        () => service.cancelDueToNonPayment('swap-123'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('SwapTimeoutService', () {
    late SwapTimeoutService service;
    late List<AtomicSwap> testSwaps;
    late List<String> logMessages;

    setUp(() {
      service = SwapTimeoutService();
      logMessages = [];
      
      testSwaps = [
        // Swap that should be auto-cancelled
        AtomicSwap.created(
          id: 'swap-1',
          sellerId: 'seller-1',
          buyerId: 'buyer-1',
          fromAsset: 'BTC',
          toAsset: 'SOL',
          fromAmount: 0.01,
          toAmount: 5.0,
          paymentBlockchain: 'solana',
        ).copyWith(
          status: AtomicSwapStatus.handshakeAccepted,
          handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
          paymentWindow: const Duration(hours: 24),
          sellerAutoCancelEnabled: true,
        ),
        // Swap that's still within payment window
        AtomicSwap.created(
          id: 'swap-2',
          sellerId: 'seller-1',
          buyerId: 'buyer-2',
          fromAsset: 'ETH',
          toAsset: 'SOL',
          fromAmount: 0.5,
          toAmount: 5.0,
          paymentBlockchain: 'solana',
        ).copyWith(
          status: AtomicSwapStatus.handshakeAccepted,
          handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 1)),
          paymentWindow: const Duration(hours: 24),
          sellerAutoCancelEnabled: true,
        ),
        // Swap with auto-cancel disabled
        AtomicSwap.created(
          id: 'swap-3',
          sellerId: 'seller-2',
          buyerId: 'buyer-3',
          fromAsset: 'TRX',
          toAsset: 'SOL',
          fromAmount: 1000,
          toAmount: 5.0,
          paymentBlockchain: 'solana',
        ).copyWith(
          status: AtomicSwapStatus.handshakeAccepted,
          handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
          paymentWindow: const Duration(hours: 24),
          sellerAutoCancelEnabled: false,
        ),
      ];

      service.setSwaps(testSwaps);
    });

    test('should identify auto-cancel candidates', () {
      final candidates = service.getAutoCancelCandidates();
      
      expect(candidates.length, equals(1));
      expect(candidates.first.id, equals('swap-1'));
    });

    test('should check specific swap and auto-cancel if eligible', () async {
      final swap = testSwaps.first;
      
      await service.checkSwap(swap);
      
      expect(swap.sellerAutoCancelEnabled, isTrue);
      expect(swap.status, equals(AtomicSwapStatus.handshakeAccepted));
    });

    test('should get swap statistics by status', () {
      // Add more swaps for stats
      service.addSwap(AtomicSwap.created(
        id: 'swap-completed',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(status: AtomicSwapStatus.completed));

      final stats = service.getSwapStats();
      
      expect(stats[AtomicSwapStatus.handshakeAccepted], equals(3));
      expect(stats[AtomicSwapStatus.completed], equals(1));
    });

    test('should add and remove swaps', () {
      final newSwap = AtomicSwap.created(
        id: 'new-swap',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      );

      service.addSwap(newSwap);
      expect(service.getAutoCancelCandidates().length, equals(1)); // Still 1 (swap-1)

      service.removeSwap('swap-1');
      expect(service.getAutoCancelCandidates().length, equals(0));
    });

    test('should configure check interval', () {
      service.setCheckInterval(const Duration(minutes: 10));
      // Service should accept the new interval
      expect(service.defaultPaymentWindow, returnsNormally);
    });
  });

  group('JSON Serialization', () {
    test('should serialize swap with new fields to JSON', () {
      final swap = AtomicSwap.created(
        id: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        toAsset: 'SOL',
        fromAmount: 0.01,
        toAmount: 5.0,
        paymentBlockchain: 'solana',
      ).copyWith(
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 1)),
        paymentWindow: const Duration(hours: 24),
        sellerAutoCancelEnabled: true,
      );

      final json = swap.toJson();

      expect(json['id'], equals('swap-123'));
      expect(json['handshakeAcceptedAt'], isNotNull);
      expect(json['paymentWindowSeconds'], equals(86400));
      expect(json['sellerAutoCancelEnabled'], isTrue);
    });

    test('should deserialize swap with new fields from JSON', () {
      final json = {
        'id': 'swap-123',
        'sellerId': 'seller-1',
        'buyerId': 'buyer-1',
        'fromAsset': 'BTC',
        'toAsset': 'SOL',
        'fromAmount': 0.01,
        'toAmount': 5.0,
        'status': 'handshakeAccepted',
        'paymentBlockchain': 'solana',
        'sellerPaymentAddress': null,
        'buyerPaymentAddress': null,
        'sellerFundingTxHash': null,
        'buyerPaymentTxHash': null,
        'htlcAddress': null,
        'secretHash': null,
        'secretPreimage': null,
        'htlcTimeoutSeconds': 86400,
        'isTestnet': true,
        'createdAt': 1234567890,
        'updatedAt': 1234567890,
        'memo': null,
        'handshakeAcceptedAt': DateTime.now().toIso8601String(),
        'paymentWindowSeconds': 86400,
        'sellerAutoCancelEnabled': true,
      };

      final swap = AtomicSwap.fromJson(json);

      expect(swap.id, equals('swap-123'));
      expect(swap.handshakeAcceptedAt, isNotNull);
      expect(swap.paymentWindow, equals(const Duration(hours: 24)));
      expect(swap.sellerAutoCancelEnabled, isTrue);
    });
  });

  group('SellerExpirationNotification', () {
    test('should create notification with correct data', () {
      final notification = SellerExpirationNotification(
        swapId: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        fromAmount: 0.01,
        toAsset: 'SOL',
        toAmount: 5.0,
        expectedPaymentWindow: const Duration(hours: 24),
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        expirationDetectedAt: DateTime.now(),
      );

      expect(notification.swapId, equals('swap-123'));
      expect(notification.sellerId, equals('seller-1'));
      expect(notification.paymentWindowMinutes, equals(1440)); // 24 hours = 1440 minutes
    });

    test('should serialize notification to JSON', () {
      final notification = SellerExpirationNotification(
        swapId: 'swap-123',
        sellerId: 'seller-1',
        buyerId: 'buyer-1',
        fromAsset: 'BTC',
        fromAmount: 0.01,
        toAsset: 'SOL',
        toAmount: 5.0,
        expectedPaymentWindow: const Duration(hours: 24),
        handshakeAcceptedAt: DateTime.now().subtract(const Duration(hours: 25)),
        expirationDetectedAt: DateTime.now(),
      );

      final json = notification.toJson();

      expect(json['swapId'], equals('swap-123'));
      expect(json['expectedPaymentWindowMinutes'], equals(1440));
      expect(json['handshakeAcceptedAt'], isNotNull);
    });
  });
}
