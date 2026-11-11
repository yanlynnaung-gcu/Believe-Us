import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_transaction.dart';

class GiftNotificationDispatcher {
  static Future<void> notifyPartnerOfGift({
    required Ref ref,
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required GiftTransaction transaction,
    required PaymentProvider provider,
  }) async {
    final chatRepo = ref.read(chatRepositoryProvider);
    final formattedAmount =
        '${NumberFormat('#,###').format(transaction.amountMmK)} MMK';
    final providerName =
        provider == PaymentProvider.kbzPay ? 'KBZPay' : 'WavePay';

    await chatRepo.sendGiftMessage(
      senderId: senderId,
      receiverId: receiverId,
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

    try {
      final ws = ref.read(webSocketSyncServiceProvider);
      ws.sendEvent(
        event: 'GIFT_RECEIVED',
        data: {
          'id': transaction.id,
          'transactionId': transaction.id,
          'senderId': senderId,
          'receiverId': receiverId,
          'coupleSpaceId': coupleSpaceId,
          'packageTitle': transaction.packageTitle,
          'amountMmK': transaction.amountMmK,
          'provider': provider == PaymentProvider.kbzPay ? 'KBZPAY' : 'WAVEPAY',
          'transactionRef': transaction.transactionRef,
          'status': 'PAID',
          'note': transaction.note,
          'createdAt': transaction.createdAt.toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('[WebSocket] Real-time gift notification warning: $e');
    }
  }
}
