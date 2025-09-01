import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/error/domain_errors.dart';
import 'package:crypto_market/core/l10n/localized_errors.dart';
import 'package:crypto_market/l10n/app_localizations_en.dart';

void main() {
  group('LocalizedErrorFactory', () {
    final l10n = AppLocalizationsEn();

    test('maps auth error to localized values', () {
      final error = AuthError.invalidCredentials();
      final localized = LocalizedErrorFactory.fromDomainError(l10n, error);
      expect(localized.title, 'Authentication Error');
      expect(localized.message, 'Invalid email or password');
    });

    test('maps validation error with field placeholder', () {
      final error = ValidationError.required('email');
      final localized = LocalizedErrorFactory.fromDomainError(l10n, error);
      expect(localized.title, 'Invalid Input');
      expect(localized.message, 'email is required');
    });
  });
}
