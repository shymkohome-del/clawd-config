import 'dart:core';
import '../../core/logger/logger.dart';

/// Validation result containing success/failure state and error messages
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final Map<String, String> fieldErrors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.fieldErrors = const {},
  });

  /// Create successful validation result
  const ValidationResult.success() : this(isValid: true);

  /// Create failed validation result
  const ValidationResult.failure(
    List<String> errors, {
    Map<String, String>? fieldErrors,
  }) : this(
         isValid: false,
         errors: errors,
         fieldErrors: fieldErrors ?? const {},
       );

  /// Get first error message or null
  String? get firstError => errors.isNotEmpty ? errors.first : null;

  /// Get error for specific field
  String? getFieldError(String field) => fieldErrors[field];
}

/// Email validation utilities
class EmailValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  );

  static const int maxEmailLength = 254; // RFC 5321 limit

  /// Validate email format and length
  static ValidationResult validate(String? email) {
    logger.logDebug('Validating email input', tag: 'EmailValidator');

    if (email == null || email.trim().isEmpty) {
      return const ValidationResult.failure(
        ['Email is required'],
        fieldErrors: {'email': 'Email is required'},
      );
    }

    final trimmedEmail = email.trim().toLowerCase();

    // Check length
    if (trimmedEmail.length > maxEmailLength) {
      return const ValidationResult.failure(
        ['Email must be less than 254 characters'],
        fieldErrors: {'email': 'Email must be less than 254 characters'},
      );
    }

    // Check format
    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return const ValidationResult.failure(
        ['Please enter a valid email address'],
        fieldErrors: {'email': 'Please enter a valid email address'},
      );
    }

    logger.logDebug('Email validation passed', tag: 'EmailValidator');
    return const ValidationResult.success();
  }

  /// Sanitize email input
  static String sanitize(String email) {
    return email.trim().toLowerCase();
  }
}

/// Password validation utilities
class PasswordValidator {
  static const int minLength = 8;
  static const int maxLength = 128;

  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');
  static final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Validate password strength and requirements
  static ValidationResult validate(String? password) {
    logger.logDebug('Validating password input', tag: 'PasswordValidator');

    if (password == null || password.isEmpty) {
      return const ValidationResult.failure(
        ['Password is required'],
        fieldErrors: {'password': 'Password is required'},
      );
    }

    final List<String> errors = [];

    // Length check
    if (password.length < minLength) {
      errors.add('Password must be at least $minLength characters long');
    }

    if (password.length > maxLength) {
      errors.add('Password must be less than $maxLength characters');
    }

    // Character requirements
    if (!_uppercaseRegex.hasMatch(password)) {
      errors.add('Password must contain at least one uppercase letter');
    }

    if (!_lowercaseRegex.hasMatch(password)) {
      errors.add('Password must contain at least one lowercase letter');
    }

    if (!_digitRegex.hasMatch(password)) {
      errors.add('Password must contain at least one digit');
    }

    if (!_specialCharRegex.hasMatch(password)) {
      errors.add('Password must contain at least one special character');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(
        errors,
        fieldErrors: {'password': errors.first},
      );
    }

    logger.logDebug('Password validation passed', tag: 'PasswordValidator');
    return const ValidationResult.success();
  }

  /// Get password strength score (0-4)
  static int getStrengthScore(String password) {
    int score = 0;

    if (password.length >= minLength) {
      score++;
    }
    if (_uppercaseRegex.hasMatch(password) &&
        _lowercaseRegex.hasMatch(password)) {
      score++;
    }
    if (_digitRegex.hasMatch(password)) {
      score++;
    }
    if (_specialCharRegex.hasMatch(password)) {
      score++;
    }

    return score;
  }

  /// Get password strength label
  static String getStrengthLabel(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }
}

