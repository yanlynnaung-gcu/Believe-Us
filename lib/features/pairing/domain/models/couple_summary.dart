import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';

class CoupleSummary {
  final String coupleSpaceId;
  final String? coverPhotoUrl;
  final DateTime? anniversaryDate;
  final DateTime? startDate;
  final DateTime? pairedAt;
  final DateTime? serverTime;
  final int daysTogether;
  final UserProfile? myProfile;
  final UserProfile? partnerProfile;

  const CoupleSummary({
    required this.coupleSpaceId,
    this.coverPhotoUrl,
    this.anniversaryDate,
    this.startDate,
    this.pairedAt,
    this.serverTime,
    this.daysTogether = 0,
    this.myProfile,
    this.partnerProfile,
  });

  /// Official couple start date (anniversaryDate -> startDate -> pairedAt)
  DateTime? get officialStartDate => anniversaryDate ?? startDate ?? pairedAt;

  factory CoupleSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val)?.toUtc();
      }
      return null;
    }

    final parsedAnniversary = parseDate(json['anniversaryDate'] ?? json['startDate']);
    final parsedStartDate = parseDate(json['startDate'] ?? json['anniversaryDate']);
    final parsedPairedAt = parseDate(json['pairedAt'] ?? json['createdAt']);
    final parsedServerTime = parseDate(json['serverTime']);

    return CoupleSummary(
      coupleSpaceId: json['coupleSpaceId'] as String? ?? '',
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      anniversaryDate: parsedAnniversary ?? parsedStartDate ?? parsedPairedAt,
      startDate: parsedStartDate ?? parsedAnniversary ?? parsedPairedAt,
      pairedAt: parsedPairedAt,
      serverTime: parsedServerTime,
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
