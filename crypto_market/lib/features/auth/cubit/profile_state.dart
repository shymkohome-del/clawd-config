part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state when profile cubit is first created
class ProfileInitial extends ProfileState {}

/// State when profile data is being loaded
class ProfileLoading extends ProfileState {}

/// State when profile data has been loaded successfully
class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

/// State when profile is being updated
class ProfileUpdating extends ProfileState {
  final UserProfile profile;

  const ProfileUpdating(this.profile);

  @override
  List<Object> get props => [profile];
}

/// State when profile update was successful
class ProfileUpdateSuccess extends ProfileState {
  final UserProfile profile;

  const ProfileUpdateSuccess(this.profile);

  @override
  List<Object> get props => [profile];
}

/// State when an error occurred during profile operations
class ProfileError extends ProfileState {
  final AuthError error;

  const ProfileError(this.error);

  @override
  List<Object> get props => [error];
}