/// String validation utilities
class StringValidator {
  /// Validate string length within specified bounds
  static ValidationResult validateLength(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
    bool allowEmpty = false,
  }) {
    logger.logDebug(
      'Validating string length for $fieldName',
      tag: 'StringValidator',
    );

    if (value == null || value.trim().isEmpty) {
      if (!allowEmpty) {
        return ValidationResult.failure(
          ['$fieldName is required'],
          fieldErrors: {fieldName.toLowerCase(): '$fieldName is required'},
        );
      }
      return const ValidationResult.success();
    }

    final trimmedValue = value.trim();

    if (minLength != null && trimmedValue.length < minLength) {
      return ValidationResult.failure(
        ['$fieldName must be at least $minLength characters long'],
        fieldErrors: {
          fieldName.toLowerCase():
              '$fieldName must be at least $minLength characters long',
        },
      );
    }

    if (maxLength != null && trimmedValue.length > maxLength) {
      return ValidationResult.failure(
        ['$fieldName must be less than $maxLength characters'],
        fieldErrors: {
          fieldName.toLowerCase():
              '$fieldName must be less than $maxLength characters',
        },
      );
    }

    return const ValidationResult.success();
  }

  /// Sanitize string input
  static String sanitize(String input) {
    return input.trim();
  }

  /// Check if string contains only allowed characters
  static ValidationResult validatePattern(
    String? value,
    String fieldName,
    RegExp pattern,
    String errorMessage,
  ) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.failure(
        ['$fieldName is required'],
        fieldErrors: {fieldName.toLowerCase(): '$fieldName is required'},
      );
    }

    if (!pattern.hasMatch(value.trim())) {
      return ValidationResult.failure(
        [errorMessage],
        fieldErrors: {fieldName.toLowerCase(): errorMessage},
      );
    }

    return const ValidationResult.success();
  }
}

/// Numeric validation utilities
class NumericValidator {
  /// Validate numeric value within specified range
  static ValidationResult validateRange(
    num? value,
    String fieldName, {
    num? min,
    num? max,
    bool allowNull = false,
  }) {
    logger.logDebug(
      'Validating numeric range for $fieldName',
      tag: 'NumericValidator',
    );

    if (value == null) {
      if (!allowNull) {
        return ValidationResult.failure(
          ['$fieldName is required'],
          fieldErrors: {fieldName.toLowerCase(): '$fieldName is required'},
        );
      }
      return const ValidationResult.success();
    }

    if (min != null && value < min) {
      return ValidationResult.failure(
        ['$fieldName must be at least $min'],
        fieldErrors: {
          fieldName.toLowerCase(): '$fieldName must be at least $min',
        },
      );
    }

    if (max != null && value > max) {
      return ValidationResult.failure(
        ['$fieldName must be at most $max'],
        fieldErrors: {
          fieldName.toLowerCase(): '$fieldName must be at most $max',
        },
      );
    }

    return const ValidationResult.success();
  }

  /// Validate positive number
  static ValidationResult validatePositive(num? value, String fieldName) {
    if (value == null) {
      return ValidationResult.failure(
        ['$fieldName is required'],
        fieldErrors: {fieldName.toLowerCase(): '$fieldName is required'},
      );
    }

    if (value <= 0) {
      return ValidationResult.failure(
        ['$fieldName must be positive'],
        fieldErrors: {fieldName.toLowerCase(): '$fieldName must be positive'},
      );
    }

    return const ValidationResult.success();
  }

  /// Validate integer value
  static ValidationResult validateInteger(
    String? value,
    String fieldName, {
    int? min,
    int? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.failure(
        ['$fieldName is required'],
        fieldErrors: {fieldName.toLowerCase(): '$fieldName is required'},
      );
    }

    final int? parsedValue = int.tryParse(value.trim());
    if (parsedValue == null) {
      return ValidationResult.failure(
        ['$fieldName must be a valid integer'],
        fieldErrors: {
          fieldName.toLowerCase(): '$fieldName must be a valid integer',
        },
      );
    }

    return validateRange(parsedValue, fieldName, min: min, max: max);
  }

  /// Validate decimal value
  static ValidationResult validateDecimal(
    String? value,
    String fieldName, {
    double? min,
    double? max,
    int? decimalPlaces,
  }) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.failure(
        ['$fieldName is required'],
        fieldErrors: {fieldName.toLowerCase(): '$fieldName is required'},
      );
    }

    final double? parsedValue = double.tryParse(value.trim());
    if (parsedValue == null) {
      return ValidationResult.failure(
        ['$fieldName must be a valid number'],
        fieldErrors: {
          fieldName.toLowerCase(): '$fieldName must be a valid number',
        },
      );
    }

    // Check decimal places if specified
    if (decimalPlaces != null) {
      final parts = value.trim().split('.');
      if (parts.length > 1 && parts[1].length > decimalPlaces) {
        return ValidationResult.failure(
          ['$fieldName can have at most $decimalPlaces decimal places'],
          fieldErrors: {
            fieldName.toLowerCase():
                '$fieldName can have at most $decimalPlaces decimal places',
          },
        );
      }
    }

    return validateRange(parsedValue, fieldName, min: min, max: max);
  }
}

