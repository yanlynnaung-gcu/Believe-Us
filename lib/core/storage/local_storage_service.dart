import 'dart:io' show Platform;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'local_storage_service.g.dart';

class LocalStorageService {
  static const String _settingsBox = 'settings_box';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyActiveUserId = 'active_user_id';
  static const String _keyAuthToken = 'auth_jwt_token';
  static const String _keyUserProfileJson = 'user_profile_json';
  static const String _keyLocationPermissionGranted = 'location_permission_granted';
  static const String _keyDeviceId = 'unique_device_id';
  static const String _keyDeviceName = 'device_display_name';

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_settingsBox);
  }

  bool get isOnboardingCompleted =>
      _box.get(_keyOnboardingCompleted, defaultValue: false) as bool;

  Future<void> setOnboardingCompleted(bool value) async {
    await _box.put(_keyOnboardingCompleted, value);
  }

  String? get activeUserId => _box.get(_keyActiveUserId) as String?;

  Future<void> setActiveUserId(String? id) async {
    if (id == null) {
      await _box.delete(_keyActiveUserId);
    } else {
      await _box.put(_keyActiveUserId, id);
    }
  }

  String? get authToken => _box.get(_keyAuthToken) as String?;

  Future<void> setAuthToken(String? token) async {
    if (token == null) {
      await _box.delete(_keyAuthToken);
    } else {
      await _box.put(_keyAuthToken, token);
    }
  }

  String? get userProfileJson => _box.get(_keyUserProfileJson) as String?;

  Future<void> setUserProfileJson(String? json) async {
    if (json == null) {
      await _box.delete(_keyUserProfileJson);
    } else {
      await _box.put(_keyUserProfileJson, json);
    }
  }

  bool get isLocationPermissionGranted =>
      _box.get(_keyLocationPermissionGranted, defaultValue: false) as bool;

  Future<void> setLocationPermissionGranted(bool value) async {
    await _box.put(_keyLocationPermissionGranted, value);
  }

  String getDeviceId() {
    final existing = _box.get(_keyDeviceId) as String?;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final newId = 'dev_${const Uuid().v4().replaceAll('-', '').substring(0, 16)}';
    _box.put(_keyDeviceId, newId);
    return newId;
  }

  String getDeviceName() {
    final existing = _box.get(_keyDeviceName) as String?;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    String name = 'Mobile Device';
    try {
      if (Platform.isAndroid) {
        name = 'Android Device';
      } else if (Platform.isIOS) {
        name = 'iPhone / iOS Device';
      } else if (Platform.isMacOS) {
        name = 'Mac';
      }
    } catch (_) {}
    _box.put(_keyDeviceName, name);
    return name;
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}

@Riverpod(keepAlive: true)
LocalStorageService localStorageService(Ref ref) {
  return LocalStorageService();
}
