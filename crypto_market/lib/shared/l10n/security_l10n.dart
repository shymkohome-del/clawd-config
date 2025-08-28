import '../../core/logger/logger.dart';

/// Validation error messages
class ValidationMessages {
  static String emailRequired() => 'Email is required';
  static String emailInvalid() => 'Please enter a valid email address';
  static String emailTooLong() => 'Email must be less than 254 characters';

  static String passwordRequired() => 'Password is required';
  static String passwordTooShort(int minLength) =>
      'Password must be at least $minLength characters long';
  static String passwordTooLong(int maxLength) =>
      'Password must be less than $maxLength characters';
  static String passwordNeedsUppercase() =>
      'Password must contain at least one uppercase letter';
  static String passwordNeedsLowercase() =>
      'Password must contain at least one lowercase letter';
  static String passwordNeedsDigit() =>
      'Password must contain at least one digit';
  static String passwordNeedsSpecialChar() =>
      'Password must contain at least one special character';
  static String passwordsDoNotMatch() => 'Passwords do not match';

  static String fieldRequired(String fieldName) => '$fieldName is required';
  static String fieldTooShort(String fieldName, int minLength) =>
      '$fieldName must be at least $minLength characters long';
  static String fieldTooLong(String fieldName, int maxLength) =>
      '$fieldName must be less than $maxLength characters';
  static String fieldMustBePositive(String fieldName) =>
      '$fieldName must be positive';
  static String fieldInvalidInteger(String fieldName) =>
      '$fieldName must be a valid integer';
  static String fieldInvalidDecimal(String fieldName) =>
      '$fieldName must be a valid number';
  static String fieldInvalidPattern(String fieldName) =>
      '$fieldName contains invalid characters';
  static String fieldOutOfRange(String fieldName, num min, num max) =>
      '$fieldName must be between $min and $max';
  static String fieldMaxDecimalPlaces(String fieldName, int places) =>
      '$fieldName can have at most $places decimal places';
}

/// Authentication error messages
class AuthMessages {
  static String invalidCredentials() => 'Invalid email or password';
  static String userNotFound() => 'User not found';
  static String emailAlreadyExists() =>
      'An account with this email already exists';
  static String weakPassword() => 'Password is too weak';
  static String accountLocked() => 'Account is temporarily locked';
  static String sessionExpired() =>
      'Your session has expired. Please log in again';
  static String authenticationRequired() =>
      'Authentication required. Please log in.';
  static String insufficientPrivileges() =>
      'You do not have permission to perform this action';
  static String invalidToken() => 'Invalid authentication token';
  static String principalMismatch() => 'Principal verification failed';
  static String loginFailed() => 'Login failed. Please try again';
  static String registrationFailed() => 'Registration failed. Please try again';

  static String roleRequired(String role) =>
      'You do not have permission to perform this action. Required role: $role';
  static String anyRoleRequired(List<String> roles) =>
      'You do not have permission to perform this action. Required roles: ${roles.join(' or ')}';
}

/// Rate limiting messages
class RateLimitMessages {
  static String rateLimitExceeded() =>
      'Rate limit exceeded. Please try again later';
  static String tooManyLoginAttempts() =>
      'Too many login attempts. Please wait before trying again';
  static String tooManyRegistrationAttempts() =>
      'Too many registration attempts. Please wait before trying again';
  static String tooManyPasswordResetAttempts() =>
      'Too many password reset attempts. Please wait before trying again';
  static String tooManyListingCreations() =>
      'You are creating listings too quickly. Please wait before creating another';
  static String tooManySearchRequests() =>
      'You are searching too frequently. Please wait a moment';
  static String tooManyProfileUpdates() =>
      'You are updating your profile too frequently. Please wait before making changes';
}

/// Security policy messages
class SecurityMessages {
  static String suspiciousInputDetected() =>
      'Invalid characters detected in input';
  static String sessionNearingExpiry() =>
      'Your session will expire soon. Please save your work';
  static String secureConnectionRequired() =>
      'A secure connection is required for this operation';
  static String invalidSecurityToken() => 'Security token verification failed';

  // GDPR/CCPA related messages
  static String dataProcessingConsent() =>
      'We need your consent to process your data';
  static String privacyPolicyAcceptance() =>
      'Please accept our privacy policy to continue';
  static String dataExportRequest() =>
      'Your data export request has been received';
  static String dataDeletionRequest() =>
      'Your data deletion request has been received';
  static String consentWithdrawn() => 'Your consent has been withdrawn';
}

