import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_space.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';
import 'package:thae_nge_lay/features/pairing/domain/repositories/pairing_repository.dart';
import 'package:thae_nge_lay/features/pairing/presentation/screens/pairing_screen.dart';

class _FakeLocalStorageService extends Fake implements LocalStorageService {
  @override
  bool get isOnboardingCompleted => true;
  @override
  Future<void> setOnboardingCompleted(bool value) async {}
  @override
  String? get activeUserId => 'usr_boyfriend';
  @override
  Future<void> setActiveUserId(String? id) async {}
  @override
  String? get authToken => 'token_pairing_test';
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
  String? get coverPhotoPath => null;
  @override
  Future<void> setCoverPhotoPath(String? path) async {}
  @override
  String? get partnerAvatarPath => null;
  @override
  Future<void> setPartnerAvatarPath(String? path) async {}
  @override
  String? get partnerName => null;
  @override
  Future<void> setPartnerName(String? name) async {}
  @override
  DateTime? get partnerBirthday => null;
  @override
  Future<void> setPartnerBirthday(DateTime? date) async {}
  @override
  DateTime? get anniversaryDate => null;
  @override
  Future<void> setAnniversaryDate(DateTime? date) async {}
  @override
  int? get daysTogether => null;
  @override
  Future<void> setDaysTogether(int? days) async {}
  @override
  Future<void> clearAll() async {}
}

class _FakeWebSocketSyncService extends Fake implements WebSocketSyncService {
  final _controller = StreamController<WebSocketEvent>.broadcast();

  @override
  void updateCredentials({String? userId, String? coupleSpaceId}) {}

  @override
  Stream<WebSocketEvent> onEvent(String eventType) =>
      _controller.stream.where((e) => e.event == eventType);

  @override
  void dispose() => _controller.close();
}

class _MockPairingRepository extends Fake implements PairingRepository {
  String currentGeneratedCode = '482910';
  String? lastPairedCode;

  @override
  Future<Either<Failure, String>> getOrCreateInviteCode(String userId) async {
    return Right(currentGeneratedCode);
  }

  @override
  Future<Either<Failure, String>> generateNewInviteCode(String userId) async {
    currentGeneratedCode = '930182';
    return Right(currentGeneratedCode);
  }

  @override
  Future<Either<Failure, CoupleSpace>> pairWithCode({
    required String currentUserId,
    required String inviteCode,
  }) async {
    lastPairedCode = inviteCode;
    return Right(CoupleSpace(
      id: 'space_paired_redesign',
      user1Id: 'usr_partner',
      user2Id: currentUserId,
      inviteCode: inviteCode,
      pairedAt: DateTime.now(),
      anniversaryDate: DateTime.now(),
      isActive: true,
    ));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkPairingStatus(String userId) async {
    return const Right({'isPaired': false});
  }

  @override
  Future<Either<Failure, CoupleSummary>> getCoupleSummary({
    required String coupleSpaceId,
    String? userId,
  }) async {
    return Right(CoupleSummary(
      coupleSpaceId: coupleSpaceId,
      daysTogether: 10,
      myProfile: const UserProfile(
        id: 'usr_boyfriend',
        displayName: 'Ko Ko',
        emailOrPhone: 'koko@believeus.app',
        role: 'BOYFRIEND',
      ),
      partnerProfile: const UserProfile(
        id: 'usr_partner',
        displayName: 'Thae Thae',
        emailOrPhone: 'thae@believeus.app',
        role: 'GIRLFRIEND',
      ),
    ));
  }

  @override
  Future<Either<Failure, bool>> unpair(String coupleSpaceId) async {
    return const Right(true);
  }
}

class _MockAuthStateNotifier extends AuthStateNotifier {
  @override
  UserProfile? build() {
    return const UserProfile(
      id: 'usr_boyfriend',
      emailOrPhone: 'koko@believeus.app',
      displayName: 'Ko Ko',
      role: 'BOYFRIEND',
    );
  }
}

Widget _buildTestApp(Widget child, _MockPairingRepository mockRepo) {
  return ProviderScope(
    overrides: [
      localStorageServiceProvider.overrideWithValue(_FakeLocalStorageService()),
      webSocketSyncServiceProvider.overrideWithValue(_FakeWebSocketSyncService()),
      pairingRepositoryProvider.overrideWithValue(mockRepo),
      authStateProvider.overrideWith(() => _MockAuthStateNotifier()),
    ],
    child: ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        home: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UI/UX Redesign: QRPairingScreen', () {
    testWidgets('1. Theme & Welcoming Header renders romantic elements and subtitle',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = _MockPairingRepository();
      // Using QRPairingScreen typedef
      await tester.pumpWidget(_buildTestApp(const QRPairingScreen(), mockRepo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Welcoming header title and security subtitle
      expect(find.text('Soul Connection ✨'), findsOneWidget);
      expect(find.text('Connect with your soulmate securely'), findsOneWidget);
      expect(find.byIcon(LucideIcons.shieldCheck), findsOneWidget);
      expect(find.byIcon(LucideIcons.heartHandshake), findsWidgets);
    });

    testWidgets('2. Animated Pill-style Switcher renders tabs cleanly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = _MockPairingRepository();
      await tester.pumpWidget(_buildTestApp(const QRPairingScreen(), mockRepo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Pill tabs
      expect(find.text('Show My QR'), findsOneWidget);
      expect(find.text('Connect Partner'), findsOneWidget);
    });

    testWidgets('3. "Show My QR" Card renders countdown timer, copy button, and styled digits',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = _MockPairingRepository();
      await tester.pumpWidget(_buildTestApp(const QRPairingScreen(), mockRepo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify QR Code image container
      expect(find.byKey(const ValueKey('qr_image_482910')), findsOneWidget);

      // Verify prominent 6-digit typography
      expect(find.text('482910'), findsOneWidget);

      // Verify live countdown timer indicator
      expect(find.textContaining('Code expires in'), findsOneWidget);

      // Verify action buttons: Copy Code & New Code
      expect(find.text('Copy Code'), findsOneWidget);
      expect(find.text('New Code'), findsOneWidget);

      // Tap Copy Code
      await tester.tap(find.text('Copy Code'));
      await tester.pump();
      expect(find.text('Couple code copied to clipboard! ✨'), findsOneWidget);
    });

    testWidgets('4. "Connect Partner" Scanner View renders camera hero card and manual input',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = _MockPairingRepository();
      await tester.pumpWidget(_buildTestApp(const QRPairingScreen(), mockRepo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Tab 2
      await tester.tap(find.text('Connect Partner'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Scanner Hero Card
      expect(find.text('Scan Partner QR Code'), findsOneWidget);
      expect(find.text('Open Camera Scanner ✨'), findsOneWidget);

      // Verify Manual input section
      expect(find.text('Enter Partner\'s Secret Code'), findsOneWidget);
      expect(find.text('Bond & Connect Now ✨'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify Strict 1-to-1 lock alert
      expect(find.textContaining('Strict 1-to-1 Lock'), findsOneWidget);
    });
  });
}
