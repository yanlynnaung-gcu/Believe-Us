import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_transaction.dart';

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
      activeSession:
          clearSession ? null : (activeSession ?? this.activeSession),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedTransaction: clearTransaction
          ? null
          : (completedTransaction ?? this.completedTransaction),
    );
  }
}
