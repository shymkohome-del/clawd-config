part of 'payment_method_provider.dart';

/// Base class for payment method events
abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

/// Load payment methods for user
class LoadPaymentMethods extends PaymentMethodEvent {
  final String userId;

  const LoadPaymentMethods({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Add new payment method
class AddPaymentMethod extends PaymentMethodEvent {
  final String userId;
  final PaymentMethodType type;
  final String accountNumber;
  final String routingNumber;
  final String accountHolderName;
  final String bankName;
  final String? swiftCode;
  final String? iban;
  final String walletId;
  final String provider;
  final String? email;
  final String? phoneNumber;
  final String? accountName;
  final String meetingLocation;
  final String preferredTime;
  final String contactInfo;
  final String? specialInstructions;
  final String locale;

  const AddPaymentMethod({
    required this.userId,
    required this.type,
    required this.accountNumber,
    required this.routingNumber,
    required this.accountHolderName,
    required this.bankName,
    this.swiftCode,
    this.iban,
    required this.walletId,
    required this.provider,
    this.email,
    this.phoneNumber,
    this.accountName,
    required this.meetingLocation,
    required this.preferredTime,
    required this.contactInfo,
    this.specialInstructions,
    required this.locale,
  });

  @override
  List<Object?> get props => [
    userId,
    type,
    accountNumber,
    routingNumber,
    accountHolderName,
    bankName,
    swiftCode,
    iban,
    walletId,
    provider,
    email,
    phoneNumber,
    accountName,
    meetingLocation,
    preferredTime,
    contactInfo,
    specialInstructions,
    locale,
  ];
}

/// Update existing payment method
class UpdatePaymentMethod extends PaymentMethodEvent {
  final String paymentMethodId;
  final PaymentMethodType type;
  final String accountNumber;
  final String routingNumber;
  final String accountHolderName;
  final String bankName;
  final String? swiftCode;
  final String? iban;
  final String walletId;
  final String provider;
  final String? email;
  final String? phoneNumber;
  final String? accountName;
  final String meetingLocation;
  final String preferredTime;
  final String contactInfo;
  final String? specialInstructions;
  final String locale;

  const UpdatePaymentMethod({
    required this.paymentMethodId,
    required this.type,
    required this.accountNumber,
    required this.routingNumber,
    required this.accountHolderName,
    required this.bankName,
    this.swiftCode,
    this.iban,
    required this.walletId,
    required this.provider,
    this.email,
    this.phoneNumber,
    this.accountName,
    required this.meetingLocation,
    required this.preferredTime,
    required this.contactInfo,
    this.specialInstructions,
    required this.locale,
  });

  @override
  List<Object?> get props => [
    paymentMethodId,
    type,
    accountNumber,
    routingNumber,
    accountHolderName,
    bankName,
    swiftCode,
    iban,
    walletId,
    provider,
    email,
    phoneNumber,
    accountName,
    meetingLocation,
    preferredTime,
    contactInfo,
    specialInstructions,
    locale,
  ];
}

/// Delete payment method
class DeletePaymentMethod extends PaymentMethodEvent {
  final String paymentMethodId;

  const DeletePaymentMethod({required this.paymentMethodId});

  @override
  List<Object?> get props => [paymentMethodId];
}

/// Validate payment method details
class ValidatePaymentMethod extends PaymentMethodEvent {
  final PaymentMethodType type;
  final String accountNumber;
  final String routingNumber;
  final String accountHolderName;
  final String bankName;
  final String? swiftCode;
  final String? iban;
  final String walletId;
  final String provider;
  final String? email;
  final String? phoneNumber;
  final String? accountName;
  final String meetingLocation;
  final String preferredTime;
  final String contactInfo;
  final String? specialInstructions;
  final String locale;

  const ValidatePaymentMethod({
    required this.type,
    required this.accountNumber,
    required this.routingNumber,
    required this.accountHolderName,
    required this.bankName,
    this.swiftCode,
    this.iban,
    required this.walletId,
    required this.provider,
    this.email,
    this.phoneNumber,
    this.accountName,
    required this.meetingLocation,
    required this.preferredTime,
    required this.contactInfo,
    this.specialInstructions,
    required this.locale,
  });

  @override
  List<Object?> get props => [
    type,
    accountNumber,
    routingNumber,
    accountHolderName,
    bankName,
    swiftCode,
    iban,
    walletId,
    provider,
    email,
    phoneNumber,
    accountName,
    meetingLocation,
    preferredTime,
    contactInfo,
    specialInstructions,
    locale,
  ];
}

/// Select payment method
class SelectPaymentMethod extends PaymentMethodEvent {
  final String? paymentMethodId;

  const SelectPaymentMethod({this.paymentMethodId});

  @override
  List<Object?> get props => [paymentMethodId];
}

/// Clear payment method error
class ClearPaymentMethodError extends PaymentMethodEvent {
  const ClearPaymentMethodError();
}
