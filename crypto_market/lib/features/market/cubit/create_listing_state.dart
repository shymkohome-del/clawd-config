part of 'create_listing_cubit.dart';

abstract class CreateListingState {
  const CreateListingState();

  factory CreateListingState.initial() = CreateListingInitial;
  factory CreateListingState.submitting() = CreateListingSubmitting;
<<<<<<< HEAD
  factory CreateListingState.success({required int listingId}) =
=======
  factory CreateListingState.success({required String listingId}) =
>>>>>>> develop
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
<<<<<<< HEAD
  final int listingId;
=======
  final String listingId;
>>>>>>> develop
}

class CreateListingFailure extends CreateListingState {
  const CreateListingFailure(this.error);
  final String error;
}
