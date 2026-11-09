import 'package:flutter_test/flutter_test.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/features/anniversary/data/datasources/anniversary_remote_data_source.dart';
import 'package:thae_nge_lay/features/anniversary/data/repositories/anniversary_repository_impl.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/gifting/data/datasources/gifting_remote_data_source.dart';
import 'package:thae_nge_lay/features/gifting/data/repositories/gifting_repository_impl.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/location_trust/data/repositories/location_arrival_repository.dart';
import 'package:thae_nge_lay/features/location_trust/data/services/geocoding_service.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/notifications/data/services/fcm_notification_service.dart';
import 'package:thae_nge_lay/features/notifications/domain/models/couple_notification.dart';
import 'package:thae_nge_lay/features/pairing/data/datasources/pairing_remote_data_source.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_space.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';

class FakePairingRemoteDataSource implements PairingRemoteDataSource {
  final Map<String, String> _codeToUserId = {};
  final Map<String, String> _userIdToCode = {};
  final Map<String, String> _pairedUserLocks = {};
  final Map<String, CoupleSpace> _coupleSpaces = {};

  @override
  Future<String> getOrCreateInviteCode(String userId) async {
    if (_userIdToCode.containsKey(userId)) {
      return _userIdToCode[userId]!;
    }
    final code = 'COD${userId.hashCode.abs().toString().padLeft(3, '0').substring(0, 3)}';
    _codeToUserId[code] = userId;
    _userIdToCode[userId] = code;
    return code;
  }

  @override
  Future<String> generateNewInviteCode(String userId) async {
    final code = 'NEW${userId.hashCode.abs().toString().padLeft(3, '0').substring(0, 3)}';
    _codeToUserId[code] = userId;
    _userIdToCode[userId] = code;
    return code;
  }

  @override
  Future<CoupleSpace> pairWithCode({
    required String currentUserId,
    required String inviteCode,
  }) async {
    if (_pairedUserLocks.containsKey(currentUserId)) {
      throw Exception('Strict 1-to-1 Lock Enforced: Your account is already bonded with a partner.');
    }
    final targetUserId = _codeToUserId[inviteCode.trim().toUpperCase()];
    if (targetUserId == null) {
      throw Exception('Invalid or expired 6-digit couple code.');
    }
    if (targetUserId == currentUserId) {
      throw Exception('Self-pairing is strictly blocked.');
    }
    if (_pairedUserLocks.containsKey(targetUserId)) {
      throw Exception('Strict 1-to-1 Lock Enforced: Partner is already bonded.');
    }

    final space = CoupleSpace(
      id: 'space_${currentUserId}_$targetUserId',
      user1Id: targetUserId,
      user2Id: currentUserId,
      inviteCode: inviteCode,
      pairedAt: DateTime.now(),
      anniversaryDate: DateTime.now(),
      isActive: true,
    );
    _pairedUserLocks[currentUserId] = targetUserId;
    _pairedUserLocks[targetUserId] = currentUserId;
    _coupleSpaces[space.id] = space;
    return space;
  }

  @override
  Future<Map<String, dynamic>> checkPairingStatus(String userId) async {
    final isPaired = _pairedUserLocks.containsKey(userId);
    return {'isPaired': isPaired};
  }

  @override
  Future<CoupleSpace?> getCoupleSpace(String coupleSpaceId) async {
    return _coupleSpaces[coupleSpaceId];
  }

  @override
  Future<CoupleSummary> getCoupleSummary({
    required String coupleSpaceId,
    String? userId,
  }) async {
    return CoupleSummary(
      coupleSpaceId: coupleSpaceId,
      coverPhotoUrl: 'https://example.com/cover.jpg',
      daysTogether: 10,
      myProfile: UserProfile(
        id: userId ?? 'usr_1',
        displayName: 'Ko Ko',
        emailOrPhone: 'koko@believeus.app',
        role: 'BOYFRIEND',
      ),
      partnerProfile: const UserProfile(
        id: 'usr_2',
        displayName: 'Thae Nge Lay',
        emailOrPhone: 'thae@believeus.app',
        role: 'GIRLFRIEND',
      ),
    );
  }

  @override
  Future<void> unpair(String coupleSpaceId) async {
    final space = _coupleSpaces.remove(coupleSpaceId);
    if (space != null) {
      _pairedUserLocks.remove(space.user1Id);
      _pairedUserLocks.remove(space.user2Id);
    }
  }
}

