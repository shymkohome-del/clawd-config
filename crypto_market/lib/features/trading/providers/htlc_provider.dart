import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:crypto_market/core/error/domain_errors.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/trading/models/swap_contract.dart';
import 'package:crypto_market/features/trading/services/htlc_service.dart';

/// HTLC provider events
abstract class HTLCEvent extends Equatable {
  const HTLCEvent();

  @override
  List<Object?> get props => [];
}

class InitiateSwapRequested extends HTLCEvent {
  final String listingId;
  final CryptoType cryptoAsset;
  final BigInt amount;
  final BigInt priceInUsd;
  final int lockTimeHours;

  const InitiateSwapRequested({
    required this.listingId,
    required this.cryptoAsset,
    required this.amount,
    required this.priceInUsd,
    required this.lockTimeHours,
  });

  @override
  List<Object?> get props => [
    listingId,
    cryptoAsset,
    amount,
    priceInUsd,
    lockTimeHours,
  ];
}

class GetSwapRequested extends HTLCEvent {
  final String swapId;

  const GetSwapRequested({required this.swapId});

  @override
  List<Object?> get props => [swapId];
}

class GetUserSwapsRequested extends HTLCEvent {
  final String principal;

  const GetUserSwapsRequested({required this.principal});

  @override
  List<Object?> get props => [principal];
}

class RefreshSwapData extends HTLCEvent {
  final String swapId;

  const RefreshSwapData({required this.swapId});

  @override
  List<Object?> get props => [swapId];
}

class ResetHTLCState extends HTLCEvent {
  const ResetHTLCState();
}

/// HTLC provider states
abstract class HTLCState extends Equatable {
  const HTLCState();

  @override
  List<Object?> get props => [];
}

class HTLCInitial extends HTLCState {
  const HTLCInitial();
}

class HTLCLoading extends HTLCState {
  const HTLCLoading();
}

class HTLCInitiationSuccess extends HTLCState {
  final InitiateSwapResponse response;

  const HTLCInitiationSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class HTLCGetSwapSuccess extends HTLCState {
  final SwapContract swap;

  const HTLCGetSwapSuccess({required this.swap});

  @override
  List<Object?> get props => [swap];
}

class HTLCUserSwapsSuccess extends HTLCState {
  final List<SwapContract> swaps;

  const HTLCUserSwapsSuccess({required this.swaps});

  @override
  List<Object?> get props => [swaps];
}

class HTLCError extends HTLCState {
  final DomainError error;
  final String? swapId;

  const HTLCError({required this.error, this.swapId});

  @override
  List<Object?> get props => [error, swapId];
}

/// HTLC provider using BLoC pattern
class HTLCProvider extends Bloc<HTLCEvent, HTLCState> {
  final HTLCService _htlcService;
  final Logger _logger;

  HTLCProvider({required HTLCService htlcService, required Logger logger})
    : _htlcService = htlcService,
      _logger = logger,
      super(const HTLCInitial()) {
    on<InitiateSwapRequested>(_onInitiateSwapRequested);
    on<GetSwapRequested>(_onGetSwapRequested);
    on<GetUserSwapsRequested>(_onGetUserSwapsRequested);
    on<RefreshSwapData>(_onRefreshSwapData);
    on<ResetHTLCState>(_onResetHTLCState);
  }

  Future<void> _onInitiateSwapRequested(
    InitiateSwapRequested event,
    Emitter<HTLCState> emit,
  ) async {
    emit(const HTLCLoading());

    try {
      final result = await _htlcService.initiateSwap(
        listingId: event.listingId,
        cryptoAsset: event.cryptoAsset,
        amount: event.amount,
        priceInUsd: event.priceInUsd,
        lockTimeHours: event.lockTimeHours,
      );

      result.fold(
        (response) {
          _logger.logDebug(
            'Swap initiated successfully: ${response.contract.id}',
            tag: 'HTLCProvider',
          );
          emit(HTLCInitiationSuccess(response: response));
        },
        (error) {
          _logger.logError(
            'Failed to initiate swap',
            tag: 'HTLCProvider',
            error: error,
          );
          emit(HTLCError(error: error));
        },
      );
    } catch (error, stackTrace) {
      _logger.logError(
        'Unexpected error during swap initiation',
        tag: 'HTLCProvider',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        HTLCError(error: DomainError.operationError('Failed to initiate swap')),
      );
    }
  }

