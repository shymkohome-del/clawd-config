import 'package:crypto_market/features/market/models/listing.dart';

/// Strongly typed container for marketplace search responses
class SearchListingsResult {
  const SearchListingsResult({
    required this.listings,
    required this.totalCount,
    required this.hasMore,
  });

  factory SearchListingsResult.empty() => const SearchListingsResult(
    listings: <Listing>[],
    totalCount: 0,
    hasMore: false,
  );

  factory SearchListingsResult.fromMap(Map<String, dynamic> raw) {
    final payload = _extractPayload(raw);
    final listingsJson = (payload['listings'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final listings = listingsJson.map(Listing.fromJson).toList();
    final totalCount =
        (payload['totalCount'] as num?)?.toInt() ?? listings.length;
    final hasMore = payload['hasMore'] as bool? ?? false;

    return SearchListingsResult(
      listings: listings,
      totalCount: totalCount,
      hasMore: hasMore,
    );
  }

  final List<Listing> listings;
  final int totalCount;
  final bool hasMore;

  SearchListingsResult copyWith({
    List<Listing>? listings,
    int? totalCount,
    bool? hasMore,
  }) {
    return SearchListingsResult(
      listings: listings ?? this.listings,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  static Map<String, dynamic> _extractPayload(Map<String, dynamic> raw) {
    if (raw.containsKey('ok') && raw['ok'] is Map<String, dynamic>) {
      return raw['ok'] as Map<String, dynamic>;
    }
    return raw;
  }
}
