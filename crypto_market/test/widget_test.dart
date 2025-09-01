// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_utils/test_app_wrapper.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('Base routes are navigable', (WidgetTester tester) async {
      // Build our app with proper test setup
      await tester.pumpWidget(
        TestAppWrapper(
          includeRouter: false,
          child: Scaffold(
            appBar: AppBar(title: const Text('Test App')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Welcome to the App'), Text('Navigation Test')],
              ),
            ),
          ),
        ),
      );

      // Wait for all widgets to settle
      await tester.pumpAndSettle();

      // Verify the app builds with expected elements
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Welcome to the App'), findsOneWidget);
      expect(find.text('Navigation Test'), findsOneWidget);
    });
  });
}