/// Composite validation utilities
class InputValidator {
  /// Validate login form inputs
  static ValidationResult validateLogin({
    required String? email,
    required String? password,
  }) {
    logger.logDebug('Validating login form', tag: 'InputValidator');

    final List<String> errors = [];
    final Map<String, String> fieldErrors = {};

    // Validate email
    final emailResult = EmailValidator.validate(email);
    if (!emailResult.isValid) {
      errors.addAll(emailResult.errors);
      fieldErrors.addAll(emailResult.fieldErrors);
    }

    // Basic password presence check (not strength for login)
    if (password == null || password.trim().isEmpty) {
      errors.add('Password is required');
      fieldErrors['password'] = 'Password is required';
    }

    if (errors.isNotEmpty) {
      logger.logWarn(
        'Login validation failed: ${errors.join(', ')}',
        tag: 'InputValidator',
      );
      return ValidationResult.failure(errors, fieldErrors: fieldErrors);
    }

    logger.logDebug('Login validation passed', tag: 'InputValidator');
    return const ValidationResult.success();
  }

  /// Validate registration form inputs
  static ValidationResult validateRegistration({
    required String? email,
    required String? password,
    required String? confirmPassword,
    String? firstName,
    String? lastName,
  }) {
    logger.logDebug('Validating registration form', tag: 'InputValidator');

    final List<String> errors = [];
    final Map<String, String> fieldErrors = {};

    // Validate email
    final emailResult = EmailValidator.validate(email);
    if (!emailResult.isValid) {
      errors.addAll(emailResult.errors);
      fieldErrors.addAll(emailResult.fieldErrors);
    }

    // Validate password strength
    final passwordResult = PasswordValidator.validate(password);
    if (!passwordResult.isValid) {
      errors.addAll(passwordResult.errors);
      fieldErrors.addAll(passwordResult.fieldErrors);
    }

    // Validate password confirmation
    if (password != confirmPassword) {
      errors.add('Passwords do not match');
      fieldErrors['confirmPassword'] = 'Passwords do not match';
    }

    // Validate optional name fields
    if (firstName != null) {
      final firstNameResult = StringValidator.validateLength(
        firstName,
        'First name',
        minLength: 1,
        maxLength: 50,
        allowEmpty: true,
      );
      if (!firstNameResult.isValid) {
        errors.addAll(firstNameResult.errors);
        fieldErrors.addAll(firstNameResult.fieldErrors);
      }
    }

    if (lastName != null) {
      final lastNameResult = StringValidator.validateLength(
        lastName,
        'Last name',
        minLength: 1,
        maxLength: 50,
        allowEmpty: true,
      );
      if (!lastNameResult.isValid) {
        errors.addAll(lastNameResult.errors);
        fieldErrors.addAll(lastNameResult.fieldErrors);
      }
    }

    if (errors.isNotEmpty) {
      logger.logWarn(
        'Registration validation failed: ${errors.join(', ')}',
        tag: 'InputValidator',
      );
      return ValidationResult.failure(errors, fieldErrors: fieldErrors);
    }

    logger.logDebug('Registration validation passed', tag: 'InputValidator');
    return const ValidationResult.success();
  }
}

/// Security utilities for input sanitization
class SecurityUtils {
  /// Sanitize general input to prevent basic injection attacks
  static String sanitizeInput(String input) {
    logger.logDebug('Sanitizing input', tag: 'SecurityUtils');

    // Remove potential HTML/JS injection patterns
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'[<>&"\x27`]'), ''); // Remove dangerous characters
  }

  /// Validate that input doesn't contain suspicious patterns
  static ValidationResult validateSecureInput(String? input, String fieldName) {
    if (input == null) return const ValidationResult.success();

    final List<String> suspiciousPatterns = [
      r'<script[^>]*>.*?</script>',
      r'javascript:',
      r'on\w+\s*=',
      r'<iframe[^>]*>',
      r'<object[^>]*>',
      r'<embed[^>]*>',
    ];

    for (final pattern in suspiciousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        logger.logWarn(
          'Suspicious input detected in $fieldName',
          tag: 'SecurityUtils',
          error: 'Pattern: $pattern',
        );
        return ValidationResult.failure(
          ['$fieldName contains invalid characters'],
          fieldErrors: {
            fieldName.toLowerCase(): '$fieldName contains invalid characters',
          },
        );
      }
    }

    return const ValidationResult.success();
  }
}
