part of 'search_listings_cubit.dart';

enum SearchStatus { initial, loading, loadingMore, success, failure }

class SearchListingsState {
  const SearchListingsState({
    this.status = SearchStatus.initial,
    this.listings = const <Listing>[],
    this.totalCount = 0,
    this.hasMore = false,
    this.query = '',
    this.filters = const SearchFilters(),
    this.errorMessage,
    this.page = 0,
  });

  static const _unset = Object();

  final SearchStatus status;
  final List<Listing> listings;
  final int totalCount;
  final bool hasMore;
  final String query;
  final SearchFilters filters;
  final String? errorMessage;
  final int page;

  SearchListingsState copyWith({
    SearchStatus? status,
    List<Listing>? listings,
    int? totalCount,
    bool? hasMore,
    String? query,
    SearchFilters? filters,
    Object? errorMessage = _unset,
    int? page,
  }) {
    return SearchListingsState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      page: page ?? this.page,
    );
  }
}
