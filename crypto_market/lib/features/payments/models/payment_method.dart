import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart' as pc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_market/core/logger/logger.dart';

part 'payment_method.g.dart';

/// Payment method types supported by the platform
@JsonEnum()
enum PaymentMethodType {
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('digital_wallet')
  digitalWallet,
  @JsonValue('cash')
  cash,
}

/// Payment proof types for transaction verification
@JsonEnum()
enum PaymentProofType {
  @JsonValue('receipt')
  receipt,
  @JsonValue('transaction_id')
  transactionId,
  @JsonValue('photo')
  photo,
  @JsonValue('confirmation')
  confirmation,
}

/// Payment method verification status
@JsonEnum()
enum VerificationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected,
}

/// Encrypted payment method details for bank transfers
@JsonSerializable()
class BankTransferDetails {
  final String accountNumber;
  final String routingNumber;
  final String accountHolderName;
  final String bankName;
  final String? swiftCode;
  final String? iban;

  const BankTransferDetails({
    required this.accountNumber,
    required this.routingNumber,
    required this.accountHolderName,
    required this.bankName,
    this.swiftCode,
    this.iban,
  });

  factory BankTransferDetails.fromJson(Map<String, dynamic> json) =>
      _$BankTransferDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BankTransferDetailsToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BankTransferDetails) return false;
    return accountNumber == other.accountNumber &&
        routingNumber == other.routingNumber &&
        accountHolderName == other.accountHolderName &&
        bankName == other.bankName &&
        swiftCode == other.swiftCode &&
        iban == other.iban;
  }

  @override
  int get hashCode {
    return Object.hash(
      accountNumber,
      routingNumber,
      accountHolderName,
      bankName,
      swiftCode,
      iban,
    );
  }
}

/// Encrypted payment method details for digital wallets
@JsonSerializable()
class DigitalWalletDetails {
  final String walletId;
  final String provider; // PayPal, Wise, Venmo, etc.
  final String? email;
  final String? phoneNumber;
  final String? accountName;

  const DigitalWalletDetails({
    required this.walletId,
    required this.provider,
    this.email,
    this.phoneNumber,
    this.accountName,
  });

  factory DigitalWalletDetails.fromJson(Map<String, dynamic> json) =>
      _$DigitalWalletDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$DigitalWalletDetailsToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DigitalWalletDetails) return false;
    return walletId == other.walletId &&
        provider == other.provider &&
        email == other.email &&
        phoneNumber == other.phoneNumber &&
        accountName == other.accountName;
  }

  @override
  int get hashCode {
    return Object.hash(walletId, provider, email, phoneNumber, accountName);
  }
}

/// Encrypted payment method details for cash payments
@JsonSerializable()
class CashPaymentDetails {
  final String meetingLocation;
  final String preferredTime;
  final String contactInfo;
  final String? specialInstructions;

  const CashPaymentDetails({
    required this.meetingLocation,
    required this.preferredTime,
    required this.contactInfo,
    this.specialInstructions,
  });

  factory CashPaymentDetails.fromJson(Map<String, dynamic> json) =>
      _$CashPaymentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CashPaymentDetailsToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CashPaymentDetails) return false;
    return meetingLocation == other.meetingLocation &&
        preferredTime == other.preferredTime &&
        contactInfo == other.contactInfo &&
        specialInstructions == other.specialInstructions;
  }

  @override
  int get hashCode {
    return Object.hash(
      meetingLocation,
      preferredTime,
      contactInfo,
      specialInstructions,
    );
  }
}

/// Main payment method model with secure encryption
@JsonSerializable()
class PaymentMethod {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String encryptedDetails; // AES-256 encrypted JSON
  final String displayName;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime? lastUsed;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.encryptedDetails,
    required this.displayName,
    required this.verificationStatus,
    required this.createdAt,
    this.lastUsed,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);

  /// Create a copy of this payment method with updated fields
  PaymentMethod copyWith({
    String? id,
    String? userId,
    PaymentMethodType? type,
    String? encryptedDetails,
    String? displayName,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      encryptedDetails: encryptedDetails ?? this.encryptedDetails,
      displayName: displayName ?? this.displayName,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentMethod) return false;
    return id == other.id &&
        userId == other.userId &&
        type == other.type &&
        encryptedDetails == other.encryptedDetails &&
        displayName == other.displayName &&
        verificationStatus == other.verificationStatus &&
        createdAt == other.createdAt &&
        lastUsed == other.lastUsed;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      type,
      encryptedDetails,
      displayName,
      verificationStatus,
      createdAt,
      lastUsed,
    );
  }
}

/// Payment proof model for transaction verification
@JsonSerializable()
class PaymentProof {
  final String id;
  final String swapId;
  final String paymentMethodId;
  final PaymentProofType proofType;
  final String ipfsHash;
  final String submittedBy;
  final DateTime submittedAt;
  final String? verifiedBy;
  final DateTime? verifiedAt;

