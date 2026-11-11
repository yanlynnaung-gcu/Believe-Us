import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Smooth lerp animator for moving partner coordinate updates over WebSocket
class PartnerMapMovementAnimator {
  final AnimationController controller;
  late final Animation<double> animation;
  LatLng? startLatLng;
  LatLng? targetLatLng;
  int _lastTickMs = 0;

  PartnerMapMovementAnimator({required this.controller, required VoidCallback onTick}) {
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    )..addListener(() {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (!controller.isCompleted && (now - _lastTickMs < 80)) return;
        _lastTickMs = now;
        onTick();
      });
  }

  LatLng? computeCurrentLatLng() {
    if (startLatLng == null || targetLatLng == null) return null;
    final t = animation.value;
    final lat = ui.lerpDouble(startLatLng!.latitude, targetLatLng!.latitude, t);
    final lng = ui.lerpDouble(startLatLng!.longitude, targetLatLng!.longitude, t);
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return null;
  }

  void animateTo(LatLng newCoords, LatLng? currentCoords) {
    if (currentCoords == null) {
      targetLatLng = newCoords;
      return;
    }
    final latDiff = (currentCoords.latitude - newCoords.latitude).abs();
    final lngDiff = (currentCoords.longitude - newCoords.longitude).abs();
    if (latDiff < 0.0001 && lngDiff < 0.0001) return;

    startLatLng = currentCoords;
    targetLatLng = newCoords;
    controller.stop();
    controller.forward(from: 0.0);
  }

  static void fitBounds({
    required GoogleMapController? controller,
    required LatLng? userLatLng,
    required LatLng? partnerLatLng,
    double padding = 70.0,
  }) {
    if (controller == null || userLatLng == null || partnerLatLng == null) return;
    final southWest = LatLng(
      math.min(userLatLng.latitude, partnerLatLng.latitude) - 0.005,
      math.min(userLatLng.longitude, partnerLatLng.longitude) - 0.005,
    );
    final northEast = LatLng(
      math.max(userLatLng.latitude, partnerLatLng.latitude) + 0.005,
      math.max(userLatLng.longitude, partnerLatLng.longitude) + 0.005,
    );
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        padding,
      ),
    );
  }

  void dispose() {
    controller.dispose();
  }
}
