import 'dart:async';
import 'dart:io';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/error/simple_result.dart';
import 'package:crypto_market/features/payments/models/payment_method.dart';
import 'package:crypto_market/features/payments/services/ipfs_service.dart';
import 'package:crypto_market/features/market/models/atomic_swap.dart';

/// Payment service for integrating payment methods with atomic swap flow
class PaymentService {
  final IpfsService _ipfsService;

  PaymentService({required IpfsService ipfsService})
    : _ipfsService = ipfsService;

  /// Get payment instructions for a swap
  Future<Result<PaymentInstructions, PaymentError>> getPaymentInstructions({
    required AtomicSwap swap,
    required PaymentMethod paymentMethod,
    required String locale,
  }) async {
    try {
      Logger.instance.logDebug(
        'Getting payment instructions for swap: ${swap.id}',
        tag: 'PaymentService',
      );

      // Check if swap is in correct state
      if (swap.status != AtomicSwapStatus.pending) {
        Logger.instance.logWarn(
          'Swap is not in pending state: ${swap.status}',
          tag: 'PaymentService',
        );
        return Result.err(PaymentError.invalidSwapState);
      }

      // Generate payment instructions based on payment method type
      final instructions = await _generatePaymentInstructions(
        swap: swap,
        paymentMethod: paymentMethod,
        locale: locale,
      );

      Logger.instance.logDebug(
        'Payment instructions generated successfully',
        tag: 'PaymentService',
      );

      return Result.ok(instructions);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to get payment instructions',
        tag: 'PaymentService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(PaymentError.serviceError);
    }
  }

  /// Submit payment proof for a swap
  Future<Result<bool, PaymentError>> submitPaymentProof({
    required String swapId,
    required String paymentMethodId,
    required File proofFile,
    required PaymentProofType proofType,
    required String userId,
    String? transactionId,
    String? notes,
  }) async {
    try {
      Logger.instance.logDebug(
        'Submitting payment proof for swap: $swapId',
        tag: 'PaymentService',
      );

      // Upload proof to IPFS
      final ipfsResult = await _ipfsService.uploadPaymentProof(
        imageFile: proofFile,
        swapId: swapId,
        paymentMethodId: paymentMethodId,
        userId: userId,
      );

      if (ipfsResult.isErr()) {
        Logger.instance.logError(
          'Failed to upload payment proof to IPFS',
          tag: 'PaymentService',
        );
        return Result.err(PaymentError.ipfsUploadFailed);
      }

      final ipfsHash = ipfsResult.unwrap();

      // Create payment proof
      final paymentProof = PaymentProof(
        id: PaymentEncryptionService.generatePaymentProofId(swapId),
        swapId: swapId,
        paymentMethodId: paymentMethodId,
        proofType: proofType,
        ipfsHash: ipfsHash,
        submittedBy: userId,
        submittedAt: DateTime.now(),
      );

      // Submit to backend
      await _submitPaymentProofToBackend(paymentProof);

      Logger.instance.logDebug(
        'Payment proof submitted successfully',
        tag: 'PaymentService',
      );

      return Result.ok(true);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to submit payment proof',
        tag: 'PaymentService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(PaymentError.submissionFailed);
    }
  }

  /// Verify payment proof (seller side)
  Future<Result<bool, PaymentError>> verifyPaymentProof({
    required String swapId,
    required String paymentProofId,
    required String userId,
    required bool isApproved,
    String? verificationNotes,
  }) async {
    try {
      Logger.instance.logDebug(
        'Verifying payment proof for swap: $swapId',
        tag: 'PaymentService',
      );

      // Update payment proof in backend
      await _verifyPaymentProofInBackend(
        swapId: swapId,
        paymentProofId: paymentProofId,
        userId: userId,
        isApproved: isApproved,
        verificationNotes: verificationNotes,
      );

      Logger.instance.logDebug(
        'Payment proof verified successfully: ${isApproved ? 'approved' : 'rejected'}',
        tag: 'PaymentService',
      );

      return Result.ok(true);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to verify payment proof',
        tag: 'PaymentService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(PaymentError.verificationFailed);
    }
  }

