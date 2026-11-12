import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_space.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';
import 'package:thae_nge_lay/features/pairing/domain/repositories/pairing_repository.dart';
import 'package:thae_nge_lay/features/pairing/presentation/controllers/pairing_controller.dart';
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
    currentGeneratedCode = '719304';
    return Right(currentGeneratedCode);
  }

  @override
  Future<Either<Failure, CoupleSpace>> pairWithCode({
    required String currentUserId,
    required String inviteCode,
  }) async {
    lastPairedCode = inviteCode;
    if (!RegExp(r'^\d{6}$').hasMatch(inviteCode)) {
      return const Left(Failure.server('Pairing code must be exactly 6 digits'));
    }
    return Right(CoupleSpace(
      id: 'space_paired_6digit',
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
      daysTogether: 1,
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

Widget _buildTestWidget(Widget child, _MockPairingRepository mockRepo) {
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

  group('Strict 6-Digit Couple Pairing Feature', () {
    testWidgets('Tab 1: Generates strict pure 6-digit payload in QrImageView and large typography',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = _MockPairingRepository();
      await tester.pumpWidget(_buildTestWidget(const PairingScreen(), mockRepo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify strict 6-digit pure payload is passed to QrImageView (NO url prefix, NO json)
      final qrFinder = find.byKey(const ValueKey('qr_image_482910'));
      expect(qrFinder, findsOneWidget);

      // Verify 6-digit large typography is rendered
      expect(find.text('482910'), findsOneWidget);

      // Verify instruction text specifies 6-digit secret code
      expect(
        find.text('Your partner can scan this QR or type your 6-digit secret code.'),
        findsOneWidget,
      );
    });

    testWidgets('Tab 2: Manual fallback input restricts keyboard to number and max 6 digits',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = _MockPairingRepository();
      await tester.pumpWidget(_buildTestWidget(const PairingScreen(), mockRepo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Tab 2: Connect Partner
      await tester.tap(find.text('Connect Partner'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find TextField
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);
      final textField = tester.widget<TextField>(textFieldFinder);

      // Verify numeric keyboard restriction
      expect(textField.keyboardType, equals(TextInputType.number));

      // Verify formatters: length limit of 6 and digits-only
      final hasLengthLimiter = textField.inputFormatters
          ?.any((f) => f is LengthLimitingTextInputFormatter && f.maxLength == 6);
      expect(hasLengthLimiter, isTrue);

      final hasDigitsOnly = textField.inputFormatters
          ?.any((f) => f is FilteringTextInputFormatter && f == FilteringTextInputFormatter.digitsOnly);
      expect(hasDigitsOnly, isTrue);

      // Verify numeric hint text
      expect(textField.decoration?.hintText, equals('482910'));
    });

    test('PairingController: Strict Regex extracts 6-digit code from raw or embedded text', () async {
      final mockRepo = _MockPairingRepository();
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(_FakeLocalStorageService()),
          webSocketSyncServiceProvider.overrideWithValue(_FakeWebSocketSyncService()),
          pairingRepositoryProvider.overrideWithValue(mockRepo),
          authStateProvider.overrideWith(() => _MockAuthStateNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(pairingControllerProvider.notifier);

      // 1. Pure 6-digit code
      final res1 = await controller.pairWithCode('482910');
      expect(res1, isTrue);
      expect(mockRepo.lastPairedCode, equals('482910'));

      // 2. Embedded in scanned text / QR URL
      final res2 = await controller.pairWithCode('https://believeus.app/pair?code=618095');
      expect(res2, isTrue);
      expect(mockRepo.lastPairedCode, equals('618095'));

      // 3. Raw text with prefix e.g. "PAIR-993821"
      final res3 = await controller.pairWithCode('PAIR-993821');
      expect(res3, isTrue);
      expect(mockRepo.lastPairedCode, equals('993821'));

      // 4. Invalid non-6-digit code rejected immediately
      final res4 = await controller.pairWithCode('12345');
      expect(res4, isFalse);
      expect(container.read(pairingControllerProvider).errorMessage,
          contains('6-digit numeric code'));

      final res5 = await controller.pairWithCode('ABCDEF');
      expect(res5, isFalse);
      expect(container.read(pairingControllerProvider).errorMessage,
          contains('6-digit numeric code'));
    });
  });
}