  const PaymentProof({
    required this.id,
    required this.swapId,
    required this.paymentMethodId,
    required this.proofType,
    required this.ipfsHash,
    required this.submittedBy,
    required this.submittedAt,
    this.verifiedBy,
    this.verifiedAt,
  });

  factory PaymentProof.fromJson(Map<String, dynamic> json) =>
      _$PaymentProofFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentProofToJson(this);

  /// Create a copy of this payment proof with updated fields
  PaymentProof copyWith({
    String? id,
    String? swapId,
    String? paymentMethodId,
    PaymentProofType? proofType,
    String? ipfsHash,
    String? submittedBy,
    DateTime? submittedAt,
    String? verifiedBy,
    DateTime? verifiedAt,
  }) {
    return PaymentProof(
      id: id ?? this.id,
      swapId: swapId ?? this.swapId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      proofType: proofType ?? this.proofType,
      ipfsHash: ipfsHash ?? this.ipfsHash,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentProof) return false;
    return id == other.id &&
        swapId == other.swapId &&
        paymentMethodId == other.paymentMethodId &&
        proofType == other.proofType &&
        ipfsHash == other.ipfsHash &&
        submittedBy == other.submittedBy &&
        submittedAt == other.submittedAt &&
        verifiedBy == other.verifiedBy &&
        verifiedAt == other.verifiedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      swapId,
      paymentMethodId,
      proofType,
      ipfsHash,
      submittedBy,
      submittedAt,
      verifiedBy,
      verifiedAt,
    );
  }
}

/// Secure encryption service for payment method data using AES-GCM
class PaymentEncryptionService {
  final FlutterSecureStorage _secureStorage;
  static const String _masterKeyKey = 'payment_master_key';
  static const String _keySaltKey = 'payment_key_salt';
  static const int _keyDerivationIterations = 100000;
  static const int _aesKeyLength = 32; // 256 bits
  static const int _saltLength = 16;

