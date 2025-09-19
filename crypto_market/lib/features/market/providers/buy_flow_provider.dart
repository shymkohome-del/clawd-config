import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:bloc/bloc.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/blockchain/price_oracle_service.dart';
import 'package:crypto_market/core/blockchain/atomic_swap_service.dart';
import 'package:crypto_market/core/services/notification_service.dart';
import 'package:crypto_market/features/market/models/atomic_swap.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/models/price_conversion.dart';
import 'package:equatable/equatable.dart';

part 'buy_flow_state.dart';

/// Manages the complete buy flow state from price conversion to swap creation
class BuyFlowProvider extends Cubit<BuyFlowState> {
  BuyFlowProvider({
    required PriceOracleService priceOracleService,
    required AtomicSwapService atomicSwapService,
    required NotificationService notificationService,
  }) : _priceOracleService = priceOracleService,
       _atomicSwapService = atomicSwapService,
       _notificationService = notificationService,
       super(const BuyFlowState());

  final PriceOracleService _priceOracleService;
  final AtomicSwapService _atomicSwapService;
  final NotificationService _notificationService;

  /// Initialize the buy flow with a listing
  Future<void> initializeBuyFlow(Listing listing) async {
    if (state.status == BuyFlowStatus.loading) return;

    Logger.instance.logDebug(
      'Initializing buy flow for listing: ${listing.id}',
      tag: 'BuyFlowProvider',
    );

    emit(
      state.copyWith(
        status: BuyFlowStatus.loading,
        currentStep: BuyFlowStep.price,
        listing: listing,
        errorMessage: null,
      ),
    );

    try {
      // Load price conversion
      final conversionResult = await _priceOracleService.getConversionAmount(
        listing.priceUSD.toDouble(),
        listing.cryptoType,
      );

      if (conversionResult.isErr) {
        Logger.instance.logWarn(
          'Failed to get price conversion: ${conversionResult.err}',
          tag: 'BuyFlowProvider',
        );
        emit(
          state.copyWith(
            status: BuyFlowStatus.error,
            errorMessage: _mapConversionError(conversionResult.err),
          ),
        );
        return;
      }

      final conversion = conversionResult.ok;

      Logger.instance.logDebug(
        'Price conversion loaded: ${conversion.cryptoAmount} ${conversion.cryptoType}',
        tag: 'BuyFlowProvider',
      );

      emit(
        state.copyWith(
          status: BuyFlowStatus.ready,
          priceConversion: conversion,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to initialize buy flow',
        tag: 'BuyFlowProvider',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: BuyFlowStatus.error,
          errorMessage: 'Failed to initialize purchase flow',
        ),
      );
    }
  }

  /// Proceed to the next step in the buy flow
  void nextStep() {
    if (state.status != BuyFlowStatus.ready) return;

    final currentStep = state.currentStep;
    BuyFlowStep nextStep;

    switch (currentStep) {
      case BuyFlowStep.price:
        nextStep = BuyFlowStep.confirm;
        break;
      case BuyFlowStep.confirm:
        nextStep = BuyFlowStep.payment;
        break;
      case BuyFlowStep.payment:
        nextStep = BuyFlowStep.completion;
        break;
      case BuyFlowStep.completion:
        // Already at completion, no next step
        return;
    }

    Logger.instance.logDebug(
      'Moving to next step: $nextStep',
      tag: 'BuyFlowProvider',
    );

    emit(state.copyWith(currentStep: nextStep));
  }

  /// Go back to the previous step
  void previousStep() {
    if (state.status != BuyFlowStatus.ready) return;

    final currentStep = state.currentStep;
    BuyFlowStep previousStep;

    switch (currentStep) {
      case BuyFlowStep.confirm:
        previousStep = BuyFlowStep.price;
        break;
      case BuyFlowStep.payment:
        previousStep = BuyFlowStep.confirm;
        break;
      case BuyFlowStep.completion:
        previousStep = BuyFlowStep.payment;
        break;
      case BuyFlowStep.price:
        // Already at price step, can't go back
        return;
    }

    Logger.instance.logDebug(
      'Moving to previous step: $previousStep',
      tag: 'BuyFlowProvider',
    );

    emit(state.copyWith(currentStep: previousStep));
  }

