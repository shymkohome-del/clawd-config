import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_market/core/auth/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Mock class
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late SecureStorageService secureStorageService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorageService = SecureStorageService(secureStorage: mockStorage);
  });

  group('SecureStorageService', () {
    const testKey = 'test-key';
    const testData = 'test-data';
    const testKeyPair = ICPKeyPair(
      principalId: 'test-principal',
      publicKey: 'test-public-key',
      privateKey: 'test-private-key',
    );

    group('storeEncryptedData', () {
      test('stores data with specified key', () async {
        when(
          () => mockStorage.write(key: testKey, value: testData),
        ).thenAnswer((_) async {});

        await secureStorageService.storeEncryptedData(testKey, testData);

        verify(
          () => mockStorage.write(key: testKey, value: testData),
        ).called(1);
      });

      test('handles storage exceptions gracefully', () async {
        when(
          () => mockStorage.write(key: testKey, value: testData),
        ).thenThrow(Exception('Storage error'));

        expect(
          () => secureStorageService.storeEncryptedData(testKey, testData),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getEncryptedData', () {
      test('retrieves stored data by key', () async {
        when(
          () => mockStorage.read(key: testKey),
        ).thenAnswer((_) async => testData);

        final result = await secureStorageService.getEncryptedData(testKey);

        expect(result, equals(testData));
        verify(() => mockStorage.read(key: testKey)).called(1);
      });

      test('returns null when data is not found', () async {
        when(
          () => mockStorage.read(key: testKey),
        ).thenAnswer((_) async => null);

        final result = await secureStorageService.getEncryptedData(testKey);

        expect(result, isNull);
      });

      test('handles retrieval exceptions gracefully', () async {
        when(
          () => mockStorage.read(key: testKey),
        ).thenThrow(Exception('Retrieval error'));

        expect(
          () => secureStorageService.getEncryptedData(testKey),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteData', () {
      test('deletes data by key', () async {
        when(() => mockStorage.delete(key: testKey)).thenAnswer((_) async {});

        await secureStorageService.deleteData(testKey);

        verify(() => mockStorage.delete(key: testKey)).called(1);
      });

      test('handles deletion exceptions gracefully', () async {
        when(
          () => mockStorage.delete(key: testKey),
        ).thenThrow(Exception('Deletion error'));

        expect(
          () => secureStorageService.deleteData(testKey),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('clearAllData', () {
      test('clears all stored data', () async {
        when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

        await secureStorageService.clearAllData();

        verify(() => mockStorage.deleteAll()).called(1);
      });

      test('handles clear all exceptions gracefully', () async {
        when(() => mockStorage.deleteAll()).thenThrow(Exception('Clear error'));

        expect(
          () => secureStorageService.clearAllData(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('ICP Key Pair Storage', () {
      const testUserId = 'test-user-id';
      const storageKey = 'icp_key_pair_$testUserId';

      test('stores ICP key pair with user-specific key', () async {
        when(
          () => mockStorage.write(
            key: storageKey,
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        await secureStorageService.storeICPKeyPair(testUserId, testKeyPair);

        verify(
          () => mockStorage.write(
            key: storageKey,
            value: any(named: 'value'),
          ),
        ).called(1);
      });

      test('retrieves ICP key pair by user id', () async {
        final expectedJson = {
          'principalId': testKeyPair.principalId,
          'publicKey': testKeyPair.publicKey,
          'privateKey': testKeyPair.privateKey,
        };

        when(
          () => mockStorage.read(key: storageKey),
        ).thenAnswer((_) async => expectedJson.toString());

        final result = await secureStorageService.getICPKeyPair(testUserId);

        expect(result, isNotNull);
        if (result != null) {
          expect(result.principalId, equals(testKeyPair.principalId));
          expect(result.publicKey, equals(testKeyPair.publicKey));
          expect(result.privateKey, equals(testKeyPair.privateKey));
        }
      });

      test('returns null when ICP key pair is not found', () async {
        when(
          () => mockStorage.read(key: storageKey),
        ).thenAnswer((_) async => null);

        final result = await secureStorageService.getICPKeyPair(testUserId);

        expect(result, isNull);
      });

      test('deletes ICP key pair by user id', () async {
        when(
          () => mockStorage.delete(key: storageKey),
        ).thenAnswer((_) async {});

        await secureStorageService.deleteICPKeyPair(testUserId);

        verify(() => mockStorage.delete(key: storageKey)).called(1);
      });
    });
  });
}
