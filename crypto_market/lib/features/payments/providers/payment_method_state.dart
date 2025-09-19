part of 'payment_method_provider.dart';

/// Payment method status
enum PaymentMethodStatus { initial, loading, loaded, error }

/// Payment method state
class PaymentMethodState extends Equatable {
  final PaymentMethodStatus status;
  final List<PaymentMethod> paymentMethods;
  final String? selectedPaymentMethodId;
  final bool isLoading;
  final String? errorMessage;
  final PaymentValidationError? validationError;
  final bool isValid;

  const PaymentMethodState({
    this.status = PaymentMethodStatus.initial,
    this.paymentMethods = const [],
    this.selectedPaymentMethodId,
    this.isLoading = false,
    this.errorMessage,
    this.validationError,
    this.isValid = false,
  });

  const PaymentMethodState.initial()
    : status = PaymentMethodStatus.initial,
      paymentMethods = const [],
      selectedPaymentMethodId = null,
      isLoading = false,
      errorMessage = null,
      validationError = null,
      isValid = false;

  /// Create a copy of this state with updated fields
  PaymentMethodState copyWith({
    PaymentMethodStatus? status,
    List<PaymentMethod>? paymentMethods,
    String? selectedPaymentMethodId,
    bool? isLoading,
    String? errorMessage,
    PaymentValidationError? validationError,
    bool? isValid,
  }) {
    return PaymentMethodState(
      status: status ?? this.status,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethodId:
          selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      validationError: validationError ?? this.validationError,
      isValid: isValid ?? this.isValid,
    );
  }

  /// Get selected payment method
  PaymentMethod? get selectedPaymentMethod {
    if (selectedPaymentMethodId == null) return null;
    return paymentMethods.firstWhere(
      (method) => method.id == selectedPaymentMethodId,
      orElse: () => throw Exception('Selected payment method not found'),
    );
  }

  /// Check if there are any payment methods
  bool get hasPaymentMethods => paymentMethods.isNotEmpty;

  /// Get verified payment methods
  List<PaymentMethod> get verifiedPaymentMethods => paymentMethods
      .where(
        (method) => method.verificationStatus == VerificationStatus.verified,
      )
      .toList();

  /// Get payment methods by type
  List<PaymentMethod> getPaymentMethodsByType(PaymentMethodType type) =>
      paymentMethods.where((method) => method.type == type).toList();

  @override
  List<Object?> get props => [
    status,
    paymentMethods,
    selectedPaymentMethodId,
    isLoading,
    errorMessage,
    validationError,
    isValid,
  ];
}
