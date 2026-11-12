import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/core/utils/anniversary_date_utils.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/anniversary/data/repositories/anniversary_repository_impl.dart';
import 'package:thae_nge_lay/features/anniversary/domain/models/anniversary_milestone.dart';
import 'package:thae_nge_lay/features/anniversary/domain/repositories/anniversary_repository.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/controllers/anniversary_notifier.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_space.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';
import 'package:thae_nge_lay/features/pairing/domain/repositories/pairing_repository.dart';

class _FakeLocalStorageService implements LocalStorageService {
  String? _coverPath;
  String? _partnerAvatar;
  String? _partnerName;
  DateTime? _partnerBday;
  DateTime? _annDate;
  int? _daysTogether;

  @override
  String? get coverPhotoPath => _coverPath;
  @override
  Future<void> setCoverPhotoPath(String? path) async => _coverPath = path;

  @override
  String? get partnerAvatarPath => _partnerAvatar;
  @override
  Future<void> setPartnerAvatarPath(String? path) async => _partnerAvatar = path;

  @override
  String? get partnerName => _partnerName;
  @override
  Future<void> setPartnerName(String? name) async => _partnerName = name;

  @override
  DateTime? get partnerBirthday => _partnerBday;
  @override
  Future<void> setPartnerBirthday(DateTime? date) async => _partnerBday = date;

  @override
  DateTime? get anniversaryDate => _annDate;
  @override
  Future<void> setAnniversaryDate(DateTime? date) async => _annDate = date;

  @override
  int? get daysTogether => _daysTogether;
  @override
  Future<void> setDaysTogether(int? days) async => _daysTogether = days;

  @override
  bool get isOnboardingCompleted => true;
  @override
  Future<void> setOnboardingCompleted(bool value) async {}
  @override
  String? get activeUserId => 'usr_boyfriend';
  @override
  Future<void> setActiveUserId(String? id) async {}
  @override
  String? get authToken => 'token_test_123';
  @override
  Future<void> setAuthToken(String? token) async {}
  @override
  String? get userProfileJson => null;
  @override
  Future<void> setUserProfileJson(String? json) async {}
  @override
  bool get isLocationPermissionGranted => true;
  @override
  Future<void> setLocationPermissionGranted(bool value) async {}
  @override
  String getDeviceId() => 'dev_test_001';
  @override
  String getDeviceName() => 'Test Device';
  @override
  Future<void> clearAll() async {}
  @override
  Future<void> init() async {}
}

class _MockPairingRepository implements PairingRepository {
  DateTime officialDate = DateTime.utc(2025, 1, 1);

  @override
  Future<Either<Failure, CoupleSummary>> getCoupleSummary({
    required String coupleSpaceId,
    String? userId,
  }) async {
    return Right(CoupleSummary(
      coupleSpaceId: coupleSpaceId,
      coverPhotoUrl: '/uploads/covers/our_real_cover.jpg',
      anniversaryDate: officialDate,
      daysTogether: AnniversaryDateUtils.calculateDaysTogether(officialDate),
      serverTime: DateTime.now().toUtc(),
      myProfile: const UserProfile(
        id: 'usr_boyfriend',
        displayName: 'Ko Ko',
        role: 'BOYFRIEND',
        photoUrl: '/uploads/avatars/koko.jpg',
      ),
      partnerProfile: const UserProfile(
        id: 'usr_girlfriend',
        displayName: 'Thae Thae',
        role: 'GIRLFRIEND',
        photoUrl: '/uploads/avatars/thae.jpg',
      ),
    ));
  }

  @override
  Future<Either<Failure, CoupleSummary>> updateAnniversaryDate({
    required String coupleSpaceId,
    required DateTime anniversaryDate,
  }) async {
    officialDate = anniversaryDate.toUtc();
    return Right(CoupleSummary(
      coupleSpaceId: coupleSpaceId,
      anniversaryDate: officialDate,
      daysTogether: AnniversaryDateUtils.calculateDaysTogether(officialDate),
      serverTime: DateTime.now().toUtc(),
    ));
  }

