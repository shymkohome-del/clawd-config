import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';

final marketServiceProvider = Provider<ICPService>((ref) {
  throw UnimplementedError('marketServiceProvider must be overridden at app root');
});


