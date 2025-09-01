import 'package:flutter/material.dart';
import '../../core/logger/logger.dart';
import '../../l10n/app_localizations.dart';

/// A reusable success snackbar for showing success messages
class SuccessSnackbar {
  /// Show a success snackbar with the given message
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    // Log the success message
    logger.logInfo('Showing success message: $message', tag: 'SuccessSnackbar');

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: colorScheme.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: action,
      ),
    );
  }

  /// Show a success snackbar for authentication operations
  static void showAuthSuccess(
    BuildContext context, {
    String? message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final l10n = AppLocalizations.of(context);
    show(context, message ?? l10n.successGeneric, duration: duration);
  }

  /// Show a success snackbar for profile operations
  static void showProfileSuccess(
    BuildContext context, {
    String? message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final l10n = AppLocalizations.of(context);
    show(context, message ?? l10n.successGeneric, duration: duration);
  }

  /// Show a success snackbar for market operations
  static void showMarketSuccess(
    BuildContext context, {
    String? message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final l10n = AppLocalizations.of(context);
    show(context, message ?? l10n.successGeneric, duration: duration);
  }

  /// Show a generic success snackbar with custom styling
  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    // Log the success message
    logger.logInfo(
      'Showing custom success message: $message',
      tag: 'SuccessSnackbar',
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? Icons.check_circle_outline,
              color: textColor ?? colorScheme.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor ?? colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? colorScheme.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: action,
      ),
    );
  }
}

/// Extension for easy access to success snackbar from BuildContext
extension SuccessSnackbarExtension on BuildContext {
  void showSuccessSnackbar(String message, {Duration? duration}) {
    SuccessSnackbar.show(
      this,
      message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
