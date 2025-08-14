import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';

final authServiceProvider = Provider<ICPService>((ref) {
  throw UnimplementedError('authServiceProvider must be overridden at app root');
});


