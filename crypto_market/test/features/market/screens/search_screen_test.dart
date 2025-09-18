import 'package:crypto_market/features/market/cubit/search_listings_cubit.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/models/search_filters.dart';
import 'package:crypto_market/features/market/screens/search_screen.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_screen_test.mocks.dart';

@GenerateMocks([SearchListingsCubit])
void main() {
  late MockSearchListingsCubit cubit;

  Widget buildSubject() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<SearchListingsCubit>.value(
        value: cubit,
        child: const SearchScreen(),
      ),
    );
  }

  setUp(() {
    cubit = MockSearchListingsCubit();
    when(cubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('renders search input and filter controls', (tester) async {
    when(
      cubit.state,
    ).thenReturn(const SearchListingsState(status: SearchStatus.loading));

    await tester.pumpWidget(buildSubject());

    expect(find.text('Browse Listings'), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt_off), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Filters'), findsOneWidget);
  });

  testWidgets('displays listings when search succeeds', (tester) async {
    const listing = Listing(
      id: 'listing-1',
      seller: 'principal-1',
      title: 'Ledger Nano',
      description: 'Hardware wallet',
      priceUSD: 199,
      cryptoType: 'BTC',
      images: <String>[],
      category: 'electronics',
      condition: ListingCondition.used,
      location: 'Riga',
      shippingOptions: <String>['Courier'],
      status: ListingStatus.active,
      createdAt: 1,
      updatedAt: 1,
    );

    when(cubit.state).thenReturn(
      const SearchListingsState(
        status: SearchStatus.success,
        listings: <Listing>[listing],
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('Ledger Nano'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });

  testWidgets('tapping clear filters triggers cubit.clearFilters', (
    tester,
  ) async {
    when(
      cubit.state,
    ).thenReturn(const SearchListingsState(status: SearchStatus.success));
    when(cubit.clearFilters()).thenAnswer((_) async {});

    await tester.pumpWidget(buildSubject());

    // Scroll to make the Clear button visible and tap it
    final clearButton = find.byKey(
      const ValueKey('search_filters_clear_button'),
    );
    await tester.ensureVisible(clearButton);
    await tester.tap(clearButton);
    await tester.pump();

    verify(cubit.clearFilters()).called(1);
  });

  testWidgets('apply filters sends canonical category value', (tester) async {
    when(
      cubit.state,
    ).thenReturn(const SearchListingsState(status: SearchStatus.success));
    when(
      cubit.search(query: anyNamed('query'), filters: anyNamed('filters')),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(buildSubject());

    // Tap on Electronics filter chip
    await tester.tap(find.text('Electronics'));
    await tester.pump();

    // Scroll to make the Apply button visible and tap it
    final applyButton = find.byKey(
      const ValueKey('search_filters_apply_button'),
    );
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pump();

    final captured = verify(
      cubit.search(
        query: captureAnyNamed('query'),
        filters: captureAnyNamed('filters'),
      ),
    ).captured;

    expect(captured.first, '');
    final appliedFilters = captured.last as SearchFilters;
    expect(appliedFilters.category, 'Electronics');
  });
}