  /// Get payment proof status for a swap
  Future<Result<PaymentProofStatus, PaymentError>> getPaymentProofStatus({
    required String swapId,
  }) async {
    try {
      Logger.instance.logDebug(
        'Getting payment proof status for swap: $swapId',
        tag: 'PaymentService',
      );

      // Get payment proof from backend
      final paymentProof = await _getPaymentProofFromBackend(swapId);

      if (paymentProof == null) {
        Logger.instance.logDebug(
          'No payment proof found for swap: $swapId',
          tag: 'PaymentService',
        );
        return Result.ok(const PaymentProofStatus.notSubmitted());
      }

      final status = PaymentProofStatus(
        isSubmitted: true,
        isVerified: paymentProof.verifiedAt != null,
        isApproved:
            paymentProof.verifiedAt !=
            null, // For now, assume verified = approved
        submittedAt: paymentProof.submittedAt,
        verifiedAt: paymentProof.verifiedAt,
        proofType: paymentProof.proofType,
        ipfsHash: paymentProof.ipfsHash,
      );

      Logger.instance.logDebug(
        'Payment proof status retrieved: ${status.isSubmitted ? 'submitted' : 'not submitted'}',
        tag: 'PaymentService',
      );

      return Result.ok(status);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to get payment proof status',
        tag: 'PaymentService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(PaymentError.serviceError);
    }
  }

  /// Get available payment methods for a user
  Future<Result<List<PaymentMethod>, PaymentError>> getAvailablePaymentMethods({
    required String userId,
    PaymentMethodType? typeFilter,
  }) async {
    try {
      Logger.instance.logDebug(
        'Getting available payment methods for user: $userId',
        tag: 'PaymentService',
      );

      // Get payment methods from backend
      final paymentMethods = await _getPaymentMethodsFromBackend(userId);

      // Apply filter if specified
      var filteredMethods = paymentMethods;
      if (typeFilter != null) {
        filteredMethods = paymentMethods
            .where((method) => method.type == typeFilter)
            .toList();
      }

      // Only return verified methods
      final verifiedMethods = filteredMethods
          .where(
            (method) =>
                method.verificationStatus == VerificationStatus.verified,
          )
          .toList();

      Logger.instance.logDebug(
        'Retrieved ${verifiedMethods.length} available payment methods',
        tag: 'PaymentService',
      );

      return Result.ok(verifiedMethods);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to get available payment methods',
        tag: 'PaymentService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(PaymentError.serviceError);
    }
  }

  /// Get payment timeout for a swap
  Duration getPaymentTimeout(AtomicSwap swap) {
    // Payment should be completed within 80% of the swap timeout
    final paymentTimeout = swap.remainingTime * 0.8;
    return paymentTimeout > Duration.zero ? paymentTimeout : Duration.zero;
  }

  /// Check if payment can be made for a swap
  bool canMakePayment(AtomicSwap swap) {
    return swap.status == AtomicSwapStatus.pending && !swap.isExpired;
  }

