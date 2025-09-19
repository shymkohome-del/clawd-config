import 'package:flutter/material.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/logger/logger.dart';

/// Enhanced error types for authentication
enum AuthErrorType {
  invalidCredentials,
  oauthDenied,
  network,
  unknown,
  weakPassword,
  emailInUse,
  usernameTaken,
  invalidEmail,
  invalidUsername,
  sessionExpired,
  tokenExpired,
  rateLimited,
  serverError,
  forbidden,
  unauthorized,
  configurationError,
  userNotFound,
  accountLocked,
  accountDisabled,
  verificationRequired,
  termsNotAccepted,
  passwordMismatch,
  oauthProviderUnavailable,
  oauthTokenInvalid,
  oauthScopeDenied,
  biometricError,
  secureStorageError,
  icpServiceError,
  jwtError,
  validationError,
  unknownError,
}

/// Authentication error details
class AuthErrorDetails {
  final AuthErrorType type;
  final String message;
  final String? technicalDetails;
  final DateTime timestamp;
  final String? code;
  final Map<String, dynamic>? additionalData;
  final StackTrace? stackTrace;

  const AuthErrorDetails({
    required this.type,
    required this.message,
    this.technicalDetails,
    required this.timestamp,
    this.code,
    this.additionalData,
    this.stackTrace,
  });

