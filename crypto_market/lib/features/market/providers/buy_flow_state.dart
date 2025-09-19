part of 'buy_flow_provider.dart';

/// Buy flow steps
enum BuyFlowStep { price, confirm, payment, completion }

/// Buy flow status
enum BuyFlowStatus { initial, loading, ready, error, completed }

/// Complete buy flow state
class BuyFlowState extends Equatable {
  const BuyFlowState({
    this.status = BuyFlowStatus.initial,
    this.currentStep = BuyFlowStep.price,
    this.listing,
    this.priceConversion,
    this.atomicSwap,
    this.secret,
    this.errorMessage,
  });

  final BuyFlowStatus status;
  final BuyFlowStep currentStep;
  final Listing? listing;
  final PriceConversionResponse? priceConversion;
  final AtomicSwap? atomicSwap;
  final Uint8List? secret;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    status,
    currentStep,
    listing,
    priceConversion,
    atomicSwap,
    secret,
    errorMessage,
  ];

  BuyFlowState copyWith({
    BuyFlowStatus? status,
    BuyFlowStep? currentStep,
    Listing? listing,
    PriceConversionResponse? priceConversion,
    AtomicSwap? atomicSwap,
    Uint8List? secret,
    String? errorMessage,
  }) {
    return BuyFlowState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      listing: listing ?? this.listing,
      priceConversion: priceConversion ?? this.priceConversion,
      atomicSwap: atomicSwap ?? this.atomicSwap,
      secret: secret ?? this.secret,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if the current step can proceed to next
  bool get canProceed {
    switch (currentStep) {
      case BuyFlowStep.price:
        return priceConversion != null && !priceConversion!.isStale;
      case BuyFlowStep.confirm:
        return true;
      case BuyFlowStep.payment:
        return true;
      case BuyFlowStep.completion:
        return atomicSwap != null;
    }
  }

  /// Check if the current step can go back
  bool get canGoBack {
    switch (currentStep) {
      case BuyFlowStep.price:
        return false;
      case BuyFlowStep.confirm:
      case BuyFlowStep.payment:
      case BuyFlowStep.completion:
        return true;
    }
  }

  /// Get the progress percentage (0.0 to 1.0)
  double get progress {
    switch (currentStep) {
      case BuyFlowStep.price:
        return 0.25;
      case BuyFlowStep.confirm:
        return 0.5;
      case BuyFlowStep.payment:
        return 0.75;
      case BuyFlowStep.completion:
        return 1.0;
    }
  }

  /// Check if the flow is completed
  bool get isCompleted => status == BuyFlowStatus.completed;

  /// Check if there's an error
  bool get hasError => status == BuyFlowStatus.error;
}
