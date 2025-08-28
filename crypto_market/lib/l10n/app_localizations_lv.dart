// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get appTitle => 'Kripto tirgus';

  @override
  String get registerTitle => 'Reģistrēties';

  @override
  String get emailLabel => 'E-pasts';

  @override
  String get emailRequired => 'E-pasts ir obligāts';

  @override
  String get emailInvalid => 'Ievadiet derīgu e-pastu';

  @override
  String get usernameLabel => 'Lietotājvārds';

  @override
  String get usernameRequired => 'Lietotājvārds ir obligāts';

  @override
  String get usernameMinLength => 'Minimālais garums 3';

  @override
  String get usernameMaxLength => 'Maksimālais garums 30';

  @override
  String get usernameInvalidChars => 'Atļauti tikai burti, cipari, _ un -';

  @override
  String get passwordLabel => 'Parole';

  @override
  String get passwordRequired => 'Parole ir obligāta';

  @override
  String get passwordMinLength => 'Minimālais garums 8';

  @override
  String get createAccount => 'Izveidot kontu';

  @override
  String get continueWithGoogle => 'Turpināt ar Google';

  @override
  String get continueWithApple => 'Turpināt ar Apple';

  @override
  String get errorInvalidCredentials => 'Nederīgi akreditācijas dati';

  @override
  String get errorOAuthDenied => 'OAuth noraidīts vai atcelts';

  @override
  String get errorNetwork => 'Tīkla kļūda. Lūdzu mēģiniet vēlreiz';

  @override
  String get errorUnknown => 'Radās kļūda';

  @override
  String get errorImagePicker => 'Kļūda attēla izvēlē';

  @override
  String get homeTitle => 'Sākums';

  @override
  String get loginTitle => 'Pieteikšanās';

  @override
  String get goToRegister => 'Doties uz reģistrāciju';

  @override
  String get languageEnglish => 'Angļu';

  @override
  String get languageLatvian => 'Latviešu';

  @override
  String get languageSystem => 'Sistēma';

  @override
  String get configErrorTitle => 'Konfigurācijas kļūda';

  @override
  String get profile => 'Profils';

  @override
  String get username => 'Lietotājvārds';

  @override
  String get email => 'E-pasts';

  @override
  String get authProvider => 'Autentifikācijas sniedzējs';

  @override
  String get selectImageSource => 'Izvēlieties attēla avotu';

  @override
  String get gallery => 'Galerija';

  @override
  String get camera => 'Kamera';

  @override
  String get retry => 'Mēģināt vēlreiz';

  @override
  String get updatingProfile => 'Atjaunina profilu...';

  @override
  String get profileUpdatedSuccess => 'Profils veiksmīgi atjaunots';

  @override
  String get logout => 'Iziet';

  @override
  String get sessionRestored => 'Sesija atjaunota';

  @override
  String get sessionExpired =>
      'Sesijas laiks beidzies, lūdzu pieteikšanās vēlreiz';
}
