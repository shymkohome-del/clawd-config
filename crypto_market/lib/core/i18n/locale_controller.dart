import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple controller to manage the app's active Locale at runtime.
class LocaleController {
  static const _prefsKey = 'app.locale';

  final ValueNotifier<Locale?> _locale = ValueNotifier<Locale?>(null);

  ValueListenable<Locale?> get listenable => _locale;
  Locale? get value => _locale.value;

  LocaleController() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.isEmpty) return;
    _locale.value = Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    _locale.value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
