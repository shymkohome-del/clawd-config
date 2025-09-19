import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/error/simple_result.dart';
import 'package:crypto_market/features/payments/models/payment_method.dart';
import 'package:crypto_market/features/payments/providers/payment_method_provider.dart';
import 'package:crypto_market/features/payments/services/payment_validation_service.dart';
import 'package:mocktail/mocktail.dart';

class MockPaymentValidationService extends Mock
    implements PaymentValidationService {}

class MockPaymentEncryptionService extends Mock
    implements PaymentEncryptionService {}

void main() {
  group('PaymentMethodBloc', () {
    late PaymentMethodBloc paymentMethodBloc;
    late MockPaymentValidationService mockValidationService;
    late MockPaymentEncryptionService mockEncryptionService;

    setUp(() {
      mockValidationService = MockPaymentValidationService();
      mockEncryptionService = MockPaymentEncryptionService();
      paymentMethodBloc = PaymentMethodBloc(
        validationService: mockValidationService,
        encryptionService: mockEncryptionService,
      );
    });

    tearDown(() {
      paymentMethodBloc.close();
    });

    test('initial state is PaymentMethodState.initial', () {
      expect(paymentMethodBloc.state, const PaymentMethodState.initial());
    });

    group('LoadPaymentMethods', () {
      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'emits loading and loaded states when loading payment methods succeeds',
        build: () {
          when(
            () => mockValidationService.validateBankTransfer(
              accountNumber: any(named: 'accountNumber'),
              routingNumber: any(named: 'routingNumber'),
              accountHolderName: any(named: 'accountHolderName'),
              bankName: any(named: 'bankName'),
            ),
          ).thenReturn(Result.ok(true));
          when(
            () => mockEncryptionService.encryptPaymentDetails(any()),
          ).thenAnswer((_) async => 'encrypted-data');
          return paymentMethodBloc;
        },
        act: (bloc) => bloc.add(const LoadPaymentMethods(userId: 'user123')),
        expect: () => [
          const PaymentMethodState(
            status: PaymentMethodStatus.loading,
            isLoading: true,
          ),
          const PaymentMethodState(
            status: PaymentMethodStatus.loaded,
            isLoading: false,
            paymentMethods: [],
          ),
        ],
      );

      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'emits error state when loading payment methods fails',
        build: () {
          when(
            () => mockValidationService.validateBankTransfer(
              accountNumber: any(named: 'accountNumber'),
              routingNumber: any(named: 'routingNumber'),
              accountHolderName: any(named: 'accountHolderName'),
              bankName: any(named: 'bankName'),
            ),
          ).thenReturn(Result.ok(true));
          when(
            () => mockEncryptionService.encryptPaymentDetails(any()),
          ).thenAnswer((_) async => 'encrypted-data');
          return paymentMethodBloc;
        },
        act: (bloc) => bloc.add(const LoadPaymentMethods(userId: 'user123')),
        expect: () => [
          const PaymentMethodState(
            status: PaymentMethodStatus.loading,
            isLoading: true,
          ),
          predicate(
            (state) =>
                state != null &&
                (state as PaymentMethodState).status ==
                    PaymentMethodStatus.error &&
                (state as PaymentMethodState).isLoading == false &&
                (state as PaymentMethodState).errorMessage != null,
          ),
        ],
      );
    });

    group('AddPaymentMethod', () {
      setUp(() {
        when(
          () => mockValidationService.validateBankTransfer(
            accountNumber: any(named: 'accountNumber'),
            routingNumber: any(named: 'routingNumber'),
            accountHolderName: any(named: 'accountHolderName'),
            bankName: any(named: 'bankName'),
          ),
        ).thenReturn(Result.ok(true));
        when(
          () => mockValidationService.validateDigitalWallet(
            walletId: any(named: 'walletId'),
            provider: any(named: 'provider'),
          ),
        ).thenReturn(Result.ok(true));
        when(
          () => mockValidationService.validateCashPayment(
            meetingLocation: any(named: 'meetingLocation'),
            preferredTime: any(named: 'preferredTime'),
            contactInfo: any(named: 'contactInfo'),
          ),
        ).thenReturn(Result.ok(true));
        when(
          () => mockEncryptionService.encryptPaymentDetails(any()),
        ).thenAnswer((_) async => 'encrypted-data');
      });

      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'emits loading and loaded states when adding bank transfer succeeds',
        build: () => paymentMethodBloc,
        act: (bloc) => bloc.add(
          const AddPaymentMethod(
            userId: 'user123',
            type: PaymentMethodType.bankTransfer,
            accountNumber: '123456789',
            routingNumber: '021000021',
            accountHolderName: 'John Doe',
            bankName: 'Test Bank',
            meetingLocation: '',
            preferredTime: '',
            contactInfo: '',
            walletId: '',
            provider: '',
            locale: 'en',
          ),
        ),
        expect: () => [
          const PaymentMethodState(
            status: PaymentMethodStatus.loading,
            isLoading: true,
          ),
          predicate(
            (state) =>
                state != null &&
                (state as PaymentMethodState).status ==
                    PaymentMethodStatus.loaded &&
                (state as PaymentMethodState).isLoading == false &&
                (state as PaymentMethodState).paymentMethods.length == 1 &&
                (state as PaymentMethodState).paymentMethods.first.type ==
                    PaymentMethodType.bankTransfer,
          ),
        ],
      );

      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'emits validation error when payment method validation fails',
        build: () {
          when(
            () => mockValidationService.validateBankTransfer(
              accountNumber: any(named: 'accountNumber'),
              routingNumber: any(named: 'routingNumber'),
              accountHolderName: any(named: 'accountHolderName'),
              bankName: any(named: 'bankName'),
            ),
          ).thenReturn(Result.err(PaymentValidationError.invalidAccountNumber));
          return paymentMethodBloc;
        },
        act: (bloc) => bloc.add(
          const AddPaymentMethod(
            userId: 'user123',
            type: PaymentMethodType.bankTransfer,
            accountNumber: 'invalid',
            routingNumber: '021000021',
            accountHolderName: 'John Doe',
            bankName: 'Test Bank',
            meetingLocation: '',
            preferredTime: '',
            contactInfo: '',
            walletId: '',
            provider: '',
            locale: 'en',
          ),
        ),
        expect: () => [
          const PaymentMethodState(
            status: PaymentMethodStatus.loading,
            isLoading: true,
          ),
          predicate(
            (state) =>
                state != null &&
                (state as PaymentMethodState).status ==
                    PaymentMethodStatus.error &&
                (state as PaymentMethodState).isLoading == false &&
                (state as PaymentMethodState).errorMessage != null &&
                (state as PaymentMethodState).validationError ==
                    PaymentValidationError.invalidAccountNumber,
          ),
        ],
      );

      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'emits loading and loaded states when adding digital wallet succeeds',
        build: () => paymentMethodBloc,
        act: (bloc) => bloc.add(
          const AddPaymentMethod(
            userId: 'user123',
            type: PaymentMethodType.digitalWallet,
            accountNumber: '',
            routingNumber: '',
            accountHolderName: '',
            bankName: '',
            meetingLocation: '',
            preferredTime: '',
            contactInfo: '',
            walletId: 'john.doe@email.com',
            provider: 'PayPal',
            locale: 'en',
          ),
        ),
        expect: () => [
          const PaymentMethodState(
            status: PaymentMethodStatus.loading,
            isLoading: true,
          ),
          predicate(
            (state) =>
                state != null &&
                (state as PaymentMethodState).status ==
                    PaymentMethodStatus.loaded &&
                (state as PaymentMethodState).isLoading == false &&
                (state as PaymentMethodState).paymentMethods.length == 1 &&
                (state as PaymentMethodState).paymentMethods.first.type ==
                    PaymentMethodType.digitalWallet,
          ),
        ],
      );

      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'emits loading and loaded states when adding cash payment succeeds',
        build: () => paymentMethodBloc,
        act: (bloc) => bloc.add(
          const AddPaymentMethod(
            userId: 'user123',
            type: PaymentMethodType.cash,
            accountNumber: '',
            routingNumber: '',
            accountHolderName: '',
            bankName: '',
            meetingLocation: 'Riga, Central Station',
            preferredTime: '2024-01-15 14:00',
            contactInfo: '+37123456789',
            walletId: '',
            provider: '',
            locale: 'en',
          ),
        ),
        expect: () => [
          const PaymentMethodState(
            status: PaymentMethodStatus.loading,
            isLoading: true,
          ),
          predicate(
            (state) =>
                state != null &&
                (state as PaymentMethodState).status ==
                    PaymentMethodStatus.loaded &&
                (state as PaymentMethodState).isLoading == false &&
                (state as PaymentMethodState).paymentMethods.length == 1 &&
                (state as PaymentMethodState).paymentMethods.first.type ==
                    PaymentMethodType.cash,
          ),
        ],
      );
    });

    group('DeletePaymentMethod', () {
      setUp(() {
        when(
          () => mockValidationService.validateBankTransfer(
            accountNumber: any(named: 'accountNumber'),
            routingNumber: any(named: 'routingNumber'),
            accountHolderName: any(named: 'accountHolderName'),
            bankName: any(named: 'bankName'),
          ),
        ).thenReturn(Result.ok(true));
        when(
          () => mockEncryptionService.encryptPaymentDetails(any()),
        ).thenAnswer((_) async => 'encrypted-data');

        // Add a payment method first
        paymentMethodBloc.add(
          const AddPaymentMethod(
            userId: 'user123',
            type: PaymentMethodType.bankTransfer,
            accountNumber: '123456789',
            routingNumber: '021000021',
            accountHolderName: 'John Doe',
            bankName: 'Test Bank',
            meetingLocation: '',
            preferredTime: '',
            contactInfo: '',
            walletId: '',
            provider: '',
            locale: 'en',
          ),
        );
      });

      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'removes payment method from state when deletion succeeds',
        build: () => paymentMethodBloc,
        act: (bloc) async {
          // Wait for the initial add to complete
          await bloc.stream.firstWhere(
            (state) => state.paymentMethods.isNotEmpty,
          );

          // Get the ID of the added payment method
          final paymentMethodId = bloc.state.paymentMethods.first.id;

          // Delete the payment method
          bloc.add(DeletePaymentMethod(paymentMethodId: paymentMethodId));
        },
        expect: () => [
          predicate(
            (state) =>
                state != null &&
                (state as PaymentMethodState).status ==
                    PaymentMethodStatus.loading &&
                (state as PaymentMethodState).isLoading == true &&
                (state as PaymentMethodState).paymentMethods.length == 1,
          ),
          predicate(
            (state) =>
                state != null &&
                (state as PaymentMethodState).status ==
                    PaymentMethodStatus.loaded &&
                (state as PaymentMethodState).isLoading == false &&
                (state as PaymentMethodState).paymentMethods.isEmpty,
          ),
        ],
      );
    });

    group('SelectPaymentMethod', () {
      setUp(() {
        when(
          () => mockValidationService.validateBankTransfer(
            accountNumber: any(named: 'accountNumber'),
            routingNumber: any(named: 'routingNumber'),
            accountHolderName: any(named: 'accountHolderName'),
            bankName: any(named: 'bankName'),
          ),
        ).thenReturn(Result.ok(true));
        when(
          () => mockEncryptionService.encryptPaymentDetails(any()),
        ).thenAnswer((_) async => 'encrypted-data');

        // Add payment methods first
        paymentMethodBloc.add(
          const AddPaymentMethod(
            userId: 'user123',
            type: PaymentMethodType.bankTransfer,
            accountNumber: '123456789',
            routingNumber: '021000021',
            accountHolderName: 'John Doe',
            bankName: 'Test Bank',
            meetingLocation: '',
            preferredTime: '',
            contactInfo: '',
            walletId: '',
            provider: '',
            locale: 'en',
          ),
        );
      });

      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'updates selected payment method ID',
        build: () => paymentMethodBloc,
        act: (bloc) async {
          // Wait for the initial add to complete
          await bloc.stream.firstWhere(
            (state) => state.paymentMethods.isNotEmpty,
          );

          // Get the ID of the added payment method
          final paymentMethodId = bloc.state.paymentMethods.first.id;

          // Select the payment method
          bloc.add(SelectPaymentMethod(paymentMethodId: paymentMethodId));
        },
        expect: () => [
          predicate(
            (state) =>
                state != null &&
                (state as PaymentMethodState).selectedPaymentMethodId != null &&
                (state as PaymentMethodState).paymentMethods?.isNotEmpty ==
                    true &&
                (state as PaymentMethodState).selectedPaymentMethodId ==
                    (state as PaymentMethodState).paymentMethods?.first.id,
          ),
        ],
      );

      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'clears selected payment method when null is passed',
        build: () => paymentMethodBloc,
        act: (bloc) async {
          // Wait for the initial add to complete
          await bloc.stream.firstWhere(
            (state) => state.paymentMethods.isNotEmpty,
          );

          // Select a payment method first
          final paymentMethodId = bloc.state.paymentMethods.first.id;
          bloc.add(SelectPaymentMethod(paymentMethodId: paymentMethodId));

          // Clear selection
          bloc.add(const SelectPaymentMethod(paymentMethodId: null));
        },
        expect: () => [
          predicate(
            (state) =>
                state != null &&
                (state as PaymentMethodState).selectedPaymentMethodId == null,
          ),
        ],
      );
    });

    group('ValidatePaymentMethod', () {
      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'updates validation state when validation succeeds',
        build: () {
          when(
            () => mockValidationService.validateBankTransfer(
              accountNumber: any(named: 'accountNumber'),
              routingNumber: any(named: 'routingNumber'),
              accountHolderName: any(named: 'accountHolderName'),
              bankName: any(named: 'bankName'),
            ),
          ).thenReturn(Result.ok(true));
          return paymentMethodBloc;
        },
        act: (bloc) => bloc.add(
          const ValidatePaymentMethod(
            type: PaymentMethodType.bankTransfer,
            accountNumber: '123456789',
            routingNumber: '021000021',
            accountHolderName: 'John Doe',
            bankName: 'Test Bank',
            meetingLocation: '',
            preferredTime: '',
            contactInfo: '',
            walletId: '',
            provider: '',
            locale: 'en',
          ),
        ),
        expect: () => [
          const PaymentMethodState(isValid: true, validationError: null),
        ],
      );

      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'updates validation state when validation fails',
        build: () {
          when(
            () => mockValidationService.validateBankTransfer(
              accountNumber: any(named: 'accountNumber'),
              routingNumber: any(named: 'routingNumber'),
              accountHolderName: any(named: 'accountHolderName'),
              bankName: any(named: 'bankName'),
            ),
          ).thenReturn(Result.err(PaymentValidationError.invalidAccountNumber));
          return paymentMethodBloc;
        },
        act: (bloc) => bloc.add(
          const ValidatePaymentMethod(
            type: PaymentMethodType.bankTransfer,
            accountNumber: 'invalid',
            routingNumber: '021000021',
            accountHolderName: 'John Doe',
            bankName: 'Test Bank',
            meetingLocation: '',
            preferredTime: '',
            contactInfo: '',
            walletId: '',
            provider: '',
            locale: 'en',
          ),
        ),
        expect: () => [
          const PaymentMethodState(
            isValid: false,
            validationError: PaymentValidationError.invalidAccountNumber,
          ),
        ],
      );
    });

    group('ClearPaymentMethodError', () {
      blocTest<PaymentMethodBloc, PaymentMethodState>(
        'clears error state',
        build: () => paymentMethodBloc,
        act: (bloc) => bloc.add(const ClearPaymentMethodError()),
        expect: () => [
          const PaymentMethodState(errorMessage: null, validationError: null),
        ],
      );
    });

    group('State Getters', () {
      setUp(() {
        when(
          () => mockValidationService.validateBankTransfer(
            accountNumber: any(named: 'accountNumber'),
            routingNumber: any(named: 'routingNumber'),
            accountHolderName: any(named: 'accountHolderName'),
            bankName: any(named: 'bankName'),
          ),
        ).thenReturn(Result.ok(true));
        when(
          () => mockEncryptionService.encryptPaymentDetails(any()),
        ).thenAnswer((_) async => 'encrypted-data');
      });

      test(
        'hasPaymentMethods returns true when payment methods exist',
        () async {
          paymentMethodBloc.add(
            const AddPaymentMethod(
              userId: 'user123',
              type: PaymentMethodType.bankTransfer,
              accountNumber: '123456789',
              routingNumber: '021000021',
              accountHolderName: 'John Doe',
              bankName: 'Test Bank',
              meetingLocation: '',
              preferredTime: '',
              contactInfo: '',
              walletId: '',
              provider: '',
              locale: 'en',
            ),
          );

          final state = await paymentMethodBloc.stream.firstWhere(
            (state) => state.paymentMethods.isNotEmpty,
          );

          expect(state.hasPaymentMethods, isTrue);
        },
      );

      test('selectedPaymentMethod returns correct payment method', () async {
        paymentMethodBloc.add(
          const AddPaymentMethod(
            userId: 'user123',
            type: PaymentMethodType.bankTransfer,
            accountNumber: '123456789',
            routingNumber: '021000021',
            accountHolderName: 'John Doe',
            bankName: 'Test Bank',
            meetingLocation: '',
            preferredTime: '',
            contactInfo: '',
            walletId: '',
            provider: '',
            locale: 'en',
          ),
        );

        await paymentMethodBloc.stream.firstWhere(
          (state) => state.paymentMethods.isNotEmpty,
        );

        final paymentMethodId = paymentMethodBloc.state.paymentMethods.first.id;
        paymentMethodBloc.add(
          SelectPaymentMethod(paymentMethodId: paymentMethodId),
        );

        final state = await paymentMethodBloc.stream.firstWhere(
          (state) =>
              (state as PaymentMethodState).selectedPaymentMethodId ==
              paymentMethodId,
        );

        expect(state.selectedPaymentMethod, isNotNull);
        expect(state.selectedPaymentMethod!.id, equals(paymentMethodId));
      });
    });
  });
}
