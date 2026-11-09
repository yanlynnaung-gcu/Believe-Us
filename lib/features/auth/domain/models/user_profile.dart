import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

Object? _readEmail(Map json, String key) =>
    json['email'] ?? json['emailOrPhone'] ?? '';

Object? _readPhoto(Map json, String key) =>
    json['avatarUrl'] ?? json['photoUrl'];

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String displayName,
    @JsonKey(readValue: _readEmail) @Default('') String emailOrPhone,
    @Default('BOYFRIEND') String role,
    DateTime? birthday,
    @JsonKey(readValue: _readPhoto) String? photoUrl,
    String? partnerId,
    String? coupleSpaceId,
    DateTime? anniversaryDate,
    @Default(false) bool isPhoneAuth,
    @Default(true) bool isProfileComplete,
    DateTime? createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