  factory AuthErrorDetails.fromException(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    final timestamp = DateTime.now();
    final errorString = error.toString().toLowerCase();

    // Map common exceptions to AuthErrorType
    AuthErrorType type = AuthErrorType.unknown;
    String message = 'An unknown error occurred';
    String? technicalDetails;
    String? code;

    if (error is AuthInvalidCredentialsException) {
      type = AuthErrorType.invalidCredentials;
      message = 'Invalid email or password';
      code = 'AUTH_INVALID_CREDENTIALS';
    } else if (error is OAuthDeniedException) {
      type = AuthErrorType.oauthDenied;
      message = 'OAuth authentication was denied or cancelled';
      code = 'AUTH_OAUTH_DENIED';
    } else if (error is AuthNetworkException) {
      type = AuthErrorType.network;
      message = 'Network connection error';
      code = 'AUTH_NETWORK_ERROR';
    } else if (error is AuthUnknownException) {
      type = AuthErrorType.unknown;
      message = 'An unknown authentication error occurred';
      code = 'AUTH_UNKNOWN_ERROR';
    }

    // String-based heuristics for additional error types
    if (errorString.contains('weak') && errorString.contains('password')) {
      type = AuthErrorType.weakPassword;
      message = 'Password is too weak';
      code = 'AUTH_WEAK_PASSWORD';
    } else if (errorString.contains('email') && errorString.contains('use')) {
      type = AuthErrorType.emailInUse;
      message = 'Email address is already in use';
      code = 'AUTH_EMAIL_IN_USE';
    } else if (errorString.contains('username') &&
        errorString.contains('taken')) {
      type = AuthErrorType.usernameTaken;
      message = 'Username is already taken';
      code = 'AUTH_USERNAME_TAKEN';
    } else if (errorString.contains('invalid') &&
        errorString.contains('email')) {
      type = AuthErrorType.invalidEmail;
      message = 'Invalid email address';
      code = 'AUTH_INVALID_EMAIL';
    } else if (errorString.contains('invalid') &&
        errorString.contains('username')) {
      type = AuthErrorType.invalidUsername;
      message = 'Invalid username';
      code = 'AUTH_INVALID_USERNAME';
    } else if (errorString.contains('session') &&
        errorString.contains('expir')) {
      type = AuthErrorType.sessionExpired;
      message = 'Session has expired';
      code = 'AUTH_SESSION_EXPIRED';
    } else if (errorString.contains('token') && errorString.contains('expir')) {
      type = AuthErrorType.tokenExpired;
      message = 'Authentication token has expired';
      code = 'AUTH_TOKEN_EXPIRED';
    } else if (errorString.contains('rate') && errorString.contains('limit')) {
      type = AuthErrorType.rateLimited;
      message = 'Too many attempts. Please try again later';
      code = 'AUTH_RATE_LIMITED';
    } else if (errorString.contains('server') || errorString.contains('500')) {
      type = AuthErrorType.serverError;
      message = 'Server error. Please try again later';
      code = 'AUTH_SERVER_ERROR';
    } else if (errorString.contains('forbidden') ||
        errorString.contains('403')) {
      type = AuthErrorType.forbidden;
      message = 'Access denied';
      code = 'AUTH_FORBIDDEN';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      type = AuthErrorType.unauthorized;
      message = 'Unauthorized access';
      code = 'AUTH_UNAUTHORIZED';
    } else if (errorString.contains('configuration')) {
      type = AuthErrorType.configurationError;
      message = 'Configuration error';
      code = 'AUTH_CONFIGURATION_ERROR';
    } else if (errorString.contains('user') &&
        errorString.contains('not found')) {
      type = AuthErrorType.userNotFound;
      message = 'User not found';
      code = 'AUTH_USER_NOT_FOUND';
    } else if (errorString.contains('locked')) {
      type = AuthErrorType.accountLocked;
      message = 'Account is locked';
      code = 'AUTH_ACCOUNT_LOCKED';
    } else if (errorString.contains('disabled')) {
      type = AuthErrorType.accountDisabled;
      message = 'Account is disabled';
      code = 'AUTH_ACCOUNT_DISABLED';
    } else if (errorString.contains('verification')) {
      type = AuthErrorType.verificationRequired;
      message = 'Email verification required';
      code = 'AUTH_VERIFICATION_REQUIRED';
    } else if (errorString.contains('terms') ||
        errorString.contains('conditions')) {
      type = AuthErrorType.termsNotAccepted;
      message = 'Terms and conditions must be accepted';
      code = 'AUTH_TERMS_NOT_ACCEPTED';
    } else if (errorString.contains('password') &&
        errorString.contains('match')) {
      type = AuthErrorType.passwordMismatch;
      message = 'Passwords do not match';
      code = 'AUTH_PASSWORD_MISMATCH';
    } else if (errorString.contains('oauth') &&
        errorString.contains('unavailable')) {
      type = AuthErrorType.oauthProviderUnavailable;
      message = 'OAuth provider is not available';
      code = 'AUTH_OAUTH_UNAVAILABLE';
    } else if (errorString.contains('oauth') && errorString.contains('token')) {
      type = AuthErrorType.oauthTokenInvalid;
      message = 'Invalid OAuth token';
      code = 'AUTH_OAUTH_TOKEN_INVALID';
    } else if (errorString.contains('oauth') && errorString.contains('scope')) {
      type = AuthErrorType.oauthScopeDenied;
      message = 'OAuth scope denied';
      code = 'AUTH_OAUTH_SCOPE_DENIED';
    } else if (errorString.contains('biometric')) {
      type = AuthErrorType.biometricError;
      message = 'Biometric authentication error';
      code = 'AUTH_BIOMETRIC_ERROR';
    } else if (errorString.contains('storage') ||
        errorString.contains('secure')) {
      type = AuthErrorType.secureStorageError;
      message = 'Secure storage error';
      code = 'AUTH_SECURE_STORAGE_ERROR';
    } else if (errorString.contains('icp')) {
      type = AuthErrorType.icpServiceError;
      message = 'ICP service error';
      code = 'AUTH_ICP_SERVICE_ERROR';
    } else if (errorString.contains('jwt')) {
      type = AuthErrorType.jwtError;
      message = 'JWT token error';
      code = 'AUTH_JWT_ERROR';
    } else if (errorString.contains('validation')) {
      type = AuthErrorType.validationError;
      message = 'Validation error';
      code = 'AUTH_VALIDATION_ERROR';
    }

    technicalDetails = error.toString();

    return AuthErrorDetails(
      type: type,
      message: message,
      technicalDetails: technicalDetails,
      timestamp: timestamp,
      code: code,
      additionalData: additionalData,
      stackTrace: stackTrace,
    );
  }

