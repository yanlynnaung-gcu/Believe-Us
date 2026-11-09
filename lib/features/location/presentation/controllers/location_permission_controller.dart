import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/location/data/services/location_service.dart';

part 'location_permission_controller.g.dart';

@Riverpod(keepAlive: true)
class LocationPermissionController extends _$LocationPermissionController {
  @override
  bool build() {
    final storage = ref.watch(localStorageServiceProvider);
    _verifyLiveStatus();
    return storage.isLocationPermissionGranted;
  }

  Future<void> _verifyLiveStatus() async {
    final service = ref.read(locationServiceProvider);
    final hasPerm = await service.hasMandatoryPermission();
    if (hasPerm != state) {
      await setGranted(hasPerm);
    }
  }

  Future<void> setGranted(bool granted) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setLocationPermissionGranted(granted);
    state = granted;
  }

  Future<bool> requestLocationPermission() async {
    final service = ref.read(locationServiceProvider);

    final serviceEnabled = await service.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await service.openLocationSettings();
      final retryEnabled = await service.isLocationServiceEnabled();
      if (!retryEnabled) {
        await setGranted(false);
        return false;
      }
    }

    var permission = await service.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await service.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await service.openAppSettings();
      return false;
    }

    final isGranted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    await setGranted(isGranted);
    return isGranted;
  }
}
