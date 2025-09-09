import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/shared/widgets/error_dialog.dart';
import 'package:crypto_market/core/error/domain_errors.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('lv')],
    home: Scaffold(body: child),
  );
}

void main() {
  group('ErrorDialog', () {
    testWidgets('should display auth error with correct title and message', (
      tester,
    ) async {
      final error = AuthError.invalidCredentials();

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(context, error),
              child: const Text('Show Error'),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text('Authentication Error'), findsOneWidget);
      expect(find.text('Invalid email or password'), findsOneWidget);
      expect(find.text('Error Code: AUTH_INVALID_CREDENTIALS'), findsOneWidget);
    });

    testWidgets('should display network error with correct content', (
      tester,
    ) async {
      final error = NetworkError.connectionTimeout();

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(context, error),
              child: const Text('Show Error'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text('Connection Error'), findsOneWidget);
      expect(
        find.text('Connection timeout. Please check your internet connection'),
        findsOneWidget,
      );
      expect(find.text('Error Code: NETWORK_TIMEOUT'), findsOneWidget);
    });

    testWidgets('should display validation error with correct content', (
      tester,
    ) async {
      final error = ValidationError.required('email');

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(context, error),
              child: const Text('Show Error'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text('Invalid Input'), findsOneWidget);
      expect(find.text('email is required'), findsOneWidget);
      expect(find.text('Error Code: VALIDATION_REQUIRED'), findsOneWidget);
    });

    testWidgets('should display business logic error with correct content', (
      tester,
    ) async {
      final error = BusinessLogicError.insufficientBalance();

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(context, error),
              child: const Text('Show Error'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text('Operation Error'), findsOneWidget);
      expect(
        find.text('Insufficient balance for this transaction'),
        findsOneWidget,
      );
      expect(
        find.text('Error Code: BUSINESS_INSUFFICIENT_BALANCE'),
        findsOneWidget,
      );
    });

    testWidgets('should show custom title when provided', (tester) async {
      final error = AuthError.invalidCredentials();

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  ErrorDialog.show(context, error, title: 'Custom Error Title'),
              child: const Text('Show Error'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Error Title'), findsOneWidget);
      expect(find.text('Authentication Error'), findsNothing);
    });

    testWidgets('should show action button when provided', (tester) async {
      final error = AuthError.invalidCredentials();
      var actionPressed = false;

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(
                context,
                error,
                actionButtonText: 'Retry',
                onActionPressed: () => actionPressed = true,
              ),
              child: const Text('Show Error'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);

      // Tap the retry button
      await tester.tap(find.text('Retry'));
      expect(actionPressed, isTrue);
    });

    testWidgets('should dismiss dialog when OK is pressed', (tester) async {
      final error = AuthError.invalidCredentials();

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(context, error),
              child: const Text('Show Error'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);

      // Tap OK button to dismiss
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsNothing);
    });

    testWidgets('should not display error code section when code is null', (
      tester,
    ) async {
      final error = const BusinessLogicError('Simple error without code');

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ErrorDialog.show(context, error),
              child: const Text('Show Error'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text('Simple error without code'), findsOneWidget);
      expect(find.textContaining('Error Code:'), findsNothing);
    });
  });
}
