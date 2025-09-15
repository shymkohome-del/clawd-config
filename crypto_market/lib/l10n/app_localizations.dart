import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_lv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('lv'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Crypto Market'**
  String get appTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Min length 3'**
  String get usernameMinLength;

  /// No description provided for @usernameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Max length 30'**
  String get usernameMaxLength;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers, _ and - allowed'**
  String get usernameInvalidChars;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Min length 8'**
  String get passwordMinLength;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get errorInvalidCredentials;

  /// No description provided for @errorOAuthDenied.
  ///
  /// In en, this message translates to:
  /// **'OAuth denied or cancelled'**
  String get errorOAuthDenied;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknown;

  /// No description provided for @errorImagePicker.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get errorImagePicker;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @goToRegister.
  ///
  /// In en, this message translates to:
  /// **'Go to Register'**
  String get goToRegister;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageLatvian.
  ///
  /// In en, this message translates to:
  /// **'Latvian'**
  String get languageLatvian;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @configErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration Error'**
  String get configErrorTitle;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @authProvider.
  ///
  /// In en, this message translates to:
  /// **'Auth Provider'**
  String get authProvider;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @updatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Updating profile...'**
  String get updatingProfile;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @sessionRestored.
  ///
  /// In en, this message translates to:
  /// **'Session restored'**
  String get sessionRestored;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired, please login again'**
  String get sessionExpired;

  /// No description provided for @editListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editListingTitle;

  /// No description provided for @listingTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get listingTitleLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get priceRequired;

  /// No description provided for @pricePositive.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than 0'**
  String get pricePositive;

  /// No description provided for @replaceImage.
  ///
  /// In en, this message translates to:
  /// **'Replace Image'**
  String get replaceImage;

  /// No description provided for @confirmUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Listing?'**
  String get confirmUpdateTitle;

  /// No description provided for @confirmUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this listing?'**
  String get confirmUpdateMessage;

  /// No description provided for @confirmUpdateYes.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get confirmUpdateYes;

  /// No description provided for @confirmUpdateNo.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get confirmUpdateNo;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @editSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing updated successfully'**
  String get editSuccess;

  /// No description provided for @editFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to update listing'**
  String get editFailure;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @errorTitleAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get errorTitleAuthentication;

  /// No description provided for @errorTitleConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get errorTitleConnection;

  /// No description provided for @errorTitleInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get errorTitleInvalidInput;

  /// No description provided for @errorTitleOperation.
  ///
  /// In en, this message translates to:
  /// **'Operation Error'**
  String get errorTitleOperation;

  /// No description provided for @errorTitleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitleGeneric;

  /// No description provided for @errorAuthInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorAuthInvalidCredentials;

  /// No description provided for @errorAuthUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get errorAuthUserNotFound;

  /// No description provided for @errorAuthEmailExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get errorAuthEmailExists;

  /// No description provided for @errorAuthWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get errorAuthWeakPassword;

  /// No description provided for @errorAuthAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'Account is temporarily locked'**
  String get errorAuthAccountLocked;

  /// No description provided for @errorAuthSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again'**
  String get errorAuthSessionExpired;

  /// No description provided for @errorAuthInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid authentication token'**
  String get errorAuthInvalidToken;

  /// No description provided for @errorAuthPrincipalMismatch.
  ///
  /// In en, this message translates to:
  /// **'Principal mismatch in ICP authentication'**
  String get errorAuthPrincipalMismatch;

  /// No description provided for @errorAuthRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again'**
  String get errorAuthRegistrationFailed;

  /// No description provided for @errorAuthLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get errorAuthLoginFailed;

  /// No description provided for @errorAuthInsufficientPrivileges.
  ///
  /// In en, this message translates to:
  /// **'Insufficient privileges to perform this action'**
  String get errorAuthInsufficientPrivileges;

  /// No description provided for @errorNetworkConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Please check your internet connection'**
  String get errorNetworkConnectionTimeout;

  /// No description provided for @errorNetworkNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection available'**
  String get errorNetworkNoInternet;

  /// No description provided for @errorNetworkServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get errorNetworkServerError;

  /// No description provided for @errorNetworkCanisterUnavailable.
  ///
  /// In en, this message translates to:
  /// **'ICP canister is currently unavailable'**
  String get errorNetworkCanisterUnavailable;

  /// No description provided for @errorNetworkRateLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait and try again'**
  String get errorNetworkRateLimitExceeded;

  /// No description provided for @errorNetworkInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server'**
  String get errorNetworkInvalidResponse;

  /// No description provided for @errorNetworkRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get errorNetworkRequestFailed;

  /// No description provided for @errorValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String errorValidationRequired(Object field);

  /// No description provided for @errorValidationFormat.
  ///
  /// In en, this message translates to:
  /// **'{field} format is invalid'**
  String errorValidationFormat(Object field);

  /// No description provided for @errorValidationLength.
  ///
  /// In en, this message translates to:
  /// **'{field} length is invalid'**
  String errorValidationLength(Object field);

  /// No description provided for @errorValidationRange.
  ///
  /// In en, this message translates to:
  /// **'{field} is out of range'**
  String errorValidationRange(Object field);

  /// No description provided for @errorBusinessInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance for this transaction'**
  String get errorBusinessInsufficientBalance;

  /// No description provided for @errorBusinessMarketClosed.
  ///
  /// In en, this message translates to:
  /// **'Market is currently closed'**
  String get errorBusinessMarketClosed;

  /// No description provided for @errorBusinessInvalidOperation.
  ///
  /// In en, this message translates to:
  /// **'This operation is not allowed'**
  String get errorBusinessInvalidOperation;

  /// No description provided for @errorBusinessRateLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Rate limit exceeded. Please try again later'**
  String get errorBusinessRateLimitExceeded;

  /// No description provided for @successGeneric.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get successGeneric;

  /// No description provided for @createListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListingTitle;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @cryptoTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Crypto Currency'**
  String get cryptoTypeLabel;

  /// No description provided for @shippingOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping Options'**
  String get shippingOptionsLabel;

  /// No description provided for @imagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get imagesLabel;

  /// No description provided for @conditionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get conditionNew;

  /// No description provided for @conditionUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get conditionUsed;

  /// No description provided for @conditionRefurbished.
  ///
  /// In en, this message translates to:
  /// **'Refurbished'**
  String get conditionRefurbished;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get categoryRequired;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get locationRequired;

  /// No description provided for @cryptoTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Cryptocurrency is required'**
  String get cryptoTypeRequired;

  /// No description provided for @shippingOptionsRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one shipping option is required'**
  String get shippingOptionsRequired;

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListing;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @listingCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing created successfully!'**
  String get listingCreatedSuccess;

  /// No description provided for @listingCreatedFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to create listing'**
  String get listingCreatedFailure;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your item in detail...'**
  String get descriptionHint;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'What are you selling?'**
  String get titleHint;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'City, State/Country'**
  String get locationHint;

  /// No description provided for @addShippingOption.
  ///
  /// In en, this message translates to:
  /// **'Add shipping option'**
  String get addShippingOption;

  /// No description provided for @uploadingImages.
  ///
  /// In en, this message translates to:
  /// **'Uploading images...'**
  String get uploadingImages;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed'**
  String get imageUploadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'lv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'lv':
      return AppLocalizationsLv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
