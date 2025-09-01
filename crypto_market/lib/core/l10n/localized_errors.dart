import '../error/domain_errors.dart';
import '../../l10n/app_localizations.dart';

/// Represents a localized error with a title and message.
class LocalizedError {
  const LocalizedError({required this.title, required this.message});

  final String title;
  final String message;
}

/// Factory for converting [DomainError]s into localized user-facing errors.
class LocalizedErrorFactory {
  /// Creates a [LocalizedError] from a [DomainError] using [AppLocalizations].
  static LocalizedError fromDomainError(
    AppLocalizations l10n,
    DomainError error,
  ) {
    final title = _titleFor(l10n, error);
    final message = _messageFor(l10n, error);
    return LocalizedError(title: title, message: message);
  }

  static String _titleFor(AppLocalizations l10n, DomainError error) {
    if (error is AuthError) return l10n.errorTitleAuthentication;
    if (error is NetworkError) return l10n.errorTitleConnection;
    if (error is ValidationError) return l10n.errorTitleInvalidInput;
    if (error is BusinessLogicError) return l10n.errorTitleOperation;
    return l10n.errorTitleGeneric;
  }

  static String _messageFor(AppLocalizations l10n, DomainError error) {
    if (error is AuthError) {
      switch (error.type) {
        case AuthErrorType.invalidCredentials:
          return l10n.errorAuthInvalidCredentials;
        case AuthErrorType.userNotFound:
          return l10n.errorAuthUserNotFound;
        case AuthErrorType.emailAlreadyExists:
          return l10n.errorAuthEmailExists;
        case AuthErrorType.weakPassword:
          return l10n.errorAuthWeakPassword;
        case AuthErrorType.accountLocked:
          return l10n.errorAuthAccountLocked;
        case AuthErrorType.sessionExpired:
          return l10n.errorAuthSessionExpired;
        case AuthErrorType.invalidToken:
          return l10n.errorAuthInvalidToken;
        case AuthErrorType.principalMismatch:
          return l10n.errorAuthPrincipalMismatch;
        case AuthErrorType.registrationFailed:
          return l10n.errorAuthRegistrationFailed;
        case AuthErrorType.loginFailed:
          return l10n.errorAuthLoginFailed;
      }
    } else if (error is NetworkError) {
      switch (error.type) {
        case NetworkErrorType.connectionTimeout:
          return l10n.errorNetworkConnectionTimeout;
        case NetworkErrorType.noInternet:
          return l10n.errorNetworkNoInternet;
        case NetworkErrorType.serverError:
          return l10n.errorNetworkServerError;
        case NetworkErrorType.canisterUnavailable:
          return l10n.errorNetworkCanisterUnavailable;
        case NetworkErrorType.rateLimitExceeded:
          return l10n.errorNetworkRateLimitExceeded;
        case NetworkErrorType.invalidResponse:
          return l10n.errorNetworkInvalidResponse;
        case NetworkErrorType.requestFailed:
          return l10n.errorNetworkRequestFailed;
      }
    } else if (error is ValidationError) {
      switch (error.type) {
        case ValidationErrorType.required:
          return l10n.errorValidationRequired(error.field);
        case ValidationErrorType.format:
          return l10n.errorValidationFormat(error.field);
        case ValidationErrorType.length:
          return l10n.errorValidationLength(error.field);
        case ValidationErrorType.range:
          return l10n.errorValidationRange(error.field);
        case ValidationErrorType.custom:
          return error.message;
      }
    } else if (error is BusinessLogicError) {
      switch (error.code) {
        case 'BUSINESS_INSUFFICIENT_BALANCE':
          return l10n.errorBusinessInsufficientBalance;
        case 'BUSINESS_MARKET_CLOSED':
          return l10n.errorBusinessMarketClosed;
        case 'BUSINESS_INVALID_OPERATION':
          return l10n.errorBusinessInvalidOperation;
        case 'BUSINESS_RATE_LIMIT_EXCEEDED':
          return l10n.errorBusinessRateLimitExceeded;
      }
    }
    return error.message;
  }
}
