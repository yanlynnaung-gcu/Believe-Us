import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:thae_nge_lay/features/chat/domain/models/chat_message.dart';
import 'package:thae_nge_lay/features/chat/domain/repositories/chat_repository.dart';
import 'package:thae_nge_lay/features/gifting/data/repositories/gifting_repository_impl.dart';
import 'package:thae_nge_lay/features/gifting/data/services/gifting_payment_intent_service.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/repositories/gifting_repository.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/gifting_controller.dart';
import 'believe_us_domain_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GiftingPaymentIntentService Deep Link & URL Builder Tests', () {
    test('builds valid KBZPay mobile app deep link scheme', () {
      final url = GiftingPaymentIntentService.buildPaymentIntentUrl(
        provider: PaymentProvider.kbzPay,
        orderId: 'ord_kbz_123',
        amountMmK: 35000,
        packageTitle: '99 Red Roses Bouquet',
      );

      expect(url.startsWith('kbzpay://pay?'), isTrue);
      expect(url.contains('orderId=ord_kbz_123'), isTrue);
      expect(url.contains('amount=35000'), isTrue);
      expect(url.contains('callbackUrl=believeus%3A%2F%2Fpayment%2Fcallback'), isTrue);
    });

    test('builds valid WavePay mobile app deep link scheme', () {
      final url = GiftingPaymentIntentService.buildPaymentIntentUrl(
        provider: PaymentProvider.wavePay,
        orderId: 'ord_wave_456',
        amountMmK: 15000,
        packageTitle: 'Sweet Boba & Bakery Date',
      );

      expect(url.startsWith('wavepay://payment?'), isTrue);
      expect(url.contains('orderId=ord_wave_456'), isTrue);
      expect(url.contains('amount=15000'), isTrue);
      expect(url.contains('callbackUrl=believeus%3A%2F%2Fpayment%2Fcallback'), isTrue);
    });

    test('builds valid web fallback merchant payment URLs', () {
      final kbzWeb = GiftingPaymentIntentService.buildFallbackWebUrl(
        provider: PaymentProvider.kbzPay,
        orderId: 'ord_1',
        amountMmK: 10000,
        packageTitle: 'Pocket Blessing',
      );
      expect(kbzWeb.startsWith('https://payment.kbzpay.com/pay?'), isTrue);

      final waveWeb = GiftingPaymentIntentService.buildFallbackWebUrl(
        provider: PaymentProvider.wavePay,
        orderId: 'ord_2',
        amountMmK: 30000,
        packageTitle: 'Care Package',
      );
      expect(waveWeb.startsWith('https://pay.wavemoney.com.mm/payment?'), isTrue);
    });

    test('parses incoming payment callback deep link URI correctly', () {
      final successUri = Uri.parse(
        'believeus://payment/callback?status=success&orderId=ord_test_01&txnRef=KPAY-778899&provider=KBZPAY',
      );
      final result = GiftingPaymentIntentService.parseCallbackUri(successUri);

      expect(result.isSuccess, isTrue);
      expect(result.isCancelled, isFalse);
      expect(result.orderId, equals('ord_test_01'));
      expect(result.transactionRef, equals('KPAY-778899'));
      expect(result.provider, equals(PaymentProvider.kbzPay));

      final cancelUri = Uri.parse(
        'believeus://payment/callback?status=cancel&orderId=ord_test_02&provider=WAVEPAY',
      );
      final cancelResult = GiftingPaymentIntentService.parseCallbackUri(cancelUri);
      expect(cancelResult.isCancelled, isTrue);
      expect(cancelResult.isSuccess, isFalse);
      expect(cancelResult.provider, equals(PaymentProvider.wavePay));
    });
  });

  group('GiftingController Intent Flow, Callback & WebSocket Automation', () {
    late ProviderContainer container;
    late GiftingRepository fakeRepo;
    late FakeChatRepository fakeChatRepo;
    late FakeWebSocketSyncService fakeWsService;

    setUp(() {
      fakeRepo = GiftingRepositoryImpl(
        remoteDataSource: FakeGiftingRemoteDataSource(),
      );
      fakeChatRepo = FakeChatRepository();
      fakeWsService = FakeWebSocketSyncService();

      final testUser = UserProfile(
        id: 'usr_gifting_sender',
        displayName: 'Ko Ko',
        role: 'BOYFRIEND',
        partnerId: 'usr_gifting_partner',
        coupleSpaceId: 'space_gifting_001',
      );

      container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(() => MockAuthStateNotifier(testUser)),
          giftingRepositoryProvider.overrideWithValue(fakeRepo),
          chatRepositoryProvider.overrideWithValue(fakeChatRepo),
          webSocketSyncServiceProvider.overrideWithValue(fakeWsService),
        ],
      );
    });

    tearDown(() => container.dispose());

    const testPackage = GiftPackage(
      id: 'pkg_roses',
      title: '99 Red Roses Bouquet',
      description: 'Everlasting romance',
      amountMmK: 35000,
      iconEmoji: '🌹',
      categoryTag: 'Romantic Package',
    );

    test('startExternalPayment creates PendingPaymentSession and transitions state to awaiting', () async {
      final controller = container.read(giftingControllerProvider.notifier);

      final session = await controller.startExternalPayment(
        package: testPackage,
        provider: PaymentProvider.kbzPay,
        note: 'Always love you',
      );

      expect(session, isNotNull);
      expect(session!.amountMmK, equals(35000));
      expect(session.provider, equals(PaymentProvider.kbzPay));
      expect(session.deepLinkUrl.contains('kbzpay://'), isTrue);

      final state = container.read(giftingControllerProvider);
      expect(state.isAwaitingExternalPayment, isTrue);
      expect(state.activeSession, isNotNull);
      expect(state.activeSession!.orderId, equals(session.orderId));
    });

    test('verifyPaymentReturn with success completes transaction and dispatches WebSocket notification', () async {
      final controller = container.read(giftingControllerProvider.notifier);

      // 1. Start external payment
      await controller.startExternalPayment(
        package: testPackage,
        provider: PaymentProvider.kbzPay,
        note: 'Forever and always',
      );

      // 2. Simulate return from KBZPay app with verified transaction reference
      final tx = await controller.verifyPaymentReturn(
        status: 'success',
        transactionRef: 'KPAY-VERIFIED-999',
      );

      expect(tx, isNotNull);
      expect(tx!.transactionRef, equals('KPAY-VERIFIED-999'));
      expect(tx.amountMmK, equals(35000));

      final state = container.read(giftingControllerProvider);
      expect(state.isAwaitingExternalPayment, isFalse);
      expect(state.activeSession, isNull);
      expect(state.completedTransaction, equals(tx));

      // 3. Verify in-chat message was recorded
      expect(fakeChatRepo.sentGiftMessages.length, equals(1));
      expect(fakeChatRepo.sentGiftMessages.first['transactionRef'], equals('KPAY-VERIFIED-999'));

      // 4. Verify real-time WebSocket event was dispatched
      expect(fakeWsService.dispatchedEvents.length, equals(1));
      final wsEvent = fakeWsService.dispatchedEvents.first;
      expect(wsEvent['event'], equals('GIFT_RECEIVED'));
      expect(wsEvent['data']['provider'], equals('KBZPAY'));
      expect(wsEvent['data']['transactionRef'], equals('KPAY-VERIFIED-999'));
    });

    test('verifyPaymentReturn with cancel aborts transaction and sets error', () async {
      final controller = container.read(giftingControllerProvider.notifier);

      await controller.startExternalPayment(
        package: testPackage,
        provider: PaymentProvider.wavePay,
        note: 'Boba date treat',
      );

      final tx = await controller.verifyPaymentReturn(status: 'cancel');
      expect(tx, isNull);

      final state = container.read(giftingControllerProvider);
      expect(state.isAwaitingExternalPayment, isFalse);
      expect(state.activeSession, isNull);
      expect(state.errorMessage, contains('cancelled'));
    });

    test('cancelPendingPayment gracefully clears awaiting session without error', () async {
      final controller = container.read(giftingControllerProvider.notifier);

      await controller.startExternalPayment(
        package: testPackage,
        provider: PaymentProvider.kbzPay,
        note: 'Testing cancel',
      );

      controller.cancelPendingPayment();

      final state = container.read(giftingControllerProvider);
      expect(state.isAwaitingExternalPayment, isFalse);
      expect(state.activeSession, isNull);
      expect(state.errorMessage, isNull);
    });
  });
}

