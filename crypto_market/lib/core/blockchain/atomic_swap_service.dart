import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/market/models/atomic_swap.dart';

/// Swap error types
enum SwapError {
  invalidListing,
  insufficientBalance,
  swapAlreadyExists,
  networkError,
  timeoutError,
  invalidSecret,
  invalidTimeout,
}

/// Service for handling atomic swap operations
class AtomicSwapService {
  final FlutterSecureStorage _secureStorage;
  final Random _secureRandom = Random.secure();

  AtomicSwapService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Generate cryptographically secure secret for HTLC
  Future<Result<Uint8List, SwapError>> generateSecureSecret() async {
    try {
      Logger.instance.logDebug(
        'Generating secure secret for atomic swap',
        tag: 'AtomicSwapService',
      );

      // Generate 32-byte cryptographically secure random secret
      final secret = Uint8List(32);
      for (int i = 0; i < 32; i++) {
        secret[i] = _secureRandom.nextInt(256);
      }

      Logger.instance.logDebug(
        'Generated secure secret (length: ${secret.length})',
        tag: 'AtomicSwapService',
      );

      return Result.ok(secret);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to generate secure secret',
        tag: 'AtomicSwapService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(SwapError.invalidSecret);
    }
  }

  /// Initiate atomic swap with the blockchain
  Future<Result<AtomicSwap, SwapError>> initiateSwap({
    required int listingId,
    required List<int> secretHash,
    required BigInt amount,
    required String cryptoType,
    required BigInt timeout,
  }) async {
    try {
      Logger.instance.logDebug(
        'Initiating atomic swap for listing: $listingId',
        tag: 'AtomicSwapService',
      );

      // Validate input parameters
      if (listingId <= 0) {
        return Result.err(SwapError.invalidListing);
      }

      if (secretHash.isEmpty || secretHash.length != 32) {
        return Result.err(SwapError.invalidSecret);
      }

      if (amount <= BigInt.zero) {
        return Result.err(SwapError.insufficientBalance);
      }

      if (timeout <= BigInt.zero ||
          timeout > BigInt.from(const Duration(days: 7).inMilliseconds)) {
        return Result.err(SwapError.invalidTimeout);
      }

      // Simulate blockchain call
      // In real implementation, this would call the ICP atomic swap canister
      final swap = await _createSwapOnBlockchain(
        listingId: listingId,
        secretHash: secretHash,
        amount: amount,
        cryptoType: cryptoType,
        timeout: timeout,
      );

      Logger.instance.logDebug(
        'Atomic swap initiated successfully with ID: ${swap.id}',
        tag: 'AtomicSwapService',
      );

      return Result.ok(swap);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to initiate atomic swap',
        tag: 'AtomicSwapService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(SwapError.networkError);
    }
  }