  Future<void> _onGetSwapRequested(
    GetSwapRequested event,
    Emitter<HTLCState> emit,
  ) async {
    emit(const HTLCLoading());

    try {
      final result = await _htlcService.getSwap(event.swapId);

      result.fold(
        (swap) {
          _logger.logDebug(
            'Swap retrieved successfully: ${swap.id}',
            tag: 'HTLCProvider',
          );
          emit(HTLCGetSwapSuccess(swap: swap));
        },
        (error) {
          _logger.logError(
            'Failed to get swap: ${event.swapId}',
            tag: 'HTLCProvider',
            error: error,
          );
          emit(HTLCError(error: error, swapId: event.swapId));
        },
      );
    } catch (error, stackTrace) {
      _logger.logError(
        'Unexpected error getting swap: ${event.swapId}',
        tag: 'HTLCProvider',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        HTLCError(
          error: DomainError.operationError('Failed to get swap'),
          swapId: event.swapId,
        ),
      );
    }
  }

  Future<void> _onGetUserSwapsRequested(
    GetUserSwapsRequested event,
    Emitter<HTLCState> emit,
  ) async {
    emit(const HTLCLoading());

    try {
      final result = await _htlcService.getUserSwaps(event.principal);

      result.fold(
        (swaps) {
          _logger.logDebug(
            'User swaps retrieved successfully: ${swaps.length} swaps',
            tag: 'HTLCProvider',
          );
          emit(HTLCUserSwapsSuccess(swaps: swaps));
        },
        (error) {
          _logger.logError(
            'Failed to get user swaps',
            tag: 'HTLCProvider',
            error: error,
          );
          emit(HTLCError(error: error));
        },
      );
    } catch (error, stackTrace) {
      _logger.logError(
        'Unexpected error getting user swaps',
        tag: 'HTLCProvider',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        HTLCError(
          error: DomainError.operationError('Failed to get user swaps'),
        ),
      );
    }
  }

  Future<void> _onRefreshSwapData(
    RefreshSwapData event,
    Emitter<HTLCState> emit,
  ) async {
    // Only refresh if we're currently showing a swap
    if (state is HTLCGetSwapSuccess) {
      final currentState = state as HTLCGetSwapSuccess;
      if (currentState.swap.id == event.swapId) {
        try {
          final result = await _htlcService.getSwap(event.swapId);

          result.fold(
            (swap) {
              _logger.logDebug(
                'Swap data refreshed successfully: ${swap.id}',
                tag: 'HTLCProvider',
              );
              emit(HTLCGetSwapSuccess(swap: swap));
            },
            (error) {
              _logger.logError(
                'Failed to refresh swap data: ${event.swapId}',
                tag: 'HTLCProvider',
                error: error,
              );
              // Don't emit error state on refresh failure, keep current state
            },
          );
        } catch (error, stackTrace) {
          _logger.logError(
            'Unexpected error refreshing swap data: ${event.swapId}',
            tag: 'HTLCProvider',
            error: error,
            stackTrace: stackTrace,
          );
          // Don't emit error state on refresh failure, keep current state
        }
      }
    }
  }

  void _onResetHTLCState(ResetHTLCState event, Emitter<HTLCState> emit) {
    emit(const HTLCInitial());
  }

  /// Get the current swap if available
  SwapContract? get currentSwap {
    if (state is HTLCGetSwapSuccess) {
      return (state as HTLCGetSwapSuccess).swap;
    }
    return null;
  }

  /// Get the current initiation response if available
  InitiateSwapResponse? get currentInitiationResponse {
    if (state is HTLCInitiationSuccess) {
      return (state as HTLCInitiationSuccess).response;
    }
    return null;
  }

  /// Get user swaps if available
  List<SwapContract>? get userSwaps {
    if (state is HTLCUserSwapsSuccess) {
      return (state as HTLCUserSwapsSuccess).swaps;
    }
    return null;
  }

  /// Check if the provider is in a loading state
  bool get isLoading => state is HTLCLoading;

  /// Check if the provider is in an error state
  bool get hasError => state is HTLCError;

  /// Get the current error if available
  DomainError? get currentError {
    if (state is HTLCError) {
      return (state as HTLCError).error;
    }
    return null;
  }
}
