import 'package:crypto_market/core/blockchain/blockchain_service.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/market/models/create_listing_request.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:dio/dio.dart';

/// Abstraction for market-related operations to enable mocking in tests.
abstract class MarketService {
  Future<Map<String, dynamic>> createListing(CreateListingRequest request);
  Future<void> updateListing({
    required String listingId,
    required String title,
    required int priceInUsd,
    String? imagePath,
  });
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
  Future<void> updateListing({
    required String listingId,
    required String title,
    required int priceInUsd,
    String? imagePath,
  }) async {
    await _blockchainService.updateListing(
      listingId: listingId,
      title: title,
      priceInUsd: priceInUsd,
    );
  }
}
