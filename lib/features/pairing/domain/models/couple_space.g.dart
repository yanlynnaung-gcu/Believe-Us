// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_space.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoupleSpace _$CoupleSpaceFromJson(Map<String, dynamic> json) => _CoupleSpace(
  id: json['id'] as String,
  user1Id: json['user1Id'] as String,
  user2Id: json['user2Id'] as String,
  inviteCode: json['inviteCode'] as String,
  pairedAt: DateTime.parse(json['pairedAt'] as String),
  anniversaryDate: json['anniversaryDate'] == null
      ? null
      : DateTime.parse(json['anniversaryDate'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$CoupleSpaceToJson(_CoupleSpace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user1Id': instance.user1Id,
      'user2Id': instance.user2Id,
      'inviteCode': instance.inviteCode,
      'pairedAt': instance.pairedAt.toIso8601String(),
      'anniversaryDate': instance.anniversaryDate?.toIso8601String(),
      'isActive': instance.isActive,
    };