  /// Generate payment instructions based on payment method type
  Future<PaymentInstructions> _generatePaymentInstructions({
    required AtomicSwap swap,
    required PaymentMethod paymentMethod,
    required String locale,
  }) async {
    final timeout = getPaymentTimeout(swap);
    final amount = swap.amount.toString();

    switch (paymentMethod.type) {
      case PaymentMethodType.bankTransfer:
        return PaymentInstructions(
          swapId: swap.id.toString(),
          paymentMethodType: paymentMethod.type,
          amount: amount,
          currency: swap.cryptoType,
          timeout: timeout,
          instructions: _getBankTransferInstructions(locale),
          steps: _getBankTransferSteps(locale),
          securityNote: _getBankTransferSecurityNote(locale),
        );

      case PaymentMethodType.digitalWallet:
        return PaymentInstructions(
          swapId: swap.id.toString(),
          paymentMethodType: paymentMethod.type,
          amount: amount,
          currency: swap.cryptoType,
          timeout: timeout,
          instructions: _getDigitalWalletInstructions(locale),
          steps: _getDigitalWalletSteps(locale),
          securityNote: _getDigitalWalletSecurityNote(locale),
        );

      case PaymentMethodType.cash:
        return PaymentInstructions(
          swapId: swap.id.toString(),
          paymentMethodType: paymentMethod.type,
          amount: amount,
          currency: swap.cryptoType,
          timeout: timeout,
          instructions: _getCashPaymentInstructions(locale),
          steps: _getCashPaymentSteps(locale),
          securityNote: _getCashPaymentSecurityNote(locale),
        );
    }
  }

  // Helper methods for generating localized instructions

  String _getBankTransferInstructions(String locale) {
    return locale == 'lv'
        ? 'Lūdzu, veiciet bankas pārskaitījumu uz norādīto kontu. Saglabājiet transakcijas apliecinājumu.'
        : 'Please make a bank transfer to the specified account. Keep the transaction confirmation.';
  }

  List<String> _getBankTransferSteps(String locale) {
    return locale == 'lv'
        ? [
            '1. Piesakieties savā bankas sistēmā',
            '2. Veiciet pārskaitījumu uz norādīto kontu',
            '3. Saglabājiet transakcijas ID vai apliecinājumu',
            '4. Augšupielādējiet maksājuma apliecinājumu',
          ]
        : [
            '1. Log in to your banking system',
            '2. Make the transfer to the specified account',
            '3. Save the transaction ID or confirmation',
            '4. Upload the payment proof',
          ];
  }

  String _getBankTransferSecurityNote(String locale) {
    return locale == 'lv'
        ? 'Nekādā gadījuma nedalieties ar saviem bankas datiem. Maksājums tiks apstrādāts droši.'
        : 'Never share your banking details. The payment will be processed securely.';
  }

  String _getDigitalWalletInstructions(String locale) {
    return locale == 'lv'
        ? 'Lūdzu, veiciet maksājumu, izmantojot norādīto digitālo maciņu. Saglabājiet transakcijas apliecinājumu.'
        : 'Please make the payment using the specified digital wallet. Keep the transaction confirmation.';
  }

  List<String> _getDigitalWalletSteps(String locale) {
    return locale == 'lv'
        ? [
            '1. Atveriet savu digitālo maciņu',
            '2. Veiciet maksājumu uz norādīto ID',
            '3. Saglabājiet transakcijas ID',
            '4. Augšupielādējiet maksājuma apliecinājumu',
          ]
        : [
            '1. Open your digital wallet',
            '2. Make the payment to the specified ID',
            '3. Save the transaction ID',
            '4. Upload the payment proof',
          ];
  }

  String _getDigitalWalletSecurityNote(String locale) {
    return locale == 'lv'
        ? 'Pārliecinieties, ka maksājat uz pareizo ID. Maksājumi ir neatgriežami.'
        : 'Ensure you are paying to the correct ID. Payments are irreversible.';
  }

  String _getCashPaymentInstructions(String locale) {
    return locale == 'lv'
        ? 'Lūdzu, tikstieties ar pārdevēju norādītajā vietā un laikā, lai veiktu skaidras naudas maksājumu.'
        : 'Please meet the seller at the specified location and time to make the cash payment.';
  }

  List<String> _getCashPaymentSteps(String locale) {
    return locale == 'lv'
        ? [
            '1. Sazinieties ar pārdevēju, lai apstiprinātu tikšanās vietu un laiku',
            '2. Tikstieties norādītajā vietā',
            '3. Veiciet skaidras naudas maksājumu',
            '4. Saņemiet maksājuma apliecinājumu',
          ]
        : [
            '1. Contact the seller to confirm meeting location and time',
            '2. Meet at the specified location',
            '3. Make the cash payment',
            '4. Receive payment confirmation',
          ];
  }

