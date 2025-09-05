import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/auth/models/user_profile.dart';
import 'package:crypto_market/features/auth/providers/user_service_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserService _userService;

  ProfileCubit(this._userService) : super(ProfileInitial());

  /// Load user profile data
  Future<void> loadProfile(String principal) async {
    emit(ProfileLoading());

    final result = await _userService.getUserProfile(principal);

    if (result.isOk) {
      emit(ProfileLoaded(result.ok));
    } else {
      emit(ProfileError(result.err));
    }
  }

  /// Update user profile with new data
  Future<void> updateProfile({
    required String principal,
    String? username,
    File? profileImage,
  }) async {
    if (state is! ProfileLoaded) {
      emit(ProfileError(AuthError.unknown));
      return;
    }

    emit(ProfileUpdating((state as ProfileLoaded).profile));

    String? profileImageHash;

    // Upload image to IPFS if provided
    if (profileImage != null) {
      final uploadResult = await _userService.uploadImageFileToIPFS(
        profileImage,
      );

      if (uploadResult.isErr) {
        emit(ProfileError(uploadResult.err));
        return;
      }

      profileImageHash = uploadResult.ok;
    }

    // Create update object with only changed fields
    final updates = UserUpdate(
      username: username,
      profileImage: profileImageHash,
    );

    if (!updates.hasChanges) {
      // No changes to make, return to loaded state
      emit(ProfileLoaded((state as ProfileUpdating).profile));
      return;
    }

    // Update profile
    FirebaseCrashlytics.instance.log('profile_update_attempt');
    final updateResult = await _userService.updateUserProfile(
      principal,
      updates,
    );

    if (updateResult.isOk) {
      FirebaseCrashlytics.instance.log('profile_update_success');
      emit(ProfileLoaded(updateResult.ok));
      emit(ProfileUpdateSuccess(updateResult.ok));
    } else {
      FirebaseCrashlytics.instance.log(
        'profile_update_error: ${updateResult.err}',
      );
      emit(ProfileError(updateResult.err));
    }
  }

  /// Upload profile image data directly
  Future<void> uploadProfileImage({
    required String principal,
    required Uint8List imageData,
  }) async {
    if (state is! ProfileLoaded) {
      emit(ProfileError(AuthError.unknown));
      return;
    }

    emit(ProfileUpdating((state as ProfileLoaded).profile));

    // Upload image to IPFS
    final uploadResult = await _userService.uploadImageToIPFS(imageData);

    if (uploadResult.isErr) {
      emit(ProfileError(uploadResult.err));
      return;
    }

    // Update profile with new image hash
    final updates = UserUpdate(profileImage: uploadResult.ok);
    final updateResult = await _userService.updateUserProfile(
      principal,
      updates,
    );

    if (updateResult.isOk) {
      emit(ProfileLoaded(updateResult.ok));
      emit(ProfileUpdateSuccess(updateResult.ok));
    } else {
      emit(ProfileError(updateResult.err));
    }
  }

  /// Reset error state
  void clearError() {
    if (state is ProfileError) {
      emit(ProfileInitial());
    }
  }

  /// Reset to initial state
  void reset() {
    emit(ProfileInitial());
  }
}
