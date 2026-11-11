import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location/presentation/utils/romantic_marker_generator.dart';

/// Loads custom partner and user BitmapDescriptor icons
Future<Map<String, BitmapDescriptor>> loadCoupleMarkerIcons(CoupleMediaState media) async {
  final Map<String, BitmapDescriptor> icons = {};
  try {
    icons['partner'] = await RomanticMarkerGenerator.createCoupleMarker(
      label: media.partnerName,
      borderColor: BelieveColors.primary,
      isPartner: true,
      avatarProvider: getCustomImageProvider(media.partnerAvatarPath),
      cacheKey: 'partner_${media.partnerName}_${media.partnerAvatarPath}',
    );
    icons['user'] = await RomanticMarkerGenerator.createCoupleMarker(
      label: 'You',
      borderColor: BelieveColors.accentLavender,
      isPartner: false,
      avatarProvider: getCustomImageProvider(media.userAvatarPath),
      cacheKey: 'user_${media.userAvatarPath}',
    );
  } catch (_) {}
  return icons;
}
