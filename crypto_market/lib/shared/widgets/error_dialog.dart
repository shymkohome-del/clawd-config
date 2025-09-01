import 'package:flutter/material.dart';
import '../../core/logger/logger.dart';
import '../../core/error/domain_errors.dart';
import '../../core/l10n/localized_errors.dart';
import '../../l10n/app_localizations.dart';

/// A reusable error dialog widget for displaying user-friendly error messages
class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.error,
    this.title,
    this.actionButtonText,
    this.onActionPressed,
  });

  final DomainError error;
  final String? title;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;

  /// Show an error dialog with the given error
  static Future<void> show(
    BuildContext context,
    DomainError error, {
    String? title,
    String? actionButtonText,
    VoidCallback? onActionPressed,
  }) {
    // Log the error when shown
    logger.logError(
      'Showing error dialog: ${error.message}',
      tag: 'ErrorDialog',
      error: error,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        error: error,
        title: title,
        actionButtonText: actionButtonText,
        onActionPressed: onActionPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final localized = LocalizedErrorFactory.fromDomainError(l10n, error);

    return AlertDialog(
      icon: Icon(Icons.error_outline, color: colorScheme.error, size: 48),
      title: Text(
        title ?? localized.title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localized.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (error.code != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Error Code: ${error.code}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onActionPressed != null && actionButtonText != null)
          TextButton(
            onPressed: onActionPressed,
            child: Text(actionButtonText!),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}

/// A helper class for showing different types of error dialogs
class ErrorDialogHelper {
  static Future<void> showAuthError(
    BuildContext context,
    AuthError error, {
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context);
    return ErrorDialog.show(
      context,
      error,
      actionButtonText: onRetry != null ? l10n.retry : null,
      onActionPressed: onRetry,
    );
  }

  static Future<void> showNetworkError(
    BuildContext context,
    NetworkError error, {
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context);
    return ErrorDialog.show(
      context,
      error,
      actionButtonText: onRetry != null ? l10n.retry : null,
      onActionPressed: onRetry,
    );
  }

  static Future<void> showValidationError(
    BuildContext context,
    ValidationError error,
  ) {
    return ErrorDialog.show(context, error);
  }

  static Future<void> showBusinessLogicError(
    BuildContext context,
    BusinessLogicError error, {
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context);
    return ErrorDialog.show(
      context,
      error,
      actionButtonText: onRetry != null ? l10n.retry : null,
      onActionPressed: onRetry,
    );
  }
}
