import 'package:bloc/bloc.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/auth/models/user_profile.dart';
import 'package:crypto_market/features/auth/providers/user_service_provider.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:equatable/equatable.dart';

part 'listing_detail_state.dart';

/// Manages the state for viewing a single listing detail
class ListingDetailCubit extends Cubit<ListingDetailState> {
  ListingDetailCubit({
    required MarketService marketService,
    required UserService userService,
  }) : _marketService = marketService,
       _userService = userService,
       super(const ListingDetailState());

  final MarketService _marketService;
  final UserService _userService;

  /// Load a listing by its ID and fetch seller profile
  Future<void> loadListing(String listingId) async {
    if (state.status == ListingDetailStatus.loading) {
      return;
    }

    emit(
      state.copyWith(status: ListingDetailStatus.loading, errorMessage: null),
    );

    try {
      Logger.instance.logDebug(
        'Loading listing: $listingId',
        tag: 'ListingDetailCubit',
      );

      final listing = await _marketService.getListingById(listingId);

      if (listing == null) {
        Logger.instance.logWarn(
          'Listing not found: $listingId',
          tag: 'ListingDetailCubit',
        );
        emit(
          state.copyWith(
            status: ListingDetailStatus.failure,
            errorMessage: 'Listing not found',
          ),
        );
        return;
      }

      Logger.instance.logDebug(
        'Successfully loaded listing: ${listing.title}',
        tag: 'ListingDetailCubit',
      );

      // Fetch seller profile
      final sellerProfileResult = await _userService.getUserProfile(
        listing.seller,
      );

      if (sellerProfileResult.isErr) {
        Logger.instance.logWarn(
          'Failed to load seller profile for: ${listing.seller}',
          tag: 'ListingDetailCubit',
        );
        // Still emit success with listing, but without seller profile
        emit(
          state.copyWith(
            status: ListingDetailStatus.success,
            listing: listing,
            errorMessage: null,
          ),
        );
        return;
      }

      final sellerProfile = sellerProfileResult.ok;
      Logger.instance.logDebug(
        'Successfully loaded seller profile: ${sellerProfile.username}',
        tag: 'ListingDetailCubit',
      );

      emit(
        state.copyWith(
          status: ListingDetailStatus.success,
          listing: listing,
          sellerProfile: sellerProfile,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to load listing: $listingId',
        tag: 'ListingDetailCubit',
        error: error,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: ListingDetailStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Reset the state to initial
  void reset() {
    emit(const ListingDetailState());
  }
}
