import 'package:crypto_market/core/i18n/locale_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LocaleController persists and loads locale', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = LocaleController();

    // Initially system locale (null)
    expect(controller.value, isNull);

    // Set to Latvian and verify persistence
    await controller.setLocale(const Locale('lv'));
    expect(controller.value?.languageCode, 'lv');

    // Create a new controller to ensure it loads from prefs
    final controller2 = LocaleController();
    // Allow async _load to complete
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(controller2.value?.languageCode, 'lv');

    // Reset to system and verify cleared
    await controller2.setLocale(null);
    expect(controller2.value, isNull);
  });
}
