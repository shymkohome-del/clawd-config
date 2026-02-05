# Seller Auto-Cancel for Atomic Swaps

This module provides seller auto-cancel functionality for atomic swap transactions, solving the problem of sellers being stuck waiting for non-paying buyers.

## Problem Solved

**Issue:** When a seller accepts a handshake in an atomic swap, the buyer has a limited time window to make payment. If the buyer doesn't pay, the seller is left waiting indefinitely with no automatic mechanism to cancel the swap.

**Solution:** This implementation adds:
1. Payment window tracking with automatic expiration detection
2. Configurable auto-cancel settings per swap
3. Automatic cancellation when payment window expires (if enabled)
4. Seller notifications about expiration events

## Architecture

### Core Components

#### 1. AtomicSwap Model (`lib/models/atomic_swap.dart`)

Extended with new fields for payment window tracking:

```dart
final DateTime? handshakeAcceptedAt;
final Duration? paymentWindow;
final bool? sellerAutoCancelEnabled;
```

**Computed Properties:**

- `isPaymentWindowExpired` - Checks if the payment window has passed
- `remainingPaymentTime` - Returns time remaining until expiration
- `canAutoCancel` - Checks if swap meets all criteria for auto-cancel

#### 2. SwapTimeoutService (`lib/services/swap_timeout_service.dart`)

Monitors all swaps for timeout conditions:

- `_checkPaymentWindowExpirations()` - Finds expired payment windows
- `_checkHtlcTimeouts()` - Monitors HTLC timeout conditions
- `_autoCancelSwap()` - Performs automatic cancellation
- `_notifySellerOfExpiration()` - Sends seller notifications

#### 3. SellerCancelService (`lib/services/seller_cancel_service.dart`)

Manages seller-initiated cancellations:

- `configureAutoCancel()` - Configure auto-cancel settings
- `cancelDueToNonPayment()` - Manual cancellation
- `autoCancelDueToNonPayment()` - Automatic cancellation based on expiration
- `notifySellerOfExpiration()` - Send expiration notifications

## Usage

### Basic Setup

```dart
import 'package:seller_auto_cancel/models/atomic_swap.dart';
import 'package:seller_auto_cancel/services/swap_timeout_service.dart';
import 'package:seller_auto_cancel/services/seller_cancel_service.dart';
```

### Creating a Swap with Auto-Cancel

```dart
final swap = AtomicSwap.created(
  id: 'swap-123',
  sellerId: 'seller-principal',
  buyerId: 'buyer-principal',
  fromAsset: 'BTC',
  toAsset: 'SOL',
  fromAmount: 0.01,
  toAmount: 5.0,
  paymentBlockchain: 'solana',
);

// Accept handshake and start payment window
final acceptedSwap = swap.acceptHandshake();

// Configure auto-cancel with 12-hour window
final configuredSwap = acceptedSwap.copyWith(
  sellerAutoCancelEnabled: true,
  paymentWindow: const Duration(hours: 12),
);
```

### Using SellerCancelService

```dart
final cancelService = SellerCancelService();

// Register swap
await cancelService.registerSwap(swap);

// Configure auto-cancel
await cancelService.configureAutoCancel(
  swapId: swap.id,
  enabled: true,
  paymentWindow: const Duration(hours: 24),
);

// Manual cancellation by seller
final cancelled = await cancelService.cancelDueToNonPayment(
  swap.id,
  reason: 'Buyer not responding after 24 hours',
);
```

### Using SwapTimeoutService

```dart
final timeoutService = SwapTimeoutService();

// Set up callbacks
timeoutService.onPaymentWindowExpired = (swap) async {
  print('Payment window expired for swap: ${swap.id}');
};

timeoutService.onSwapExpired = (swap) async {
  print('Swap auto-cancelled: ${swap.id}');
};

// Start monitoring
timeoutService.start();

// Get auto-cancel candidates
final candidates = timeoutService.getAutoCancelCandidates();
```

### Testing Payment Window Expiration

```dart
// Create a swap with expired payment window
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

// Check if expired
expect(expiredSwap.isPaymentWindowExpired, isTrue);
expect(expiredSwap.canAutoCancel, isTrue);
```

## Configuration Options

### Default Payment Window

```dart
// Set default to 12 hours for all new swaps
cancelService.setDefaultPaymentWindow(const Duration(hours: 12));
```

### Custom Timeout Check Interval

```dart
// Check for timeouts every minute (for testing)
timeoutService.setCheckInterval(const Duration(minutes: 1));
```

## Integration Points

### Adding to Existing Project

1. **Copy the lib/ directory** to your project
2. **Update your AtomicSwap model** to include the new fields
3. **Initialize SwapTimeoutService** at app startup
4. **Configure swaps** with auto-cancel settings as needed
5. **Handle notifications** for seller awareness

### Event Callbacks

Set up callbacks for handling events:

```dart
timeoutService.onPaymentWindowExpired = (swap) async {
  // Notify seller via push/email
  await notificationService.sendPaymentWindowWarning(swap);
};

timeoutService.onSwapExpired = (swap) async {
  // Update UI, log event, etc.
  await analytics.track('swap_auto_cancelled', {'swapId': swap.id});
};
```

## Running Tests

```bash
dart test/seller_auto_cancel_test.dart
```

Or with coverage:

```bash
dart test --coverage=coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Files Structure

```
seller_auto_cancel/
├── lib/
│   ├── models/
│   │   └── atomic_swap.dart      # Extended swap model
│   └── services/
│       ├── swap_timeout_service.dart   # Timeout monitoring
│       └── seller_cancel_service.dart # Cancellation logic
├── test/
│   └── seller_auto_cancel_test.dart  # Comprehensive tests
├── pubspec.yaml
└── README.md
```

## API Reference

### AtomicSwap

| Field | Type | Description |
|-------|------|-------------|
| `handshakeAcceptedAt` | `DateTime?` | When buyer accepted handshake |
| `paymentWindow` | `Duration?` | Time buyer has to pay |
| `sellerAutoCancelEnabled` | `bool?` | Enable auto-cancel |

| Method | Returns | Description |
|--------|---------|-------------|
| `isPaymentWindowExpired` | `bool` | Check if window has passed |
| `remainingPaymentTime` | `Duration?` | Time until expiration |
| `canAutoCancel` | `bool` | Eligibility for auto-cancel |

### SellerCancelService

| Method | Returns | Description |
|--------|---------|-------------|
| `configureAutoCancel()` | `Future<void>` | Configure auto-cancel settings |
| `cancelDueToNonPayment()` | `Future<AtomicSwap>` | Manual cancellation |
| `autoCancelDueToNonPayment()` | `Future<AtomicSwap>` | Auto-cancel expired swap |
| `notifySellerOfExpiration()` | `Future<void>` | Send seller notification |

### SwapTimeoutService

| Method | Returns | Description |
|--------|---------|-------------|
| `start()` | `void` | Start timeout monitoring |
| `stop()` | `void` | Stop monitoring |
| `getAutoCancelCandidates()` | `List<AtomicSwap>` | Swaps eligible for auto-cancel |

## Best Practices

1. **Set appropriate payment windows** - Balance buyer convenience with seller protection
2. **Notify sellers before auto-cancel** - Give a warning before actual cancellation
3. **Log all cancellation events** - For audit trail and dispute resolution
4. **Test edge cases** - Especially around time zone changes and leap seconds
5. **Monitor auto-cancel rates** - High rates may indicate UX issues

## License

This code is part of the crypto_market project.
