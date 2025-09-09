import 'package:crypto_market/core/blockchain/blockchain_service.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:dio/dio.dart';

/// DI via Bloc RepositoryProvider at app root.
class MarketServiceProvider {
  final ICPService icpService;
  late final BlockchainService _blockchainService;

  MarketServiceProvider(this.icpService) {
    _blockchainService = BlockchainService(
      dio: Dio(),
      logger: logger,
    );
  }

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
