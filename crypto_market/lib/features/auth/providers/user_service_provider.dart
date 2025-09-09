import 'dart:io';
import 'dart:typed_data';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/auth/models/user_profile.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart' show ICPService;

/// Service for user profile operations
abstract class UserService {
  /// Get user profile by principal
  Future<Result<UserProfile, AuthError>> getUserProfile(String principal);

  /// Update user profile with new data
  Future<Result<UserProfile, AuthError>> updateUserProfile(
    String principal,
    UserUpdate updates,
  );

  /// Update user reputation (admin/system operation)
  Future<Result<void, AuthError>> updateReputation(
    String principal,
    int reputationChange,
  );

  /// Upload image to IPFS and return hash
  Future<Result<String, AuthError>> uploadImageToIPFS(Uint8List imageData);

  /// Upload image file to IPFS and return hash
  Future<Result<String, AuthError>> uploadImageFileToIPFS(File imageFile);
}

/// Implementation of UserService using ICP service layer
class UserServiceProvider implements UserService {
  final ICPService icpService; // ICPService dependency

  const UserServiceProvider(this.icpService);

  @override
  Future<Result<UserProfile, AuthError>> getUserProfile(
    String principal,
  ) async {
    try {
      // TODO: Replace with actual canister call
      final result = await icpService.getUserProfile(principal: principal);

      if (result.isErr) {
        return Result.err(result.err);
      }

      final Map<String, dynamic> profileData = result.ok;

      // Mock profile data for now - replace with actual canister response parsing
      final profile = UserProfile(
        id: principal,
        email: profileData['email'] ?? 'user@example.com',
        username: profileData['username'] ?? 'user',
        authProvider: profileData['authProvider'] ?? 'email',
        createdAtMillis:
            profileData['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
        reputation: profileData['reputation'] ?? 0,
        kycVerified: profileData['kycVerified'] ?? false,
        profileImage: profileData['profileImage'],
      );

      return Result.ok(profile);
    } catch (e) {
      return Result.err(mapAuthExceptionToAuthError(e));
    }
  }

  @override
  Future<Result<UserProfile, AuthError>> updateUserProfile(
    String principal,
    UserUpdate updates,
  ) async {
    try {
      // TODO: Replace with actual canister call
      // Validate inputs
      if (updates.username != null && updates.username!.trim().isEmpty) {
        return const Result.err(AuthError.invalidCredentials);
      }

      // Simulate canister call
      await Future.delayed(const Duration(milliseconds: 100));

      // Get current profile to merge with updates
      final currentProfileResult = await getUserProfile(principal);
      if (currentProfileResult.isErr) {
        return Result.err(currentProfileResult.err);
      }

      final currentProfile = currentProfileResult.ok;
      final updatedProfile = currentProfile.copyWith(
        username: updates.username,
        profileImage: updates.profileImage,
      );

      return Result.ok(updatedProfile);
    } catch (e) {
      return Result.err(mapAuthExceptionToAuthError(e));
    }
  }

  @override
  Future<Result<void, AuthError>> updateReputation(
    String principal,
    int reputationChange,
  ) async {
    try {
      // TODO: Replace with actual canister call
      // This would typically be called by system/admin operations
      await Future.delayed(const Duration(milliseconds: 50));
      return const Result.ok(null);
    } catch (e) {
      return Result.err(mapAuthExceptionToAuthError(e));
    }
  }

  @override
  Future<Result<String, AuthError>> uploadImageToIPFS(
    Uint8List imageData,
  ) async {
    try {
      // TODO: Replace with actual IPFS integration
      // For now, simulate IPFS upload
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate mock IPFS hash
      final hash =
          'Qm${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
      return Result.ok(hash);
    } catch (e) {
      return const Result.err(AuthError.network);
    }
  }

  @override
  Future<Result<String, AuthError>> uploadImageFileToIPFS(
    File imageFile,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return uploadImageToIPFS(bytes);
    } catch (e) {
      return const Result.err(AuthError.network);
    }
  }
}

/// Mock implementation for testing
class MockUserService implements UserService {
  final Map<String, UserProfile> _profiles = {};

  @override
  Future<Result<UserProfile, AuthError>> getUserProfile(
    String principal,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final profile =
        _profiles[principal] ??
        UserProfile(
          id: principal,
          email: 'test@example.com',
          username: 'testuser',
          authProvider: 'email',
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        );

    return Result.ok(profile);
  }

  @override
  Future<Result<UserProfile, AuthError>> updateUserProfile(
    String principal,
    UserUpdate updates,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final currentResult = await getUserProfile(principal);
    if (currentResult.isErr) return Result.err(currentResult.err);

    final updated = currentResult.ok.copyWith(
      username: updates.username,
      profileImage: updates.profileImage,
    );

    _profiles[principal] = updated;
    return Result.ok(updated);
  }

  @override
  Future<Result<void, AuthError>> updateReputation(
    String principal,
    int reputationChange,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return const Result.ok(null);
  }

  @override
  Future<Result<String, AuthError>> uploadImageToIPFS(
    Uint8List imageData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Result.ok('QmMockHash${imageData.length}');
  }

  @override
  Future<Result<String, AuthError>> uploadImageFileToIPFS(
    File imageFile,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final stats = await imageFile.stat();
    return Result.ok('QmMockHash${stats.size}');
  }
}