  @override
  Future<Either<Failure, String>> generateNewInviteCode(String userId) async => const Right('123456');
  @override
  Future<Either<Failure, String>> getOrCreateInviteCode(String userId) async => const Right('123456');
  @override
  Future<Either<Failure, CoupleSpace?>> getCoupleSpace(String coupleSpaceId) async => const Right(null);
  @override
  Future<Either<Failure, Map<String, dynamic>>> checkPairingStatus(String userId) async => const Right({'isPaired': true});
  @override
  Future<Either<Failure, CoupleSpace>> pairWithCode({required String currentUserId, required String inviteCode}) async {
    throw UnimplementedError();
  }
  @override
  Future<Either<Failure, void>> unpair(String coupleSpaceId) async => const Right(null);
}

class _MockAnniversaryRepository implements AnniversaryRepository {
  @override
  Future<Either<Failure, List<AnniversaryMilestone>>> getMilestones(String coupleSpaceId) async {
    return Right([
      AnniversaryMilestone(
        id: 'm1',
        title: 'Our First Trip Together',
        targetDate: DateTime.now().add(const Duration(days: 30)),
        isRecurringAnnual: false,
        iconEmoji: '✈️',
      ),
    ]);
  }

  @override
  Future<Either<Failure, AnniversaryMilestone>> addMilestone({
    required String coupleSpaceId,
    required String title,
    required DateTime targetDate,
    required bool isRecurringAnnual,
    required String iconEmoji,
    String? note,
  }) async {
    return Right(AnniversaryMilestone(
      id: 'm2',
      title: title,
      targetDate: targetDate,
      isRecurringAnnual: isRecurringAnnual,
      iconEmoji: iconEmoji,
    ));
  }

  @override
  Future<Either<Failure, void>> deleteMilestone(String milestoneId) async => const Right(null);
}

class _TestAuthStateNotifier extends AuthStateNotifier {
  @override
  UserProfile? build() {
    return const UserProfile(
      id: 'usr_boyfriend',
      displayName: 'Ko Ko',
      role: 'BOYFRIEND',
      coupleSpaceId: 'space_couple_456',
      partnerId: 'usr_girlfriend',
      photoUrl: '/uploads/avatars/koko.jpg',
      isProfileComplete: true,
    );
  }
}

