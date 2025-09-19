import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:crypto_market/core/blockchain/atomic_swap_service.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/price_oracle_service.dart';
import 'package:crypto_market/core/error/domain_errors.dart';
import 'package:crypto_market/core/error/result.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/trading/models/swap_contract.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';

/// Service for handling HTLC (Hashed Timelock Contract) operations
class HTLCService {
  final AtomicSwapService _atomicSwapService;
  final ICPService _icpService;
  final PriceOracleService _priceOracleService;
  final Logger _logger;

  HTLCService({
    required AtomicSwapService atomicSwapService,
    required ICPService icpService,
    required PriceOracleService priceOracleService,
    required Logger logger,
  }) : _atomicSwapService = atomicSwapService,
       _icpService = icpService,
       _priceOracleService = priceOracleService,
       _logger = logger;

  /// Generate a cryptographically secure random secret
  String generateSecureSecret() {
    final random = FortunaRandom();
    random.seed(
      KeyParameter(
        Uint8List.fromList(List.generate(32, (i) => Random().nextInt(256))),
      ),
    );

    final secretBytes = Uint8List(32);
    random.nextBytes(secretBytes);

    return secretBytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join('');
  }

  /// Create SHA-256 hash from secret
  List<int> createHashLock(String secret) {
    final secretBytes = Uint8List.fromList(
      List.generate(
        secret.length ~/ 2,
        (i) => int.parse(secret.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );

    final digest = sha256.convert(secretBytes);
    return digest.bytes.toList();
  }

  /// Get current USD price for cryptocurrency
  Future<Result<BigInt, DomainError>> getCryptoPriceInUsd(
    CryptoType cryptoType,
  ) async {
    try {
      final result = await _priceOracleService.getPrice(
        cryptoType.name.toUpperCase(),
      );

      return result.fold(
        (price) => Result.success(
          BigInt.from(price * 1000000),
        ), // Convert to micro-dollars
        (error) => Result.failure(error),
      );
    } catch (error, stackTrace) {
      _logger.logError(
        'Failed to get crypto price',
        tag: 'HTLCService',
        error: error,
        stackTrace: stackTrace,
      );
      return Result.failure(
        DomainError.networkError('Failed to fetch crypto price'),
      );
    }
  }

  /// Calculate crypto amount from USD amount
  Future<Result<BigInt, DomainError>> calculateCryptoAmount({
    required BigInt usdAmount,
    required CryptoType cryptoType,
  }) async {
    try {
      final priceResult = await getCryptoPriceInUsd(cryptoType);

      return priceResult.fold((priceInUsdMicro) {
        if (priceInUsdMicro == BigInt.zero) {
          return Result.failure(
            DomainError.invalidInput('Price cannot be zero'),
          );
        }

        // Calculate: (usdAmount * 1e6) / priceInUsdMicro
        final cryptoAmount =
            (usdAmount * BigInt.from(1000000)) ~/ priceInUsdMicro;
        return Result.success(cryptoAmount);
      }, (error) => Result.failure(error));
    } catch (error, stackTrace) {
      _logger.logError(
        'Failed to calculate crypto amount',
        tag: 'HTLCService',
        error: error,
        stackTrace: stackTrace,
      );
      return Result.failure(
        DomainError.calculationError('Failed to calculate crypto amount'),
      );
    }
  }

  /// Validate swap parameters
  Result<void, DomainError> validateSwapParameters({
    required String listingId,
    required CryptoType cryptoAsset,
    required BigInt amount,
    required BigInt priceInUsd,
    required int lockTimeHours,
  }) {
    if (listingId.isEmpty) {
      return Result.failure(DomainError.invalidInput('Listing ID is required'));
    }

    if (amount <= BigInt.zero) {
      return Result.failure(
        DomainError.invalidInput('Amount must be greater than zero'),
      );
    }

    if (priceInUsd <= BigInt.zero) {
      return Result.failure(
        DomainError.invalidInput('Price must be greater than zero'),
      );
    }

    if (lockTimeHours < 1 || lockTimeHours > 168) {
      // Max 1 week
      return Result.failure(
        DomainError.invalidInput('Lock time must be between 1 and 168 hours'),
      );
    }

    return Result.success(null);
  }

  /// Initiate a new HTLC swap
  Future<Result<InitiateSwapResponse, DomainError>> initiateSwap({
    required String listingId,
    required CryptoType cryptoAsset,
    required BigInt amount,
    required BigInt priceInUsd,
    required int lockTimeHours,
  }) async {
    try {
      // Validate parameters
      final validation = validateSwapParameters(
        listingId: listingId,
        cryptoAsset: cryptoAsset,
        amount: amount,
        priceInUsd: priceInUsd,
        lockTimeHours: lockTimeHours,
      );

      if (validation.isFailure) {
        return Result.failure(validation.error);
      }

      // Generate secure secret and hash lock
      final secret = generateSecureSecret();
      final secretHash = createHashLock(secret);

      // Get current user principal
      final principalResult = await _icpService.getCurrentUserPrincipal();
      if (principalResult.isFailure) {
        return Result.failure(principalResult.error);
      }

      final principal = principalResult.value;

      // Call atomic swap canister
      final swapResult = await _atomicSwapService.initiateSwap(
        seller: principal,
        listingId: listingId,
        cryptoAsset: cryptoAsset.name,
        amount: amount.toInt(),
        priceInUsd: priceInUsd.toInt(),
        lockTimeHours: lockTimeHours,
        secretHash: secretHash,
      );

      return swapResult.fold((contract) {
        final swapContract = SwapContract(
          id: contract.id,
          listingId: contract.listingId,
          buyer: contract.buyer.toText(),
          seller: contract.seller.toText(),
          cryptoAsset: cryptoAsset,
          amount: BigInt.from(contract.amount),
          priceInUsd: BigInt.from(contract.priceInUsd),
          secretHash: contract.secretHash,
          lockTime: BigInt.from(contract.lockTime),
          status: _mapSwapState(contract.state),
          createdAt: BigInt.from(contract.createdAt),
          buyerDeposit: contract.buyerDeposit != null
              ? BigInt.from(contract.buyerDeposit!)
              : null,
          sellerDeposit: contract.sellerDeposit != null
              ? BigInt.from(contract.sellerDeposit!)
              : null,
        );

        _logger.logDebug(
          'Swap initiated successfully: ${swapContract.id}',
          tag: 'HTLCService',
        );

        return Result.success(
          InitiateSwapResponse(contract: swapContract, secret: secret),
        );
      }, (error) => Result.failure(error));
    } catch (error, stackTrace) {
      _logger.logError(
        'Failed to initiate swap',
        tag: 'HTLCService',
        error: error,
        stackTrace: stackTrace,
      );
      return Result.failure(
        DomainError.operationError('Failed to initiate swap'),
      );
    }
  }

  /// Get swap details by ID
  Future<Result<SwapContract, DomainError>> getSwap(String swapId) async {
    try {
      final result = await _atomicSwapService.getSwap(swapId);

      return result.fold((contract) {
        final swapContract = SwapContract(
          id: contract.id,
          listingId: contract.listingId,
          buyer: contract.buyer.toText(),
          seller: contract.seller.toText(),
          cryptoAsset: _mapCryptoType(contract.cryptoAsset),
          amount: BigInt.from(contract.amount),
          priceInUsd: BigInt.from(contract.priceInUsd),
          secretHash: contract.secretHash,
          lockTime: BigInt.from(contract.lockTime),
          status: _mapSwapState(contract.state),
          createdAt: BigInt.from(contract.createdAt),
          buyerDeposit: contract.buyerDeposit != null
              ? BigInt.from(contract.buyerDeposit!)
              : null,
          sellerDeposit: contract.sellerDeposit != null
              ? BigInt.from(contract.sellerDeposit!)
              : null,
        );

        return Result.success(swapContract);
      }, (error) => Result.failure(error));
    } catch (error, stackTrace) {
      _logger.logError(
        'Failed to get swap: $swapId',
        tag: 'HTLCService',
        error: error,
        stackTrace: stackTrace,
      );
      return Result.failure(
        DomainError.operationError('Failed to get swap details'),
      );
    }
  }

  /// Get user's swaps
  Future<Result<List<SwapContract>, DomainError>> getUserSwaps(
    String principal,
  ) async {
    try {
      final result = await _atomicSwapService.getUserSwaps(principal);

      return result.fold((contracts) {
        final swapContracts = contracts
            .map(
              (contract) => SwapContract(
                id: contract.id,
                listingId: contract.listingId,
                buyer: contract.buyer.toText(),
                seller: contract.seller.toText(),
                cryptoAsset: _mapCryptoType(contract.cryptoAsset),
                amount: BigInt.from(contract.amount),
                priceInUsd: BigInt.from(contract.priceInUsd),
                secretHash: contract.secretHash,
                lockTime: BigInt.from(contract.lockTime),
                status: _mapSwapState(contract.state),
                createdAt: BigInt.from(contract.createdAt),
                buyerDeposit: contract.buyerDeposit != null
                    ? BigInt.from(contract.buyerDeposit!)
                    : null,
                sellerDeposit: contract.sellerDeposit != null
                    ? BigInt.from(contract.sellerDeposit!)
                    : null,
              ),
            )
            .toList();

        return Result.success(swapContracts);
      }, (error) => Result.failure(error));
    } catch (error, stackTrace) {
      _logger.logError(
        'Failed to get user swaps',
        tag: 'HTLCService',
        error: error,
        stackTrace: stackTrace,
      );
      return Result.failure(
        DomainError.operationError('Failed to get user swaps'),
      );
    }
  }

  /// Map canister swap state to contract status
  SwapContractStatus _mapSwapState(String state) {
    switch (state) {
      case 'initiated':
        return SwapContractStatus.initiated;
      case 'locked':
        return SwapContractStatus.locked;
      case 'completed':
        return SwapContractStatus.completed;
      case 'refunded':
        return SwapContractStatus.refunded;
      case 'expired':
        return SwapContractStatus.expired;
      default:
        return SwapContractStatus.initiated;
    }
  }

  /// Map crypto asset string to enum
  CryptoType _mapCryptoType(String cryptoAsset) {
    switch (cryptoAsset.toUpperCase()) {
      case 'BTC':
        return CryptoType.btc;
      case 'ETH':
        return CryptoType.eth;
      case 'ICP':
        return CryptoType.icp;
      case 'USDT':
        return CryptoType.usdt;
      case 'USDC':
        return CryptoType.usdc;
      default:
        return CryptoType.btc;
    }
  }

  /// Generate timeline events for a swap
  List<SwapTimelineEvent> generateTimelineEvents(SwapContract contract) {
    final events = <SwapTimelineEvent>[];
    final now = DateTime.now();
    const eventIdPrefix = 'timeline_event_';

    // Swap initiated
    events.add(
      SwapTimelineEvent(
        id: '${eventIdPrefix}initiated_${contract.id}',
        swapId: contract.id,
        title: 'Swap Initiated',
        description:
            'HTLC contract has been created and is waiting for funds to be locked.',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          contract.createdAt.toInt(),
        ),
        status: SwapContractStatus.initiated,
      ),
    );

    // Funds locked (if applicable)
    if (contract.status.index >= SwapContractStatus.locked.index) {
      events.add(
        SwapTimelineEvent(
          id: '${eventIdPrefix}locked_${contract.id}',
          swapId: contract.id,
          title: 'Funds Locked',
          description:
              'Both buyer and seller have locked their funds in the contract.',
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            contract.createdAt.toInt() + 300000,
          ), // 5 minutes after initiation
          status: SwapContractStatus.locked,
        ),
      );
    }

    // Swap completed (if applicable)
    if (contract.status == SwapContractStatus.completed) {
      events.add(
        SwapTimelineEvent(
          id: '${eventIdPrefix}completed_${contract.id}',
          swapId: contract.id,
          title: 'Swap Completed',
          description:
              'The atomic swap has been successfully completed and funds have been released.',
          timestamp: now,
          status: SwapContractStatus.completed,
        ),
      );
    }

    // Swap refunded (if applicable)
    if (contract.status == SwapContractStatus.refunded) {
      events.add(
        SwapTimelineEvent(
          id: '${eventIdPrefix}refunded_${contract.id}',
          swapId: contract.id,
          title: 'Swap Refunded',
          description:
              'The swap has been refunded due to timeout or cancellation.',
          timestamp: now,
          status: SwapContractStatus.refunded,
        ),
      );
    }

    // Swap expired (if applicable)
    if (contract.status == SwapContractStatus.expired) {
      events.add(
        SwapTimelineEvent(
          id: '${eventIdPrefix}expired_${contract.id}',
          swapId: contract.id,
          title: 'Swap Expired',
          description: 'The swap has expired due to timeout.',
          timestamp: contract.lockTimeDateTime,
          status: SwapContractStatus.expired,
        ),
      );
    }

    return events;
  }
}
