import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:thae_nge_lay/features/gifting/data/repositories/gifting_repository_impl.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_transaction.dart';

part 'gifting_controller.g.dart';

class GiftingUIState {
  final bool isProcessing;
  final String? errorMessage;
  final GiftTransaction? completedTransaction;

  const GiftingUIState({
    this.isProcessing = false,
    this.errorMessage,
    this.completedTransaction,
  });

  GiftingUIState copyWith({
    bool? isProcessing,
    String? errorMessage,
    GiftTransaction? completedTransaction,
    bool clearError = false,
    bool clearTransaction = false,
  }) {
    return GiftingUIState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedTransaction: clearTransaction
          ? null
          : (completedTransaction ?? this.completedTransaction),
    );
  }
}

@riverpod
class GiftingController extends _$GiftingController {
  @override
  GiftingUIState build() {
    return const GiftingUIState();
  }

  Future<GiftTransaction?> sendGift({
    required GiftPackage package,
    required PaymentProvider provider,
    required String note,
    int? customAmountMmK,
  }) async {
    final user = ref.read(authStateProvider);
    if (user == null) {
      state = state.copyWith(errorMessage: 'Please sign in first.');
      return null;
    }

    final partnerId = user.partnerId;
    final coupleSpaceId = user.coupleSpaceId;
    if (partnerId == null || coupleSpaceId == null) {
      state = state.copyWith(errorMessage: 'Please pair with your partner before sending gifts.');
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
        // Automatically create in-chat gift message (Domain Rule #5)
        final chatRepo = ref.read(chatRepositoryProvider);
        final formattedAmount =
            '${NumberFormat('#,###').format(transaction.amountMmK)} MMK';

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
            'provider': provider == PaymentProvider.kbzPay ? 'KBZPay' : 'WavePay',
            'note': transaction.note,
            'sentAt': transaction.createdAt.toIso8601String(),
          },
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
