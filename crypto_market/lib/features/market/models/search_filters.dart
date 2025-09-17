import 'package:crypto_market/features/market/models/listing.dart';

/// Supported sort orders for marketplace search results
enum SearchSortOption { newest, priceLowToHigh, priceHighToLow }

/// Immutable filter set for marketplace search operations
class SearchFilters {
  const SearchFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.location,
    this.condition,
    this.sortOption,
  });

  static const _unset = Object();

  final String? category;
  final int? minPrice;
  final int? maxPrice;
  final String? location;
  final ListingCondition? condition;
  final SearchSortOption? sortOption;

  SearchFilters copyWith({
    Object? category = _unset,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    Object? location = _unset,
    Object? condition = _unset,
    Object? sortOption = _unset,
  }) {
    return SearchFilters(
      category: category == _unset ? this.category : category as String?,
      minPrice: minPrice == _unset ? this.minPrice : minPrice as int?,
      maxPrice: maxPrice == _unset ? this.maxPrice : maxPrice as int?,
      location: location == _unset ? this.location : location as String?,
      condition: condition == _unset
          ? this.condition
          : condition as ListingCondition?,
      sortOption: sortOption == _unset
          ? this.sortOption
          : sortOption as SearchSortOption?,
    );
  }

  bool get isEmpty {
    return category == null &&
        minPrice == null &&
        maxPrice == null &&
        location == null &&
        condition == null &&
        sortOption == null;
  }

  Map<String, dynamic> toRequestPayload() {
    return {
      if (category != null) 'category': category,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (location != null) 'location': location,
      if (condition != null) 'condition': _conditionToString(condition!),
    };
  }

  String toDebugString() {
    final conditionLabel = condition == null
        ? null
        : _conditionToString(condition!);
    return '{category: $category, minPrice: $minPrice, maxPrice: $maxPrice, location: $location, condition: $conditionLabel, sort: $sortOption}';
  }

  static String _conditionToString(ListingCondition condition) {
    switch (condition) {
      case ListingCondition.newCondition:
        return 'new';
      case ListingCondition.used:
        return 'used';
      case ListingCondition.refurbished:
        return 'refurbished';
    }
  }
}
