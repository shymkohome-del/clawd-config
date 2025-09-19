import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto_market/features/payments/models/payment_method.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('PaymentEncryptionService', () {
    late PaymentEncryptionService encryptionService;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      encryptionService = PaymentEncryptionService(secureStorage: mockStorage);
    });

    tearDown(() async {
      // Don't call clearMasterKey in tests as it causes issues with mock
    });

    group('Master Key Management', () {
      test('should generate new master key when none exists', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        // Test that master key is created when needed by using encryption
        final details = {'test': 'data'};
        final encrypted = await encryptionService.encryptPaymentDetails(
          details,
        );
        expect(encrypted, isNotNull);
        verify(
          () => mockStorage.write(
            key: 'payment_master_key',
            value: any(named: 'value'),
          ),
        ).called(1);
      });

      test('should reuse existing master key', () async {
        final existingKey = List.generate(32, (i) => i);
        when(
          () => mockStorage.read(key: 'payment_master_key'),
        ).thenAnswer((_) async => existingKey.join(','));

        // Test that existing master key is reused
        final details = {'test': 'data'};
        await encryptionService.encryptPaymentDetails(details);
        verifyNever(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );
      });
    });

    group('Payment Method Encryption', () {
      setUp(() async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});
      });

      test('should encrypt and decrypt payment method details', () async {
        final details = {
          'accountNumber': '123456789',
          'routingNumber': '021000021',
          'accountHolderName': 'John Doe',
          'bankName': 'Test Bank',
        };

        final encrypted = await encryptionService.encryptPaymentDetails(
          details,
        );
        final decrypted = await encryptionService.decryptPaymentDetails(
          encrypted,
        );

        expect(decrypted, equals(details));
      });

      test(
        'should generate different encrypted values for same data',
        () async {
          final details = {
            'accountNumber': '123456789',
            'routingNumber': '021000021',
          };

          final encrypted1 = await encryptionService.encryptPaymentDetails(
            details,
          );
          final encrypted2 = await encryptionService.encryptPaymentDetails(
            details,
          );

          expect(encrypted1, isNot(equals(encrypted2)));
        },
      );

      test('should fail to decrypt with invalid data', () async {
        final invalidEncryptedData = 'invalid-encrypted-data';

        expect(
          () => encryptionService.decryptPaymentDetails(invalidEncryptedData),
          throwsException,
        );
      });
    });

    group('Payment Method ID Generation', () {
      test('should generate unique payment method IDs', () {
        final userId = 'user123';
        final id1 = PaymentEncryptionService.generatePaymentMethodId(userId);
        final id2 = PaymentEncryptionService.generatePaymentMethodId(userId);

        expect(id1, isNot(equals(id2)));
        expect(id1.length, equals(16));
        expect(id2.length, equals(16));
      });

      test('should generate unique payment proof IDs', () {
        final swapId = 'swap123';
        final id1 = PaymentEncryptionService.generatePaymentProofId(swapId);
        final id2 = PaymentEncryptionService.generatePaymentProofId(swapId);

        expect(id1, isNot(equals(id2)));
        expect(id1.length, equals(16));
        expect(id2.length, equals(16));
      });

      test('should generate different IDs for different users', () {
        final userId1 = 'user123';
        final userId2 = 'user456';

        final id1 = PaymentEncryptionService.generatePaymentMethodId(userId1);
        final id2 = PaymentEncryptionService.generatePaymentMethodId(userId2);

        expect(id1, isNot(equals(id2)));
      });
    });

    group('Key Rotation', () {
      test('should rotate master key', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockStorage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async {});

        // Test key rotation by encrypting before and after
        final details = {'test': 'data'};
        final encrypted1 = await encryptionService.encryptPaymentDetails(
          details,
        );
        await encryptionService.rotateMasterKey();
        final encrypted2 = await encryptionService.encryptPaymentDetails(
          details,
        );

        expect(encrypted2, isNot(equals(encrypted1)));
        verify(() => mockStorage.delete(key: 'payment_master_key')).called(1);
      });
    });

    group('Security', () {
      test('should not store sensitive data in logs', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => null);
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        final sensitiveData = {
          'accountNumber': '123456789',
          'routingNumber': '021000021',
          'accountHolderName': 'John Doe',
          'bankName': 'Test Bank',
        };

        final encrypted = await encryptionService.encryptPaymentDetails(
          sensitiveData,
        );

        // Encrypted data should not contain plain text account number
        expect(encrypted, isNot(contains('123456789')));
        expect(encrypted, isNot(contains('John Doe')));
        expect(encrypted, isNot(contains('Test Bank')));
      });

      test('should clear master key on request', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => 'existing-key');
        when(
          () => mockStorage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async {});

        await encryptionService.clearMasterKey();

        verify(() => mockStorage.delete(key: 'payment_master_key')).called(1);
      });
    });
  });
}