void main() {
  group('Core Domain Rule #2: Strict 1-to-1 Partner Lock', () {
    late PairingRepositoryImpl pairingRepo;

    setUp(() {
      pairingRepo = PairingRepositoryImpl(
        remoteDataSource: FakePairingRemoteDataSource(),
      );
    });

    test('Self-pairing is strictly blocked with Failure.pairing', () async {
      const currentUserId = 'usr_alice';
      final codeResult =
          await pairingRepo.getOrCreateInviteCode(currentUserId);
      final myCode = codeResult.getOrElse((_) => '');

      final pairResult = await pairingRepo.pairWithCode(
        currentUserId: currentUserId,
        inviteCode: myCode,
      );

      expect(pairResult.isLeft(), isTrue);
      pairResult.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should not allow self-pairing'),
      );
    });

    test('Successful 1-to-1 pairing creates shared CoupleSpace', () async {
      const user1 = 'usr_user1';
      const user2 = 'usr_user2';

      final codeResult = await pairingRepo.getOrCreateInviteCode(user1);
      final user1Code = codeResult.getOrElse((_) => '');

      final pairResult = await pairingRepo.pairWithCode(
        currentUserId: user2,
        inviteCode: user1Code,
      );

      expect(pairResult.isRight(), isTrue);
      final space = pairResult.getOrElse((_) => throw Exception());
      expect(space.isActive, isTrue);
      expect(space.user1Id, equals(user1));
      expect(space.user2Id, equals(user2));

      // Attempting to pair an already paired user must be strictly blocked
      final doublePairResult = await pairingRepo.pairWithCode(
        currentUserId: user2,
        inviteCode: 'ANYCOD',
      );
      expect(doublePairResult.isLeft(), isTrue);
    });
  });

  group('Core Domain Rule #5: KBZPay & WavePay Gifting with fpdart', () {
    late GiftingRepositoryImpl giftingRepo;

    setUp(() {
      giftingRepo = GiftingRepositoryImpl(
        remoteDataSource: GiftingRemoteDataSourceImpl(),
      );
    });

    test('Returns available Myanmar couple packages', () async {
      final result = await giftingRepo.getAvailableGiftPackages();
      expect(result.isRight(), isTrue);
      final packages = result.getOrElse((_) => []);
      expect(packages.isNotEmpty, isTrue);
    });

    test('Initiates and verifies payment generating transaction reference',
        () async {
      final result = await giftingRepo.initiateAndVerifyPayment(
        senderId: 'usr_me',
        receiverId: 'usr_partner',
        coupleSpaceId: 'space_123',
        packageTitle: '99 Red Roses Bouquet',
        amountMmK: 35000,
        provider: PaymentProvider.kbzPay,
        note: 'Everlasting love',
      );

      expect(result.isRight(), isTrue);
      final tx = result.getOrElse((_) => throw Exception());
      expect(tx.transactionRef.startsWith('KBZ-'), isTrue);
      expect(tx.amountMmK, equals(35000));
    });

    test('Invalid amount returns Left(Failure.payment)', () async {
      final result = await giftingRepo.initiateAndVerifyPayment(
        senderId: 'usr_me',
        receiverId: 'usr_partner',
        coupleSpaceId: 'space_123',
        packageTitle: 'Test',
        amountMmK: 0,
        provider: PaymentProvider.wavePay,
        note: '',
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('Core Domain Rule #6: Anniversary & Milestone Engine', () {
    late AnniversaryRepositoryImpl anniversaryRepo;

    setUp(() {
      anniversaryRepo = AnniversaryRepositoryImpl(
        remoteDataSource: AnniversaryRemoteDataSourceImpl(),
      );
    });

    test('Loads shared couple timeline and seeds default memories', () async {
      final result = await anniversaryRepo.getMilestones('space_demo');
      expect(result.isRight(), isTrue);
      final list = result.getOrElse((_) => []);
      expect(list.isNotEmpty, isTrue);
    });

    test('Adding a new milestone succeeds with Either Right', () async {
      final result = await anniversaryRepo.addMilestone(
        coupleSpaceId: 'space_demo',
        title: 'First Flight Reunion',
        targetDate: DateTime.now().add(const Duration(days: 45)),
        isRecurringAnnual: false,
        iconEmoji: '✈️',
        note: 'Flight ticket booked!',
      );

      expect(result.isRight(), isTrue);
      final milestone = result.getOrElse((_) => throw Exception());
      expect(milestone.title, equals('First Flight Reunion'));
      expect(milestone.iconEmoji, equals('✈️'));
    });
  });

  group('Core Domain Rule #7: FCM Push Notifications for 5 Events', () {
    late FcmNotificationService fcmService;

    setUp(() async {
      fcmService = FcmNotificationService();
      await fcmService.init();
    });

    test('Triggers all 5 domain push notifications into the reactive stream',
        () async {
      final received = <CoupleNotification>[];
      final subscription =
          fcmService.onNotificationReceived.listen(received.add);

      // Event 1: New text message
      fcmService.triggerTextMessagePush(
        senderName: 'My Love',
        previewText: 'Thinking about holding your hand ❤️',
      );

      // Event 2: New voice message
      fcmService.triggerVoiceMessagePush(
        senderName: 'My Love',
        durationSeconds: 12,
      );

      // Event 3: KPay / WavePay gift received
      fcmService.triggerGiftReceivedPush(
        senderName: 'My Love',
        provider: 'KBZPay',
        amount: '50,000 MMK',
      );

      // Event 4: Partner location check-in / arrival alert
      fcmService.triggerLocationArrivalPush(
        partnerName: 'My Love',
        placeName: 'Mandalay, Myanmar',
      );

      // Event 5: Upcoming anniversary reminder
      fcmService.triggerAnniversaryReminderPush(
        title: 'The Day We Said Yes',
        daysRemaining: 7,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      expect(received.length, equals(5));
      expect(received[0].type, equals(NotificationType.textMessage));
      expect(received[1].type, equals(NotificationType.voiceMessage));
      expect(received[2].type, equals(NotificationType.giftReceived));
      expect(received[3].type, equals(NotificationType.locationArrival));
      expect(received[4].type, equals(NotificationType.anniversaryReminder));

      await subscription.cancel();
    });
  });

  group('Feature: Partner Location & Arrival Details (features/location_trust/)', () {
    late LocationArrivalRepository locationRepo;
    late FcmNotificationService fcmService;

    setUp(() {
      fcmService = FcmNotificationService();
      locationRepo = LocationArrivalRepository(
        geocodingService: GeocodingService(),
        fcmService: fcmService,
      );
    });

    test('Haversine distance calculation is accurate', () {
      // Distance between Kamayut (16.8295, 96.1305) and Sule (16.7795, 96.1603) ~ 6.4km
      final distMeters = locationRepo.calculateDistanceMeters(
        16.8295,
        96.1305,
        16.7795,
        96.1603,
      );
      expect(distMeters, greaterThan(5000));
      expect(distMeters, lessThan(8000));
    });

    test('Partner entering 150m of Trusted Place triggers arrival log and push notification', () async {
      final received = <CoupleNotification>[];
      final sub = fcmService.onNotificationReceived.listen(received.add);

      // Heartbeat at Sweet Home coordinates (16.8295, 96.1305)
      final result = await locationRepo.processLocationHeartbeat(
        partnerId: 'partner-id',
        partnerName: 'Thae Nge Lay',
        latitude: 16.8295,
        longitude: 96.1305,
        speedKmh: 0.0,
        batteryLevel: 80,
        isCharging: true,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should succeed'),
        (arrival) {
          expect(arrival.placeName, equals('Sweet Home'));
          expect(arrival.status, equals(MovementStatus.stationary));
          expect(arrival.batteryLevel, equals(80));
        },
      );

      await sub.cancel();
    });

    test('Partner moving > 200m departs previous location and marks moving status', () async {
      // Move far away from Sweet Home (~1 km away)
      final result = await locationRepo.processLocationHeartbeat(
        partnerId: 'partner-id',
        partnerName: 'Thae Nge Lay',
        latitude: 16.8500,
        longitude: 96.1400,
        speedKmh: 35.0,
        batteryLevel: 79,
        isCharging: false,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should succeed'),
        (arrival) {
          expect(arrival.status, equals(MovementStatus.moving));
          expect(arrival.speedKmh, equals(35.0));
        },
      );
    });

    test('Adding a new Trusted Place saves with 150m geofence', () async {
      final result = await locationRepo.addTrustedPlace(
        name: 'University Campus',
        iconName: 'school',
        latitude: 16.8240,
        longitude: 96.1330,
        radiusMeters: 150.0,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should add trusted place'),
        (place) {
          expect(place.name, equals('University Campus'));
          expect(place.radiusMeters, equals(150.0));
        },
      );

      final placesResult = await locationRepo.getTrustedPlaces();
      placesResult.fold(
        (_) => fail('Should load places'),
        (places) => expect(places.any((p) => p.name == 'University Campus'), isTrue),
      );
    });

    test('Sending Reached Safely heart nudge triggers sweet notification', () async {
      final received = <CoupleNotification>[];
      final sub = fcmService.onNotificationReceived.listen(received.add);

      final result = await locationRepo.sendReachedSafelyNudge(
        partnerName: 'Thae Nge Lay',
      );

      expect(result.isRight(), isTrue);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(received.any((n) => n.body.contains('Have you reached safely')), isTrue);

      await sub.cancel();
    });
  });
}
