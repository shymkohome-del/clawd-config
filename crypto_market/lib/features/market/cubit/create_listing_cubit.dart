import 'package:bloc/bloc.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/market/models/create_listing_request.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';

part 'create_listing_state.dart';

class CreateListingCubit extends Cubit<CreateListingState> {
  CreateListingCubit({required MarketService marketService})
    : _marketService = marketService,
      super(CreateListingState.initial());

  final MarketService _marketService;

  /// Create a new listing with the provided details
  Future<void> createListing(CreateListingRequest request) async {
    if (state is CreateListingSubmitting) return;

    Logger.instance.logDebug(
      'Creating listing: ${request.title}',
      tag: 'CreateListingCubit',
    );

    emit(CreateListingState.submitting());

    try {
      final result = await _marketService.createListing(request);

      Logger.instance.logInfo(
        'Listing created successfully: ${request.title}',
        tag: 'CreateListingCubit',
      );

      // Extract listing ID from result
      final payload = _unwrapCanisterPayload(result);
      final rawListingId = payload['id'] ?? payload['listingId'];
      final listingId = rawListingId == null ? '' : rawListingId.toString();
      emit(CreateListingState.success(listingId: listingId));
    } catch (error) {
      Logger.instance.logError(
        'Failed to create listing: ${request.title}',
        tag: 'CreateListingCubit',
        error: error,
      );

      emit(CreateListingState.failure(error.toString()));
    }
  }

  /// Reset state to initial
  void reset() {
    emit(CreateListingState.initial());
  }
}

Map<String, dynamic> _unwrapCanisterPayload(Map<String, dynamic> raw) {
  final okValue = raw['ok'];
  if (okValue is Map<String, dynamic>) {
    return okValue;
  }
  return raw;
}