/// Success messages for security operations
class SecuritySuccessMessages {
  static String loginSuccessful() => 'Welcome! You have successfully logged in';
  static String registrationSuccessful() =>
      'Your account has been created successfully';
  static String passwordChanged() =>
      'Your password has been updated successfully';
  static String passwordResetEmailSent() =>
      'Password reset instructions have been sent to your email';
  static String emailVerificationSent() =>
      'A verification email has been sent to your account';
  static String accountVerified() =>
      'Your account has been verified successfully';
  static String securitySettingsUpdated() =>
      'Your security settings have been updated';
  static String twoFactorEnabled() =>
      'Two-factor authentication has been enabled';
  static String twoFactorDisabled() =>
      'Two-factor authentication has been disabled';
  static String sessionExtended() => 'Your session has been extended';
  static String logoutSuccessful() => 'You have been logged out successfully';
}

/// Factory for creating localized security-related messages
class SecurityL10nFactory {
  // For now, using hardcoded English strings as fallback
  // TODO: Integrate with proper localization system when available

  /// Get localized validation error message
  static String getValidationError(
    String errorType, [
    Map<String, dynamic>? params,
  ]) {
    logger.logDebug(
      'Getting validation error message: $errorType',
      tag: 'SecurityL10n',
    );

    switch (errorType) {
      case 'email_required':
        return ValidationMessages.emailRequired();
      case 'email_invalid':
        return ValidationMessages.emailInvalid();
      case 'email_too_long':
        return ValidationMessages.emailTooLong();
      case 'password_required':
        return ValidationMessages.passwordRequired();
      case 'password_too_short':
        final minLength = params?['minLength'] ?? 8;
        return ValidationMessages.passwordTooShort(minLength);
      case 'password_too_long':
        final maxLength = params?['maxLength'] ?? 128;
        return ValidationMessages.passwordTooLong(maxLength);
      case 'password_needs_uppercase':
        return ValidationMessages.passwordNeedsUppercase();
      case 'password_needs_lowercase':
        return ValidationMessages.passwordNeedsLowercase();
      case 'password_needs_digit':
        return ValidationMessages.passwordNeedsDigit();
      case 'password_needs_special_char':
        return ValidationMessages.passwordNeedsSpecialChar();
      case 'passwords_do_not_match':
        return ValidationMessages.passwordsDoNotMatch();
      case 'field_required':
        final fieldName = params?['fieldName'] ?? 'Field';
        return ValidationMessages.fieldRequired(fieldName);
      case 'field_too_short':
        final fieldName = params?['fieldName'] ?? 'Field';
        final minLength = params?['minLength'] ?? 1;
        return ValidationMessages.fieldTooShort(fieldName, minLength);
      case 'field_too_long':
        final fieldName = params?['fieldName'] ?? 'Field';
        final maxLength = params?['maxLength'] ?? 100;
        return ValidationMessages.fieldTooLong(fieldName, maxLength);
      case 'field_must_be_positive':
        final fieldName = params?['fieldName'] ?? 'Field';
        return ValidationMessages.fieldMustBePositive(fieldName);
      case 'field_invalid_integer':
        final fieldName = params?['fieldName'] ?? 'Field';
        return ValidationMessages.fieldInvalidInteger(fieldName);
      case 'field_invalid_decimal':
        final fieldName = params?['fieldName'] ?? 'Field';
        return ValidationMessages.fieldInvalidDecimal(fieldName);
      case 'field_invalid_pattern':
        final fieldName = params?['fieldName'] ?? 'Field';
        return ValidationMessages.fieldInvalidPattern(fieldName);
      case 'field_out_of_range':
        final fieldName = params?['fieldName'] ?? 'Field';
        final min = params?['min'] ?? 0;
        final max = params?['max'] ?? 100;
        return ValidationMessages.fieldOutOfRange(fieldName, min, max);
      case 'field_max_decimal_places':
        final fieldName = params?['fieldName'] ?? 'Field';
        final places = params?['places'] ?? 2;
        return ValidationMessages.fieldMaxDecimalPlaces(fieldName, places);
      default:
        logger.logWarn(
          'Unknown validation error type: $errorType',
          tag: 'SecurityL10n',
        );
        return 'Validation error';
    }
  }

