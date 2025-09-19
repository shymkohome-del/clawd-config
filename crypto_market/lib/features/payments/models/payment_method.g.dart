// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankTransferDetails _$BankTransferDetailsFromJson(Map<String, dynamic> json) =>
    BankTransferDetails(
      accountNumber: json['accountNumber'] as String,
      routingNumber: json['routingNumber'] as String,
      accountHolderName: json['accountHolderName'] as String,
      bankName: json['bankName'] as String,
      swiftCode: json['swiftCode'] as String?,
      iban: json['iban'] as String?,
    );

Map<String, dynamic> _$BankTransferDetailsToJson(
  BankTransferDetails instance,
) => <String, dynamic>{
  'accountNumber': instance.accountNumber,
  'routingNumber': instance.routingNumber,
  'accountHolderName': instance.accountHolderName,
  'bankName': instance.bankName,
  'swiftCode': instance.swiftCode,
  'iban': instance.iban,
};

DigitalWalletDetails _$DigitalWalletDetailsFromJson(
  Map<String, dynamic> json,
) => DigitalWalletDetails(
  walletId: json['walletId'] as String,
  provider: json['provider'] as String,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  accountName: json['accountName'] as String?,
);

Map<String, dynamic> _$DigitalWalletDetailsToJson(
  DigitalWalletDetails instance,
) => <String, dynamic>{
  'walletId': instance.walletId,
  'provider': instance.provider,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'accountName': instance.accountName,
};

CashPaymentDetails _$CashPaymentDetailsFromJson(Map<String, dynamic> json) =>
    CashPaymentDetails(
      meetingLocation: json['meetingLocation'] as String,
      preferredTime: json['preferredTime'] as String,
      contactInfo: json['contactInfo'] as String,
      specialInstructions: json['specialInstructions'] as String?,
    );

Map<String, dynamic> _$CashPaymentDetailsToJson(CashPaymentDetails instance) =>
    <String, dynamic>{
      'meetingLocation': instance.meetingLocation,
      'preferredTime': instance.preferredTime,
      'contactInfo': instance.contactInfo,
      'specialInstructions': instance.specialInstructions,
    };

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$PaymentMethodTypeEnumMap, json['type']),
      encryptedDetails: json['encryptedDetails'] as String,
      displayName: json['displayName'] as String,
      verificationStatus: $enumDecode(
        _$VerificationStatusEnumMap,
        json['verificationStatus'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$PaymentMethodTypeEnumMap[instance.type]!,
      'encryptedDetails': instance.encryptedDetails,
      'displayName': instance.displayName,
      'verificationStatus':
          _$VerificationStatusEnumMap[instance.verificationStatus]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUsed': instance.lastUsed?.toIso8601String(),
    };

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.bankTransfer: 'bank_transfer',
  PaymentMethodType.digitalWallet: 'digital_wallet',
  PaymentMethodType.cash: 'cash',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.verified: 'verified',
  VerificationStatus.rejected: 'rejected',
};

PaymentProof _$PaymentProofFromJson(Map<String, dynamic> json) => PaymentProof(
  id: json['id'] as String,
  swapId: json['swapId'] as String,
  paymentMethodId: json['paymentMethodId'] as String,
  proofType: $enumDecode(_$PaymentProofTypeEnumMap, json['proofType']),
  ipfsHash: json['ipfsHash'] as String,
  submittedBy: json['submittedBy'] as String,
  submittedAt: DateTime.parse(json['submittedAt'] as String),
  verifiedBy: json['verifiedBy'] as String?,
  verifiedAt: json['verifiedAt'] == null
      ? null
      : DateTime.parse(json['verifiedAt'] as String),
);

Map<String, dynamic> _$PaymentProofToJson(PaymentProof instance) =>
    <String, dynamic>{
      'id': instance.id,
      'swapId': instance.swapId,
      'paymentMethodId': instance.paymentMethodId,
      'proofType': _$PaymentProofTypeEnumMap[instance.proofType]!,
      'ipfsHash': instance.ipfsHash,
      'submittedBy': instance.submittedBy,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'verifiedBy': instance.verifiedBy,
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
    };

const _$PaymentProofTypeEnumMap = {
  PaymentProofType.receipt: 'receipt',
  PaymentProofType.transactionId: 'transaction_id',
  PaymentProofType.photo: 'photo',
  PaymentProofType.confirmation: 'confirmation',
};
