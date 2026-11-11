import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/gifting/data/repositories/gifting_repository_impl.dart';
import 'package:thae_nge_lay/features/gifting/data/services/gifting_payment_intent_service.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_transaction.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/gift_notification_dispatcher.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/gifting_ui_state.dart';

export 'gifting_ui_state.dart';

part 'gifting_controller.g.dart';

@riverpod
class GiftingController extends _$GiftingController {
  void Function()? _closeKeepAlive;

  @override
  GiftingUIState build() {
    ref.onDispose(() {
      _closeKeepAlive?.call();
    });
    return const GiftingUIState();
  }

  (String, String) _getPartnerIds() {
    final user = ref.read(authStateProvider);
    if (user == null) throw Exception('Please sign in first.');
    final partnerId = user.partnerId;
    final spaceId = user.coupleSpaceId;
    if (partnerId == null || spaceId == null) {
      throw Exception('Please pair with your partner before sending gifts.');
    }
    return (partnerId, spaceId);
  }

  Future<PendingPaymentSession?> startExternalPayment({
    required GiftPackage package,
    required PaymentProvider provider,
    required String note,
    int? customAmountMmK,
    String? customCallbackUrl,
  }) async {
    final user = ref.read(authStateProvider);
    String partnerId, coupleSpaceId;
    try {
      final ids = _getPartnerIds();
      partnerId = ids.$1;
      coupleSpaceId = ids.$2;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return null;
    }

    final amount = customAmountMmK ?? package.amountMmK;
    final orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}';
    final prefix = provider == PaymentProvider.kbzPay ? 'KPAY' : 'WAVE';
    final transactionRef =
        '$prefix-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    final intentUrl = GiftingPaymentIntentService.buildPaymentIntentUrl(
      provider: provider, orderId: orderId, amountMmK: amount, packageTitle: package.title, callbackUrl: customCallbackUrl);
    final fallbackWebUrl = GiftingPaymentIntentService.buildFallbackWebUrl(
      provider: provider, orderId: orderId, amountMmK: amount, packageTitle: package.title, callbackUrl: customCallbackUrl);

    final session = PendingPaymentSession(
      orderId: orderId, transactionRef: transactionRef, package: package,
      provider: provider, amountMmK: amount, note: note, senderId: user!.id,
      receiverId: partnerId, coupleSpaceId: coupleSpaceId, initiatedAt: DateTime.now(),
      deepLinkUrl: intentUrl, fallbackWebUrl: fallbackWebUrl,
    );

    _closeKeepAlive ??= ref.keepAlive().close;

    state = state.copyWith(
      isProcessing: false,
      isAwaitingExternalPayment: true,
      activeSession: session,
      clearError: true,
      clearTransaction: true,
    );

    await GiftingPaymentIntentService.launchPaymentApp(
      intentUrl: intentUrl,
      fallbackWebUrl: fallbackWebUrl,
    );

    return session;
  }

  Future<GiftTransaction?> verifyPaymentReturn({
    String? status,
    String? orderId,
    String? transactionRef,
  }) async {
    final session = state.activeSession;
    if (session == null || !state.isAwaitingExternalPayment) {
      return null;
    }

    if (status != null &&
        (status.toLowerCase() == 'cancel' ||
            status.toLowerCase() == 'cancelled' ||
            status.toLowerCase() == 'failed')) {
      _closeKeepAlive?.call();
      _closeKeepAlive = null;
      final providerName =
          session.provider == PaymentProvider.kbzPay ? 'KBZPay' : 'WavePay';
      state = state.copyWith(
        isAwaitingExternalPayment: false,
        clearSession: true,
        errorMessage: '$providerName payment was cancelled.',
      );
      return null;
    }

    state = state.copyWith(
      isProcessing: true,
      isAwaitingExternalPayment: false,
      clearError: true,
    );

    final giftingRepo = ref.read(giftingRepositoryProvider);
    final effectiveRef = transactionRef ?? session.transactionRef;

    final result = await giftingRepo.initiateAndVerifyPayment(
      senderId: session.senderId,
      receiverId: session.receiverId,
      coupleSpaceId: session.coupleSpaceId,
      packageTitle: session.package.title,
      amountMmK: session.amountMmK,
      provider: session.provider,
      note: session.note,
      transactionRef: effectiveRef,
    );

    return result.fold(
      (failure) {
        _closeKeepAlive?.call();
        _closeKeepAlive = null;
        state = state.copyWith(
          isProcessing: false,
          errorMessage: failure.message ?? 'Payment verification failed.',
          clearSession: true,
        );
        return null;
      },
      (transaction) async {
        await GiftNotificationDispatcher.notifyPartnerOfGift(
          ref: ref,
          senderId: session.senderId,
          receiverId: session.receiverId,
          coupleSpaceId: session.coupleSpaceId,
          transaction: transaction,
          provider: session.provider,
        );

        _closeKeepAlive?.call();
        _closeKeepAlive = null;

        state = state.copyWith(
          isProcessing: false,
          completedTransaction: transaction,
          clearSession: true,
        );
        return transaction;
      },
    );
  }

  void cancelPendingPayment() {
    _closeKeepAlive?.call();
    _closeKeepAlive = null;
    state = state.copyWith(
      isAwaitingExternalPayment: false,
      clearSession: true,
      clearError: true,
    );
  }

  Future<GiftTransaction?> sendGift({
    required GiftPackage package,
    required PaymentProvider provider,
    required String note,
    int? customAmountMmK,
    String? transactionRef,
  }) async {
    final user = ref.read(authStateProvider);
    String partnerId, coupleSpaceId;
    try {
      final ids = _getPartnerIds();
      partnerId = ids.$1;
      coupleSpaceId = ids.$2;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return null;
    }

    final amount = customAmountMmK ?? package.amountMmK;
    state = state.copyWith(isProcessing: true, clearError: true);

    final giftingRepo = ref.read(giftingRepositoryProvider);
    final result = await giftingRepo.initiateAndVerifyPayment(
      senderId: user!.id,
      receiverId: partnerId,
      coupleSpaceId: coupleSpaceId,
      packageTitle: package.title,
      amountMmK: amount,
      provider: provider,
      note: note,
      transactionRef: transactionRef,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: failure.message ?? 'Payment failed.',
        );
        return null;
      },
      (transaction) async {
        await GiftNotificationDispatcher.notifyPartnerOfGift(
          ref: ref,
          senderId: user.id,
          receiverId: partnerId,
          coupleSpaceId: coupleSpaceId,
          transaction: transaction,
          provider: provider,
        );

        state = state.copyWith(
          isProcessing: false,
          completedTransaction: transaction,
        );
        return transaction;
      },
    );
  }

  void reset() {
    state = const GiftingUIState();
  }
}