  /// Refresh price conversion
  Future<void> refreshPriceConversion() async {
    if (state.listing == null || state.status == BuyFlowStatus.loading) return;

    Logger.instance.logDebug(
      'Refreshing price conversion',
      tag: 'BuyFlowProvider',
    );

    emit(state.copyWith(status: BuyFlowStatus.loading));

    try {
      final conversionResult = await _priceOracleService.getConversionAmount(
        state.listing!.priceUSD.toDouble(),
        state.listing!.cryptoType,
      );

      if (conversionResult.isErr) {
        emit(
          state.copyWith(
            status: BuyFlowStatus.error,
            errorMessage: _mapConversionError(conversionResult.err),
          ),
        );
        return;
      }

      final conversion = conversionResult.ok;

      Logger.instance.logDebug(
        'Price conversion refreshed: ${conversion.cryptoAmount} ${conversion.cryptoType}',
        tag: 'BuyFlowProvider',
      );

      emit(
        state.copyWith(
          status: BuyFlowStatus.ready,
          priceConversion: conversion,
        ),
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to refresh price conversion',
        tag: 'BuyFlowProvider',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: BuyFlowStatus.error,
          errorMessage: 'Failed to refresh price conversion',
        ),
      );
    }
  }

  /// Confirm purchase and initiate atomic swap
  Future<void> confirmPurchase() async {
    if (state.listing == null ||
        state.priceConversion == null ||
        state.status != BuyFlowStatus.ready) {
      return;
    }

    Logger.instance.logDebug(
      'Confirming purchase for listing: ${state.listing!.id}',
      tag: 'BuyFlowProvider',
    );

    emit(state.copyWith(status: BuyFlowStatus.loading));

    try {
      // Generate secure secret for atomic swap
      final secretResult = await _atomicSwapService.generateSecureSecret();
      if (secretResult.isErr) {
        emit(
          state.copyWith(
            status: BuyFlowStatus.error,
            errorMessage: 'Failed to generate secure secret',
          ),
        );
        return;
      }

      final secret = secretResult.ok;
      final secretHash = _generateSecretHash(secret);

      Logger.instance.logDebug(
        'Generated secret and hash for atomic swap',
        tag: 'BuyFlowProvider',
      );

      // Initiate atomic swap
      final swapResult = await _atomicSwapService.initiateSwap(
        listingId: int.parse(state.listing!.id),
        secretHash: secretHash,
        amount: BigInt.from(state.priceConversion!.cryptoAmount),
        cryptoType: state.listing!.cryptoType,
        timeout: BigInt.from(
          const Duration(hours: 24).inMilliseconds,
        ), // 24 hour timeout
      );

      if (swapResult.isErr) {
        emit(
          state.copyWith(
            status: BuyFlowStatus.error,
            errorMessage: _mapSwapError(swapResult.err),
          ),
        );
        return;
      }

      final atomicSwap = swapResult.ok;

      Logger.instance.logDebug(
        'Atomic swap initiated with ID: ${atomicSwap.id}',
        tag: 'BuyFlowProvider',
      );

      // Send notification to seller
      await _notificationService.sendSwapCreatedNotification(
        swapId: atomicSwap.id,
        sellerId: atomicSwap.seller,
        listingTitle: state.listing!.title,
        amount: atomicSwap.amount,
        cryptoType: atomicSwap.cryptoType,
      );

      // Store the secret securely for later use
      await _atomicSwapService.storeSwapSecret(
        swapId: atomicSwap.id,
        secret: secret,
      );

      emit(
        state.copyWith(
          status: BuyFlowStatus.completed,
          atomicSwap: atomicSwap,
          secret: secret,
          currentStep: BuyFlowStep.completion,
        ),
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to confirm purchase',
        tag: 'BuyFlowProvider',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: BuyFlowStatus.error,
          errorMessage: 'Failed to confirm purchase',
        ),
      );
    }
  }

  /// Reset the buy flow to initial state
  void reset() {
    Logger.instance.logDebug('Resetting buy flow', tag: 'BuyFlowProvider');

    emit(const BuyFlowState());
  }

  /// Update the buy flow state (for persistence handling)
  void updateState(BuyFlowState newState) {
    emit(newState);
  }

  /// Map conversion error to user-friendly message
  String _mapConversionError(PriceConversionError error) {
    switch (error) {
      case PriceConversionError.oracleUnavailable:
        return 'Price oracle is currently unavailable';
      case PriceConversionError.invalidCryptoType:
        return 'Invalid cryptocurrency type';
      case PriceConversionError.priceTooStale:
        return 'Price data is too stale, please refresh';
      case PriceConversionError.conversionFailed:
        return 'Failed to convert price';
      case PriceConversionError.networkError:
        return 'Network error, please check your connection';
    }
  }

  /// Map swap error to user-friendly message
  String _mapSwapError(SwapError error) {
    switch (error) {
      case SwapError.invalidListing:
        return 'Invalid listing';
      case SwapError.insufficientBalance:
        return 'Insufficient balance';
      case SwapError.swapAlreadyExists:
        return 'Swap already exists for this listing';
      case SwapError.networkError:
        return 'Network error, please try again';
      case SwapError.timeoutError:
        return 'Operation timed out';
      case SwapError.invalidSecret:
        return 'Invalid secret provided';
      case SwapError.invalidTimeout:
        return 'Invalid timeout value';
    }
  }

  /// Generate SHA-256 hash from secret
  List<int> _generateSecretHash(Uint8List secret) {
    final hash = sha256.convert(secret);
    return hash.bytes.toList();
  }
}
