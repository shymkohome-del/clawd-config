import 'dart:async';

import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/market/cubit/search_listings_cubit.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/models/search_filters.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Screen responsible for searching and filtering marketplace listings
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _locationController = TextEditingController();
  late final ScrollController _scrollController;
  Timer? _debounce;

  SearchFilters _filters = const SearchFilters();
  String? _selectedCategory;
  ListingCondition? _selectedCondition;
  SearchSortOption? _selectedSort;

  static const _categories = <String>[
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports',
    'Books',
    'Automotive',
    'Collectibles',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _locationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (kDebugMode) {
        Logger.instance.logDebug(
          'Pagination threshold reached, requesting next page',
          tag: 'SearchScreen',
        );
      }
      context.read<SearchListingsCubit>().loadMore();
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (kDebugMode) {
        Logger.instance.logDebug(
          'Search query updated: "$value"',
          tag: 'SearchScreen',
        );
      }
      context.read<SearchListingsCubit>().search(
        query: value.trim(),
        filters: _filters,
      );
    });
  }

  void _applyFilters(AppLocalizations l10n) {
    final minPrice = int.tryParse(_minPriceController.text.trim());
    final maxPrice = int.tryParse(_maxPriceController.text.trim());
    final locationText = _locationController.text.trim();

    final updatedFilters = SearchFilters(
      category: _selectedCategory,
      minPrice: minPrice,
      maxPrice: maxPrice,
      location: locationText.isEmpty ? null : locationText,
      condition: _selectedCondition,
      sortOption: _selectedSort,
    );

    setState(() {
      _filters = updatedFilters;
    });

    if (kDebugMode) {
      Logger.instance.logDebug(
        'Applying filters ${_filters.toDebugString()}',
        tag: 'SearchScreen',
      );
    }

    context.read<SearchListingsCubit>().search(
      query: _searchController.text.trim(),
      filters: _filters,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.filtersApplied)));
  }

  void _clearFilters(AppLocalizations l10n) {
    _debounce?.cancel();
    setState(() {
      _filters = const SearchFilters();
      _selectedCategory = null;
      _selectedCondition = null;
      _selectedSort = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _locationController.clear();
      _searchController.clear();
    });

    if (kDebugMode) {
      Logger.instance.logDebug('Clearing filters', tag: 'SearchScreen');
    }

    context.read<SearchListingsCubit>().clearFilters();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.filtersCleared)));
  }

  String _categoryLabel(String category, AppLocalizations l10n) {
    final normalized = category
        .toLowerCase()
        .replaceAll('&', '')
        .replaceAll(' ', '_');
    switch (normalized) {
      case 'electronics':
        return l10n.categoryElectronics;
      case 'fashion':
        return l10n.categoryFashion;
      case 'home__garden':
      case 'home_garden':
        return l10n.categoryHomeGarden;
      case 'sports':
        return l10n.categorySports;
      case 'books':
        return l10n.categoryBooks;
      case 'automotive':
        return l10n.categoryAutomotive;
      case 'collectibles':
        return l10n.categoryCollectibles;
      case 'other':
        return l10n.categoryOther;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchListingsTitle),
        actions: [
          IconButton(
            tooltip: l10n.filtersClear,
            onPressed: () => _clearFilters(l10n),
            icon: const Icon(Icons.filter_alt_off),
          ),
        ],
      ),
      body: BlocConsumer<SearchListingsCubit, SearchListingsState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.status == SearchStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSearchField(l10n),
                      const SizedBox(height: 12),
                      _buildFilterSection(l10n),
                    ],
                  ),
                ),
              ),
              Expanded(child: _buildResults(state, l10n)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      onChanged: _onQueryChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: l10n.searchPlaceholder,
        labelText: l10n.searchFieldLabel,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildFilterSection(AppLocalizations l10n) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.filtersTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(_categoryLabel(category, l10n)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.filterPriceMin,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.filterPriceMax,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: l10n.filterLocationLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ListingCondition>(
              initialValue: _selectedCondition,
              decoration: InputDecoration(
                labelText: l10n.filterConditionLabel,
                border: const OutlineInputBorder(),
              ),
              items: ListingCondition.values.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(_conditionLabel(condition, l10n)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SearchSortOption>(
              initialValue: _selectedSort,
              decoration: InputDecoration(
                labelText: l10n.filterSortLabel,
                border: const OutlineInputBorder(),
              ),
              items: SearchSortOption.values.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(_sortLabel(option, l10n)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSort = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    key: const ValueKey('search_filters_apply_button'),
                    onPressed: () => _applyFilters(l10n),
                    icon: const Icon(Icons.filter_alt),
                    label: Text(l10n.filtersApply),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('search_filters_clear_button'),
                    onPressed: () => _clearFilters(l10n),
                    icon: const Icon(Icons.clear),
                    label: Text(l10n.filtersClear),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(SearchListingsState state, AppLocalizations l10n) {
    if (state.status == SearchStatus.loading && state.listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.listings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 48),
              const SizedBox(height: 16),
              Text(l10n.searchNoResults, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<SearchListingsCubit>().search(
          query: _searchController.text.trim(),
          filters: _filters,
        );
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.hasMore
            ? state.listings.length + 1
            : state.listings.length,
        separatorBuilder: (context, _) => const Divider(height: 0),
        itemBuilder: (context, index) {
          if (index >= state.listings.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final listing = state.listings[index];
          return _ListingTile(
            listing: listing,
            categoryLabel: _categoryLabel(listing.category, l10n),
            conditionLabel: _conditionLabel(listing.condition, l10n),
            priceLabel: '\$${listing.priceUSD}',
          );
        },
      ),
    );
  }

  String _conditionLabel(ListingCondition condition, AppLocalizations l10n) {
    switch (condition) {
      case ListingCondition.newCondition:
        return l10n.conditionNew;
      case ListingCondition.used:
        return l10n.conditionUsed;
      case ListingCondition.refurbished:
        return l10n.conditionRefurbished;
    }
  }

  String _sortLabel(SearchSortOption option, AppLocalizations l10n) {
    switch (option) {
      case SearchSortOption.newest:
        return l10n.sortNewest;
      case SearchSortOption.priceLowToHigh:
        return l10n.sortPriceLowHigh;
      case SearchSortOption.priceHighToLow:
        return l10n.sortPriceHighLow;
    }
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({
    required this.listing,
    required this.categoryLabel,
    required this.conditionLabel,
    required this.priceLabel,
  });

  final Listing listing;
  final String categoryLabel;
  final String conditionLabel;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.shopping_bag_outlined),
      title: Text(listing.title),
      subtitle: Text('$categoryLabel • $conditionLabel • ${listing.location}'),
      trailing: Text(
        priceLabel,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () {
        context.go('/listing/${listing.id}');
      },
      tileColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      enableFeedback: true,
      hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      focusColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.16),
    );
  }
}
