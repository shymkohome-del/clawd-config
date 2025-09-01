import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

/// User profile model with extended fields for profile and reputation management
@JsonSerializable()
class UserProfile {
  final String id; // Principal text representation
  final String email;
  final String username;
  final String authProvider;
  final int createdAtMillis;
  final int reputation;
  final bool kycVerified;
  final String? profileImage; // IPFS hash or URL

  const UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.authProvider,
    required this.createdAtMillis,
    this.reputation = 0,
    this.kycVerified = false,
    this.profileImage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  /// Create UserProfile from basic User model
  factory UserProfile.fromUser(
    dynamic user, {
    int reputation = 0,
    bool kycVerified = false,
    String? profileImage,
  }) {
    return UserProfile(
      id: user.id,
      email: user.email,
      username: user.username,
      authProvider: user.authProvider,
      createdAtMillis: user.createdAtMillis,
      reputation: reputation,
      kycVerified: kycVerified,
      profileImage: profileImage,
    );
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? email,
    String? username,
    String? authProvider,
    int? createdAtMillis,
    int? reputation,
    bool? kycVerified,
    String? profileImage,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      authProvider: authProvider ?? this.authProvider,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      reputation: reputation ?? this.reputation,
      kycVerified: kycVerified ?? this.kycVerified,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  /// Get trust level based on reputation score
  TrustLevel get trustLevel {
    if (reputation >= 1000) return TrustLevel.expert;
    if (reputation >= 500) return TrustLevel.trusted;
    if (reputation >= 100) return TrustLevel.established;
    if (reputation >= 50) return TrustLevel.newcomer;
    return TrustLevel.novice;
  }

  /// Get user's display name (username or email)
  String get displayName => username.isNotEmpty ? username : email;
}

/// User update model for profile modifications
@JsonSerializable()
class UserUpdate {
  final String? username;
  final String? profileImage;

  const UserUpdate({this.username, this.profileImage});

  factory UserUpdate.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateToJson(this);

  /// Check if update contains any changes
  bool get hasChanges => username != null || profileImage != null;
}

/// Trust levels based on reputation
enum TrustLevel {
  novice(0, 'Novice'),
  newcomer(50, 'Newcomer'),
  established(100, 'Established'),
  trusted(500, 'Trusted'),
  expert(1000, 'Expert');

  const TrustLevel(this.minReputation, this.displayName);

  final int minReputation;
  final String displayName;
}
