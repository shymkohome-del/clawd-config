import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/main.dart';

void main() {
  testWidgets('MyApp renders base routes', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Login Screen (placeholder)'), findsOneWidget);
  });
}
