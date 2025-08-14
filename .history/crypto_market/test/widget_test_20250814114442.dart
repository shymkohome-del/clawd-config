// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/main.dart';

void main() {
  testWidgets('Base routes are navigable', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Initial route: /login
    expect(find.text('Login Screen (placeholder)'), findsOneWidget);

    // Navigate to /register
    await tester.tap(find.text('Go to Register'));
    await tester.pumpAndSettle();
    expect(find.text('Register Screen (placeholder)'), findsOneWidget);

    // Navigate to /home
    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home Screen (placeholder)'), findsOneWidget);
  });
}
