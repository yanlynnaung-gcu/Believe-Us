// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  emailOrPhone: _readEmail(json, 'emailOrPhone') as String? ?? '',
  role: json['role'] as String? ?? 'BOYFRIEND',
  birthday: json['birthday'] == null
      ? null
      : DateTime.parse(json['birthday'] as String),
  photoUrl: _readPhoto(json, 'photoUrl') as String?,
  partnerId: json['partnerId'] as String?,
  coupleSpaceId: json['coupleSpaceId'] as String?,
  anniversaryDate: json['anniversaryDate'] == null
      ? null
      : DateTime.parse(json['anniversaryDate'] as String),
  isPhoneAuth: json['isPhoneAuth'] as bool? ?? false,
  isProfileComplete: json['isProfileComplete'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'emailOrPhone': instance.emailOrPhone,
      'role': instance.role,
      'birthday': instance.birthday?.toIso8601String(),
      'photoUrl': instance.photoUrl,
      'partnerId': instance.partnerId,
      'coupleSpaceId': instance.coupleSpaceId,
      'anniversaryDate': instance.anniversaryDate?.toIso8601String(),
      'isPhoneAuth': instance.isPhoneAuth,
      'isProfileComplete': instance.isProfileComplete,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
