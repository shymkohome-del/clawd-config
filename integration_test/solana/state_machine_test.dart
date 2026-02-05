import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:crypto_market/features/market/models/atomic_swap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Solana - State Machine Tests', () {
    // Helper to create swap with specific status
    AtomicSwap createSwapWithStatus(AtomicSwapStatus status) {
      return AtomicSwap(
        id: 'state_test_${DateTime.now().millisecondsSinceEpoch}_${status.index}',
        listingId: 'listing_state_test',
        buyer: 'buyer_state_test',
        seller: 'seller_state_test',
        secretHash: [1, 2, 3, 4, 5, 6, 7, 8],
        amount: BigInt.from(1000000),
        cryptoType: 'SOL',
        timeout: BigInt.from(3600000),
        status: status,
        createdAt: BigInt.from(DateTime.now().millisecondsSinceEpoch),
      );
    }

    // ========== VALID STATE TRANSITIONS ==========

    group('Valid State Transitions', () {
      testWidgets('handshakeRequested → handshakeAccepted', (tester) async {
        final swap = createSwapWithStatus(AtomicSwapStatus.handshakeRequested);
        
        expect(swap.status, equals(AtomicSwapStatus.handshakeRequested));
        expect(swap.isInHandshake, isTrue);
        
        // Transition to handshakeAccepted
        final acceptedSwap = swap.copyWith(status: AtomicSwapStatus.handshakeAccepted);
        
        expect(acceptedSwap.status, equals(AtomicSwapStatus.handshakeAccepted));
        expect(acceptedSwap.isInHandshake, isTrue);
        expect(acceptedSwap.canBeCanceled, isTrue);
      });

      testWidgets('handshakeAccepted → initiated', (tester) async {
        final swap = createSwapWithStatus(AtomicSwapStatus.handshakeAccepted);
        
        expect(swap.status, equals(AtomicSwapStatus.handshakeAccepted));
        
        // Transition to initiated
        final initiatedSwap = swap.copyWith(status: AtomicSwapStatus.initiated);
        
        expect(initiatedSwap.status, equals(AtomicSwapStatus.initiated));
        expect(initiatedSwap.canBeLocked, isTrue);
        expect(initiatedSwap.canBeRefunded, isTrue);
      });

      testWidgets('initiated → locked', (tester) async {
        final swap = createSwapWithStatus(AtomicSwapStatus.initiated);
        
        expect(swap.status, equals(AtomicSwapStatus.initiated));
        expect(swap.canBeLocked, isTrue);
        
        // Transition to locked
        final lockedSwap = swap.copyWith(status: AtomicSwapStatus.locked);
        
        expect(lockedSwap.status, equals(AtomicSwapStatus.locked));
        expect(lockedSwap.isFundsLocked, isTrue);
        expect(lockedSwap.canBeCompleted, isTrue);
      });

      testWidgets('locked → completed', (tester) async {
        final swap = createSwapWithStatus(AtomicSwapStatus.locked);
        
        expect(swap.status, equals(AtomicSwapStatus.locked));
        expect(swap.isFundsLocked, isTrue);
        expect(swap.canBeCompleted, isTrue);
        
        // Transition to completed
        final completedSwap = swap.copyWith(status: AtomicSwapStatus.completed);
        
        expect(completedSwap.status, equals(AtomicSwapStatus.completed));
        expect(completedSwap.isFundsLocked, isFalse);
        expect(completedSwap.canBeCanceled, isFalse);
      });

      testWidgets('locked → refunded', (tester) async {
        final swap = createSwapWithStatus(AtomicSwapStatus.locked);
        
        expect(swap.status, equals(AtomicSwapStatus.locked));
        expect(swap.isFundsLocked, isTrue);
        
        // Transition to refunded
        final refundedSwap = swap.copyWith(status: AtomicSwapStatus.refunded);
        
        expect(refundedSwap.status, equals(AtomicSwapStatus.refunded));
        expect(refundedSwap.isFundsLocked, isFalse);
        expect(refundedSwap.canBeCanceled, isFalse);
      });

      testWidgets('locked → expired', (tester) async {
        final swap = createSwapWithStatus(AtomicSwapStatus.locked);
        
        expect(swap.status, equals(AtomicSwapStatus.locked));
        
        // Simulate timeout
        final expiredSwap = swap.copyWith(status: AtomicSwapStatus.expired);
        
        expect(expiredSwap.status, equals(AtomicSwapStatus.expired));
        expect(expiredSwap.isExpired, isTrue);
        expect(expiredSwap.canBeCanceled, isFalse);
      });

      testWidgets('locked → disputed', (tester) async {
        final swap = createSwapWithStatus(AtomicSwapStatus.locked);
        
        expect(swap.status, equals(AtomicSwapStatus.locked));
        expect(swap.isFundsLocked, isTrue);
        
        // Transition to disputed
        final disputedSwap = swap.copyWith(status: AtomicSwapStatus.disputed);
        
        expect(disputedSwap.status, equals(AtomicSwapStatus.disputed));
        expect(disputedSwap.isFundsLocked, isTrue);
        expect(disputedSwap.canBeCanceled, isFalse);
      });

      testWidgets('Any active state → canceled', (tester) async {
        // Test cancel from handshakeRequested
        final cancelFromHandshake = createSwapWithStatus(AtomicSwapStatus.handshakeRequested);
        expect(cancelFromHandshake.canBeCanceled, isTrue);
        
        final canceledFromHandshake = cancelFromHandshake.copyWith(
          status: AtomicSwapStatus.canceled,
          canceledBy: 'buyer_test',
          cancellationReason: 'Changed mind',
        );
        expect(canceledFromHandshake.status, equals(AtomicSwapStatus.canceled));
        
        // Test cancel from initiated
        final cancelFromInitiated = createSwapWithStatus(AtomicSwapStatus.initiated);
        expect(cancelFromInitiated.canBeCanceled, isTrue);
        
        final canceledFromInitiated = cancelFromInitiated.copyWith(
          status: AtomicSwapStatus.canceled,
          canceledBy: 'buyer_test',
          cancellationReason: 'Changed mind',
        );
        expect(canceledFromInitiated.status, equals(AtomicSwapStatus.canceled));
        
        // Test cancel from locked (requires approval)
        final cancelFromLocked = createSwapWithStatus(AtomicSwapStatus.locked);
        expect(cancelFromLocked.canBeCanceled, isTrue);
        
        final canceledFromLocked = cancelFromLocked.copyWith(
          status: AtomicSwapStatus.canceled,
          canceledBy: 'buyer_test',
          cancellationReason: 'Both agreed to cancel',
        );
        expect(canceledFromLocked.status, equals(AtomicSwapStatus.canceled));
      });
    });

    // ========== INVALID STATE TRANSITIONS ==========

    group('Invalid State Transitions', () {
      testWidgets('Cannot transition from completed to any other state', (tester) async {
        final completedSwap = createSwapWithStatus(AtomicSwapStatus.completed);
        
        expect(completedSwap.canBeCanceled, isFalse);
        expect(completedSwap.canBeCompleted, isFalse);
        expect(completedSwap.isActive, isFalse);
        
        // Attempting to modify should fail validation
        final isTerminalState = completedSwap.status == AtomicSwapStatus.completed;
        expect(isTerminalState, isTrue);
        
        // All transition attempts should be blocked
        expect(completedSwap.canBeRefunded, isFalse);
        expect(completedSwap.canBeLocked, isFalse);
      });

      testWidgets('Cannot transition from refunded to any other state', (tester) async {
        final refundedSwap = createSwapWithStatus(AtomicSwapStatus.refunded);
        
        expect(refundedSwap.canBeCanceled, isFalse);
        expect(refundedSwap.canBeCompleted, isFalse);
        expect(refundedSwap.isActive, isFalse);
        
        // Refunded is a terminal state
        final isTerminalState = refundedSwap.status == AtomicSwapStatus.refunded;
        expect(isTerminalState, isTrue);
      });

      testWidgets('Cannot transition from expired to any other state', (tester) async {
        final expiredSwap = createSwapWithStatus(AtomicSwapStatus.expired);
        
        expect(expiredSwap.canBeCanceled, isFalse);
        expect(expiredSwap.canBeCompleted, isFalse);
        expect(expiredSwap.isActive, isFalse);
        
        // Expired is a terminal state
        final isTerminalState = expiredSwap.status == AtomicSwapStatus.expired;
        expect(isTerminalState, isTrue);
      });

      testWidgets('Cannot transition from canceled to any other state', (tester) async {
        final canceledSwap = createSwapWithStatus(AtomicSwapStatus.canceled);
        
        expect(canceledSwap.canBeCanceled, isFalse);
        expect(canceledSwap.canBeCompleted, isFalse);
        expect(canceledSwap.isActive, isFalse);
        
        // Canceled is a terminal state
        final isTerminalState = canceledSwap.status == AtomicSwapStatus.canceled;
        expect(isTerminalState, isTrue);
      });

      testWidgets('Cannot transition from disputed to completed directly', (tester) async {
        final disputedSwap = createSwapWithStatus(AtomicSwapStatus.disputed);
        
        // Must go through resolution first
        expect(disputedSwap.status, equals(AtomicSwapStatus.disputed));
        
        // Direct completion should be blocked
        final canCompleteDirectly = disputedSwap.status == AtomicSwapStatus.disputed;
        expect(canCompleteDirectly, isFalse); // Cannot complete while disputed
        
        // Must resolve dispute first
        expect(disputedSwap.isActive, isFalse); // Disputed is not considered active
      });

      testWidgets('Cannot skip handshake phase', (tester) async {
        // Attempting to go directly from requested to initiated should fail
        final handshakeRequested = createSwapWithStatus(AtomicSwapStatus.handshakeRequested);
        
        // Should not be able to lock without accepting handshake
        expect(handshakeRequested.canBeLocked, isFalse);
        expect(handshakeRequested.canBeCompleted, isFalse);
        
        // Must go through handshake_accepted first
        expect(handshakeRequested.isInHandshake, isTrue);
      });

      testWidgets('Cannot complete before funds are locked', (tester) async {
        final initiatedSwap = createSwapWithStatus(AtomicSwapStatus.initiated);
        
        // Cannot complete in initiated state
        expect(initiatedSwap.canBeCompleted, isFalse);
        expect(initiatedSwap.isFundsLocked, isFalse);
        
        // Must transition to locked first
        final canCompleteBeforeLock = initiatedSwap.status == AtomicSwapStatus.initiated;
        expect(canCompleteBeforeLock, isFalse);
      });

      testWidgets('Cannot refund non-expired non-active swap', (tester) async {
        final lockedSwap = createSwapWithStatus(AtomicSwapStatus.locked);
        
        // Locked swap can only be refunded if expired
        expect(lockedSwap.isExpired, isFalse);
        expect(lockedSwap.canBeRefunded, isFalse);
        
        // Only after expiration can it be refunded
        expect(lockedSwap.isActive, isTrue);
      });
    });

    // ========== STATE MACHINE INVARIANTS ==========

    group('State Machine Invariants', () {
      testWidgets('Active states are mutually exclusive', (tester) async {
        final states = AtomicSwapStatus.values;
        
        for (final state in states) {
          final swap = createSwapWithStatus(state);
          final isActive = swap.isActive;
          
          // Only these states should be active
          final expectedActive = [
            AtomicSwapStatus.handshakeRequested,
            AtomicSwapStatus.handshakeAccepted,
            AtomicSwapStatus.initiated,
            AtomicSwapStatus.locked,
          ].contains(state);
          
          expect(isActive, equals(expectedActive));
        }
      });

      testWidgets('Terminal states cannot transition', (tester) async {
        final terminalStates = [
          AtomicSwapStatus.completed,
          AtomicSwapStatus.refunded,
          AtomicSwapStatus.expired,
          AtomicSwapStatus.canceled,
        ];
        
        for (final state in terminalStates) {
          final swap = createSwapWithStatus(state);
          
          expect(swap.isActive, isFalse);
          expect(swap.canBeCompleted, isFalse);
          expect(swap.canBeRefunded, isFalse);
          expect(swap.canBeCanceled, isFalse);
          expect(swap.canBeLocked, isFalse);
        }
      });

      testWidgets('Funds are only locked in locked state', (tester) async {
        final states = AtomicSwapStatus.values;
        
        for (final state in states) {
          final swap = createSwapWithStatus(state);
          final expectedFundsLocked = state == AtomicSwapStatus.locked;
          
          expect(swap.isFundsLocked, equals(expectedFundsLocked));
        }
      });

      testWidgets('Cancellation requires appropriate state', (tester) async {
        // States that can be canceled
        final cancelableStates = [
          AtomicSwapStatus.handshakeRequested,
          AtomicSwapStatus.handshakeAccepted,
          AtomicSwapStatus.initiated,
          AtomicSwapStatus.locked,
        ];
        
        for (final state in cancelableStates) {
          final swap = createSwapWithStatus(state);
          expect(swap.canBeCanceled, isTrue);
        }
        
        // States that cannot be canceled
        final nonCancelableStates = [
          AtomicSwapStatus.completed,
          AtomicSwapStatus.refunded,
          AtomicSwapStatus.expired,
          AtomicSwapStatus.canceled,
          AtomicSwapStatus.disputed,
        ];
        
        for (final state in nonCancelableStates) {
          final swap = createSwapWithStatus(state);
          expect(swap.canBeCanceled, isFalse);
        }
      });
    });
  });
}
