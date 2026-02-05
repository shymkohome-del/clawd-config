import 'dart:async';
import 'atomic_swap.dart';

/// Service responsible for monitoring and handling swap timeout scenarios
class SwapTimeoutService {
  // Singleton instance
  static final SwapTimeoutService _instance = SwapTimeoutService._internal();
  factory SwapTimeoutService() => _instance;
  SwapTimeoutService._internal();

  // Dependencies
  List<AtomicSwap> _swaps = [];
  Timer? _checkTimer;
  Duration _checkInterval = const Duration(minutes: 5);
  
  // Callbacks for external handling
  Function(AtomicSwap swap)? onPaymentWindowExpired;
  Function(AtomicSwap swap)? onHtlcTimeout;
  Function(AtomicSwap swap)? onSwapExpired;

  // === CONFIGURATION ===

  /// Set the interval for checking timeouts
  void setCheckInterval(Duration interval) {
    _checkInterval = interval;
    _restartTimer();
  }

  /// Set the list of swaps to monitor (for testing or external management)
  void setSwaps(List<AtomicSwap> swaps) {
    _swaps = swaps;
  }

  // === MONITORING ===

  /// Start the timeout monitoring service
  void start() {
    _restartTimer();
    print('SwapTimeoutService started with interval: $_checkInterval');
  }

  /// Stop the timeout monitoring service
  void stop() {
    _checkTimer?.cancel();
    _checkTimer = null;
    print('SwapTimeoutService stopped');
  }

  void _restartTimer() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(
      _checkInterval,
      (_) => _checkAllTimeouts(),
    );
  }

  // === TIMEOUT CHECKING ===

  /// Check all timeout scenarios
  Future<void> _checkAllTimeouts() async {
    await Future.wait([
      _checkPaymentWindowExpirations(),
      _checkHtlcTimeouts(),
    ]);
  }

  /// Check for expired payment windows (for seller auto-cancel)
  Future<void> _checkPaymentWindowExpirations() async {
    final now = DateTime.now();
    
    for (final swap in _swaps) {
      // Only check swaps in handshakeAccepted state
      if (swap.status != AtomicSwapStatus.handshakeAccepted) {
        continue;
      }

      // Check if payment window has expired
      if (swap.isPaymentWindowExpired) {
        print('Payment window expired for swap: ${swap.id}');
        
        // Notify about expired payment window
        onPaymentWindowExpired?.call(swap);
        
        // If auto-cancel is enabled, trigger cancellation
        if (swap.sellerAutoCancelEnabled == true) {
          await _autoCancelSwap(swap);
        }
      }
    }
  }

  /// Check for HTLC timeouts (funds locked too long)
  Future<void> _checkHtlcTimeouts() async {
    final now = DateTime.now();
    
    for (final swap in _swaps) {
      // Only check swaps in paymentReceived state
      if (swap.status != AtomicSwapStatus.paymentReceived) {
        continue;
      }

      // Calculate if HTLC timeout has passed
      // This is a simplified check - in production, you'd check actual blockchain time
      if (swap.remainingPaymentTime != null && 
          swap.remainingPaymentTime!.isNegative) {
        print('HTLC timeout for swap: ${swap.id}');
        onHtlcTimeout?.call(swap);
      }
    }
  }

  // === AUTO-CANCEL LOGIC ===

  /// Auto-cancel a swap due to payment window expiration
  Future<void> _autoCancelSwap(AtomicSwap swap) async {
    print('Auto-cancelling swap: ${swap.id} due to payment window expiration');
    
    // Update swap status to sellerAutoCancelled
    final cancelledSwap = swap.copyWith(
      status: AtomicSwapStatus.sellerAutoCancelled,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    
    // Update in our list
    final index = _swaps.indexWhere((s) => s.id == swap.id);
    if (index != -1) {
      _swaps[index] = cancelledSwap;
    }
    
    // Trigger notification to seller
    await _notifySellerOfExpiration(cancelledSwap);
    
    // Notify external handlers
    onSwapExpired?.call(cancelledSwap);
  }

  /// Notify seller that swap was auto-cancelled
  Future<void> _notifySellerOfExpiration(AtomicSwap swap) async {
    print('Notifying seller ${swap.sellerId} about auto-cancellation of swap ${swap.id}');
    
    // In a real implementation, this would:
    // 1. Send a notification (push, email, in-app)
    // 2. Update seller's dashboard
    // 3. Log the event for audit purposes
    
    // Simulate notification delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    print('Seller notification sent for swap: ${swap.id}');
  }

  // === MANUAL OPERATIONS ===

  /// Manually trigger timeout check for a specific swap
  Future<void> checkSwap(AtomicSwap swap) async {
    if (swap.status == AtomicSwapStatus.handshakeAccepted && 
        swap.isPaymentWindowExpired &&
        swap.sellerAutoCancelEnabled == true) {
      await _autoCancelSwap(swap);
    }
  }

  /// Add a swap to the monitoring list
  void addSwap(AtomicSwap swap) {
    if (!_swaps.any((s) => s.id == swap.id)) {
      _swaps.add(swap);
    }
  }

  /// Remove a swap from the monitoring list
  void removeSwap(String swapId) {
    _swaps.removeWhere((s) => s.id == swapId);
  }

  /// Get all swaps that are candidates for auto-cancel
  List<AtomicSwap> getAutoCancelCandidates() {
    return _swaps.where((swap) => swap.canAutoCancel).toList();
  }

  /// Get count of swaps in each status
  Map<AtomicSwapStatus, int> getSwapStats() {
    final stats = <AtomicSwapStatus, int>{};
    for (final swap in _swaps) {
      stats[swap.status] = (stats[swap.status] ?? 0) + 1;
    }
    return stats;
  }
}
