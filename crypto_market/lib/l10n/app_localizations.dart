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

  /// No description provided for @searchListingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Listings'**
  String get searchListingsTitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search listings by keyword'**
  String get searchPlaceholder;

  /// No description provided for @searchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchFieldLabel;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filterPriceMin.
  ///
  /// In en, this message translates to:
  /// **'Min price (USD)'**
  String get filterPriceMin;

  /// No description provided for @filterPriceMax.
  ///
  /// In en, this message translates to:
  /// **'Max price (USD)'**
  String get filterPriceMax;

  /// No description provided for @filterLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filterLocationLabel;

  /// No description provided for @filterConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get filterConditionLabel;

  /// No description provided for @filterSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSortLabel;

  /// No description provided for @filtersApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filtersApply;

  /// No description provided for @filtersClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filtersClear;

  /// No description provided for @filtersApplied.
  ///
  /// In en, this message translates to:
  /// **'Filters applied'**
  String get filtersApplied;

  /// No description provided for @filtersCleared.
  ///
  /// In en, this message translates to:
  /// **'Filters cleared'**
  String get filtersCleared;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No listings match your filters yet. Adjust your search or try again later.'**
  String get searchNoResults;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// No description provided for @sortPriceLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortPriceLowHigh;

  /// No description provided for @sortPriceHighLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get sortPriceHighLow;

  /// No description provided for @listingDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing Details'**
  String get listingDetailTitle;

  /// No description provided for @contactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact Seller'**
  String get contactSeller;

  /// No description provided for @reportListing.
  ///
  /// In en, this message translates to:
  /// **'Report Listing'**
  String get reportListing;

  /// No description provided for @shareListing.
  ///
  /// In en, this message translates to:
  /// **'Share Listing'**
  String get shareListing;

  /// No description provided for @sellerInfo.
  ///
  /// In en, this message translates to:
  /// **'Seller Information'**
  String get sellerInfo;

  /// No description provided for @sellerReputation.
  ///
  /// In en, this message translates to:
  /// **'Reputation'**
  String get sellerReputation;

  /// No description provided for @sellerLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get sellerLocation;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @noImagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No images available'**
  String get noImagesAvailable;

  /// No description provided for @imageGallery.
  ///
  /// In en, this message translates to:
  /// **'Image Gallery'**
  String get imageGallery;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @imageOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get imageOf;

  /// No description provided for @loadingListing.
  ///
  /// In en, this message translates to:
  /// **'Loading listing...'**
  String get loadingListing;

  /// No description provided for @listingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Listing not found'**
  String get listingNotFound;

  /// No description provided for @errorLoadingListing.
  ///
  /// In en, this message translates to:
  /// **'Error loading listing'**
  String get errorLoadingListing;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get categoryFashion;

  /// No description provided for @categoryHomeGarden.
  ///
  /// In en, this message translates to:
  /// **'Home & Garden'**
  String get categoryHomeGarden;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @categoryBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get categoryBooks;

  /// No description provided for @categoryAutomotive.
  ///
  /// In en, this message translates to:
  /// **'Automotive'**
  String get categoryAutomotive;

  /// No description provided for @categoryCollectibles.
  ///
  /// In en, this message translates to:
  /// **'Collectibles'**
  String get categoryCollectibles;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @managePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Manage Payment Methods'**
  String get managePaymentMethods;

  /// No description provided for @paymentMethodsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add and manage your payment methods for secure transactions.'**
  String get paymentMethodsDescription;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get addPaymentMethod;

  /// No description provided for @editPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Method'**
  String get editPaymentMethod;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No Payment Methods'**
  String get noPaymentMethods;

  /// No description provided for @addPaymentMethodPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add a payment method to start making secure transactions.'**
  String get addPaymentMethodPrompt;

  /// No description provided for @selectPaymentType.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Type'**
  String get selectPaymentType;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @bankTransferDescription.
  ///
  /// In en, this message translates to:
  /// **'Direct bank to bank transfer'**
  String get bankTransferDescription;

  /// No description provided for @digitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get digitalWallet;

  /// No description provided for @digitalWalletDescription.
  ///
  /// In en, this message translates to:
  /// **'PayPal, Wise, Venmo, etc.'**
  String get digitalWalletDescription;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @cashDescription.
  ///
  /// In en, this message translates to:
  /// **'In-person cash payment'**
  String get cashDescription;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @accountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your account number'**
  String get accountNumberHint;

  /// No description provided for @accountNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Account number is required'**
  String get accountNumberRequired;

  /// No description provided for @routingNumber.
  ///
  /// In en, this message translates to:
  /// **'Routing Number'**
  String get routingNumber;

  /// No description provided for @routingNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter routing number'**
  String get routingNumberHint;

  /// No description provided for @routingNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Routing number is required'**
  String get routingNumberRequired;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get accountHolderName;

  /// No description provided for @accountHolderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter account holder name'**
  String get accountHolderNameHint;

  /// No description provided for @accountHolderNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Account holder name is required'**
  String get accountHolderNameRequired;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @bankNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter bank name'**
  String get bankNameHint;

  /// No description provided for @bankNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Bank name is required'**
  String get bankNameRequired;

  /// No description provided for @swiftCode.
  ///
  /// In en, this message translates to:
  /// **'SWIFT Code'**
  String get swiftCode;

  /// No description provided for @swiftCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter SWIFT/BIC code (optional)'**
  String get swiftCodeHint;

  /// No description provided for @iban.
  ///
  /// In en, this message translates to:
  /// **'IBAN'**
  String get iban;

  /// No description provided for @ibanHint.
  ///
  /// In en, this message translates to:
  /// **'Enter IBAN number (optional)'**
  String get ibanHint;

  /// No description provided for @walletId.
  ///
  /// In en, this message translates to:
  /// **'Wallet ID'**
  String get walletId;

  /// No description provided for @walletIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter wallet ID or email'**
  String get walletIdHint;

  /// No description provided for @walletIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Wallet ID is required'**
  String get walletIdRequired;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @providerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., PayPal, Wise, Venmo'**
  String get providerHint;

  /// No description provided for @providerRequired.
  ///
  /// In en, this message translates to:
  /// **'Provider is required'**
  String get providerRequired;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get emailHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phoneNumberHint;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter account name (optional)'**
  String get accountNameHint;

  /// No description provided for @meetingLocation.
  ///
  /// In en, this message translates to:
  /// **'Meeting Location'**
  String get meetingLocation;

  /// No description provided for @meetingLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter meeting location'**
  String get meetingLocationHint;

  /// No description provided for @meetingLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Meeting location is required'**
  String get meetingLocationRequired;

  /// No description provided for @preferredTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred Time'**
  String get preferredTime;

  /// No description provided for @preferredTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter preferred meeting time'**
  String get preferredTimeHint;

  /// No description provided for @preferredTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Preferred time is required'**
  String get preferredTimeRequired;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @contactInfoHint.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get contactInfoHint;

  /// No description provided for @contactInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'Contact information is required'**
  String get contactInfoRequired;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @specialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Any special requirements (optional)'**
  String get specialInstructionsHint;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Delete Payment Method'**
  String get deletePaymentMethod;

  /// No description provided for @deletePaymentMethodConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this payment method? This action cannot be undone.'**
  String get deletePaymentMethodConfirmation;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @lastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last Used'**
  String get lastUsed;

  /// No description provided for @paymentProof.
  ///
  /// In en, this message translates to:
  /// **'Payment Proof'**
  String get paymentProof;

  /// No description provided for @submitPaymentProof.
  ///
  /// In en, this message translates to:
  /// **'Submit Payment Proof'**
  String get submitPaymentProof;

  /// No description provided for @paymentProofDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload proof of your payment to complete the transaction.'**
  String get paymentProofDescription;

  /// No description provided for @paymentProofSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Your proof will be securely stored on IPFS and only shared with the transaction counterparty.'**
  String get paymentProofSecurityNote;

  /// No description provided for @selectProofType.
  ///
  /// In en, this message translates to:
  /// **'Select Proof Type'**
  String get selectProofType;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @uploadProof.
  ///
  /// In en, this message translates to:
  /// **'Upload Proof'**
  String get uploadProof;

  /// No description provided for @uploadReceiptOrPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Receipt or Photo'**
  String get uploadReceiptOrPhoto;

  /// No description provided for @uploadInstructions.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or upload a receipt/transaction confirmation'**
  String get uploadInstructions;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @chooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose Another'**
  String get chooseAnother;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @transactionIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter transaction ID (if applicable)'**
  String get transactionIdHint;

  /// No description provided for @transactionIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID is required'**
  String get transactionIdRequired;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @additionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any additional information (optional)'**
  String get additionalNotesHint;

  /// No description provided for @submitProof.
  ///
  /// In en, this message translates to:
  /// **'Submit Proof'**
  String get submitProof;

  /// No description provided for @pleaseUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Please upload an image as proof'**
  String get pleaseUploadImage;

  /// No description provided for @imagePickerError.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get imagePickerError;

  /// No description provided for @paymentProofSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Payment proof submitted successfully'**
  String get paymentProofSubmitted;

  /// No description provided for @paymentProofSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit payment proof'**
  String get paymentProofSubmitError;

  /// No description provided for @buyFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy Listing'**
  String get buyFlowTitle;

  /// No description provided for @buyFlowCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buyFlowCancelButton;

  /// No description provided for @buyFlowErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during the buy process'**
  String get buyFlowErrorMessage;

  /// No description provided for @buyFlowErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buyFlowErrorRetry;

  /// No description provided for @buyFlowPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Price'**
  String get buyFlowPriceTitle;

  /// No description provided for @buyFlowPriceDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the current price and cryptocurrency conversion rate before proceeding.'**
  String get buyFlowPriceDescription;

  /// No description provided for @buyFlowConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get buyFlowConfirmTitle;

  /// No description provided for @buyFlowConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'Please review your purchase details below before proceeding to payment.'**
  String get buyFlowConfirmDescription;

  /// No description provided for @buyFlowConfirmListing.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get buyFlowConfirmListing;

  /// No description provided for @buyFlowConfirmSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get buyFlowConfirmSeller;

  /// No description provided for @buyFlowUsdAmount.
  ///
  /// In en, this message translates to:
  /// **'USD Amount'**
  String get buyFlowUsdAmount;

  /// No description provided for @buyFlowCryptoAmount.
  ///
  /// In en, this message translates to:
  /// **'Crypto Amount'**
  String get buyFlowCryptoAmount;

  /// No description provided for @buyFlowPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get buyFlowPaymentTitle;

  /// No description provided for @buyFlowPaymentDescription.
  ///
  /// In en, this message translates to:
  /// **'Your payment will be secured through an atomic swap contract to protect both buyer and seller.'**
  String get buyFlowPaymentDescription;

  /// No description provided for @buyFlowPaymentGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating secure payment...'**
  String get buyFlowPaymentGenerating;

  /// No description provided for @buyFlowConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get buyFlowConfirmButton;

  /// No description provided for @buyFlowCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Successful'**
  String get buyFlowCompleteTitle;

  /// No description provided for @buyFlowCompleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your purchase has been initiated successfully!'**
  String get buyFlowCompleteSuccess;

  /// No description provided for @buyFlowCompleteSwapCreated.
  ///
  /// In en, this message translates to:
  /// **'Swap ID: {swapId}'**
  String buyFlowCompleteSwapCreated(Object swapId);

  /// No description provided for @buyFlowCompleteNextSteps.
  ///
  /// In en, this message translates to:
  /// **'Next Steps'**
  String get buyFlowCompleteNextSteps;

  /// No description provided for @buyFlowCompleteStep1.
  ///
  /// In en, this message translates to:
  /// **'Contact {seller} to arrange payment'**
  String buyFlowCompleteStep1(Object seller);

  /// No description provided for @buyFlowCompleteStep2.
  ///
  /// In en, this message translates to:
  /// **'Complete payment and submit proof'**
  String get buyFlowCompleteStep2;

  /// No description provided for @buyFlowCompleteStep3.
  ///
  /// In en, this message translates to:
  /// **'Seller will release cryptocurrency upon payment confirmation'**
  String get buyFlowCompleteStep3;

  /// No description provided for @buyFlowBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buyFlowBackButton;

  /// No description provided for @buyFlowNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buyFlowNextButton;

  /// No description provided for @buyFlowErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get buyFlowErrorTitle;

  /// No description provided for @buyFlowErrorCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buyFlowErrorCancel;

  /// No description provided for @buyFlowStepPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get buyFlowStepPrice;

  /// No description provided for @buyFlowStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buyFlowStepConfirm;

  /// No description provided for @buyFlowStepPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get buyFlowStepPayment;

  /// No description provided for @buyFlowStepCompletion.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get buyFlowStepCompletion;

  /// No description provided for @buyFlowRefreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get buyFlowRefreshButton;

  /// No description provided for @buyFlowExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get buyFlowExchangeRate;

  /// No description provided for @buyFlowPriceStaleWarning.
  ///
  /// In en, this message translates to:
  /// **'Price may be stale. Tap refresh to update.'**
  String get buyFlowPriceStaleWarning;

  /// No description provided for @buyFlowLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get buyFlowLastUpdated;
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
