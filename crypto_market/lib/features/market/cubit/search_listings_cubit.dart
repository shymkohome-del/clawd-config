import 'package:bloc/bloc.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/models/search_filters.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:flutter/foundation.dart';

part 'search_listings_state.dart';

/// Manages search/filter lifecycle and pagination for marketplace listings
class SearchListingsCubit extends Cubit<SearchListingsState> {
  SearchListingsCubit({required MarketService marketService, int pageSize = 20})
    : _marketService = marketService,
      _pageSize = pageSize,
      super(const SearchListingsState());

  final MarketService _marketService;
  final int _pageSize;

  Future<void> search({String? query, SearchFilters? filters}) async {
    if (state.status == SearchStatus.loading) {
      return;
    }

    final resolvedFilters = filters ?? state.filters;
    final resolvedQuery = query ?? state.query;

    emit(
      state.copyWith(
        status: SearchStatus.loading,
        query: resolvedQuery,
        filters: resolvedFilters,
        errorMessage: null,
        listings: const <Listing>[],
        page: 0,
      ),
    );

    await _fetchPage(page: 0, query: resolvedQuery, filters: resolvedFilters);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == SearchStatus.loadingMore) {
      return;
    }

    final currentState = state;
    final nextPage = currentState.page + 1;

    emit(state.copyWith(status: SearchStatus.loadingMore));
    await _fetchPage(
      page: nextPage,
      query: currentState.query,
      filters: currentState.filters,
      append: true,
      previousListings: currentState.listings,
      previousHasMore: currentState.hasMore,
      previousPage: currentState.page,
    );
  }

  Future<void> clearFilters() async {
    await search(query: '', filters: const SearchFilters());
  }

  Future<void> _fetchPage({
    required int page,
    required String query,
    required SearchFilters filters,
    bool append = false,
    List<Listing>? previousListings,
    bool? previousHasMore,
    int? previousPage,
  }) async {
    final stopwatch = Stopwatch()..start();

    if (kDebugMode) {
      Logger.instance.logDebug(
        'Fetching page $page (append: $append) for query "$query" with filters ${filters.toDebugString()}',
        tag: 'SearchListingsCubit',
      );
    }

    try {
      final result = await _marketService.searchListings(
        query: query.isEmpty ? null : query,
        filters: filters,
        page: page,
        limit: _pageSize,
      );

      final combined = append
          ? [...state.listings, ...result.listings]
          : result.listings;
      final listings = _applySorting(combined, filters);

      emit(
        state.copyWith(
          status: SearchStatus.success,
          listings: listings,
          totalCount: result.totalCount,
          hasMore: result.hasMore,
          errorMessage: null,
          page: page,
        ),
      );

      if (kDebugMode) {
        Logger.instance.logDebug(
          'Search page $page completed in ${stopwatch.elapsedMilliseconds}ms; accumulated results: ${listings.length}',
          tag: 'SearchListingsCubit',
        );
      }
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: error.toString(),
          hasMore: append ? (previousHasMore ?? state.hasMore) : false,
          listings: append
              ? (previousListings ?? state.listings)
              : const <Listing>[],
          page: append ? (previousPage ?? state.page) : state.page,
        ),
      );

      if (kDebugMode) {
        Logger.instance.logError(
          'Search failed on page $page',
          tag: 'SearchListingsCubit',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } finally {
      stopwatch.stop();
    }
  }

  List<Listing> _applySorting(List<Listing> listings, SearchFilters filters) {
    final sortOption = filters.sortOption;
    if (sortOption == null) {
      return listings;
    }

    final sorted = [...listings];
    switch (sortOption) {
      case SearchSortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SearchSortOption.priceLowToHigh:
        sorted.sort((a, b) => a.priceUSD.compareTo(b.priceUSD));
        break;
      case SearchSortOption.priceHighToLow:
        sorted.sort((a, b) => b.priceUSD.compareTo(a.priceUSD));
        break;
    }
    return sorted;
  }
}
