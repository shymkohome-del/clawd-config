part of 'listing_detail_cubit.dart';

enum ListingDetailStatus { initial, loading, success, failure }

class ListingDetailState extends Equatable {
  const ListingDetailState({
    this.status = ListingDetailStatus.initial,
    this.listing,
    this.sellerProfile,
    this.errorMessage,
  });

  final ListingDetailStatus status;
  final Listing? listing;
  final UserProfile? sellerProfile;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, listing, sellerProfile, errorMessage];

  ListingDetailState copyWith({
    ListingDetailStatus? status,
    Listing? listing,
    UserProfile? sellerProfile,
    String? errorMessage,
  }) {
    return ListingDetailState(
      status: status ?? this.status,
      listing: listing ?? this.listing,
      sellerProfile: sellerProfile ?? this.sellerProfile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
