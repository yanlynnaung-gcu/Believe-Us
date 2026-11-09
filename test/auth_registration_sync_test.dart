import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/domain/repositories/auth_repository.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/auth/presentation/screens/login_screen.dart';
import 'package:thae_nge_lay/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_space.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';
import 'package:thae_nge_lay/features/pairing/domain/repositories/pairing_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserProfile? registeredUser;

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendEmailOtp(String email) async {
    return Right({'message': 'A 6-digit verification code has been sent to $email'});
  }

  @override
  Future<Either<Failure, ({UserProfile user, bool isNewUser})>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final user = UserProfile(
      id: 'usr_otp_verified',
      displayName: 'My Love',
      emailOrPhone: email,
      role: 'BOYFRIEND',
      isProfileComplete: false,
    );
    return Right((user: user, isNewUser: true));
  }

  @override
  Future<Either<Failure, UserProfile>> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    DateTime? birthday,
    File? avatarFile,
  }) async {
    final user = UserProfile(
      id: 'usr_real_${DateTime.now().millisecondsSinceEpoch}',
      displayName: displayName,
      emailOrPhone: email,
      role: role,
      birthday: birthday,
      photoUrl: avatarFile != null ? '/uploads/avatars/real_avatar.jpg' : null,
      isProfileComplete: true,
    );
    registeredUser = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, UserProfile>> login({
    required String email,
    required String password,
  }) async {
    final user = UserProfile(
      id: 'usr_real_login',
      displayName: 'Ko Ko',
      emailOrPhone: email,
      role: 'BOYFRIEND',
      birthday: DateTime(1998, 5, 12),
      photoUrl: '/uploads/avatars/koko.jpg',
      partnerId: 'usr_real_thae',
      coupleSpaceId: 'space_123',
      isProfileComplete: true,
    );
    return Right(user);
  }

  @override
  Future<Either<Failure, UserProfile>> signInWithGoogle({
    String? role,
    DateTime? birthday,
  }) async {
    final user = UserProfile(
      id: 'usr_google_1',
      displayName: 'Google Love',
      emailOrPhone: 'google@believeus.app',
      role: role ?? 'BOYFRIEND',
      birthday: birthday,
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      isProfileComplete: true,
    );
    return Right(user);
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File avatarFile,
  }) async {
    return const Right('/uploads/avatars/uploaded_pic.jpg');
  }

  @override
  Future<Either<Failure, String>> uploadCoverPhoto({
    required String coupleSpaceId,
    required File coverFile,
  }) async {
    return const Right('/uploads/covers/uploaded_cover.jpg');
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String userId,
    required String displayName,
    String? role,
    DateTime? birthday,
    String? avatarUrl,
  }) async {
    return Right(UserProfile(
      id: userId,
      displayName: displayName,
      emailOrPhone: 'user@believeus.app',
      role: role ?? 'BOYFRIEND',
      birthday: birthday,
      photoUrl: avatarUrl,
      isProfileComplete: true,
    ));
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return const Right(null);
  }
}

class MockPairingRepository implements PairingRepository {
  @override
  Future<Either<Failure, String>> getOrCreateInviteCode(String userId) async {
    return const Right('LOVE01');
  }

  @override
  Future<Either<Failure, String>> generateNewInviteCode(String userId) async {
    return const Right('LOVE02');
  }

  @override
  Future<Either<Failure, CoupleSpace>> pairWithCode({
    required String currentUserId,
    required String inviteCode,
  }) async {
    return Right(CoupleSpace(
      id: 'space_real_123',
      user1Id: 'usr_boyfriend',
      user2Id: currentUserId,
      inviteCode: inviteCode,
      pairedAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<Failure, CoupleSpace?>> getCoupleSpace(String coupleSpaceId) async {
    return const Right(null);
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
      coverPhotoUrl: '/uploads/covers/our_space.jpg',
      daysTogether: 42,
      myProfile: const UserProfile(
        id: 'usr_boyfriend',
        displayName: 'Ko Ko',
        emailOrPhone: 'koko@believeus.app',
        role: 'BOYFRIEND',
        photoUrl: '/uploads/avatars/koko.jpg',
      ),
      partnerProfile: UserProfile(
        id: 'usr_girlfriend',
        displayName: 'Thae Nge Lay',
        emailOrPhone: 'thae@believeus.app',
        role: 'GIRLFRIEND',
        birthday: DateTime(2000, 8, 20),
        photoUrl: '/uploads/avatars/thae.jpg',
      ),
    ));
  }

  @override
  Future<Either<Failure, void>> unpair(String coupleSpaceId) async {
    return const Right(null);
  }
}

class MockLocalStorageService implements LocalStorageService {
  String? _userId;
  String? _profileJson;
  String? _token;