  /// Convert to JSON for logging/serialization
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'message': message,
      'technicalDetails': technicalDetails,
      'timestamp': timestamp.toIso8601String(),
      'code': code,
      'additionalData': additionalData,
      'stackTrace': stackTrace?.toString(),
    };
  }

  /// Create a user-friendly display message
  String get displayMessage {
    switch (type) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid email or password. Please check your credentials.';
      case AuthErrorType.oauthDenied:
        return 'OAuth authentication was cancelled. Please try again.';
      case AuthErrorType.network:
        return 'Network error. Please check your connection and try again.';
      case AuthErrorType.weakPassword:
        return 'Password is too weak. Please include uppercase, lowercase, and numbers.';
      case AuthErrorType.emailInUse:
        return 'This email address is already in use. Please try logging in or use a different email.';
      case AuthErrorType.usernameTaken:
        return 'This username is already taken. Please choose a different username.';
      case AuthErrorType.invalidEmail:
        return 'Please enter a valid email address.';
      case AuthErrorType.invalidUsername:
        return 'Username must be 3-20 characters and contain only letters, numbers, and underscores.';
      case AuthErrorType.sessionExpired:
        return 'Your session has expired. Please log in again.';
      case AuthErrorType.tokenExpired:
        return 'Your authentication has expired. Please log in again.';
      case AuthErrorType.rateLimited:
        return 'Too many attempts. Please wait a few minutes and try again.';
      case AuthErrorType.serverError:
        return 'Server error. Please try again later.';
      case AuthErrorType.forbidden:
        return 'Access denied. You don\'t have permission to perform this action.';
      case AuthErrorType.unauthorized:
        return 'Unauthorized access. Please log in and try again.';
      case AuthErrorType.configurationError:
        return 'Configuration error. Please contact support.';
      case AuthErrorType.userNotFound:
        return 'User not found. Please check your credentials or register for an account.';
      case AuthErrorType.accountLocked:
        return 'Your account is locked. Please contact support.';
      case AuthErrorType.accountDisabled:
        return 'Your account is disabled. Please contact support.';
      case AuthErrorType.verificationRequired:
        return 'Please verify your email address before continuing.';
      case AuthErrorType.termsNotAccepted:
        return 'You must accept the terms and conditions to continue.';
      case AuthErrorType.passwordMismatch:
        return 'Passwords do not match. Please try again.';
      case AuthErrorType.oauthProviderUnavailable:
        return 'OAuth provider is currently unavailable. Please try again later.';
      case AuthErrorType.oauthTokenInvalid:
        return 'Invalid OAuth token. Please try again.';
      case AuthErrorType.oauthScopeDenied:
        return 'OAuth scope denied. Please grant the required permissions.';
      case AuthErrorType.biometricError:
        return 'Biometric authentication failed. Please try again or use a different authentication method.';
      case AuthErrorType.secureStorageError:
        return 'Secure storage error. Please restart the app and try again.';
      case AuthErrorType.icpServiceError:
        return 'ICP service error. Please try again later.';
      case AuthErrorType.jwtError:
        return 'Authentication token error. Please log in again.';
      case AuthErrorType.validationError:
        return 'Please check your input and try again.';
      case AuthErrorType.unknown:
      case AuthErrorType.unknownError:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get suggested user action
  String get suggestedAction {
    switch (type) {
      case AuthErrorType.invalidCredentials:
      case AuthErrorType.userNotFound:
        return 'Check your email and password, or create a new account.';
      case AuthErrorType.oauthDenied:
        return 'Try the OAuth authentication again.';
      case AuthErrorType.network:
        return 'Check your internet connection and try again.';
      case AuthErrorType.weakPassword:
        return 'Create a stronger password with uppercase, lowercase, and numbers.';
      case AuthErrorType.emailInUse:
        return 'Try logging in or use a different email address.';
      case AuthErrorType.usernameTaken:
        return 'Choose a different username.';
      case AuthErrorType.invalidEmail:
        return 'Enter a valid email address.';
      case AuthErrorType.invalidUsername:
        return 'Choose a valid username (3-20 characters, letters/numbers/underscores only).';
      case AuthErrorType.sessionExpired:
      case AuthErrorType.tokenExpired:
      case AuthErrorType.unauthorized:
        return 'Log in again to continue.';
      case AuthErrorType.rateLimited:
        return 'Wait a few minutes and try again.';
      case AuthErrorType.serverError:
        return 'Try again later or contact support.';
      case AuthErrorType.forbidden:
        return 'Contact an administrator if you believe this is an error.';
      case AuthErrorType.configurationError:
        return 'Contact support about this configuration issue.';
      case AuthErrorType.accountLocked:
      case AuthErrorType.accountDisabled:
        return 'Contact support for assistance with your account.';
      case AuthErrorType.verificationRequired:
        return 'Check your email for a verification link.';
      case AuthErrorType.termsNotAccepted:
        return 'Accept the terms and conditions to continue.';
      case AuthErrorType.passwordMismatch:
        return 'Ensure both password fields match.';
      case AuthErrorType.oauthProviderUnavailable:
      case AuthErrorType.oauthTokenInvalid:
      case AuthErrorType.oauthScopeDenied:
        return 'Try a different authentication method.';
      case AuthErrorType.biometricError:
        return 'Use password authentication instead.';
      case AuthErrorType.secureStorageError:
      case AuthErrorType.icpServiceError:
      case AuthErrorType.jwtError:
        return 'Restart the app and try again.';
      case AuthErrorType.validationError:
        return 'Review your input for errors.';
      case AuthErrorType.unknown:
      case AuthErrorType.unknownError:
        return 'Try again or contact support if the problem persists.';
    }
  }

  /// Check if error is recoverable
  bool get isRecoverable {
    switch (type) {
      case AuthErrorType.invalidCredentials:
      case AuthErrorType.oauthDenied:
      case AuthErrorType.network:
      case AuthErrorType.weakPassword:
      case AuthErrorType.emailInUse:
      case AuthErrorType.usernameTaken:
      case AuthErrorType.invalidEmail:
      case AuthErrorType.invalidUsername:
      case AuthErrorType.sessionExpired:
      case AuthErrorType.tokenExpired:
      case AuthErrorType.rateLimited:
      case AuthErrorType.validationError:
      case AuthErrorType.passwordMismatch:
      case AuthErrorType.termsNotAccepted:
      case AuthErrorType.oauthProviderUnavailable:
      case AuthErrorType.oauthTokenInvalid:
      case AuthErrorType.oauthScopeDenied:
      case AuthErrorType.biometricError:
        return true;
      case AuthErrorType.serverError:
      case AuthErrorType.forbidden:
      case AuthErrorType.unauthorized:
      case AuthErrorType.configurationError:
      case AuthErrorType.userNotFound:
      case AuthErrorType.accountLocked:
      case AuthErrorType.accountDisabled:
      case AuthErrorType.verificationRequired:
      case AuthErrorType.secureStorageError:
      case AuthErrorType.icpServiceError:
      case AuthErrorType.jwtError:
      case AuthErrorType.unknown:
      case AuthErrorType.unknownError:
        return false;
    }
  }
}

