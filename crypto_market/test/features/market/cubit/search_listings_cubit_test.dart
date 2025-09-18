import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_market/features/market/cubit/search_listings_cubit.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/models/search_filters.dart';
import 'package:crypto_market/features/market/models/search_listings_result.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_listings_cubit_test.mocks.dart';

@GenerateMocks([MarketService])
void main() {
  group('SearchListingsCubit', () {
    late MockMarketService marketService;
    late SearchListingsCubit cubit;
    const testResult = SearchListingsResult(
      listings: <Listing>[],
      totalCount: 0,
      hasMore: false,
    );

    final listingA = Listing(
      id: 'listing-1',
      seller: 'principal-1',
      title: 'Ledger Nano S',
      description: 'Hardware wallet',
      priceUSD: 199,
      cryptoType: 'BTC',
      images: const [],
      category: 'electronics',
      condition: ListingCondition.newCondition,
      location: 'Riga',
      shippingOptions: const ['Courier'],
      status: ListingStatus.active,
      createdAt: 5,
      updatedAt: 5,
    );

    final listingB = listingA.copyWith(
      id: 'listing-2',
      title: 'Trezor Model T',
      priceUSD: 250,
      createdAt: 6,
    );

    setUp(() {
      marketService = MockMarketService();
      cubit = SearchListingsCubit(marketService: marketService);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is default', () {
      expect(cubit.state.status, SearchStatus.initial);
      expect(cubit.state.listings, isEmpty);
    });

    blocTest<SearchListingsCubit, SearchListingsState>(
      'emits success state when search returns results',
      build: () {
        when(
          marketService.searchListings(
            query: anyNamed('query'),
            filters: anyNamed('filters'),
            page: anyNamed('page'),
            limit: anyNamed('limit'),
          ),
        ).thenAnswer(
          (_) async => SearchListingsResult(
            listings: [listingA],
            totalCount: 1,
            hasMore: false,
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.search(query: 'ledger'),
      expect: () => [
        isA<SearchListingsState>()
            .having((s) => s.status, 'status', SearchStatus.loading)
            .having((s) => s.listings, 'listings', isEmpty),
        isA<SearchListingsState>()
            .having((s) => s.status, 'status', SearchStatus.success)
            .having((s) => s.listings, 'listings', [listingA])
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<SearchListingsCubit, SearchListingsState>(
      'emits failure when search throws',
      build: () {
        when(
          marketService.searchListings(
            query: anyNamed('query'),
            filters: anyNamed('filters'),
            page: anyNamed('page'),
            limit: anyNamed('limit'),
          ),
        ).thenThrow(Exception('network'));
        return cubit;
      },
      act: (cubit) => cubit.search(query: 'ledger'),
      expect: () => [
        isA<SearchListingsState>().having(
          (s) => s.status,
          'status',
          SearchStatus.loading,
        ),
        isA<SearchListingsState>()
            .having((s) => s.status, 'status', SearchStatus.failure)
            .having(
              (s) => s.errorMessage,
              'error message',
              contains('network'),
            ),
      ],
    );

    blocTest<SearchListingsCubit, SearchListingsState>(
      'loadMore appends results and respects sorting',
      build: () {
        when(
          marketService.searchListings(
            query: anyNamed('query'),
            filters: anyNamed('filters'),
            page: 0,
            limit: anyNamed('limit'),
          ),
        ).thenAnswer(
          (_) async => SearchListingsResult(
            listings: [listingA],
            totalCount: 2,
            hasMore: true,
          ),
        );
        when(
          marketService.searchListings(
            query: anyNamed('query'),
            filters: anyNamed('filters'),
            page: 1,
            limit: anyNamed('limit'),
          ),
        ).thenAnswer(
          (_) async => SearchListingsResult(
            listings: [listingB],
            totalCount: 2,
            hasMore: false,
          ),
        );
        return cubit;
      },
      act: (cubit) async {
        await cubit.search(
          query: 'wallet',
          filters: const SearchFilters(
            sortOption: SearchSortOption.priceHighToLow,
          ),
        );
        await cubit.loadMore();
      },
      expect: () => [
        isA<SearchListingsState>().having(
          (s) => s.status,
          'status after initial search start',
          SearchStatus.loading,
        ),
        isA<SearchListingsState>().having(
          (s) => s.listings,
          'initial search results',
          [listingA],
        ),
        isA<SearchListingsState>().having(
          (s) => s.status,
          'status when loading more',
          SearchStatus.loadingMore,
        ),
        isA<SearchListingsState>().having(
          (s) => s.listings.first,
          'sorted order keeps higher price first',
          listingB,
        ),
      ],
    );

    blocTest<SearchListingsCubit, SearchListingsState>(
      'clearFilters triggers search with cleared parameters',
      build: () {
        when(
          marketService.searchListings(
            query: anyNamed('query'),
            filters: anyNamed('filters'),
            page: anyNamed('page'),
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => testResult);
        return cubit;
      },
      act: (cubit) => cubit.clearFilters(),
      expect: () => [
        isA<SearchListingsState>().having(
          (s) => s.status,
          'status after clearing',
          SearchStatus.loading,
        ),
        isA<SearchListingsState>().having((s) => s.query, 'query cleared', ''),
      ],
    );
  });
}
