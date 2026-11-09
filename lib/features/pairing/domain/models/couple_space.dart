import 'package:freezed_annotation/freezed_annotation.dart';

part 'couple_space.freezed.dart';
part 'couple_space.g.dart';

@freezed
abstract class CoupleSpace with _$CoupleSpace {
  const factory CoupleSpace({
    required String id,
    required String user1Id,
    required String user2Id,
    required String inviteCode,
    required DateTime pairedAt,
    DateTime? anniversaryDate,
    @Default(true) bool isActive,
  }) = _CoupleSpace;

  factory CoupleSpace.fromJson(Map<String, dynamic> json) =>
      _$CoupleSpaceFromJson(json);
}
