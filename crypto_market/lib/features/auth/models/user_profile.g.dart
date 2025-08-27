// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  authProvider: json['authProvider'] as String,
  createdAtMillis: (json['createdAtMillis'] as num).toInt(),
  reputation: (json['reputation'] as num?)?.toInt() ?? 0,
  kycVerified: json['kycVerified'] as bool? ?? false,
  profileImage: json['profileImage'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'authProvider': instance.authProvider,
      'createdAtMillis': instance.createdAtMillis,
      'reputation': instance.reputation,
      'kycVerified': instance.kycVerified,
      'profileImage': instance.profileImage,
    };

UserUpdate _$UserUpdateFromJson(Map<String, dynamic> json) => UserUpdate(
  username: json['username'] as String?,
  profileImage: json['profileImage'] as String?,
);

Map<String, dynamic> _$UserUpdateToJson(UserUpdate instance) =>
    <String, dynamic>{
      'username': instance.username,
      'profileImage': instance.profileImage,
    };
