// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crypto Market';

  @override
  String get registerTitle => 'Register';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get usernameMinLength => 'Min length 3';

  @override
  String get usernameMaxLength => 'Max length 30';

  @override
  String get usernameInvalidChars => 'Only letters, numbers, _ and - allowed';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Min length 8';

  @override
  String get createAccount => 'Create account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get errorInvalidCredentials => 'Invalid credentials';

  @override
  String get errorOAuthDenied => 'OAuth denied or cancelled';

  @override
  String get errorNetwork => 'Network error. Please try again';

  @override
  String get errorUnknown => 'Something went wrong';

  @override
  String get errorImagePicker => 'Error selecting image';

  @override
  String get homeTitle => 'Home';

  @override
  String get loginTitle => 'Login';

  @override
  String get goToRegister => 'Go to Register';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageLatvian => 'Latvian';

  @override
  String get languageSystem => 'System';

  @override
  String get configErrorTitle => 'Configuration Error';

  @override
  String get profile => 'Profile';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get authProvider => 'Auth Provider';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get retry => 'Retry';

  @override
  String get updatingProfile => 'Updating profile...';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get logout => 'Logout';

  @override
  String get sessionRestored => 'Session restored';

  @override
  String get sessionExpired => 'Session expired, please login again';
}
