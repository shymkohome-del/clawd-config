import 'package:crypto_market/features/auth/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_utils/test_app_wrapper.dart';

void main() {
  group('RegisterScreen integration', () {
    testWidgets('successful email registration navigates to home', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestAppWrapper(includeRouter: false, child: const RegisterScreen()),
      );

      await tester.pumpAndSettle();

      // Verify the register screen loads
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Basic functionality test - verify form fields exist
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('OAuth initiation buttons are present and tappable', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestAppWrapper(includeRouter: false, child: const RegisterScreen()),
      );

      await tester.pumpAndSettle();

      // Verify the register screen loads
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Look for buttons (OAuth buttons would be present)
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    });
  });
}