  @override
  bool get isOnboardingCompleted => true;
  @override
  Future<void> setOnboardingCompleted(bool value) async {}
  @override
  String? get activeUserId => _userId;
  @override
  Future<void> setActiveUserId(String? id) async => _userId = id;
  @override
  String? get authToken => _token;
  @override
  Future<void> setAuthToken(String? token) async => _token = token;
  @override
  String? get userProfileJson => _profileJson;
  @override
  Future<void> setUserProfileJson(String? json) async => _profileJson = json;
  @override
  bool get isLocationPermissionGranted => true;
  @override
  Future<void> setLocationPermissionGranted(bool value) async {}
  @override
  Future<void> clearAll() async {}
  @override
  Future<void> init() async {}
}

void main() {
  group('Real User Registration & Partner Profile Live Sync Tests', () {
    late MockAuthRepository mockAuthRepo;
    late MockPairingRepository mockPairingRepo;
    late MockLocalStorageService mockStorage;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      mockPairingRepo = MockPairingRepository();
      mockStorage = MockLocalStorageService();
    });

    testWidgets('LoginScreen toggles between Email OTP, Sign In and Sign Up tabs cleanly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
            localStorageServiceProvider.overrideWithValue(mockStorage),
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (context, child) => const MaterialApp(
              home: LoginScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on Free Email OTP tab
      expect(find.text('Free Email OTP Sign-In'), findsOneWidget);
      expect(find.text('Send 6-Digit OTP Code 💌'), findsOneWidget);
      expect(find.text('Continue with Google Account'), findsOneWidget);

      // Tap on "Sign In 💕" tab
      await tester.tap(find.text('Sign In 💕'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back, My Love'), findsOneWidget);
      expect(find.text('Sign In With Love 💕'), findsOneWidget);

      // Tap on "Sign Up ✨" tab
      await tester.tap(find.text('Sign Up ✨'));
      await tester.pumpAndSettle();

      // Now on Create Account tab
      expect(find.text('Create Our Love Account'), findsOneWidget);
      expect(find.text('Your Romantic Display Name'), findsOneWidget);
      expect(find.text('Boyfriend'), findsOneWidget);
      expect(find.text('Girlfriend'), findsOneWidget);
      expect(find.text('Your Birthday'), findsOneWidget);
      expect(find.text('Create Our Love Account ✨'), findsOneWidget);
    });

    testWidgets('OtpVerifyScreen renders 6 digits and email recipient badge', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
            localStorageServiceProvider.overrideWithValue(mockStorage),
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (context, child) => const MaterialApp(
              home: OtpVerifyScreen(email: 'koko@believeus.app'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Verify Your Email 💌'), findsOneWidget);
      expect(find.text('koko@believeus.app'), findsOneWidget);
      expect(find.text('Verify & Enter Sanctuary 💕'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
    });

    test('CoupleMediaController populates real partner name, avatar, and birthday from CoupleSummary', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          pairingRepositoryProvider.overrideWithValue(mockPairingRepo),
          localStorageServiceProvider.overrideWithValue(mockStorage),
          authStateProvider.overrideWith(() => _TestAuthStateNotifier()),
        ],
      );

      final controller = container.read(coupleMediaProvider.notifier);
      final summaryResult = await mockPairingRepo.getCoupleSummary(
        coupleSpaceId: 'space_real_123',
        userId: 'usr_boyfriend',
      );

      summaryResult.fold(
        (_) => fail('Failed to get summary'),
        (summary) {
          controller.initFromCoupleSummary(summary);
          final state = container.read(coupleMediaProvider);
          expect(state.partnerName, equals('Thae Nge Lay'));
          expect(state.partnerAvatarPath, equals('/uploads/avatars/thae.jpg'));
          expect(state.coverPhotoPath, equals('/uploads/covers/our_space.jpg'));
          expect(state.userAvatarPath, equals('/uploads/avatars/koko.jpg'));
          expect(state.partnerBirthday.month, equals(8));
          expect(state.partnerBirthday.day, equals(20));
        },
      );
    });

    test('UserProfile model supports readValue serialization from backend email and avatarUrl', () {
      final backendJson = {
        'id': 'usr_real_001',
        'email': 'thae@believeus.app',
        'displayName': 'Thae Nge Lay',
        'role': 'GIRLFRIEND',
        'avatarUrl': '/uploads/avatars/thae_real.jpg',
        'birthday': '2000-08-20',
      };

      final profile = UserProfile.fromJson(backendJson);
      expect(profile.id, equals('usr_real_001'));
      expect(profile.displayName, equals('Thae Nge Lay'));
      expect(profile.emailOrPhone, equals('thae@believeus.app'));
      expect(profile.role, equals('GIRLFRIEND'));
      expect(profile.photoUrl, equals('/uploads/avatars/thae_real.jpg'));
      expect(profile.birthday?.year, equals(2000));
      expect(profile.birthday?.month, equals(8));
      expect(profile.birthday?.day, equals(20));
    });
  });
}

class _TestAuthStateNotifier extends AuthStateNotifier {
  @override
  UserProfile? build() {
    return const UserProfile(
      id: 'usr_boyfriend',
      displayName: 'Ko Ko',
      emailOrPhone: 'koko@believeus.app',
      role: 'BOYFRIEND',
      partnerId: 'usr_girlfriend',
      coupleSpaceId: 'space_real_123',
    );
  }
}
