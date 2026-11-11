import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Interactive Google Map widget with couple markers and love connection polyline
class WdPartnerGoogleMap extends StatelessWidget {
  final MapType mapType;
  final LatLng partnerPos;
  final LatLng? userPos;
  final BitmapDescriptor? partnerMarkerIcon;
  final BitmapDescriptor? userMarkerIcon;
  final String partnerName;
  final String placeName;
  final int batteryLevel;
  final bool isCharging;
  final void Function(GoogleMapController controller) onMapCreated;
  final VoidCallback onCameraMoveStarted;

  static const String _romanticPastelMapStyle = '''
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

  const WdPartnerGoogleMap({
    super.key,
    required this.mapType,
    required this.partnerPos,
    required this.userPos,
    required this.partnerMarkerIcon,
    required this.userMarkerIcon,
    required this.partnerName,
    required this.placeName,
    required this.batteryLevel,
    required this.isCharging,
    required this.onMapCreated,
    required this.onCameraMoveStarted,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('partner-marker'),
        position: partnerPos,
        icon: partnerMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        anchor: const Offset(0.5, 0.95),
        infoWindow: InfoWindow(
          title: '$partnerName ($placeName)',
          snippet:
              'Battery: $batteryLevel% • ${isCharging ? "Charging" : "Unplugged"}',
        ),
      ),
      if (userPos != null)
        Marker(
          markerId: const MarkerId('user-marker'),
          position: userPos!,
          icon: userMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          anchor: const Offset(0.5, 0.95),
          infoWindow: const InfoWindow(
            title: 'You',
            snippet: 'Your Live Location',
          ),
        ),
    };

    final polylines = <Polyline>{
      if (userPos != null)
        Polyline(
          polylineId: const PolylineId('couple-love-line'),
          points: [userPos!, partnerPos],
          color: BelieveColors.primary,
          width: 3,
          geodesic: true,
          patterns: [PatternItem.dash(14), PatternItem.gap(8)],
        ),
    };

    return GoogleMap(
      style: mapType == MapType.normal ? _romanticPastelMapStyle : null,
      mapType: mapType,
      initialCameraPosition: CameraPosition(target: partnerPos, zoom: 14.5),
      onMapCreated: onMapCreated,
      markers: markers,
      polylines: polylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      onCameraMoveStarted: onCameraMoveStarted,
    );
  }
}
