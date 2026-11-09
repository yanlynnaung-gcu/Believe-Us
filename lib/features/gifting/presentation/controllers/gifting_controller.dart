import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:thae_nge_lay/features/gifting/data/repositories/gifting_repository_impl.dart';
import 'package:thae_nge_lay/features/gifting/data/services/gifting_payment_intent_service.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_transaction.dart';

part 'gifting_controller.g.dart';

/// Context for an active pending payment in external wallet app
class PendingPaymentSession {
  final String orderId;
  final String transactionRef;
  final GiftPackage package;
  final PaymentProvider provider;
  final int amountMmK;
  final String note;
  final String senderId;
  final String receiverId;
  final String coupleSpaceId;
  final DateTime initiatedAt;
  final String deepLinkUrl;
  final String fallbackWebUrl;

  const PendingPaymentSession({
    required this.orderId,
    required this.transactionRef,
    required this.package,
    required this.provider,
    required this.amountMmK,
    required this.note,
    required this.senderId,
    required this.receiverId,
    required this.coupleSpaceId,
    required this.initiatedAt,
    required this.deepLinkUrl,
    required this.fallbackWebUrl,
  });
}

class GiftingUIState {
  final bool isProcessing;
  final bool isAwaitingExternalPayment;
  final PendingPaymentSession? activeSession;
  final String? errorMessage;
  final GiftTransaction? completedTransaction;

  const GiftingUIState({
    this.isProcessing = false,
    this.isAwaitingExternalPayment = false,
    this.activeSession,
    this.errorMessage,
    this.completedTransaction,
  });

