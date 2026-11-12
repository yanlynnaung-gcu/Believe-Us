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
  static const String _keyCoverPhotoPath = 'couple_cover_photo_path';
  static const String _keyPartnerAvatarPath = 'couple_partner_avatar_path';
  static const String _keyPartnerName = 'couple_partner_name';
  static const String _keyPartnerBirthday = 'couple_partner_birthday';
  static const String _keyAnniversaryDate = 'couple_anniversary_date';
  static const String _keyDaysTogether = 'couple_days_together';

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

  String? get coverPhotoPath => _box.get(_keyCoverPhotoPath) as String?;
  Future<void> setCoverPhotoPath(String? path) async {
    if (path == null) {
      await _box.delete(_keyCoverPhotoPath);
    } else {
      await _box.put(_keyCoverPhotoPath, path);
    }
  }

  String? get partnerAvatarPath => _box.get(_keyPartnerAvatarPath) as String?;
  Future<void> setPartnerAvatarPath(String? path) async {
    if (path == null) {
      await _box.delete(_keyPartnerAvatarPath);
    } else {
      await _box.put(_keyPartnerAvatarPath, path);
    }
  }

  String? get partnerName => _box.get(_keyPartnerName) as String?;
  Future<void> setPartnerName(String? name) async {
    if (name == null) {
      await _box.delete(_keyPartnerName);
    } else {
      await _box.put(_keyPartnerName, name);
    }
  }

  DateTime? get partnerBirthday {
    final str = _box.get(_keyPartnerBirthday) as String?;
    return str != null ? DateTime.tryParse(str) : null;
  }
  Future<void> setPartnerBirthday(DateTime? date) async {
    if (date == null) {
      await _box.delete(_keyPartnerBirthday);
    } else {
      await _box.put(_keyPartnerBirthday, date.toIso8601String());
    }
  }

  DateTime? get anniversaryDate {
    final str = _box.get(_keyAnniversaryDate) as String?;
    return str != null ? DateTime.tryParse(str) : null;
  }
  Future<void> setAnniversaryDate(DateTime? date) async {
    if (date == null) {
      await _box.delete(_keyAnniversaryDate);
    } else {
      await _box.put(_keyAnniversaryDate, date.toUtc().toIso8601String());
    }
  }

  int? get daysTogether => _box.get(_keyDaysTogether) as int?;
  Future<void> setDaysTogether(int? days) async {
    if (days == null) {
      await _box.delete(_keyDaysTogether);
    } else {
      await _box.put(_keyDaysTogether, days);
    }
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}

@Riverpod(keepAlive: true)
LocalStorageService localStorageService(Ref ref) {
  return LocalStorageService();
}
