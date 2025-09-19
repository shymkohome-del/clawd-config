import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:crypto_market/core/error/simple_result.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/payments/models/payment_method.dart';
import 'package:crypto_market/features/payments/services/payment_validation_service.dart';

part 'payment_method_state.dart';
part 'payment_method_event.dart';

/// BLoC provider for payment method management
class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final PaymentValidationService _validationService;
  final PaymentEncryptionService _encryptionService;

  PaymentMethodBloc({
    required PaymentValidationService validationService,
    required PaymentEncryptionService encryptionService,
  }) : _validationService = validationService,
       _encryptionService = encryptionService,
       super(const PaymentMethodState.initial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<AddPaymentMethod>(_onAddPaymentMethod);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
    on<ValidatePaymentMethod>(_onValidatePaymentMethod);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<ClearPaymentMethodError>(_onClearError);
  }

  /// Load user's payment methods
  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<PaymentMethodState> emit,
  ) async {
    try {
      Logger.instance.logDebug(
        'Loading payment methods for user: ${event.userId}',
        tag: 'PaymentMethodBloc',
      );

      emit(
        state.copyWith(status: PaymentMethodStatus.loading, isLoading: true),
      );

      // Simulate API call to load payment methods
      // In real implementation, this would call the ICP canister
      final paymentMethods = await _loadPaymentMethodsFromBackend(event.userId);

      emit(
        state.copyWith(
          status: PaymentMethodStatus.loaded,
          paymentMethods: paymentMethods,
          isLoading: false,
          errorMessage: null,
        ),
      );

      Logger.instance.logDebug(
        'Loaded ${paymentMethods.length} payment methods',
        tag: 'PaymentMethodBloc',
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to load payment methods',
        tag: 'PaymentMethodBloc',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: PaymentMethodStatus.error,
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Add new payment method
  Future<void> _onAddPaymentMethod(
    AddPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    try {
      Logger.instance.logDebug(
        'Adding payment method: ${event.type}',
        tag: 'PaymentMethodBloc',
      );

      emit(
        state.copyWith(status: PaymentMethodStatus.loading, isLoading: true),
      );

      // Validate payment method details
      final validationResult = _validatePaymentMethodDetails(event);
      if (validationResult.isErr()) {
        emit(
          state.copyWith(
            status: PaymentMethodStatus.error,
            isLoading: false,
            errorMessage: _validationService.getErrorMessage(
              validationResult.unwrapErr(),
              event.locale,
            ),
          ),
        );
        return;
      }

      // Encrypt payment method details
      final encryptedDetails = await _encryptPaymentMethodDetails(event);

      // Create payment method
      final paymentMethod = PaymentMethod(
        id: PaymentEncryptionService.generatePaymentMethodId(event.userId),
        userId: event.userId,
        type: event.type,
        encryptedDetails: encryptedDetails,
        displayName: _generateDisplayName(event),
        verificationStatus: VerificationStatus.pending,
        createdAt: DateTime.now(),
      );

      // Save to backend
      await _savePaymentMethodToBackend(paymentMethod);

      // Add to local state
      final updatedPaymentMethods = [...state.paymentMethods, paymentMethod];

      emit(
        state.copyWith(
          status: PaymentMethodStatus.loaded,
          paymentMethods: updatedPaymentMethods,
          isLoading: false,
          errorMessage: null,
        ),
      );

      Logger.instance.logDebug(
        'Payment method added successfully: ${paymentMethod.id}',
        tag: 'PaymentMethodBloc',
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to add payment method',
        tag: 'PaymentMethodBloc',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: PaymentMethodStatus.error,
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Update existing payment method
  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    try {
      Logger.instance.logDebug(
        'Updating payment method: ${event.paymentMethodId}',
        tag: 'PaymentMethodBloc',
      );

      emit(
        state.copyWith(status: PaymentMethodStatus.loading, isLoading: true),
      );

      // Find payment method
      final existingMethod = state.paymentMethods.firstWhere(
        (method) => method.id == event.paymentMethodId,
        orElse: () => throw Exception('Payment method not found'),
      );

      // Validate new details
      final validationResult = _validatePaymentMethodDetails(event);
      if (validationResult.isErr()) {
        emit(
          state.copyWith(
            status: PaymentMethodStatus.error,
            isLoading: false,
            errorMessage: _validationService.getErrorMessage(
              validationResult.unwrapErr(),
              event.locale,
            ),
          ),
        );
        return;
      }

      // Encrypt new details
      final encryptedDetails = await _encryptPaymentMethodDetails(event);

      // Update payment method
      final updatedMethod = existingMethod.copyWith(
        encryptedDetails: encryptedDetails,
        displayName: _generateDisplayName(event),
        verificationStatus:
            VerificationStatus.pending, // Reset verification status
      );

      // Update in backend
      await _updatePaymentMethodInBackend(updatedMethod);

      // Update local state
      final updatedPaymentMethods = state.paymentMethods
          .map(
            (method) =>
                method.id == event.paymentMethodId ? updatedMethod : method,
          )
          .toList();

      emit(
        state.copyWith(
          status: PaymentMethodStatus.loaded,
          paymentMethods: updatedPaymentMethods,
          isLoading: false,
          errorMessage: null,
        ),
      );

      Logger.instance.logDebug(
        'Payment method updated successfully: ${updatedMethod.id}',
        tag: 'PaymentMethodBloc',
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to update payment method',
        tag: 'PaymentMethodBloc',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: PaymentMethodStatus.error,
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Delete payment method
  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    try {
      Logger.instance.logDebug(
        'Deleting payment method: ${event.paymentMethodId}',
        tag: 'PaymentMethodBloc',
      );

      emit(
        state.copyWith(status: PaymentMethodStatus.loading, isLoading: true),
      );

      // Delete from backend
      await _deletePaymentMethodFromBackend(event.paymentMethodId);

      // Remove from local state
      final updatedPaymentMethods = state.paymentMethods
          .where((method) => method.id != event.paymentMethodId)
          .toList();

      emit(
        state.copyWith(
          status: PaymentMethodStatus.loaded,
          paymentMethods: updatedPaymentMethods,
          isLoading: false,
          errorMessage: null,
        ),
      );

      Logger.instance.logDebug(
        'Payment method deleted successfully: ${event.paymentMethodId}',
        tag: 'PaymentMethodBloc',
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to delete payment method',
        tag: 'PaymentMethodBloc',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: PaymentMethodStatus.error,
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Validate payment method details
  void _onValidatePaymentMethod(
    ValidatePaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) {
    try {
      Logger.instance.logDebug(
        'Validating payment method: ${event.type}',
        tag: 'PaymentMethodBloc',
      );

      final validationResult = _validatePaymentMethodDetails(event);

      emit(
        state.copyWith(
          validationError: validationResult.isErr()
              ? validationResult.unwrapErr()
              : null,
          isValid: validationResult.isOk(),
        ),
      );

      if (validationResult.isErr()) {
        emit(
          state.copyWith(
            errorMessage: _validationService.getErrorMessage(
              validationResult.unwrapErr(),
              event.locale,
            ),
          ),
        );
      }

      Logger.instance.logDebug(
        'Payment method validation ${validationResult.isOk() ? 'passed' : 'failed'}',
        tag: 'PaymentMethodBloc',
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to validate payment method',
        tag: 'PaymentMethodBloc',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          validationError: PaymentValidationError.formatError,
          isValid: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Select payment method
  void _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) {
    Logger.instance.logDebug(
      'Selecting payment method: ${event.paymentMethodId}',
      tag: 'PaymentMethodBloc',
    );

    emit(state.copyWith(selectedPaymentMethodId: event.paymentMethodId));
  }

  /// Clear error state
  void _onClearError(
    ClearPaymentMethodError event,
    Emitter<PaymentMethodState> emit,
  ) {
    emit(state.copyWith(errorMessage: null, validationError: null));
  }

  // Helper methods

  Result<bool, PaymentValidationError> _validatePaymentMethodDetails(
    dynamic event,
  ) {
    switch (event.type) {
      case PaymentMethodType.bankTransfer:
        return _validationService.validateBankTransfer(
          accountNumber: event.accountNumber,
          routingNumber: event.routingNumber,
          accountHolderName: event.accountHolderName,
          bankName: event.bankName,
          swiftCode: event.swiftCode,
          iban: event.iban,
        );

      case PaymentMethodType.digitalWallet:
        return _validationService.validateDigitalWallet(
          walletId: event.walletId,
          provider: event.provider,
          email: event.email,
          phoneNumber: event.phoneNumber,
          accountName: event.accountName,
        );

      case PaymentMethodType.cash:
        return _validationService.validateCashPayment(
          meetingLocation: event.meetingLocation,
          preferredTime: event.preferredTime,
          contactInfo: event.contactInfo,
          specialInstructions: event.specialInstructions,
        );

      default:
        return Result.err(PaymentValidationError.formatError);
    }
  }

  Future<String> _encryptPaymentMethodDetails(dynamic event) async {
    Map<String, dynamic> details;

    switch (event.type) {
      case PaymentMethodType.bankTransfer:
        details = {
          'accountNumber': event.accountNumber,
          'routingNumber': event.routingNumber,
          'accountHolderName': event.accountHolderName,
          'bankName': event.bankName,
          'swiftCode': event.swiftCode,
          'iban': event.iban,
        };

      case PaymentMethodType.digitalWallet:
        details = {
          'walletId': event.walletId,
          'provider': event.provider,
          'email': event.email,
          'phoneNumber': event.phoneNumber,
          'accountName': event.accountName,
        };

      case PaymentMethodType.cash:
        details = {
          'meetingLocation': event.meetingLocation,
          'preferredTime': event.preferredTime,
          'contactInfo': event.contactInfo,
          'specialInstructions': event.specialInstructions,
        };

      default:
        throw Exception('Unsupported payment method type');
    }

    return await _encryptionService.encryptPaymentDetails(details);
  }

  String _generateDisplayName(dynamic event) {
    switch (event.type) {
      case PaymentMethodType.bankTransfer:
        return '${event.bankName} • ${event.accountNumber.substring(event.accountNumber.length - 4)}';

      case PaymentMethodType.digitalWallet:
        return '${event.provider} • ${event.walletId.substring(event.walletId.length - 4)}';

      case PaymentMethodType.cash:
        return 'Cash • ${event.meetingLocation.substring(0, 10)}...';

      default:
        return 'Unknown Payment Method';
    }
  }

  // Backend simulation methods (replace with actual ICP canister calls)

  Future<List<PaymentMethod>> _loadPaymentMethodsFromBackend(
    String userId,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data for now
    return [];
  }

  Future<void> _savePaymentMethodToBackend(PaymentMethod paymentMethod) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _updatePaymentMethodInBackend(
    PaymentMethod paymentMethod,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _deletePaymentMethodFromBackend(String paymentMethodId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