  GiftingUIState copyWith({
    bool? isProcessing,
    bool? isAwaitingExternalPayment,
    PendingPaymentSession? activeSession,
    String? errorMessage,
    GiftTransaction? completedTransaction,
    bool clearError = false,
    bool clearTransaction = false,
    bool clearSession = false,
  }) {
    return GiftingUIState(
      isProcessing: isProcessing ?? this.isProcessing,
      isAwaitingExternalPayment:
          isAwaitingExternalPayment ?? this.isAwaitingExternalPayment,
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedTransaction: clearTransaction
          ? null
          : (completedTransaction ?? this.completedTransaction),
    );
  }
}

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

  /// 1. Constructs deep link, sets waiting state, and launches KBZPay/WavePay app
  Future<PendingPaymentSession?> startExternalPayment({
    required GiftPackage package,
    required PaymentProvider provider,
    required String note,
    int? customAmountMmK,
    String? customCallbackUrl,
  }) async {
    final user = ref.read(authStateProvider);
    if (user == null) {
      state = state.copyWith(errorMessage: 'Please sign in first.');
      return null;
    }

    final partnerId = user.partnerId;
    final coupleSpaceId = user.coupleSpaceId;
    if (partnerId == null || coupleSpaceId == null) {
      state = state.copyWith(
        errorMessage: 'Please pair with your partner before sending gifts.',
      );
      return null;
    }

    final amount = customAmountMmK ?? package.amountMmK;
    final orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}';
    final prefix = provider == PaymentProvider.kbzPay ? 'KPAY' : 'WAVE';
    final transactionRef =
        '$prefix-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    final intentUrl = GiftingPaymentIntentService.buildPaymentIntentUrl(
      provider: provider,
      orderId: orderId,
      amountMmK: amount,
      packageTitle: package.title,
      callbackUrl: customCallbackUrl,
    );

    final fallbackWebUrl = GiftingPaymentIntentService.buildFallbackWebUrl(
      provider: provider,
      orderId: orderId,
      amountMmK: amount,
      packageTitle: package.title,
      callbackUrl: customCallbackUrl,
    );

    final session = PendingPaymentSession(
      orderId: orderId,
      transactionRef: transactionRef,
      package: package,
      provider: provider,
      amountMmK: amount,
      note: note,
      senderId: user.id,
      receiverId: partnerId,
      coupleSpaceId: coupleSpaceId,
      initiatedAt: DateTime.now(),
      deepLinkUrl: intentUrl,
      fallbackWebUrl: fallbackWebUrl,
    );

    _closeKeepAlive ??= ref.keepAlive().close;

    state = state.copyWith(
      isProcessing: false,
      isAwaitingExternalPayment: true,
      activeSession: session,
      clearError: true,
      clearTransaction: true,
    );

    // Launch external mobile application via url_launcher
    await GiftingPaymentIntentService.launchPaymentApp(
      intentUrl: intentUrl,
      fallbackWebUrl: fallbackWebUrl,
    );

    return session;
  }

  /// 2. Verifies transaction upon return (via deep link callback or app resumption)
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
        final chatRepo = ref.read(chatRepositoryProvider);
        final formattedAmount =
            '${NumberFormat('#,###').format(transaction.amountMmK)} MMK';
        final providerName =
            session.provider == PaymentProvider.kbzPay ? 'KBZPay' : 'WavePay';

        // 1. Send in-chat gift card message
        await chatRepo.sendGiftMessage(
          senderId: session.senderId,
          receiverId: session.receiverId,
          coupleSpaceId: session.coupleSpaceId,
          giftData: {
            'transactionId': transaction.id,
            'transactionRef': transaction.transactionRef,
            'amount': formattedAmount,
            'amountRaw': transaction.amountMmK,
            'packageName': transaction.packageTitle,
            'provider': providerName,
            'note': transaction.note,
            'sentAt': transaction.createdAt.toIso8601String(),
          },
        );

        // 2. Dispatch real-time WebSocket confirmation event to notify partner
        try {
          final ws = ref.read(webSocketSyncServiceProvider);
          ws.sendEvent(
            event: 'GIFT_RECEIVED',
            data: {
              'id': transaction.id,
              'transactionId': transaction.id,
              'senderId': session.senderId,
              'receiverId': session.receiverId,
              'coupleSpaceId': session.coupleSpaceId,
              'packageTitle': transaction.packageTitle,
              'amountMmK': transaction.amountMmK,
              'provider':
                  session.provider == PaymentProvider.kbzPay ? 'KBZPAY' : 'WAVEPAY',
              'transactionRef': transaction.transactionRef,
              'status': 'PAID',
              'note': transaction.note,
              'createdAt': transaction.createdAt.toIso8601String(),
            },
          );
        } catch (e) {
          debugPrint('[WebSocket] Real-time gift notification warning: $e');
        }

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

  /// Cancels any active pending payment session
  void cancelPendingPayment() {
    _closeKeepAlive?.call();
    _closeKeepAlive = null;
    state = state.copyWith(
      isAwaitingExternalPayment: false,
      clearSession: true,
      clearError: true,
    );
  }

  /// Direct synchronous payment dispatch (for automated flows or testing)
  Future<GiftTransaction?> sendGift({
    required GiftPackage package,
    required PaymentProvider provider,
    required String note,
    int? customAmountMmK,
    String? transactionRef,
  }) async {
    final user = ref.read(authStateProvider);
    if (user == null) {
      state = state.copyWith(errorMessage: 'Please sign in first.');
      return null;
    }

    final partnerId = user.partnerId;
    final coupleSpaceId = user.coupleSpaceId;
    if (partnerId == null || coupleSpaceId == null) {
      state = state.copyWith(
        errorMessage: 'Please pair with your partner before sending gifts.',
      );
      return null;
    }

    final amount = customAmountMmK ?? package.amountMmK;
    state = state.copyWith(isProcessing: true, clearError: true);

    final giftingRepo = ref.read(giftingRepositoryProvider);
    final result = await giftingRepo.initiateAndVerifyPayment(
      senderId: user.id,
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
        final chatRepo = ref.read(chatRepositoryProvider);
        final formattedAmount =
            '${NumberFormat('#,###').format(transaction.amountMmK)} MMK';
        final providerName =
            provider == PaymentProvider.kbzPay ? 'KBZPay' : 'WavePay';

        // 1. In-chat gift message
        await chatRepo.sendGiftMessage(
          senderId: user.id,
          receiverId: partnerId,
          coupleSpaceId: coupleSpaceId,
          giftData: {
            'transactionId': transaction.id,
            'transactionRef': transaction.transactionRef,
            'amount': formattedAmount,
            'amountRaw': transaction.amountMmK,
            'packageName': transaction.packageTitle,
            'provider': providerName,
            'note': transaction.note,
            'sentAt': transaction.createdAt.toIso8601String(),
          },
        );

        // 2. Real-time WebSocket confirmation
        try {
          final ws = ref.read(webSocketSyncServiceProvider);
          ws.sendEvent(
            event: 'GIFT_RECEIVED',
            data: {
              'id': transaction.id,
              'transactionId': transaction.id,
              'senderId': user.id,
              'receiverId': partnerId,
              'coupleSpaceId': coupleSpaceId,
              'packageTitle': transaction.packageTitle,
              'amountMmK': transaction.amountMmK,
              'provider':
                  provider == PaymentProvider.kbzPay ? 'KBZPAY' : 'WAVEPAY',
              'transactionRef': transaction.transactionRef,
              'status': 'PAID',
              'note': transaction.note,
              'createdAt': transaction.createdAt.toIso8601String(),
            },
          );
        } catch (e) {
          debugPrint('[WebSocket] Real-time gift notification warning: $e');
        }

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
