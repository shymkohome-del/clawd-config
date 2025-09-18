import 'package:crypto_market/core/blockchain/blockchain_service.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/market/models/create_listing_request.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/models/search_filters.dart';
import 'package:crypto_market/features/market/models/search_listings_result.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// Result type for update operations
sealed class UpdateListingResult {
  const UpdateListingResult();
}

class UpdateListingSuccess extends UpdateListingResult {
  final Listing listing;

  const UpdateListingSuccess(this.listing);
}

class UpdateListingFailure extends UpdateListingResult {
  final String error;

  const UpdateListingFailure(this.error);
}

/// Abstraction for market-related operations to enable mocking in tests.
abstract class MarketService {
  Future<Map<String, dynamic>> createListing(CreateListingRequest request);
  Future<UpdateListingResult> updateListing({
    required String listingId,
    required String title,
    required int priceInUsd,
    String? imagePath,
  });
  Future<SearchListingsResult> searchListings({
    String? query,
    SearchFilters filters = const SearchFilters(),
    int page = 0,
    int limit = 20,
  });
  Future<Listing?> getListingById(String listingId);
}

/// Implementation of MarketService using ICP blockchain
class MarketServiceProvider implements MarketService {
  final ICPService icpService;
  late final BlockchainService _blockchainService;

  MarketServiceProvider(this.icpService) {
    _blockchainService = BlockchainService(
      config: icpService.config,
      dio: Dio(),
      logger: Logger.instance,
    );
  }

  @override
  Future<Map<String, dynamic>> createListing(
    CreateListingRequest request,
  ) async {
    try {
      Logger.instance.logDebug(
        'Creating listing through blockchain service: ${request.title}',
        tag: 'MarketServiceProvider',
      );

      return await _blockchainService.createListing(
        title: request.title,
        description: request.description,
        priceUSD: request.priceUSD,
        cryptoType: request.cryptoType,
        images: request.images,
        category: request.category,
        condition: _conditionToString(request.condition),
        location: request.location,
        shippingOptions: request.shippingOptions,
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to create listing: ${request.title}',
        tag: 'MarketServiceProvider',
        error: e,
      );
      rethrow;
    }
  }

  /// Convert ListingCondition enum to string for canister call
  String _conditionToString(ListingCondition condition) {
    switch (condition) {
      case ListingCondition.newCondition:
        return 'new';
      case ListingCondition.used:
        return 'used';
      case ListingCondition.refurbished:
        return 'refurbished';
    }
  }

  @override
  Future<UpdateListingResult> updateListing({
    required String listingId,
    required String title,
    required int priceInUsd,
    String? imagePath,
  }) async {
    try {
      Logger.instance.logDebug(
        'Updating listing: $listingId',
        tag: 'MarketServiceProvider',
      );

      final result = await _blockchainService.updateListing(
        listingId: listingId,
        title: title,
        priceUSD: priceInUsd,
        images: imagePath != null ? [imagePath] : null,
      );

      final payload = _unwrapCanisterPayload(result);
      final updatedListing = Listing.fromJson(payload);

      Logger.instance.logInfo(
        'Listing updated successfully: $listingId',
        tag: 'MarketServiceProvider',
      );

      return UpdateListingSuccess(updatedListing);
    } catch (e) {
      Logger.instance.logError(
        'Failed to update listing: $listingId',
        tag: 'MarketServiceProvider',
        error: e,
      );

      return UpdateListingFailure(e.toString());
    }
  }

  @override
  Future<SearchListingsResult> searchListings({
    String? query,
    SearchFilters filters = const SearchFilters(),
    int page = 0,
    int limit = 20,
  }) async {
    final stopwatch = Stopwatch()..start();
    final filterPayload = filters.toRequestPayload();
    try {
      final response = await _blockchainService.getListings(
        query: query,
        category: filterPayload['category'] as String?,
        minPrice: filterPayload['minPrice'] as int?,
        maxPrice: filterPayload['maxPrice'] as int?,
        location: filterPayload['location'] as String?,
        condition: filterPayload['condition'] as String?,
        offset: page * limit,
        limit: limit,
      );

      final result = SearchListingsResult.fromMap(response);

      if (kDebugMode) {
        Logger.instance.logDebug(
          'Search completed in ${stopwatch.elapsedMilliseconds}ms – ${result.listings.length} results (total: ${result.totalCount})',
          tag: 'MarketServiceProvider',
        );
      }

      return result;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        Logger.instance.logError(
          'Search failed for query "$query" with filters ${filters.toDebugString()}',
          tag: 'MarketServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<Listing?> getListingById(String listingId) async {
    try {
      Logger.instance.logDebug(
        'Fetching listing by ID: $listingId',
        tag: 'MarketServiceProvider',
      );

      final response = await _blockchainService.getListing(listingId);

      if (response == null) {
        Logger.instance.logWarn(
          'Listing not found: $listingId',
          tag: 'MarketServiceProvider',
        );
        return null;
      }

      final listing = Listing.fromJson(response);

      Logger.instance.logDebug(
        'Successfully fetched listing: ${listing.title}',
        tag: 'MarketServiceProvider',
      );

      return listing;
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to fetch listing: $listingId',
        tag: 'MarketServiceProvider',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Helper to unwrap canister response payload
  Map<String, dynamic> _unwrapCanisterPayload(Map<String, dynamic> raw) {
    final okValue = raw['ok'];
    if (okValue is Map<String, dynamic>) {
      return okValue;
    }
    return raw;
  }
}
