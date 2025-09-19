import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/error/simple_result.dart';
import 'package:crypto_market/features/payments/models/payment_method.dart';

/// Payment validation errors
enum PaymentValidationError {
  invalidAccountNumber,
  invalidRoutingNumber,
  invalidIban,
  invalidSwiftCode,
  invalidEmail,
  invalidPhoneNumber,
  invalidWalletId,
  invalidLocation,
  invalidContactInfo,
  incompleteDetails,
  unsupportedRegion,
  formatError,
}

/// Payment validation service for different payment method types
class PaymentValidationService {
  PaymentValidationService();

  /// Validate bank transfer details
  Result<bool, PaymentValidationError> validateBankTransfer({
    required String accountNumber,
    required String routingNumber,
    required String accountHolderName,
    required String bankName,
    String? swiftCode,
    String? iban,
  }) {
    try {
      Logger.instance.logDebug(
        'Validating bank transfer details',
        tag: 'PaymentValidationService',
      );

      // Check required fields
      if (accountNumber.trim().isEmpty ||
          routingNumber.trim().isEmpty ||
          accountHolderName.trim().isEmpty ||
          bankName.trim().isEmpty) {
        Logger.instance.logWarn(
          'Missing required bank transfer fields',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.incompleteDetails);
      }

      // Validate account number (basic check - format varies by country)
      if (!_validateAccountNumber(accountNumber)) {
        Logger.instance.logWarn(
          'Invalid account number format',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.invalidAccountNumber);
      }

      // Validate routing number (US format - 9 digits)
      if (!_validateRoutingNumber(routingNumber)) {
        Logger.instance.logWarn(
          'Invalid routing number format',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.invalidRoutingNumber);
      }

      // Validate IBAN if provided
      if (iban != null && iban.isNotEmpty && !_validateIban(iban)) {
        Logger.instance.logWarn(
          'Invalid IBAN format',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.invalidIban);
      }

      // Validate SWIFT code if provided
      if (swiftCode != null &&
          swiftCode.isNotEmpty &&
          !_validateSwiftCode(swiftCode)) {
        Logger.instance.logWarn(
          'Invalid SWIFT code format',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.invalidSwiftCode);
      }

      // Validate account holder name
      if (accountHolderName.length < 2) {
        Logger.instance.logWarn(
          'Account holder name too short',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.formatError);
      }

      Logger.instance.logDebug(
        'Bank transfer validation passed',
        tag: 'PaymentValidationService',
      );

      return Result.ok(true);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Error validating bank transfer details',
        tag: 'PaymentValidationService',
        error: error,
        stackTrace: stackTrace,
      );
      return Result.err(PaymentValidationError.formatError);
    }
  }

  /// Validate digital wallet details
  Result<bool, PaymentValidationError> validateDigitalWallet({
    required String walletId,
    required String provider,
    String? email,
    String? phoneNumber,
    String? accountName,
  }) {
    try {
      Logger.instance.logDebug(
        'Validating digital wallet details',
        tag: 'PaymentValidationService',
      );

      // Check required fields
      if (walletId.trim().isEmpty || provider.trim().isEmpty) {
        Logger.instance.logWarn(
          'Missing required digital wallet fields',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.incompleteDetails);
      }

      // Validate wallet ID based on provider
      if (!_validateWalletId(walletId, provider)) {
        Logger.instance.logWarn(
          'Invalid wallet ID for provider: $provider',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.invalidWalletId);
      }

      // Validate email if provided
      if (email != null && email.isNotEmpty && !_validateEmail(email)) {
        Logger.instance.logWarn(
          'Invalid email format',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.invalidEmail);
      }

      // Validate phone number if provided
      if (phoneNumber != null &&
          phoneNumber.isNotEmpty &&
          !_validatePhoneNumber(phoneNumber)) {
        Logger.instance.logWarn(
          'Invalid phone number format',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.invalidPhoneNumber);
      }

      Logger.instance.logDebug(
        'Digital wallet validation passed',
        tag: 'PaymentValidationService',
      );

      return Result.ok(true);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Error validating digital wallet details',
        tag: 'PaymentValidationService',
        error: error,
        stackTrace: stackTrace,
      );
      return Result.err(PaymentValidationError.formatError);
    }
  }

  /// Validate cash payment details
  Result<bool, PaymentValidationError> validateCashPayment({
    required String meetingLocation,
    required String preferredTime,
    required String contactInfo,
    String? specialInstructions,
  }) {
    try {
      Logger.instance.logDebug(
        'Validating cash payment details',
        tag: 'PaymentValidationService',
      );

      // Check required fields
      if (meetingLocation.trim().isEmpty ||
          preferredTime.trim().isEmpty ||
          contactInfo.trim().isEmpty) {
        Logger.instance.logWarn(
          'Missing required cash payment fields',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.incompleteDetails);
      }

      // Validate meeting location (basic check)
      if (meetingLocation.length < 5) {
        Logger.instance.logWarn(
          'Meeting location too short',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.invalidLocation);
      }

      // Validate contact info (email or phone)
      if (!_validateEmail(contactInfo) && !_validatePhoneNumber(contactInfo)) {
        Logger.instance.logWarn(
          'Invalid contact info format',
          tag: 'PaymentValidationService',
        );
        return Result.err(PaymentValidationError.invalidContactInfo);
      }

      Logger.instance.logDebug(
        'Cash payment validation passed',
        tag: 'PaymentValidationService',
      );

      return Result.ok(true);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Error validating cash payment details',
        tag: 'PaymentValidationService',
        error: error,
        stackTrace: stackTrace,
      );
      return Result.err(PaymentValidationError.formatError);
    }
  }

  /// Validate account number format (basic validation)
  bool _validateAccountNumber(String accountNumber) {
    final cleanNumber = accountNumber.trim().replaceAll(RegExp(r'[\s-]'), '');

    // Basic validation - length varies by country
    // This is a simplified validation - in production, use country-specific rules
    if (cleanNumber.length < 8 || cleanNumber.length > 20) {
      return false;
    }

    // Check if it contains only digits
    return RegExp(r'^\d+$').hasMatch(cleanNumber);
  }

  /// Validate routing number (US format - 9 digits)
  bool _validateRoutingNumber(String routingNumber) {
    final cleanNumber = routingNumber.trim().replaceAll(RegExp(r'[\s-]'), '');

    if (cleanNumber.length != 9) {
      return false;
    }

    // Check if it contains only digits
    return RegExp(r'^\d+$').hasMatch(cleanNumber);
  }

  /// Validate IBAN format
  bool _validateIban(String iban) {
    final cleanIban = iban
        .trim()
        .replaceAll(RegExp(r'[\s-]'), '')
        .toUpperCase();

    if (cleanIban.length < 15 || cleanIban.length > 34) {
      return false;
    }

    // Basic IBAN format validation
    return RegExp(r'^[A-Z]{2}\d{2}[A-Z\d]{1,30}$').hasMatch(cleanIban);
  }

  /// Validate SWIFT/BIC code
  bool _validateSwiftCode(String swiftCode) {
    final cleanSwift = swiftCode.trim().toUpperCase();

    if (cleanSwift.length != 8 && cleanSwift.length != 11) {
      return false;
    }

    // SWIFT code format: BBBBCCLLbbb (8-11 characters)
    return RegExp(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$').hasMatch(cleanSwift);
  }

  /// Validate wallet ID based on provider
  bool _validateWalletId(String walletId, String provider) {
    final cleanWalletId = walletId.trim();
    final normalizedProvider = provider.toLowerCase();

    switch (normalizedProvider) {
      case 'paypal':
        // PayPal usually uses email addresses
        return _validateEmail(cleanWalletId) || cleanWalletId.length >= 6;

      case 'wise':
      case 'venmo':
        // Wise/Venmo can use email, phone, or username
        return _validateEmail(cleanWalletId) ||
            _validatePhoneNumber(cleanWalletId) ||
            cleanWalletId.length >= 3;

      case 'crypto':
        // Crypto wallet addresses
        return cleanWalletId.length >= 25 && cleanWalletId.length <= 42;

      default:
        // Generic validation for unknown providers
        return cleanWalletId.length >= 3;
    }
  }

  /// Validate email format
  bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate phone number format (international format)
  bool _validatePhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.trim().replaceAll(RegExp(r'[\s-()]'), '');

    // Basic international phone number validation
    if (cleanNumber.startsWith('+')) {
      return cleanNumber.length >= 10 &&
          cleanNumber.length <= 15 &&
          RegExp(r'^\+\d+$').hasMatch(cleanNumber);
    }

    // Local format (no country code)
    return cleanNumber.length >= 10 &&
        cleanNumber.length <= 15 &&
        RegExp(r'^\d+$').hasMatch(cleanNumber);
  }

  /// Get localized error message for payment validation error
  String getErrorMessage(PaymentValidationError error, String locale) {
    switch (error) {
      case PaymentValidationError.invalidAccountNumber:
        return locale == 'lv'
            ? 'Nederīgs konta numurs'
            : 'Invalid account number';
      case PaymentValidationError.invalidRoutingNumber:
        return locale == 'lv'
            ? 'Nederīgs maršrutēšanas numurs'
            : 'Invalid routing number';
      case PaymentValidationError.invalidIban:
        return locale == 'lv' ? 'Nederīgs IBAN numurs' : 'Invalid IBAN number';
      case PaymentValidationError.invalidSwiftCode:
        return locale == 'lv' ? 'Nederīgs SWIFT kods' : 'Invalid SWIFT code';
      case PaymentValidationError.invalidEmail:
        return locale == 'lv'
            ? 'Nederīgs e-pasta adrese'
            : 'Invalid email address';
      case PaymentValidationError.invalidPhoneNumber:
        return locale == 'lv'
            ? 'Nederīgs tālruņa numurs'
            : 'Invalid phone number';
      case PaymentValidationError.invalidWalletId:
        return locale == 'lv' ? 'Nederīgs maciņa ID' : 'Invalid wallet ID';
      case PaymentValidationError.invalidLocation:
        return locale == 'lv' ? 'Nederīga atrašanās vieta' : 'Invalid location';
      case PaymentValidationError.invalidContactInfo:
        return locale == 'lv'
            ? 'Nederīga kontakta informācija'
            : 'Invalid contact information';
      case PaymentValidationError.incompleteDetails:
        return locale == 'lv' ? 'Nepilnīgi detaļas' : 'Incomplete details';
      case PaymentValidationError.unsupportedRegion:
        return locale == 'lv' ? 'Neatbalstīts reģions' : 'Unsupported region';
      case PaymentValidationError.formatError:
        return locale == 'lv' ? 'Formāta kļūda' : 'Format error';
    }
  }

  /// Get validation requirements for payment method type
  Map<String, String> getValidationRequirements(
    PaymentMethodType type,
    String locale,
  ) {
    switch (type) {
      case PaymentMethodType.bankTransfer:
        return {
          'accountNumber': locale == 'lv'
              ? 'Konta numurs (8-20 cipari)'
              : 'Account number (8-20 digits)',
          'routingNumber': locale == 'lv'
              ? 'Maršrutēšanas numurs (9 cipari)'
              : 'Routing number (9 digits)',
          'accountHolderName': locale == 'lv'
              ? 'Konta īpašnieka vārds'
              : 'Account holder name',
          'bankName': locale == 'lv' ? 'Bankas nosaukums' : 'Bank name',
          'swiftCode': locale == 'lv'
              ? 'SWIFT kods (neobligāts)'
              : 'SWIFT code (optional)',
          'iban': locale == 'lv'
              ? 'IBAN numurs (neobligāts)'
              : 'IBAN number (optional)',
        };

      case PaymentMethodType.digitalWallet:
        return {
          'walletId': locale == 'lv' ? 'Maciņa ID' : 'Wallet ID',
          'provider': locale == 'lv' ? 'Pakalpojuma sniedzējs' : 'Provider',
          'email': locale == 'lv'
              ? 'E-pasta adrese (neobligāts)'
              : 'Email address (optional)',
          'phoneNumber': locale == 'lv'
              ? 'Tālruņa numurs (neobligāts)'
              : 'Phone number (optional)',
          'accountName': locale == 'lv'
              ? 'Konta nosaukums (neobligāts)'
              : 'Account name (optional)',
        };

      case PaymentMethodType.cash:
        return {
          'meetingLocation': locale == 'lv'
              ? 'Tikšanās vieta'
              : 'Meeting location',
          'preferredTime': locale == 'lv' ? 'Vēlamais laiks' : 'Preferred time',
          'contactInfo': locale == 'lv'
              ? 'Kontaktinformācija'
              : 'Contact information',
          'specialInstructions': locale == 'lv'
              ? 'Speciālas norādes (neobligāts)'
              : 'Special instructions (optional)',
        };
    }
  }

  /// Check if payment method type is supported in region
  bool isPaymentMethodSupported(PaymentMethodType type, String regionCode) {
    // This is a simplified implementation
    // In production, check against actual regional restrictions

    switch (type) {
      case PaymentMethodType.bankTransfer:
        // Bank transfers are generally supported
        return true;

      case PaymentMethodType.digitalWallet:
        // Some digital wallets have regional restrictions
        return ['US', 'EU', 'UK', 'LV'].contains(regionCode.toUpperCase());

      case PaymentMethodType.cash:
        // Cash payments are location-dependent
        return regionCode.toUpperCase() == 'LV'; // Example: Only Latvia
    }
  }
}
