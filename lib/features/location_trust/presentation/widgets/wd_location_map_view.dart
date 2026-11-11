import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_romantic_map_pins.dart';

/// Top Map View displaying interactive Google Map with custom pastel styling and couple markers
class WdLocationMapView extends StatelessWidget {
  final LocationDetailState state;
  final CoupleMediaState coupleMedia;
  final Animation<double> pulseAnimation;
  final void Function(GoogleMapController controller)? onMapCreated;
  final bool useGoogleMaps;

  static const String _pastelMapStyle = '''
  [
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#DCEBFF"}]},
    {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#FFF9FB"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#FFFFFF"}]},
    {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#FFEBF1"}]},
    {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#EAF9EE"}]},
    {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#8C7B83"}]},
    {"featureType": "transit", "stylers": [{"visibility": "off"}]}
  ]
  ''';

  const WdLocationMapView({
    super.key,
    required this.state,
    required this.coupleMedia,
    required this.pulseAnimation,
    this.onMapCreated,
    this.useGoogleMaps = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!useGoogleMaps) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF6F8), Color(0xFFEFF5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _PastelGridPainter(),
            ),
            WdRomanticHeartPinsOverlay(
              partnerName: state.partnerName,
              partnerAvatarPath: coupleMedia.partnerAvatarPath,
              userAvatarPath: coupleMedia.userAvatarPath,
              pulseAnimation: pulseAnimation,
            ),
          ],
        ),
      );
    }

    final partnerLatLng = LatLng(state.partnerLatitude, state.partnerLongitude);
    final userLatLng =
        LatLng(state.currentUserLatitude, state.currentUserLongitude);

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('partner'),
        position: partnerLatLng,
        infoWindow: InfoWindow(
          title: "${state.partnerName} (${state.placeName})",
          snippet: state.addressLine,
        ),
      ),
      Marker(
        markerId: const MarkerId('user'),
        position: userLatLng,
        infoWindow: const InfoWindow(title: 'You', snippet: 'Your Live Location'),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('couple-connection'),
        points: [userLatLng, partnerLatLng],
        color: BelieveColors.primary,
        width: 4,
        patterns: [PatternItem.dash(15), PatternItem.gap(10)],
      ),
    };

    return Stack(
      children: [
        GoogleMap(
          style: _pastelMapStyle,
          initialCameraPosition: CameraPosition(
            target: partnerLatLng,
            zoom: 13.5,
          ),
          onMapCreated: onMapCreated,
          markers: markers,
          polylines: polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: WdRomanticHeartPinsOverlay(
              partnerName: state.partnerName,
              partnerAvatarPath: coupleMedia.partnerAvatarPath,
              userAvatarPath: coupleMedia.userAvatarPath,
              pulseAnimation: pulseAnimation,
            ),
          ),
        ),
      ],
    );
  }
}

class _PastelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF0E5EB)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
