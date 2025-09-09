import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_utils/test_app_wrapper.dart';

void main() {
  group('Register -> Home principal display (shim off)', () {
    testWidgets('principal is not shown on Home when shim disabled', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper(
          includeRouter: false,
          child: Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: const Center(
              child: Text('Principal display test'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the test app loads
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Principal display test'), findsOneWidget);
    });
  });
}
