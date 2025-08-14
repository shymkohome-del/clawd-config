import 'package:crypto_market/core/blockchain/icp_service.dart';

/// DI via Bloc RepositoryProvider at app root.
class AuthServiceProvider {
  final ICPService icpService;
  const AuthServiceProvider(this.icpService);
}


