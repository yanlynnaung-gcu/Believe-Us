// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GiftPackage _$GiftPackageFromJson(Map<String, dynamic> json) => _GiftPackage(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  amountMmK: (json['amountMmK'] as num).toInt(),
  iconEmoji: json['iconEmoji'] as String,
  isCustomMonetary: json['isCustomMonetary'] as bool? ?? false,
  categoryTag: json['categoryTag'] as String?,
);

Map<String, dynamic> _$GiftPackageToJson(_GiftPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'amountMmK': instance.amountMmK,
      'iconEmoji': instance.iconEmoji,
      'isCustomMonetary': instance.isCustomMonetary,
      'categoryTag': instance.categoryTag,
    };