  /// Get localized authentication error message
  static String getAuthError(String errorType, [Map<String, dynamic>? params]) {
    logger.logDebug(
      'Getting auth error message: $errorType',
      tag: 'SecurityL10n',
    );

    switch (errorType) {
      case 'invalid_credentials':
        return AuthMessages.invalidCredentials();
      case 'user_not_found':
        return AuthMessages.userNotFound();
      case 'email_already_exists':
        return AuthMessages.emailAlreadyExists();
      case 'weak_password':
        return AuthMessages.weakPassword();
      case 'account_locked':
        return AuthMessages.accountLocked();
      case 'session_expired':
        return AuthMessages.sessionExpired();
      case 'authentication_required':
        return AuthMessages.authenticationRequired();
      case 'insufficient_privileges':
        return AuthMessages.insufficientPrivileges();
      case 'invalid_token':
        return AuthMessages.invalidToken();
      case 'principal_mismatch':
        return AuthMessages.principalMismatch();
      case 'login_failed':
        return AuthMessages.loginFailed();
      case 'registration_failed':
        return AuthMessages.registrationFailed();
      case 'role_required':
        final role = params?['role'] ?? 'unknown';
        return AuthMessages.roleRequired(role);
      case 'any_role_required':
        final roles = List<String>.from(params?['roles'] ?? ['unknown']);
        return AuthMessages.anyRoleRequired(roles);
      default:
        logger.logWarn(
          'Unknown auth error type: $errorType',
          tag: 'SecurityL10n',
        );
        return 'Authentication error';
    }
  }

  /// Get localized rate limit error message
  static String getRateLimitError(String operation) {
    logger.logDebug(
      'Getting rate limit error message for: $operation',
      tag: 'SecurityL10n',
    );

    switch (operation) {
      case 'auth.login':
        return RateLimitMessages.tooManyLoginAttempts();
      case 'auth.register':
        return RateLimitMessages.tooManyRegistrationAttempts();
      case 'auth.password_reset':
        return RateLimitMessages.tooManyPasswordResetAttempts();
      case 'listing.create':
        return RateLimitMessages.tooManyListingCreations();
      case 'listing.search':
        return RateLimitMessages.tooManySearchRequests();
      case 'profile.update':
        return RateLimitMessages.tooManyProfileUpdates();
      default:
        return RateLimitMessages.rateLimitExceeded();
    }
  }

  /// Get localized security message
  static String getSecurityMessage(
    String messageType, [
    Map<String, dynamic>? params,
  ]) {
    logger.logDebug(
      'Getting security message: $messageType',
      tag: 'SecurityL10n',
    );

    switch (messageType) {
      case 'suspicious_input_detected':
        return SecurityMessages.suspiciousInputDetected();
      case 'session_nearing_expiry':
        return SecurityMessages.sessionNearingExpiry();
      case 'secure_connection_required':
        return SecurityMessages.secureConnectionRequired();
      case 'invalid_security_token':
        return SecurityMessages.invalidSecurityToken();
      case 'data_processing_consent':
        return SecurityMessages.dataProcessingConsent();
      case 'privacy_policy_acceptance':
        return SecurityMessages.privacyPolicyAcceptance();
      case 'data_export_request':
        return SecurityMessages.dataExportRequest();
      case 'data_deletion_request':
        return SecurityMessages.dataDeletionRequest();
      case 'consent_withdrawn':
        return SecurityMessages.consentWithdrawn();
      default:
        logger.logWarn(
          'Unknown security message type: $messageType',
          tag: 'SecurityL10n',
        );
        return 'Security message';
    }
  }

  /// Get localized success message
  static String getSuccessMessage(
    String messageType, [
    Map<String, dynamic>? params,
  ]) {
    logger.logDebug(
      'Getting success message: $messageType',
      tag: 'SecurityL10n',
    );

    switch (messageType) {
      case 'login_successful':
        return SecuritySuccessMessages.loginSuccessful();
      case 'registration_successful':
        return SecuritySuccessMessages.registrationSuccessful();
      case 'password_changed':
        return SecuritySuccessMessages.passwordChanged();
      case 'password_reset_email_sent':
        return SecuritySuccessMessages.passwordResetEmailSent();
      case 'email_verification_sent':
        return SecuritySuccessMessages.emailVerificationSent();
      case 'account_verified':
        return SecuritySuccessMessages.accountVerified();
      case 'security_settings_updated':
        return SecuritySuccessMessages.securitySettingsUpdated();
      case 'two_factor_enabled':
        return SecuritySuccessMessages.twoFactorEnabled();
      case 'two_factor_disabled':
        return SecuritySuccessMessages.twoFactorDisabled();
      case 'session_extended':
        return SecuritySuccessMessages.sessionExtended();
      case 'logout_successful':
        return SecuritySuccessMessages.logoutSuccessful();
      default:
        logger.logWarn(
          'Unknown success message type: $messageType',
          tag: 'SecurityL10n',
        );
        return 'Operation successful';
    }
  }

  /// Format message with parameters
  static String formatMessage(String template, Map<String, dynamic> params) {
    String result = template;

    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });

    return result;
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int score) {
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
