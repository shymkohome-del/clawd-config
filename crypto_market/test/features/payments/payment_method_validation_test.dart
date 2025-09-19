import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/features/payments/services/payment_validation_service.dart';
import 'package:crypto_market/features/payments/models/payment_method.dart';

void main() {
  group('PaymentValidationService', () {
    late PaymentValidationService validationService;

    setUp(() {
      validationService = PaymentValidationService();
    });

    group('Bank Transfer Validation', () {
      test('should validate correct bank transfer details', () {
        final result = validationService.validateBankTransfer(
          accountNumber: '123456789',
          routingNumber: '021000021',
          accountHolderName: 'John Doe',
          bankName: 'Test Bank',
        );

        expect(result.isOk(), true);
        expect(result.unwrap(), true);
      });

      test('should reject empty account number', () {
        final result = validationService.validateBankTransfer(
          accountNumber: '',
          routingNumber: '021000021',
          accountHolderName: 'John Doe',
          bankName: 'Test Bank',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.incompleteDetails);
      });

      test('should reject invalid routing number', () {
        final result = validationService.validateBankTransfer(
          accountNumber: '123456789',
          routingNumber: '123',
          accountHolderName: 'John Doe',
          bankName: 'Test Bank',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.invalidRoutingNumber);
      });

      test('should reject invalid account number', () {
        final result = validationService.validateBankTransfer(
          accountNumber: '12',
          routingNumber: '021000021',
          accountHolderName: 'John Doe',
          bankName: 'Test Bank',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.invalidAccountNumber);
      });

      test('should validate IBAN when provided', () {
        final result = validationService.validateBankTransfer(
          accountNumber: '123456789',
          routingNumber: '021000021',
          accountHolderName: 'John Doe',
          bankName: 'Test Bank',
          iban: 'GB82WEST12345698765432',
        );

        expect(result.isOk(), true);
      });

      test('should reject invalid IBAN', () {
        final result = validationService.validateBankTransfer(
          accountNumber: '123456789',
          routingNumber: '021000021',
          accountHolderName: 'John Doe',
          bankName: 'Test Bank',
          iban: 'INVALID_IBAN',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.invalidIban);
      });

      test('should validate SWIFT code when provided', () {
        final result = validationService.validateBankTransfer(
          accountNumber: '123456789',
          routingNumber: '021000021',
          accountHolderName: 'John Doe',
          bankName: 'Test Bank',
          swiftCode: 'DEUTDEFF',
        );

        expect(result.isOk(), true);
      });

      test('should reject invalid SWIFT code', () {
        final result = validationService.validateBankTransfer(
          accountNumber: '123456789',
          routingNumber: '021000021',
          accountHolderName: 'John Doe',
          bankName: 'Test Bank',
          swiftCode: 'INVALID',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.invalidSwiftCode);
      });

      test('should reject short account holder name', () {
        final result = validationService.validateBankTransfer(
          accountNumber: '123456789',
          routingNumber: '021000021',
          accountHolderName: 'A',
          bankName: 'Test Bank',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.formatError);
      });
    });

    group('Digital Wallet Validation', () {
      test('should validate correct digital wallet details', () {
        final result = validationService.validateDigitalWallet(
          walletId: 'john.doe@email.com',
          provider: 'PayPal',
        );

        expect(result.isOk(), true);
        expect(result.unwrap(), true);
      });

      test('should reject empty wallet ID', () {
        final result = validationService.validateDigitalWallet(
          walletId: '',
          provider: 'PayPal',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.incompleteDetails);
      });

      test('should reject empty provider', () {
        final result = validationService.validateDigitalWallet(
          walletId: 'john.doe@email.com',
          provider: '',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.incompleteDetails);
      });

      test('should validate email for digital wallet', () {
        final result = validationService.validateDigitalWallet(
          walletId: 'john.doe@email.com',
          provider: 'PayPal',
          email: 'john.doe@email.com',
        );

        expect(result.isOk(), true);
      });

      test('should reject invalid email for digital wallet', () {
        final result = validationService.validateDigitalWallet(
          walletId: 'john.doe@email.com',
          provider: 'PayPal',
          email: 'invalid-email',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.invalidEmail);
      });

      test('should validate phone number for digital wallet', () {
        final result = validationService.validateDigitalWallet(
          walletId: '+37123456789',
          provider: 'PayPal',
          phoneNumber: '+37123456789',
        );

        expect(result.isOk(), true);
      });

      test('should reject invalid phone number for digital wallet', () {
        final result = validationService.validateDigitalWallet(
          walletId: 'john.doe@email.com',
          provider: 'PayPal',
          phoneNumber: '123',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.invalidPhoneNumber);
      });
    });

    group('Cash Payment Validation', () {
      test('should validate correct cash payment details', () {
        final result = validationService.validateCashPayment(
          meetingLocation: 'Riga, Central Station',
          preferredTime: '2024-01-15 14:00',
          contactInfo: '+37123456789',
        );

        expect(result.isOk(), true);
        expect(result.unwrap(), true);
      });

      test('should reject empty meeting location', () {
        final result = validationService.validateCashPayment(
          meetingLocation: '',
          preferredTime: '2024-01-15 14:00',
          contactInfo: '+37123456789',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.incompleteDetails);
      });

      test('should reject empty preferred time', () {
        final result = validationService.validateCashPayment(
          meetingLocation: 'Riga, Central Station',
          preferredTime: '',
          contactInfo: '+37123456789',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.incompleteDetails);
      });

      test('should reject empty contact info', () {
        final result = validationService.validateCashPayment(
          meetingLocation: 'Riga, Central Station',
          preferredTime: '2024-01-15 14:00',
          contactInfo: '',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.incompleteDetails);
      });

      test('should reject invalid contact info', () {
        final result = validationService.validateCashPayment(
          meetingLocation: 'Riga, Central Station',
          preferredTime: '2024-01-15 14:00',
          contactInfo: 'invalid-contact',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.invalidContactInfo);
      });

      test('should accept email as contact info', () {
        final result = validationService.validateCashPayment(
          meetingLocation: 'Riga, Central Station',
          preferredTime: '2024-01-15 14:00',
          contactInfo: 'john.doe@email.com',
        );

        expect(result.isOk(), true);
      });

      test('should accept phone number as contact info', () {
        final result = validationService.validateCashPayment(
          meetingLocation: 'Riga, Central Station',
          preferredTime: '2024-01-15 14:00',
          contactInfo: '+37123456789',
        );

        expect(result.isOk(), true);
      });

      test('should reject short meeting location', () {
        final result = validationService.validateCashPayment(
          meetingLocation: 'A',
          preferredTime: '2024-01-15 14:00',
          contactInfo: '+37123456789',
        );

        expect(result.isErr(), true);
        expect(result.unwrapErr(), PaymentValidationError.invalidLocation);
      });
    });

    group('Error Messages', () {
      test('should return localized error messages in English', () {
        expect(
          validationService.getErrorMessage(
            PaymentValidationError.invalidAccountNumber,
            'en',
          ),
          equals('Invalid account number'),
        );

        expect(
          validationService.getErrorMessage(
            PaymentValidationError.invalidEmail,
            'en',
          ),
          equals('Invalid email address'),
        );

        expect(
          validationService.getErrorMessage(
            PaymentValidationError.incompleteDetails,
            'en',
          ),
          equals('Incomplete details'),
        );
      });

      test('should return localized error messages in Latvian', () {
        expect(
          validationService.getErrorMessage(
            PaymentValidationError.invalidAccountNumber,
            'lv',
          ),
          equals('Nederīgs konta numurs'),
        );

        expect(
          validationService.getErrorMessage(
            PaymentValidationError.invalidEmail,
            'lv',
          ),
          equals('Nederīgs e-pasta adrese'),
        );

        expect(
          validationService.getErrorMessage(
            PaymentValidationError.incompleteDetails,
            'lv',
          ),
          equals('Nepilnīgi detaļas'),
        );
      });
    });

    group('Payment Method Requirements', () {
      test('should return bank transfer requirements', () {
        final requirements = validationService.getValidationRequirements(
          PaymentMethodType.bankTransfer,
          'en',
        );

        expect(
          requirements['accountNumber'],
          equals('Account number (8-20 digits)'),
        );
        expect(
          requirements['routingNumber'],
          equals('Routing number (9 digits)'),
        );
        expect(
          requirements['accountHolderName'],
          equals('Account holder name'),
        );
        expect(requirements['bankName'], equals('Bank name'));
      });

      test('should return digital wallet requirements', () {
        final requirements = validationService.getValidationRequirements(
          PaymentMethodType.digitalWallet,
          'en',
        );

        expect(requirements['walletId'], equals('Wallet ID'));
        expect(requirements['provider'], equals('Provider'));
        expect(requirements['email'], equals('Email address (optional)'));
        expect(requirements['phoneNumber'], equals('Phone number (optional)'));
      });

      test('should return cash payment requirements', () {
        final requirements = validationService.getValidationRequirements(
          PaymentMethodType.cash,
          'en',
        );

        expect(requirements['meetingLocation'], equals('Meeting location'));
        expect(requirements['preferredTime'], equals('Preferred time'));
        expect(requirements['contactInfo'], equals('Contact information'));
        expect(
          requirements['specialInstructions'],
          equals('Special instructions (optional)'),
        );
      });
    });

    group('Regional Support', () {
      test('should support bank transfers in all regions', () {
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.bankTransfer,
            'US',
          ),
          isTrue,
        );
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.bankTransfer,
            'EU',
          ),
          isTrue,
        );
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.bankTransfer,
            'LV',
          ),
          isTrue,
        );
      });

      test('should support digital wallets in specific regions', () {
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.digitalWallet,
            'US',
          ),
          isTrue,
        );
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.digitalWallet,
            'EU',
          ),
          isTrue,
        );
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.digitalWallet,
            'LV',
          ),
          isTrue,
        );
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.digitalWallet,
            'CN',
          ),
          isFalse,
        );
      });

      test('should support cash payments only in Latvia', () {
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.cash,
            'LV',
          ),
          isTrue,
        );
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.cash,
            'US',
          ),
          isFalse,
        );
        expect(
          validationService.isPaymentMethodSupported(
            PaymentMethodType.cash,
            'EU',
          ),
          isFalse,
        );
      });
    });
  });
}