void main() {
  group('Date & Duration Calculation (UTC & Server Sync) Tests', () {
    test('AnniversaryDateUtils calculates UTC calendar day difference correctly (Day 1 on same day)', () {
      final todayUtc = DateTime.utc(2026, 11, 12, 15, 30);
      final startDate = DateTime.utc(2026, 11, 12, 2, 0);

      // Same calendar date -> Day 1 of relationship
      final days = AnniversaryDateUtils.calculateDaysTogether(startDate, serverTime: todayUtc);
      expect(days, equals(1));
    });

    test('AnniversaryDateUtils calculates 1 year duration consistently across timezones', () {
      // Exactly 365 calendar days ago
      final startDateUtc = DateTime.utc(2025, 11, 12, 10, 0);
      final currentUtc = DateTime.utc(2026, 11, 12, 18, 0);

      final days = AnniversaryDateUtils.calculateDaysTogether(startDateUtc, serverTime: currentUtc);
      // Calendar difference = 365, plus 1 for start day = 366th day together
      expect(days, equals(366));
    });

    test('Both client devices sync exact official start date from backend and eliminate 365 vs 1 day asymmetry', () async {
      final mockStorage = _FakeLocalStorageService();
      final mockPairingRepo = _MockPairingRepository();
      final mockAnniversaryRepo = _MockAnniversaryRepository();
      mockPairingRepo.officialDate = DateTime.utc(2024, 6, 1);

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          pairingRepositoryProvider.overrideWithValue(mockPairingRepo),
          anniversaryRepositoryProvider.overrideWithValue(mockAnniversaryRepo),
          authStateProvider.overrideWith(() => _TestAuthStateNotifier()),
        ],
      );

      // Read anniversary provider
      final stateBefore = container.read(anniversaryProvider);
      expect(stateBefore.daysTogether, greaterThanOrEqualTo(1));

      // Trigger backend sync
      await container.read(anniversaryProvider.notifier).syncAnniversaryFromBackend();

      final stateAfter = container.read(anniversaryProvider);
      expect(stateAfter.officialStartDate, equals(DateTime.utc(2024, 6, 1)));
      expect(stateAfter.daysTogether, greaterThan(500));
      // LocalStorage should now be cached with exact date
      expect(mockStorage.anniversaryDate, equals(DateTime.utc(2024, 6, 1)));
    });

    test('WebSocket ANNIVERSARY_UPDATED event instantly updates state on both partner devices', () async {
      final mockStorage = _FakeLocalStorageService();
      final mockPairingRepo = _MockPairingRepository();
      final mockAnniversaryRepo = _MockAnniversaryRepository();
      final wsService = WebSocketSyncService();

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          pairingRepositoryProvider.overrideWithValue(mockPairingRepo),
          anniversaryRepositoryProvider.overrideWithValue(mockAnniversaryRepo),
          webSocketSyncServiceProvider.overrideWithValue(wsService),
          authStateProvider.overrideWith(() => _TestAuthStateNotifier()),
        ],
      );

      container.read(anniversaryProvider);
      // Wait for initial background sync to complete
      await container.read(anniversaryProvider.notifier).syncAnniversaryFromBackend();

      // Simulate partner updating the anniversary date to 2023-01-01
      wsService.simulateIncomingEvent(WebSocketEvent(
        event: 'ANNIVERSARY_UPDATED',
        data: {
          'coupleSpaceId': 'space_couple_456',
          'anniversaryDate': '2023-01-01T00:00:00Z',
          'daysTogether': 1412,
          'serverTime': '2026-11-12T03:00:00Z',
        },
      ));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(anniversaryProvider);
      expect(state.daysTogether, equals(1412));
      expect(state.officialStartDate, equals(DateTime.utc(2023, 1, 1)));
      expect(mockStorage.anniversaryDate, equals(DateTime.utc(2023, 1, 1)));
    });
  });

  group('Image Loading & State Rebuild Stability Tests', () {
    test('CoupleMediaController preserves cached cover photo and partner avatar across state rebuilds', () async {
      final mockStorage = _FakeLocalStorageService();
      // Pre-seed storage with user-uploaded images
      await mockStorage.setCoverPhotoPath('/uploads/covers/sacred_bond.jpg');
      await mockStorage.setPartnerAvatarPath('/uploads/avatars/partner_custom.jpg');
      await mockStorage.setPartnerName('My Sweetheart');

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(mockStorage),
          pairingRepositoryProvider.overrideWithValue(_MockPairingRepository()),
          authStateProvider.overrideWith(() => _TestAuthStateNotifier()),
        ],
      );

      final state = container.read(coupleMediaProvider);

      // Must NOT reset to hardcoded unsplash placeholders
      expect(state.coverPhotoPath, equals('/uploads/covers/sacred_bond.jpg'));
      expect(state.partnerAvatarPath, equals('/uploads/avatars/partner_custom.jpg'));
      expect(state.partnerName, equals('My Sweetheart'));
    });

    test('getImageUrl cleanly resolves backend uploads and handles missing local file paths without bogus host prepends', () {
      // Valid relative backend paths
      expect(getImageUrl('/uploads/avatars/pic.jpg'), contains('/uploads/avatars/pic.jpg'));
      expect(getImageUrl('/covers/photo.jpg'), contains('/covers/photo.jpg'));

      // Non-existent device local path must fall back to default placeholder and NEVER prepend baseUrl
      const missingDevicePath = '/data/user/0/com.believeus.app/cache/non_existent.jpg';
      final resolved = getImageUrl(missingDevicePath);
      expect(resolved, equals(kDefaultFallbackImageUrl));
      expect(resolved.contains('/data/user/0'), isFalse);
    });
  });
}
