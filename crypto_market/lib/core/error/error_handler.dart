import 'domain_errors.dart';

/// Centralized error handler for the application
class ErrorHandler {
  /// Handle domain errors with logging and user feedback
  void handleError(DomainError error, {String? context}) {
    // In a real implementation, this would log to crashlytics
    // and potentially show user-friendly error messages
    // TODO: Implement proper logging instead of print statements
    if (error.code != null) {
      // Error code: ${error.code}
    }
    if (error.details != null) {
      // Error details: ${error.details}
    }
  }

  /// Create a user-friendly error message from domain errors
  String getUserMessage(DomainError error) {
    return error.message; // In real app, this would be localized
  }
}
