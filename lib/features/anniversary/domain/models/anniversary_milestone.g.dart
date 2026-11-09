// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anniversary_milestone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnniversaryMilestone _$AnniversaryMilestoneFromJson(
  Map<String, dynamic> json,
) => _AnniversaryMilestone(
  id: json['id'] as String,
  title: json['title'] as String,
  targetDate: DateTime.parse(json['targetDate'] as String),
  isRecurringAnnual: json['isRecurringAnnual'] as bool? ?? true,
  iconEmoji: json['iconEmoji'] as String? ?? '❤️',
  note: json['note'] as String?,
  category: json['category'] as String? ?? 'Anniversary',
);

Map<String, dynamic> _$AnniversaryMilestoneToJson(
  _AnniversaryMilestone instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'targetDate': instance.targetDate.toIso8601String(),
  'isRecurringAnnual': instance.isRecurringAnnual,
  'iconEmoji': instance.iconEmoji,
  'note': instance.note,
  'category': instance.category,
};