  String _getCashPaymentSecurityNote(String locale) {
    return locale == 'lv'
        ? 'Tikšanās notiek uz jūsu atbildību. Vienmēr tikieties publiskās vietās.'
        : 'Meeting is at your own risk. Always meet in public places.';
  }

  // Backend simulation methods (replace with actual ICP canister calls)

  Future<void> _submitPaymentProofToBackend(PaymentProof paymentProof) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _verifyPaymentProofInBackend({
    required String swapId,
    required String paymentProofId,
    required String userId,
    required bool isApproved,
    String? verificationNotes,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<PaymentProof?> _getPaymentProofFromBackend(String swapId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 200));
    return null; // Return null for now
  }

  Future<List<PaymentMethod>> _getPaymentMethodsFromBackend(
    String userId,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    return []; // Return empty list for now
  }
}

/// Payment instructions for atomic swap
class PaymentInstructions {
  final String swapId;
  final PaymentMethodType paymentMethodType;
  final String amount;
  final String currency;
  final Duration timeout;
  final String instructions;
  final List<String> steps;
  final String securityNote;

  const PaymentInstructions({
    required this.swapId,
    required this.paymentMethodType,
    required this.amount,
    required this.currency,
    required this.timeout,
    required this.instructions,
    required this.steps,
    required this.securityNote,
  });

  /// Create a copy of this payment instructions with updated fields
  PaymentInstructions copyWith({
    String? swapId,
    PaymentMethodType? paymentMethodType,
    String? amount,
    String? currency,
    Duration? timeout,
    String? instructions,
    List<String>? steps,
    String? securityNote,
  }) {
    return PaymentInstructions(
      swapId: swapId ?? this.swapId,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      timeout: timeout ?? this.timeout,
      instructions: instructions ?? this.instructions,
      steps: steps ?? this.steps,
      securityNote: securityNote ?? this.securityNote,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentInstructions) return false;
    return swapId == other.swapId &&
        paymentMethodType == other.paymentMethodType &&
        amount == other.amount &&
        currency == other.currency &&
        timeout == other.timeout &&
        instructions == other.instructions &&
        steps.toString() == other.steps.toString() &&
        securityNote == other.securityNote;
  }

  @override
  int get hashCode {
    return Object.hash(
      swapId,
      paymentMethodType,
      amount,
      currency,
      timeout,
      instructions,
      steps,
      securityNote,
    );
  }
}

/// Payment proof status
class PaymentProofStatus {
  final bool isSubmitted;
  final bool isVerified;
  final bool isApproved;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final PaymentProofType? proofType;
  final String? ipfsHash;

  const PaymentProofStatus({
    required this.isSubmitted,
    required this.isVerified,
    required this.isApproved,
    this.submittedAt,
    this.verifiedAt,
    this.proofType,
    this.ipfsHash,
  });

  const PaymentProofStatus.notSubmitted()
    : isSubmitted = false,
      isVerified = false,
      isApproved = false,
      submittedAt = null,
      verifiedAt = null,
      proofType = null,
      ipfsHash = null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentProofStatus) return false;
    return isSubmitted == other.isSubmitted &&
        isVerified == other.isVerified &&
        isApproved == other.isApproved &&
        submittedAt == other.submittedAt &&
        verifiedAt == other.verifiedAt &&
        proofType == other.proofType &&
        ipfsHash == other.ipfsHash;
  }

  @override
  int get hashCode {
    return Object.hash(
      isSubmitted,
      isVerified,
      isApproved,
      submittedAt,
      verifiedAt,
      proofType,
      ipfsHash,
    );
  }
}

/// Payment service errors
enum PaymentError {
  invalidSwapState,
  ipfsUploadFailed,
  submissionFailed,
  verificationFailed,
  serviceError,
}