  /// Store swap secret securely
  Future<void> storeSwapSecret({
    required int swapId,
    required Uint8List secret,
  }) async {
    try {
      Logger.instance.logDebug(
        'Storing secret for swap: $swapId',
        tag: 'AtomicSwapService',
      );

      final secretKey = 'swap_secret_$swapId';
      await _secureStorage.write(key: secretKey, value: secret.join(','));

      Logger.instance.logDebug(
        'Secret stored successfully for swap: $swapId',
        tag: 'AtomicSwapService',
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to store swap secret',
        tag: 'AtomicSwapService',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  /// Retrieve swap secret
  Future<Result<Uint8List, SwapError>> getSwapSecret(int swapId) async {
    try {
      Logger.instance.logDebug(
        'Retrieving secret for swap: $swapId',
        tag: 'AtomicSwapService',
      );

      final secretKey = 'swap_secret_$swapId';
      final secretString = await _secureStorage.read(key: secretKey);

      if (secretString == null) {
        Logger.instance.logWarn(
          'Secret not found for swap: $swapId',
          tag: 'AtomicSwapService',
        );
        return Result.err(SwapError.invalidSecret);
      }

      final secretBytes = secretString.split(',').map(int.parse).toList();
      final secret = Uint8List.fromList(secretBytes);

      Logger.instance.logDebug(
        'Secret retrieved successfully for swap: $swapId',
        tag: 'AtomicSwapService',
      );

      return Result.ok(secret);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to retrieve swap secret',
        tag: 'AtomicSwapService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(SwapError.networkError);
    }
  }

  /// Simulate creating swap on blockchain
  Future<AtomicSwap> _createSwapOnBlockchain({
    required int listingId,
    required List<int> secretHash,
    required BigInt amount,
    required String cryptoType,
    required BigInt timeout,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Generate mock swap ID (in real implementation, this comes from blockchain)
    final swapId = DateTime.now().millisecondsSinceEpoch % 1000000;

    // Mock buyer and seller principals
    final buyer = 'principal-buyer-${Random().nextInt(1000)}';
    final seller = 'principal-seller-${Random().nextInt(1000)}';

    final now = DateTime.now().millisecondsSinceEpoch;

    return AtomicSwap(
      id: swapId,
      listingId: listingId,
      buyer: buyer,
      seller: seller,
      secretHash: secretHash,
      amount: amount,
      cryptoType: cryptoType,
      timeout: timeout,
      status: AtomicSwapStatus.pending,
      createdAt: BigInt.from(now),
    );
  }

  /// Generate SHA-256 hash from secret
  List<int> generateSecretHash(Uint8List secret) {
    final hash = sha256.convert(secret);
    return hash.bytes.toList();
  }

  /// Complete atomic swap by revealing secret
  Future<Result<bool, SwapError>> completeSwap({
    required int swapId,
    required Uint8List secret,
  }) async {
    try {
      Logger.instance.logDebug(
        'Completing atomic swap: $swapId',
        tag: 'AtomicSwapService',
      );

      // Simulate blockchain call
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove stored secret
      final secretKey = 'swap_secret_$swapId';
      await _secureStorage.delete(key: secretKey);

      Logger.instance.logDebug(
        'Atomic swap completed successfully: $swapId',
        tag: 'AtomicSwapService',
      );

      return Result.ok(true);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to complete atomic swap',
        tag: 'AtomicSwapService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(SwapError.networkError);
    }
  }

  /// Refund atomic swap
  Future<Result<bool, SwapError>> refundSwap(int swapId) async {
    try {
      Logger.instance.logDebug(
        'Refunding atomic swap: $swapId',
        tag: 'AtomicSwapService',
      );

      // Simulate blockchain call
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove stored secret
      final secretKey = 'swap_secret_$swapId';
      await _secureStorage.delete(key: secretKey);

      Logger.instance.logDebug(
        'Atomic swap refunded successfully: $swapId',
        tag: 'AtomicSwapService',
      );

      return Result.ok(true);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to refund atomic swap',
        tag: 'AtomicSwapService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(SwapError.networkError);
    }
  }

  /// Get swap status
  Future<Result<AtomicSwapStatus, SwapError>> getSwapStatus(int swapId) async {
    try {
      Logger.instance.logDebug(
        'Getting swap status: $swapId',
        tag: 'AtomicSwapService',
      );

      // Simulate blockchain call
      await Future.delayed(const Duration(milliseconds: 200));

      // Mock status - in real implementation, this would query the blockchain
      final statuses = AtomicSwapStatus.values;
      final randomStatus = statuses[Random().nextInt(statuses.length)];

      Logger.instance.logDebug(
        'Swap status retrieved: $randomStatus for swap: $swapId',
        tag: 'AtomicSwapService',
      );

      return Result.ok(randomStatus);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to get swap status',
        tag: 'AtomicSwapService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(SwapError.networkError);
    }
  }

  /// Clear all stored secrets (for testing/cleanup)
  Future<void> clearStoredSecrets() async {
    Logger.instance.logDebug(
      'Clearing all stored swap secrets',
      tag: 'AtomicSwapService',
    );

    final allKeys = await _secureStorage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith('swap_secret_')) {
        await _secureStorage.delete(key: key);
      }
    }
  }

  /// Get number of stored secrets
  Future<int> get storedSecretsCount async {
    final allKeys = await _secureStorage.readAll();
    return allKeys.keys.where((key) => key.startsWith('swap_secret_')).length;
  }
}
