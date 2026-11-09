import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';

class CoupleSummary {
  final String coupleSpaceId;
  final String? coverPhotoUrl;
  final DateTime? anniversaryDate;
  final int daysTogether;
  final UserProfile? myProfile;
  final UserProfile? partnerProfile;

  const CoupleSummary({
    required this.coupleSpaceId,
    this.coverPhotoUrl,
    this.anniversaryDate,
    this.daysTogether = 0,
    this.myProfile,
    this.partnerProfile,
  });

  factory CoupleSummary.fromJson(Map<String, dynamic> json) {
    return CoupleSummary(
      coupleSpaceId: json['coupleSpaceId'] as String? ?? '',
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      anniversaryDate: json['anniversaryDate'] != null
          ? DateTime.tryParse(json['anniversaryDate'] as String)
          : null,
      daysTogether: (json['daysTogether'] as num?)?.toInt() ?? 0,
      myProfile: json['myProfile'] != null
          ? UserProfile.fromJson(Map<String, dynamic>.from(json['myProfile'] as Map))
          : null,
      partnerProfile: json['partnerProfile'] != null
          ? UserProfile.fromJson(Map<String, dynamic>.from(json['partnerProfile'] as Map))
          : null,
    );
  }
}
