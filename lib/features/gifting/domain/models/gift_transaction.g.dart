// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GiftTransaction _$GiftTransactionFromJson(Map<String, dynamic> json) =>
    _GiftTransaction(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      coupleSpaceId: json['coupleSpaceId'] as String,
      packageTitle: json['packageTitle'] as String,
      amountMmK: (json['amountMmK'] as num).toInt(),
      provider: $enumDecode(_$PaymentProviderEnumMap, json['provider']),
      note: json['note'] as String,
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      transactionRef: json['transactionRef'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GiftTransactionToJson(_GiftTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'coupleSpaceId': instance.coupleSpaceId,
      'packageTitle': instance.packageTitle,
      'amountMmK': instance.amountMmK,
      'provider': _$PaymentProviderEnumMap[instance.provider]!,
      'note': instance.note,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'transactionRef': instance.transactionRef,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$PaymentProviderEnumMap = {
  PaymentProvider.kbzPay: 'kbzPay',
  PaymentProvider.wavePay: 'wavePay',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.completed: 'completed',
  TransactionStatus.failed: 'failed',
};
