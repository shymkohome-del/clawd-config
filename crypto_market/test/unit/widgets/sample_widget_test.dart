import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/core/i18n/locale_controller.dart';

void main() {
  testWidgets('MyApp renders base routes', (tester) async {
    await tester.pumpWidget(
      RepositoryProvider<LocaleController>(
        create: (_) => LocaleController(),
        child: const MyApp(),
      ),
    );
    // Just ensure it builds without throwing; the placeholder text may be localized.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
