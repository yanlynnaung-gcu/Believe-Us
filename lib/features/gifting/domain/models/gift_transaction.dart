import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';

part 'gift_transaction.freezed.dart';
part 'gift_transaction.g.dart';

enum TransactionStatus {
  pending,
  completed,
  failed,
}

@freezed
abstract class GiftTransaction with _$GiftTransaction {
  const factory GiftTransaction({
    required String id,
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String packageTitle,
    required int amountMmK,
    required PaymentProvider provider,
    required String note,
    required TransactionStatus status,
    required String transactionRef,
    required DateTime createdAt,
  }) = _GiftTransaction;

  factory GiftTransaction.fromJson(Map<String, dynamic> json) =>
      _$GiftTransactionFromJson(json);
}
