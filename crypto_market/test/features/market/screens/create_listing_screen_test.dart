import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:crypto_market/features/market/cubit/create_listing_cubit.dart';
import 'package:crypto_market/features/market/models/create_listing_request.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/screens/create_listing_screen.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'create_listing_screen_test.mocks.dart';

@GenerateMocks([CreateListingCubit])
void main() {
  group('CreateListingScreen', () {
    late MockCreateListingCubit mockCubit;

    setUp(() {
      mockCubit = MockCreateListingCubit();
      when(mockCubit.state).thenReturn(CreateListingState.initial());
      when(mockCubit.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('lv')],
        home: BlocProvider<CreateListingCubit>(
          create: (context) => mockCubit,
          child: const CreateListingScreen(),
        ),
      );
    }

    testWidgets('renders correctly with all form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify app bar (should be only one instance)
      expect(find.text('Create Listing').first, findsOneWidget);

      // Verify form fields
      expect(
        find.byType(TextFormField),
        findsNWidgets(5),
      ); // title, description, price, location, shipping
      expect(
        find.byType(DropdownButtonFormField),
        findsNWidgets(3),
      ); // crypto, category, condition

      // Verify field labels
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Crypto Currency'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Condition'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Shipping Options'), findsOneWidget);
      expect(find.text('Images'), findsOneWidget);

      // Verify submit button
      expect(
        find.text('Create Listing'),
        findsNWidgets(2),
      ); // App bar and button
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Try to submit empty form
      final submitButton = find.text('Create Listing').last;
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should not call cubit because validation fails
      verifyNever(mockCubit.createListing(any));
    });

    testWidgets('submits form with valid data', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill in the form
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Test Item',
      ); // title
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Test description for the item',
      ); // description
      await tester.enterText(find.byType(TextFormField).at(2), '100'); // price
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'Test City',
      ); // location

      // Add shipping option
      await tester.enterText(
        find.byType(TextFormField).at(4),
        'Standard Shipping',
      );
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Submit the form
      final submitButton = find.text('Create Listing').last;
      await tester.tap(submitButton);
      await tester.pump();

      // Verify the cubit was called with correct data
      final captured = verify(mockCubit.createListing(captureAny)).captured;
      expect(captured.length, 1);

      final request = captured.first as CreateListingRequest;
      expect(request.title, 'Test Item');
      expect(request.description, 'Test description for the item');
      expect(request.priceUSD, 100);
      expect(request.location, 'Test City');
      expect(request.shippingOptions, ['Standard Shipping']);
      expect(request.cryptoType, 'BTC'); // default
      expect(request.category, 'Electronics'); // default
      expect(request.condition, ListingCondition.used); // default
    });

    testWidgets('shows loading state when submitting', (tester) async {
      when(mockCubit.state).thenReturn(CreateListingState.submitting());

      await tester.pumpWidget(createTestWidget());

      // Verify loading indicators
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Creating...'), findsOneWidget);

      // Submit button should be disabled
      final submitButton = find.byType(ElevatedButton);
      final button = tester.widget<ElevatedButton>(submitButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('shows success message on successful creation', (tester) async {
      whenListen(
        mockCubit,
        Stream.fromIterable([
          CreateListingState.initial(),
          CreateListingState.submitting(),
          CreateListingState.success(listingId: 123),
        ]),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Process the success state

      // Verify success message
      expect(find.text('Listing created successfully!'), findsOneWidget);
    });

    testWidgets('shows error dialog on failure', (tester) async {
      whenListen(
        mockCubit,
        Stream.fromIterable([
          CreateListingState.initial(),
          CreateListingState.submitting(),
          CreateListingState.failure('Network error'),
        ]),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Process the failure state

      // Verify error dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Operation Error'), findsOneWidget);
      expect(find.textContaining('Network error'), findsOneWidget);
    });

    testWidgets('adds and removes shipping options', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Add first shipping option
      await tester.enterText(find.byType(TextFormField).at(4), 'Standard');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Standard'), findsOneWidget);

      // Add second shipping option
      await tester.enterText(find.byType(TextFormField).at(4), 'Express');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Express'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNWidgets(2));

      // Remove first option
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();

      expect(find.text('Standard'), findsNothing);
      expect(find.text('Express'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('changes dropdown values', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Change crypto type
      await tester.tap(find.byType(DropdownButtonFormField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ETH').last);
      await tester.pumpAndSettle();

      // Change category
      await tester.tap(find.byType(DropdownButtonFormField).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fashion').last);
      await tester.pumpAndSettle();

      // Change condition
      await tester.tap(find.byType(DropdownButtonFormField).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New').last);
      await tester.pumpAndSettle();

      // The dropdowns should show the selected values
      expect(find.text('ETH'), findsOneWidget);
      expect(find.text('Fashion'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid inputs', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid price
      await tester.enterText(find.byType(TextFormField).at(2), '-5');

      // Try to submit
      final submitButton = find.text('Create Listing').last;
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('greater than'), findsOneWidget);
      verifyNever(mockCubit.createListing(any));
    });
  });
}
