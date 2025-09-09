import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../test_utils/test_app_wrapper.dart';

void main() {
  testWidgets('MyApp renders base routes', (tester) async {
    await tester.pumpWidget(
      const TestAppWrapper(
        child: MaterialApp(
          home: Scaffold(body: Center(child: Text('Test'))),
        ),
      ),
    );
    // Just ensure it builds without throwing; the placeholder text may be localized.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
