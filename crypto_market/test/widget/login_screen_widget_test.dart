import 'package:crypto_market/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_utils/test_app_wrapper.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper(
          includeRouter: false,
          child: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify basic elements are present
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // email and password fields
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1)); // login button
    });

    testWidgets('Login form has required fields', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper(
          includeRouter: false,
          child: const LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for form fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));
      
      // Test text input
      await tester.enterText(textFields.at(0), 'test@email.com');
      await tester.enterText(textFields.at(1), 'password123');
      
      expect(find.text('test@email.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
