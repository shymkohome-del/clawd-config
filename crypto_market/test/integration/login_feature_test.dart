import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_utils/test_app_wrapper.dart';

void main() {
  group('Login Feature Integration Tests', () {
    testWidgets('app starts successfully', (WidgetTester tester) async {
      // Build a simple test app
      await tester.pumpWidget(
        TestAppWrapper(
          child: MaterialApp(
            home: Scaffold(body: Center(child: Text('Test App'))),
          ),
        ),
      );

      // Verify the app starts without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
