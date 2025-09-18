import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_market/features/auth/models/user_profile.dart';
import 'package:crypto_market/features/market/cubit/listing_detail_cubit.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/screens/listing_detail_screen.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockListingDetailCubit extends MockCubit<ListingDetailState>
    implements ListingDetailCubit {}

void main() {
  late MockListingDetailCubit cubit;

  setUp(() {
    cubit = MockListingDetailCubit();
    // Mock the loadListing method to do nothing for all tests
    when(() => cubit.loadListing(any())).thenAnswer((_) async {});
  });

  Widget buildSubject({required String listingId}) {
    return MaterialApp(
      localizationsDelegates: [
        _MockAppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<ListingDetailCubit>.value(
        value: cubit,
        child: ListingDetailScreen(listingId: listingId),
      ),
    );
  }

  group('ListingDetailScreen', () {
    const testListingId = 'test-listing-id';

    testWidgets('renders loading state initially', (tester) async {
      when(() => cubit.state).thenReturn(
        const ListingDetailState(status: ListingDetailStatus.loading),
      );

      // Mock the loadListing method to do nothing
      when(() => cubit.loadListing(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();

      // Just pump once to let the widget build
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays error message when loading fails', (tester) async {
      when(() => cubit.state).thenReturn(
        const ListingDetailState(
          status: ListingDetailStatus.failure,
          errorMessage: 'Failed to load listing',
        ),
      );

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();
      await tester.pump();

      expect(find.text('Failed to load listing'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays listing not found when listing is null', (
      tester,
    ) async {
      when(() => cubit.state).thenReturn(
        const ListingDetailState(
          status: ListingDetailStatus.success,
          listing: null,
        ),
      );

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();
      await tester.pump();

      expect(find.text('Listing not found'), findsOneWidget);
    });

    testWidgets('displays listing content when loading succeeds', (
      tester,
    ) async {
      final testListing = Listing(
        id: 'test-listing-id',
        seller: 'test-seller',
        title: 'Test Item',
        description: 'This is a test item description',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: ['https://example.com/image.jpg'],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'New York, NY',
        shippingOptions: ['Standard'],
        status: ListingStatus.active,
        createdAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
      );

      when(() => cubit.state).thenReturn(
        ListingDetailState(
          status: ListingDetailStatus.success,
          listing: testListing,
        ),
      );

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('\$100.00'), findsOneWidget);
      expect(find.text('This is a test item description'), findsOneWidget);
      expect(find.text('test-seller'), findsOneWidget);
      expect(find.text('Location: New York, NY'), findsOneWidget);
      expect(find.text('Category: Electronics'), findsOneWidget);
      expect(find.text('Contact Seller'), findsOneWidget);
    });

    testWidgets('displays placeholder when no images available', (
      tester,
    ) async {
      final testListing = Listing(
        id: 'test-listing-id',
        seller: 'test-seller',
        title: 'Test Item',
        description: 'This is a test item description',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: [],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'New York, NY',
        shippingOptions: ['Standard'],
        status: ListingStatus.active,
        createdAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
      );

      when(() => cubit.state).thenReturn(
        ListingDetailState(
          status: ListingDetailStatus.success,
          listing: testListing,
        ),
      );

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();

      expect(find.text('No images available'), findsOneWidget);
    });

    testWidgets('calls loadListing on init', (tester) async {
      when(() => cubit.state).thenReturn(
        const ListingDetailState(status: ListingDetailStatus.loading),
      );

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();

      verify(() => cubit.loadListing(testListingId)).called(1);
    });

    testWidgets('calls loadListing when retry is pressed', (tester) async {
      when(() => cubit.state).thenReturn(
        const ListingDetailState(
          status: ListingDetailStatus.failure,
          errorMessage: 'Failed to load listing',
        ),
      );

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();
      await tester.tap(find.text('Retry'));

      verify(() => cubit.loadListing(testListingId)).called(2);
    });

    testWidgets('shows action buttons for seller interaction', (tester) async {
      final testListing = Listing(
        id: 'test-listing-id',
        seller: 'test-seller',
        title: 'Test Item',
        description: 'This is a test item description',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: [],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'New York, NY',
        shippingOptions: ['Standard'],
        status: ListingStatus.active,
        createdAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
      );

      when(() => cubit.state).thenReturn(
        ListingDetailState(
          status: ListingDetailStatus.success,
          listing: testListing,
        ),
      );

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();

      expect(find.text('Buy Now'), findsOneWidget);
      expect(find.text('Contact Seller'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets(
      'shows Buy Now and Contact Seller buttons with proper styling',
      (tester) async {
        final testListing = Listing(
          id: 'test-listing-id',
          seller: 'test-seller',
          title: 'Test Item',
          description: 'This is a test item description',
          priceUSD: 100,
          cryptoType: 'BTC',
          images: [],
          category: 'Electronics',
          condition: ListingCondition.newCondition,
          location: 'New York, NY',
          shippingOptions: ['Standard'],
          status: ListingStatus.active,
          createdAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
          updatedAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        );

        when(() => cubit.state).thenReturn(
          ListingDetailState(
            status: ListingDetailStatus.success,
            listing: testListing,
          ),
        );

        await tester.pumpWidget(buildSubject(listingId: testListingId));
        await tester.pump();

        // Find Buy Now button (should be prominent)
        final buyNowButton = find.widgetWithText(ElevatedButton, 'Buy Now');
        expect(buyNowButton, findsOneWidget);

        // Find Contact Seller button (should be outlined)
        final contactSellerButton = find.widgetWithText(
          OutlinedButton,
          'Contact Seller',
        );
        expect(contactSellerButton, findsOneWidget);
      },
    );

    testWidgets('displays seller reputation with proper styling', (
      tester,
    ) async {
      final testListing = Listing(
        id: 'test-listing-id',
        seller: 'test-seller',
        title: 'Test Item',
        description: 'This is a test item description',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: [],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'New York, NY',
        shippingOptions: ['Standard'],
        status: ListingStatus.active,
        createdAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
      );

      // Create a mock user profile with KYC verified
      final mockUserProfile = UserProfile(
        id: 'test-user-id',
        username: 'test-seller',
        email: 'test@example.com',
        authProvider: 'internet_identity',
        createdAtMillis: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        reputation: 100,
        kycVerified: true,
      );

      when(() => cubit.state).thenReturn(
        ListingDetailState(
          status: ListingDetailStatus.success,
          listing: testListing,
          sellerProfile: mockUserProfile,
        ),
      );

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();

      expect(find.text('test-seller'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
      expect(find.textContaining('Reputation:'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('displays image gallery with page indicators', (tester) async {
      final testListing = Listing(
        id: 'test-listing-id',
        seller: 'test-seller',
        title: 'Test Item',
        description: 'This is a test item description',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg',
          'https://example.com/image3.jpg',
        ],
        category: 'Electronics',
        condition: ListingCondition.newCondition,
        location: 'New York, NY',
        shippingOptions: ['Standard'],
        status: ListingStatus.active,
        createdAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
      );

      when(() => cubit.state).thenReturn(
        ListingDetailState(
          status: ListingDetailStatus.success,
          listing: testListing,
        ),
      );

      await tester.pumpWidget(buildSubject(listingId: testListingId));
      await tester.pump();

      // Should find page view for images
      expect(find.byType(PageView), findsOneWidget);

      // Should find page indicators (dots)
      expect(find.byType(Container), findsAtLeastNWidgets(3));
    });
  });
}

class _MockAppLocalizations implements AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _MockLocalizationsDelegate();

  static const _MockAppLocalizations instance = _MockAppLocalizations._();

  const _MockAppLocalizations._();

  @override
  String get localeName => 'en';

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

  @override
  String get editListingTitle => 'Edit Listing';

  @override
  String get listingTitleLabel => 'Title';

  @override
  String get priceLabel => 'Price';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get priceRequired => 'Price is required';

  @override
  String get pricePositive => 'Price must be greater than 0';

  @override
  String get replaceImage => 'Replace Image';

  @override
  String get confirmUpdateTitle => 'Update Listing?';

  @override
  String get confirmUpdateMessage =>
      'Are you sure you want to update this listing?';

  @override
  String get confirmUpdateYes => 'Update';

  @override
  String get confirmUpdateNo => 'Cancel';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get editSuccess => 'Listing updated successfully';

  @override
  String get editFailure => 'Failed to update listing';

  @override
  String get ok => 'OK';

  @override
  String get errorTitleAuthentication => 'Authentication Error';

  @override
  String get errorTitleConnection => 'Connection Error';

  @override
  String get errorTitleInvalidInput => 'Invalid Input';

  @override
  String get errorTitleOperation => 'Operation Error';

  @override
  String get errorTitleGeneric => 'Error';

  @override
  String get errorAuthInvalidCredentials => 'Invalid email or password';

  @override
  String get errorAuthUserNotFound => 'User not found';

  @override
  String get errorAuthEmailExists =>
      'An account with this email already exists';

  @override
  String get errorAuthWeakPassword => 'Password is too weak';

  @override
  String get errorAuthAccountLocked => 'Account is temporarily locked';

  @override
  String get errorAuthSessionExpired =>
      'Your session has expired. Please log in again';

  @override
  String get errorAuthInvalidToken => 'Invalid authentication token';

  @override
  String get errorAuthPrincipalMismatch =>
      'Principal mismatch in ICP authentication';

  @override
  String get errorAuthRegistrationFailed =>
      'Registration failed. Please try again';

  @override
  String get errorAuthLoginFailed => 'Login failed';

  @override
  String get errorAuthInsufficientPrivileges =>
      'Insufficient privileges to perform this action';

  @override
  String get errorNetworkConnectionTimeout =>
      'Connection timeout. Please check your internet connection';

  @override
  String get errorNetworkNoInternet => 'No internet connection available';

  @override
  String get errorNetworkServerError => 'Server error occurred';

  @override
  String get errorNetworkCanisterUnavailable =>
      'ICP canister is currently unavailable';

  @override
  String get errorNetworkRateLimitExceeded =>
      'Too many requests. Please wait and try again';

  @override
  String get errorNetworkInvalidResponse => 'Invalid response from server';

  @override
  String get errorNetworkRequestFailed => 'Request failed';

  @override
  String errorValidationRequired(Object field) => '$field is required';

  @override
  String errorValidationFormat(Object field) => '$field format is invalid';

  @override
  String errorValidationLength(Object field) => '$field length is invalid';

  @override
  String errorValidationRange(Object field) => '$field is out of range';

  @override
  String get errorBusinessInsufficientBalance =>
      'Insufficient balance for this transaction';

  @override
  String get errorBusinessMarketClosed => 'Market is currently closed';

  @override
  String get errorBusinessInvalidOperation => 'This operation is not allowed';

  @override
  String get errorBusinessRateLimitExceeded =>
      'Rate limit exceeded. Please try again later';

  @override
  String get successGeneric => 'Operation completed successfully';

  @override
  String get createListingTitle => 'Create Listing';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get categoryLabel => 'Category';

  @override
  String get conditionLabel => 'Condition';

  @override
  String get locationLabel => 'Location';

  @override
  String get cryptoTypeLabel => 'Crypto Currency';

  @override
  String get shippingOptionsLabel => 'Shipping Options';

  @override
  String get imagesLabel => 'Images';

  @override
  String get conditionNew => 'New';

  @override
  String get conditionUsed => 'Used';

  @override
  String get conditionRefurbished => 'Refurbished';

  @override
  String get addImages => 'Add Images';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get categoryRequired => 'Category is required';

  @override
  String get locationRequired => 'Location is required';

  @override
  String get cryptoTypeRequired => 'Cryptocurrency is required';

  @override
  String get shippingOptionsRequired =>
      'At least one shipping option is required';

  @override
  String get createListing => 'Create Listing';

  @override
  String get creating => 'Creating...';

  @override
  String get listingCreatedSuccess => 'Listing created successfully!';

  @override
  String get listingCreatedFailure => 'Failed to create listing';

  @override
  String get descriptionHint => 'Describe your item in detail...';

  @override
  String get titleHint => 'What are you selling?';

  @override
  String get locationHint => 'City, State/Country';

  @override
  String get addShippingOption => 'Add shipping option';

  @override
  String get uploadingImages => 'Uploading images...';

  @override
  String get imageUploadFailed => 'Image upload failed';

  @override
  String get searchListingsTitle => 'Browse Listings';

  @override
  String get searchPlaceholder => 'Search listings by keyword';

  @override
  String get searchFieldLabel => 'Search';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filterPriceMin => 'Min price (USD)';

  @override
  String get filterPriceMax => 'Max price (USD)';

  @override
  String get filterLocationLabel => 'Location';

  @override
  String get filterConditionLabel => 'Condition';

  @override
  String get filterSortLabel => 'Sort by';

  @override
  String get filtersApply => 'Apply filters';

  @override
  String get filtersClear => 'Clear filters';

  @override
  String get filtersApplied => 'Filters applied';

  @override
  String get filtersCleared => 'Filters cleared';

  @override
  String get searchNoResults =>
      'No listings match your filters yet. Adjust your search or try again later.';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortPriceLowHigh => 'Price: Low to High';

  @override
  String get sortPriceHighLow => 'Price: High to Low';

  @override
  String get listingDetailTitle => 'Listing Details';

  @override
  String get contactSeller => 'Contact Seller';

  @override
  String get reportListing => 'Report Listing';

  @override
  String get shareListing => 'Share Listing';

  @override
  String get sellerInfo => 'Seller Information';

  @override
  String get sellerReputation => 'Reputation';

  @override
  String get sellerLocation => 'Location';

  @override
  String get memberSince => 'Member since';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get noImagesAvailable => 'No images available';

  @override
  String get imageGallery => 'Image Gallery';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get imageOf => 'of';

  @override
  String get loadingListing => 'Loading listing...';

  @override
  String get listingNotFound => 'Listing not found';

  @override
  String get errorLoadingListing => 'Error loading listing';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryFashion => 'Fashion';

  @override
  String get categoryHomeGarden => 'Home & Garden';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryBooks => 'Books';

  @override
  String get categoryAutomotive => 'Automotive';

  @override
  String get categoryCollectibles => 'Collectibles';

  @override
  String get categoryOther => 'Other';
}

class _MockLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _MockLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      _MockAppLocalizations.instance;

  @override
  bool shouldReload(_MockLocalizationsDelegate old) => false;
}