class MockAuthStateNotifier extends AuthStateNotifier {
  final UserProfile? _mockUser;
  MockAuthStateNotifier(this._mockUser);

  @override
  UserProfile? build() => _mockUser;
}

class FakeChatRepository implements ChatRepository {
  final List<Map<String, dynamic>> sentGiftMessages = [];

  @override
  Future<Either<Failure, ChatMessage>> sendGiftMessage({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required Map<String, dynamic> giftData,
  }) async {
    sentGiftMessages.add(giftData);
    final msg = ChatMessage(
      id: 'msg_test_gift',
      senderId: senderId,
      receiverId: receiverId,
      coupleSpaceId: coupleSpaceId,
      type: MessageType.gift,
      giftData: giftData,
      createdAt: DateTime.now(),
    );
    return Right(msg);
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String coupleSpaceId) async =>
      const Right([]);

  @override
  Stream<List<ChatMessage>> streamMessages(String coupleSpaceId) =>
      const Stream.empty();

  @override
  Future<Either<Failure, ChatMessage>> sendTextMessage({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String text,
  }) async =>
      Left(const Failure.server('Not implemented in fake'));

  @override
  Future<Either<Failure, ChatMessage>> sendVoiceMessage({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String audioPath,
    required int durationSeconds,
    required List<double> waveforms,
  }) async =>
      Left(const Failure.server('Not implemented in fake'));

  @override
  Future<Either<Failure, int>> getUnreadCount({
    required String coupleSpaceId,
    required String receiverId,
  }) async =>
      const Right(0);

  @override
  Future<Either<Failure, int>> markMessagesAsRead({
    required String coupleSpaceId,
    required String receiverId,
  }) async =>
      const Right(0);
}

class FakeWebSocketSyncService extends WebSocketSyncService {
  final List<Map<String, dynamic>> dispatchedEvents = [];

  @override
  void sendEvent({
    required String event,
    required Map<String, dynamic> data,
    String? topic,
  }) {
    dispatchedEvents.add({
      'event': event,
      'data': data,
      'topic': topic,
    });
  }
}