/// Comprehensive authentication error handler
class AuthErrorHandler {
  final GlobalKey<NavigatorState> navigatorKey;

  AuthErrorHandler({required this.navigatorKey});

  /// Handle authentication errors with user feedback
  void handleAuthError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
    VoidCallback? onRetry,
  }) {
    final errorDetails = AuthErrorDetails.fromException(
      error,
      stackTrace: stackTrace,
      additionalData: additionalData,
    );

    // Log the error
    Logger.instance.logError(
      'Authentication error: ${errorDetails.type}',
      tag: 'AuthErrorHandler',
      error: error,
      stackTrace: stackTrace,
    );

    // Show user-friendly message
    showErrorSnackBar(error, onRetry: onRetry);

    // Track error for analytics (if needed)
    _trackError(errorDetails);
  }

  /// Show error snackbar with appropriate styling and actions
  void showErrorSnackBar(
    Object error, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    final errorDetails = AuthErrorDetails.fromException(error);
    final context = navigatorKey.currentContext;
    if (context == null) return;

    _showErrorSnackBar(context, errorDetails, onRetry);
  }

  void _showErrorSnackBar(
    BuildContext context,
    AuthErrorDetails errorDetails,
    VoidCallback? onRetry,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isRecoverable = errorDetails.isRecoverable;

    // Hide any existing snackbars
    scaffoldMessenger.hideCurrentSnackBar();

    // Create snackbar content
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          errorDetails.displayMessage,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (errorDetails.suggestedAction.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            errorDetails.suggestedAction,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ],
    );

    // Create snackbar with optional retry action
    final snackBar = SnackBar(
      content: content,
      backgroundColor: _getErrorColor(errorDetails.type),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: isRecoverable
          ? const Duration(seconds: 6)
          : const Duration(seconds: 4),
      action: isRecoverable && onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }

  /// Get error color based on error type
  Color _getErrorColor(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.invalidCredentials:
      case AuthErrorType.oauthDenied:
      case AuthErrorType.unauthorized:
      case AuthErrorType.forbidden:
        return Colors.orange[700]!;
      case AuthErrorType.network:
        return Colors.blue[700]!;
      case AuthErrorType.serverError:
      case AuthErrorType.configurationError:
      case AuthErrorType.secureStorageError:
      case AuthErrorType.icpServiceError:
      case AuthErrorType.jwtError:
        return Colors.red[700]!;
      case AuthErrorType.rateLimited:
        return Colors.amber[700]!;
      case AuthErrorType.accountLocked:
      case AuthErrorType.accountDisabled:
        return Colors.purple[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  /// Track error for analytics
  void _trackError(AuthErrorDetails errorDetails) {
    // Implement error tracking for analytics
    // This could integrate with Firebase Analytics, Sentry, or other services
    Logger.instance.logInfo(
      'Error tracked: ${errorDetails.toJson()}',
      tag: 'AuthErrorHandler',
    );
  }

  /// Show error dialog for critical errors
  void showErrorDialog(
    Object error, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    final errorDetails = AuthErrorDetails.fromException(error);
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getDialogTitle(errorDetails.type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorDetails.displayMessage),
            if (errorDetails.suggestedAction.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                errorDetails.suggestedAction,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          if (errorDetails.isRecoverable && onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get dialog title based on error type
  String _getDialogTitle(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.invalidCredentials:
      case AuthErrorType.userNotFound:
        return 'Login Failed';
      case AuthErrorType.oauthDenied:
        return 'OAuth Cancelled';
      case AuthErrorType.network:
        return 'Connection Error';
      case AuthErrorType.weakPassword:
      case AuthErrorType.emailInUse:
      case AuthErrorType.usernameTaken:
      case AuthErrorType.invalidEmail:
      case AuthErrorType.invalidUsername:
      case AuthErrorType.validationError:
      case AuthErrorType.passwordMismatch:
      case AuthErrorType.termsNotAccepted:
        return 'Invalid Input';
      case AuthErrorType.sessionExpired:
      case AuthErrorType.tokenExpired:
      case AuthErrorType.unauthorized:
        return 'Session Expired';
      case AuthErrorType.rateLimited:
        return 'Too Many Attempts';
      case AuthErrorType.serverError:
        return 'Server Error';
      case AuthErrorType.forbidden:
        return 'Access Denied';
      case AuthErrorType.configurationError:
        return 'Configuration Error';
      case AuthErrorType.accountLocked:
      case AuthErrorType.accountDisabled:
        return 'Account Issue';
      case AuthErrorType.verificationRequired:
        return 'Verification Required';
      case AuthErrorType.oauthProviderUnavailable:
      case AuthErrorType.oauthTokenInvalid:
      case AuthErrorType.oauthScopeDenied:
        return 'OAuth Error';
      case AuthErrorType.biometricError:
        return 'Biometric Error';
      case AuthErrorType.secureStorageError:
      case AuthErrorType.icpServiceError:
      case AuthErrorType.jwtError:
        return 'System Error';
      case AuthErrorType.unknown:
      case AuthErrorType.unknownError:
        return 'Error';
    }
  }

  /// Create user-friendly error from AuthError enum
  AuthErrorDetails fromAuthError(AuthError authError) {
    switch (authError) {
      case AuthError.invalidCredentials:
        return AuthErrorDetails(
          type: AuthErrorType.invalidCredentials,
          message: 'Invalid credentials',
          timestamp: DateTime.now(),
          code: 'AUTH_INVALID_CREDENTIALS',
        );
      case AuthError.oauthDenied:
        return AuthErrorDetails(
          type: AuthErrorType.oauthDenied,
          message: 'OAuth denied',
          timestamp: DateTime.now(),
          code: 'AUTH_OAUTH_DENIED',
        );
      case AuthError.network:
        return AuthErrorDetails(
          type: AuthErrorType.network,
          message: 'Network error',
          timestamp: DateTime.now(),
          code: 'AUTH_NETWORK_ERROR',
        );
      case AuthError.unknown:
        return AuthErrorDetails(
          type: AuthErrorType.unknown,
          message: 'Unknown error',
          timestamp: DateTime.now(),
          code: 'AUTH_UNKNOWN_ERROR',
        );
    }
  }
}
