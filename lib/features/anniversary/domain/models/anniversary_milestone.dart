import 'package:freezed_annotation/freezed_annotation.dart';

part 'anniversary_milestone.freezed.dart';
part 'anniversary_milestone.g.dart';

@freezed
abstract class AnniversaryMilestone with _$AnniversaryMilestone {
  const factory AnniversaryMilestone({
    required String id,
    required String title,
    required DateTime targetDate,
    @Default(true) bool isRecurringAnnual,
    @Default('❤️') String iconEmoji,
    String? note,
    @Default('Anniversary') String category,
  }) = _AnniversaryMilestone;

  factory AnniversaryMilestone.fromJson(Map<String, dynamic> json) =>
      _$AnniversaryMilestoneFromJson(json);
}