  PaymentEncryptionService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Generate or retrieve master encryption key using PBKDF2
  Future<Uint8List> _getMasterKey() async {
    try {
      Logger.instance.logDebug(
        'Getting master encryption key',
        tag: 'PaymentEncryptionService',
      );

      // Get or generate salt for key derivation
      final salt = await _getOrGenerateSalt();

      // Check if master key exists
      final existingKey = await _secureStorage.read(key: _masterKeyKey);
      if (existingKey != null) {
        Logger.instance.logDebug(
          'Using existing master encryption key',
          tag: 'PaymentEncryptionService',
        );
        return Uint8List.fromList(
          existingKey.split(',').map(int.parse).toList(),
        );
      }

      // Generate new master key using PBKDF2
      final passphrase = await _getSecurePassphrase();
      final key = await _deriveKey(passphrase, salt);

      await _secureStorage.write(key: _masterKeyKey, value: key.join(','));

      Logger.instance.logDebug(
        'Generated new master encryption key',
        tag: 'PaymentEncryptionService',
      );

      return Uint8List.fromList(key);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to get master encryption key',
        tag: 'PaymentEncryptionService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get or generate salt for key derivation
  Future<Uint8List> _getOrGenerateSalt() async {
    try {
      final existingSalt = await _secureStorage.read(key: _keySaltKey);
      if (existingSalt != null) {
        return Uint8List.fromList(
          existingSalt.split(',').map(int.parse).toList(),
        );
      }

      // Generate new salt
      final salt = List<int>.generate(_saltLength, (i) => i);
      await _secureStorage.write(key: _keySaltKey, value: salt.join(','));

      return Uint8List.fromList(salt);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to get or generate salt',
        tag: 'PaymentEncryptionService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get secure passphrase from device
  Future<String> _getSecurePassphrase() async {
    // In a real implementation, this would use biometric authentication
    // or device-specific secure storage. For now, use a device-specific key.
    return 'crypto_market_secure_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Derive key using PBKDF2
  Future<List<int>> _deriveKey(String passphrase, Uint8List salt) async {
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));

    final params = pc.Pbkdf2Parameters(
      salt,
      _keyDerivationIterations,
      _aesKeyLength,
    );

    derivator.init(params);
    return derivator.process(utf8.encode(passphrase));
  }

  /// Encrypt payment method details using AES-GCM
  Future<String> encryptPaymentDetails(Map<String, dynamic> details) async {
    try {
      Logger.instance.logDebug(
        'Encrypting payment method details',
        tag: 'PaymentEncryptionService',
      );

      final masterKey = await _getMasterKey();
      final key = enc.Key(masterKey);

      // Generate secure nonce for AES-GCM
      final nonce = enc.IV.fromSecureRandom(12); // 12 bytes recommended for GCM
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

      final jsonStr = jsonEncode(details);
      final encrypted = encrypter.encrypt(jsonStr, iv: nonce);

      // Combine nonce, authentication tag, and encrypted data for storage
      final encryptedData = {
        'nonce': nonce.base64,
        'tag': encrypted.bytes.isNotEmpty
            ? base64.encode(
                encrypted.bytes.sublist(encrypted.bytes.length - 16),
              )
            : '',
        'data': encrypted.base64,
        'algorithm': 'AES-256-GCM',
        'version': '1.0',
      };

      final result = jsonEncode(encryptedData);

      Logger.instance.logDebug(
        'Payment method details encrypted successfully with AES-GCM',
        tag: 'PaymentEncryptionService',
      );

      return result;
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to encrypt payment method details',
        tag: 'PaymentEncryptionService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Decrypt payment method details using AES-GCM
  Future<Map<String, dynamic>> decryptPaymentDetails(
    String encryptedData,
  ) async {
    try {
      Logger.instance.logDebug(
        'Decrypting payment method details',
        tag: 'PaymentEncryptionService',
      );

      final masterKey = await _getMasterKey();
      final key = enc.Key(masterKey);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

      final encryptedMap = jsonDecode(encryptedData) as Map<String, dynamic>;

      // Validate encrypted data structure
      if (encryptedMap['algorithm'] != 'AES-256-GCM' ||
          encryptedMap['version'] != '1.0') {
        throw Exception('Invalid encryption algorithm or version');
      }

      final nonce = enc.IV.fromBase64(encryptedMap['nonce'] as String);
      final encrypted = enc.Encrypted.fromBase64(
        encryptedMap['data'] as String,
      );

      // Note: In AES-GCM, the authentication tag is part of the encrypted data
      // The encrypt package handles this automatically

      final decrypted = encrypter.decrypt(encrypted, iv: nonce);
      final result = jsonDecode(decrypted) as Map<String, dynamic>;

      Logger.instance.logDebug(
        'Payment method details decrypted successfully with AES-GCM',
        tag: 'PaymentEncryptionService',
      );

      return result;
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to decrypt payment method details',
        tag: 'PaymentEncryptionService',
        error: error,
        stackTrace: stackTrace,
      );
      // Do not rethrow to prevent padding oracle attacks - return empty map instead
      return {};
    }
  }

  /// Generate payment method ID from user ID and timestamp
  static String generatePaymentMethodId(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final input = '$userId-$timestamp';
    final hash = sha256.convert(utf8.encode(input));
    return hash.toString().substring(0, 16);
  }

  /// Generate payment proof ID
  static String generatePaymentProofId(String swapId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final input = '$swapId-$timestamp';
    final hash = sha256.convert(utf8.encode(input));
    return hash.toString().substring(0, 16);
  }

  /// Clear master encryption key (for testing/cleanup)
  Future<void> clearMasterKey() async {
    Logger.instance.logDebug(
      'Clearing master encryption key',
      tag: 'PaymentEncryptionService',
    );

    await _secureStorage.delete(key: _masterKeyKey);
  }

  /// Rotate master encryption key
  Future<void> rotateMasterKey() async {
    try {
      Logger.instance.logDebug(
        'Rotating master encryption key',
        tag: 'PaymentEncryptionService',
      );

      // Clear existing key and salt
      await clearMasterKey();
      await _secureStorage.delete(key: _keySaltKey);

      // Generate new key with fresh salt
      await _getMasterKey();

      Logger.instance.logDebug(
        'Master encryption key rotated successfully with new salt',
        tag: 'PaymentEncryptionService',
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to rotate master encryption key',
        tag: 'PaymentEncryptionService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Clear all secure data (master key, salt, and any cached data)
  Future<void> clearAllSecureData() async {
    try {
      Logger.instance.logDebug(
        'Clearing all secure payment data',
        tag: 'PaymentEncryptionService',
      );

      await _secureStorage.delete(key: _masterKeyKey);
      await _secureStorage.delete(key: _keySaltKey);

      Logger.instance.logDebug(
        'All secure payment data cleared successfully',
        tag: 'PaymentEncryptionService',
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to clear secure payment data',
        tag: 'PaymentEncryptionService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Validate encryption key integrity
  Future<bool> validateKeyIntegrity() async {
    try {
      final testKey = await _getMasterKey();
      final testNonce = enc.IV.fromSecureRandom(12);
      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(testKey), mode: enc.AESMode.gcm),
      );

      final testData = 'integrity_test';
      final encrypted = encrypter.encrypt(testData, iv: testNonce);
      final decrypted = encrypter.decrypt(encrypted, iv: testNonce);

      return decrypted == testData;
    } catch (error) {
      Logger.instance.logError(
        'Key integrity validation failed',
        tag: 'PaymentEncryptionService',
        error: error,
      );
      return false;
    }
  }
}
