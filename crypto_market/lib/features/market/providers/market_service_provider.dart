import 'package:crypto_market/core/blockchain/icp_service.dart';

/// DI via Bloc RepositoryProvider at app root.
class MarketServiceProvider {
  final ICPService icpService;
  const MarketServiceProvider(this.icpService);
}
