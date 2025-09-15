part of 'create_listing_cubit.dart';

abstract class CreateListingState {
  const CreateListingState();

  factory CreateListingState.initial() = CreateListingInitial;
  factory CreateListingState.submitting() = CreateListingSubmitting;
  factory CreateListingState.success({required int listingId}) =
      CreateListingSuccess;
  factory CreateListingState.failure(String error) = CreateListingFailure;
}

class CreateListingInitial extends CreateListingState {
  const CreateListingInitial();
}

class CreateListingSubmitting extends CreateListingState {
  const CreateListingSubmitting();
}

class CreateListingSuccess extends CreateListingState {
  const CreateListingSuccess({required this.listingId});
  final int listingId;
}

class CreateListingFailure extends CreateListingState {
  const CreateListingFailure(this.error);
  final String error;
}
