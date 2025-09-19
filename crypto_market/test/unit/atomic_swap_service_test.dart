import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto_market/core/blockchain/atomic_swap_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/market/models/atomic_swap.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AtomicSwapService atomicSwapService;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    atomicSwapService = AtomicSwapService(secureStorage: mockSecureStorage);

    // Mock default storage behavior
    when(
      () => mockSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockSecureStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => mockSecureStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});
    when(
      () => mockSecureStorage.readAll(),
    ).thenAnswer((_) async => <String, String>{});
  });

  tearDown(() async {
    await atomicSwapService.clearStoredSecrets();
  });

  group('AtomicSwapService', () {
    group('generateSecureSecret', () {
      test('should generate 32-byte secret', () async {
        // Act
        final result = await atomicSwapService.generateSecureSecret();

        // Assert
        expect(result.isOk, true);
        final secret = result.ok;
        expect(secret.length, 32);
      });

      test('should generate different secrets on multiple calls', () async {
        // Act
        final result1 = await atomicSwapService.generateSecureSecret();
        final result2 = await atomicSwapService.generateSecureSecret();

        // Assert
        expect(result1.isOk, true);
        expect(result2.isOk, true);
        expect(result1.ok, isNot(result2.ok));
      });

      test('should generate secrets with random bytes', () async {
        // Act
        final result = await atomicSwapService.generateSecureSecret();

        // Assert
        expect(result.isOk, true);
        final secret = result.ok;

        // Check that not all bytes are the same
        expect(secret.toSet().length, greaterThan(1));
      });
    });

    group('initiateSwap', () {
      test('should create valid atomic swap', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;
        final secretHash = atomicSwapService.generateSecretHash(secret);

        // Act
        final result = await atomicSwapService.initiateSwap(
          listingId: 1,
          secretHash: secretHash,
          amount: BigInt.from(1000000), // 0.001 BTC in satoshis
          cryptoType: 'BTC',
          timeout: BigInt.from(const Duration(hours: 24).inMilliseconds),
        );

        // Assert
        expect(result.isOk, true);
        final swap = result.ok;
        expect(swap.id, greaterThan(0));
        expect(swap.listingId, 1);
        expect(swap.secretHash, secretHash);
        expect(swap.amount, BigInt.from(1000000));
        expect(swap.cryptoType, 'BTC');
        expect(swap.status, AtomicSwapStatus.pending);
        expect(
          swap.timeout,
          BigInt.from(const Duration(hours: 24).inMilliseconds),
        );
      });

      test('should return error for invalid listing ID', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;
        final secretHash = atomicSwapService.generateSecretHash(secret);

        // Act
        final result = await atomicSwapService.initiateSwap(
          listingId: -1,
          secretHash: secretHash,
          amount: BigInt.from(1000000),
          cryptoType: 'BTC',
          timeout: BigInt.from(const Duration(hours: 24).inMilliseconds),
        );

        // Assert
        expect(result.isErr, true);
        expect(result.err, SwapError.invalidListing);
      });

      test('should return error for invalid secret hash', () async {
        // Act
        final result = await atomicSwapService.initiateSwap(
          listingId: 1,
          secretHash: [],
          amount: BigInt.from(1000000),
          cryptoType: 'BTC',
          timeout: BigInt.from(const Duration(hours: 24).inMilliseconds),
        );

        // Assert
        expect(result.isErr, true);
        expect(result.err, SwapError.invalidSecret);
      });

      test('should return error for invalid amount', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;
        final secretHash = atomicSwapService.generateSecretHash(secret);

        // Act
        final result = await atomicSwapService.initiateSwap(
          listingId: 1,
          secretHash: secretHash,
          amount: BigInt.from(0),
          cryptoType: 'BTC',
          timeout: BigInt.from(const Duration(hours: 24).inMilliseconds),
        );

        // Assert
        expect(result.isErr, true);
        expect(result.err, SwapError.insufficientBalance);
      });

      test('should return error for invalid timeout', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;
        final secretHash = atomicSwapService.generateSecretHash(secret);

        // Act
        final result = await atomicSwapService.initiateSwap(
          listingId: 1,
          secretHash: secretHash,
          amount: BigInt.from(1000000),
          cryptoType: 'BTC',
          timeout: BigInt.from(0),
        );

        // Assert
        expect(result.isErr, true);
        expect(result.err, SwapError.invalidTimeout);
      });

      test('should return error for timeout too long', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;
        final secretHash = atomicSwapService.generateSecretHash(secret);

        // Act
        final result = await atomicSwapService.initiateSwap(
          listingId: 1,
          secretHash: secretHash,
          amount: BigInt.from(1000000),
          cryptoType: 'BTC',
          timeout: BigInt.from(const Duration(days: 8).inMilliseconds),
        );

        // Assert
        expect(result.isErr, true);
        expect(result.err, SwapError.invalidTimeout);
      });
    });

    group('store and retrieve swap secrets', () {
      test('should store and retrieve swap secret', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;
        const swapId = 123;

        // Act
        await atomicSwapService.storeSwapSecret(swapId: swapId, secret: secret);
        final retrieveResult = await atomicSwapService.getSwapSecret(swapId);

        // Assert
        expect(retrieveResult.isOk, true);
        expect(retrieveResult.ok, secret);
      });

      test('should return error for non-existent swap secret', () async {
        // Act
        final result = await atomicSwapService.getSwapSecret(999);

        // Assert
        expect(result.isErr, true);
        expect(result.err, SwapError.invalidSecret);
      });
    });

    group('completeSwap', () {
      test('should complete swap successfully', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;
        const swapId = 123;

        await atomicSwapService.storeSwapSecret(swapId: swapId, secret: secret);

        // Act
        final result = await atomicSwapService.completeSwap(
          swapId: swapId,
          secret: secret,
        );

        // Assert
        expect(result.isOk, true);
        expect(result.ok, true);

        // Secret should be removed after completion
        final retrieveResult = await atomicSwapService.getSwapSecret(swapId);
        expect(retrieveResult.isErr, true);
      });
    });

    group('refundSwap', () {
      test('should refund swap successfully', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;
        const swapId = 123;

        await atomicSwapService.storeSwapSecret(swapId: swapId, secret: secret);

        // Act
        final result = await atomicSwapService.refundSwap(swapId);

        // Assert
        expect(result.isOk, true);
        expect(result.ok, true);

        // Secret should be removed after refund
        final retrieveResult = await atomicSwapService.getSwapSecret(swapId);
        expect(retrieveResult.isErr, true);
      });
    });

    group('getSwapStatus', () {
      test('should return swap status', () async {
        // Act
        final result = await atomicSwapService.getSwapStatus(123);

        // Assert
        expect(result.isOk, true);
        expect(result.ok, isNotNull); // Should return a valid status
      });
    });

    group('clearStoredSecrets', () {
      test('should clear all stored secrets', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;

        await atomicSwapService.storeSwapSecret(swapId: 1, secret: secret);
        await atomicSwapService.storeSwapSecret(swapId: 2, secret: secret);

        expect(await atomicSwapService.storedSecretsCount, 2);

        // Act
        await atomicSwapService.clearStoredSecrets();

        // Assert
        expect(await atomicSwapService.storedSecretsCount, 0);
      });
    });

    group('generateSecretHash', () {
      test('should generate hash from secret', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;

        // Act
        final hash = atomicSwapService.generateSecretHash(secret);

        // Assert
        expect(hash, isNotNull);
        expect(hash.length, secret.length);
        expect(hash, isNot(secret)); // Hash should be different from secret
      });

      test('should generate consistent hash for same secret', () async {
        // Arrange
        final secretResult = await atomicSwapService.generateSecureSecret();
        expect(secretResult.isOk, true);
        final secret = secretResult.ok;

        // Act
        final hash1 = atomicSwapService.generateSecretHash(secret);
        final hash2 = atomicSwapService.generateSecretHash(secret);

        // Assert
        expect(hash1, hash2);
      });
    });
  });
}
