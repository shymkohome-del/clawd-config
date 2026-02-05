import 'dart:async';
import '../models/atomic_swap.dart';

/// Service responsible for managing seller-initiated cancellations of atomic swaps
/// 
/// This service handles:
/// - Configuring auto-cancel settings for swaps
/// - Manual cancellations due to non-payment
/// - Notifications to sellers about payment window expirations
class SellerCancelService {
  // Singleton instance
  static final SellerCancelService _instance = SellerCancelService._internal();
  factory SellerCancelService() => _instance;
  SellerCancelService._internal();

  // Dependencies
  final Map<String, AtomicSwap> _swaps = {};
  final List<SellerCancelListener> _listeners = [];
  Duration _defaultPaymentWindow = const Duration(hours: 24);
  
  // === CONFIGURATION ===

  /// Configure auto-cancel settings for a specific swap
  Future<void> configureAutoCancel({
    required String swapId,
    required bool enabled,
    Duration? paymentWindow,
  }) async {
    final swap = _swaps[swapId];
    if (swap == null) {
      throw ArgumentError('Swap not found: $swapId');
    }

    final configuredSwap = swap.copyWith(
      sellerAutoCancelEnabled: enabled,
      paymentWindow: paymentWindow ?? _defaultPaymentWindow,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    _swaps[swapId] = configuredSwap;
    
    print('Auto-cancel configured for swap $swapId: enabled=$enabled, window=${configuredSwap.paymentWindow}');
    
    // Notify listeners
    _notifyListeners(
      SellerCancelEvent.configured,
      configuredSwap,
      'Auto-cancel ${enabled ? 'enabled' : 'disabled'} with payment window: ${configuredSwap.paymentWindow}',
    );
  }

  /// Get the default payment window duration
  Duration get defaultPaymentWindow => _defaultPaymentWindow;

  /// Set the default payment window duration for new swaps
  void setDefaultPaymentWindow(Duration duration) {
    _defaultPaymentWindow = duration;
    print('Default payment window set to: $duration');
  }

  // === MANUAL CANCELLATION ===

  /// Cancel a swap due to buyer's non-payment
  Future<AtomicSwap> cancelDueToNonPayment(String swapId, {String? reason}) async {
    final swap = _swaps[swapId];
    if (swap == null) {
      throw ArgumentError('Swap not found: $swapId');
    }

    // Validate that swap can be cancelled
    if (swap.status == AtomicSwapStatus.completed ||
        swap.status == AtomicSwapStatus.cancelled ||
        swap.status == AtomicSwapStatus.refunded ||
        swap.status == AtomicSwapStatus.sellerAutoCancelled) {
      throw StateError('Swap $swapId cannot be cancelled in status: ${swap.status}');
    }

    final cancelledSwap = swap.copyWith(
      status: AtomicSwapStatus.cancelled,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      memo: reason ?? 'Cancelled by seller due to non-payment',
    );

    _swaps[swapId] = cancelledSwap;
    
    print('Swap $swapId cancelled due to non-payment. Reason: ${reason ?? "No payment received"}');
    
    // Notify listeners
    _notifyListeners(
      SellerCancelEvent.cancelled,
      cancelledSwap,
      'Cancelled due to non-payment. Reason: ${reason ?? "No payment received"}',
    );

    return cancelledSwap;
  }

  /// Auto-cancel a swap based on payment window expiration
  Future<AtomicSwap> autoCancelDueToNonPayment(String swapId) async {
    final swap = _swaps[swapId];
    if (swap == null) {
      throw ArgumentError('Swap not found: $swapId');
    }

    if (!swap.canAutoCancel) {
      throw StateError('Swap $swapId does not meet auto-cancel criteria');
    }

    final cancelledSwap = swap.copyWith(
      status: AtomicSwapStatus.sellerAutoCancelled,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      memo: 'Auto-cancelled: payment window expired',
    );

    _swaps[swapId] = cancelledSwap;
    
    print('Swap $swapId auto-cancelled due to payment window expiration');
    
    // Send notification to seller
    await notifySellerOfExpiration(cancelledSwap);
    
    // Notify listeners
    _notifyListeners(
      SellerCancelEvent.autoCancelled,
      cancelledSwap,
      'Auto-cancelled: payment window of ${swap.paymentWindow ?? _defaultPaymentWindow} expired',
    );

    return cancelledSwap;
  }

  // === NOTIFICATIONS ===

  /// Notify seller about payment window expiration
  Future<void> notifySellerOfExpiration(AtomicSwap swap) async {
    print('Sending expiration notification to seller ${swap.sellerId} for swap ${swap.id}');

    // Calculate how much time was expected
    final window = swap.paymentWindow ?? _defaultPaymentWindow;
    final timeAgo = swap.handshakeAcceptedAt?.subtract(window);
    
    final notification = SellerExpirationNotification(
      swapId: swap.id,
      sellerId: swap.sellerId,
      buyerId: swap.buyerId,
      fromAsset: swap.fromAsset,
      fromAmount: swap.fromAmount,
      toAsset: swap.toAsset,
      toAmount: swap.toAmount,
      expectedPaymentWindow: window,
      handshakeAcceptedAt: swap.handshakeAcceptedAt,
      expirationDetectedAt: DateTime.now(),
      paymentWindowMinutes: window.inMinutes,
    );

    // In a real implementation, this would:
    // 1. Send push notification
    // 2. Send email notification
    // 3. Update in-app notification center
    // 4. Log for audit trail

    // Simulate notification processing
    await Future.delayed(const Duration(milliseconds: 100));
    
    print('Expiration notification sent for swap ${swap.id}');
    
    // Notify listeners
    _notifyListeners(
      SellerCancelEvent.notificationSent,
      swap,
      'Expiration notification sent for swap ${swap.id}',
    );
  }

  // === SWAP MANAGEMENT ===

  /// Register a swap for auto-cancel management
  Future<void> registerSwap(AtomicSwap swap) async {
    _swaps[swap.id] = swap;
    print('Swap ${swap.id} registered for auto-cancel management');
  }

  /// Unregister a swap from auto-cancel management
  Future<void> unregisterSwap(String swapId) async {
    _swaps.remove(swapId);
    print('Swap $swapId unregistered from auto-cancel management');
  }

  /// Get a swap by ID
  AtomicSwap? getSwap(String swapId) => _swaps[swapId];

  /// Get all swaps for a seller
  List<AtomicSwap> getSwapsForSeller(String sellerId) {
    return _swaps.values
        .where((swap) => swap.sellerId == sellerId)
        .toList();
  }

  /// Get all swaps pending cancellation
  List<AtomicSwap> getPendingAutoCancel() {
    return _swaps.values
        .where((swap) => swap.canAutoCancel)
        .toList();
  }

  // === LISTENERS ===

  /// Add a listener for cancel events
  void addListener(SellerCancelListener listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(SellerCancelListener listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(SellerCancelEvent event, AtomicSwap swap, String message) {
    for (final listener in _listeners) {
      try {
        listener.onSellerCancelEvent(event, swap, message);
      } catch (e) {
        print('Error notifying listener: $e');
      }
    }
  }
}

// === SUPPORTING CLASSES ===

/// Events that can be triggered by SellerCancelService
enum SellerCancelEvent {
  configured,
  cancelled,
  autoCancelled,
  notificationSent,
}

/// Listener interface for cancel events
abstract class SellerCancelListener {
  void onSellerCancelEvent(SellerCancelEvent event, AtomicSwap swap, String message);
}

/// Notification payload for seller expiration events
class SellerExpirationNotification {
  final String swapId;
  final String sellerId;
  final String buyerId;
  final String fromAsset;
  final double fromAmount;
  final String toAsset;
  final double toAmount;
  final Duration expectedPaymentWindow;
  final DateTime? handshakeAcceptedAt;
  final DateTime expirationDetectedAt;
  final int paymentWindowMinutes;

  SellerExpirationNotification({
    required this.swapId,
    required this.sellerId,
    required this.buyerId,
    required this.fromAsset,
    required this.fromAmount,
    required this.toAsset,
    required this.toAmount,
    required this.expectedPaymentWindow,
    required this.handshakeAcceptedAt,
    required this.expirationDetectedAt,
  }) : paymentWindowMinutes = expectedPaymentWindow.inMinutes;

  Map<String, dynamic> toJson() {
    return {
      'swapId': swapId,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'fromAsset': fromAsset,
      'fromAmount': fromAmount,
      'toAsset': toAsset,
      'toAmount': toAmount,
      'expectedPaymentWindowMinutes': paymentWindowMinutes,
      'handshakeAcceptedAt': handshakeAcceptedAt?.toIso8601String(),
      'expirationDetectedAt': expirationDetectedAt.toIso8601String(),
    };
  }
}
