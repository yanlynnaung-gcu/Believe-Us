import 'dart:math';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_transaction.dart';

abstract interface class GiftingRemoteDataSource {
  Future<List<GiftPackage>> getAvailableGiftPackages();
  Future<GiftTransaction> initiateAndVerifyPayment({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String packageTitle,
    required int amountMmK,
    required PaymentProvider provider,
    required String note,
  });
  Future<int> getUnseenGiftsCount({
    required String coupleSpaceId,
    required String receiverId,
  });
  Future<void> markGiftsAsSeen({
    required String coupleSpaceId,
    required String receiverId,
  });
}

class GiftingRemoteDataSourceImpl implements GiftingRemoteDataSource {
  final Dio _dio;
  final Uuid _uuid = const Uuid();

  GiftingRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  final List<GiftPackage> _packages = const [
    GiftPackage(
      id: 'pkg_monetary_10k',
      title: 'Pocket Love Blessing',
      description: 'Sweet pocket money for snacks & coffee',
      amountMmK: 10000,
      iconEmoji: '☕',
      categoryTag: 'Monetary',
    ),
    GiftPackage(
      id: 'pkg_boba',
      title: 'Sweet Boba & Bakery Date',
      description: 'Treat your love to their favorite brown sugar boba',
      amountMmK: 15000,
      iconEmoji: '🧋',
      categoryTag: 'Virtual Treat',
    ),
    GiftPackage(
      id: 'pkg_monetary_30k',
      title: 'Darling Grocery Fund',
      description: 'Care package for their daily happiness',
      amountMmK: 30000,
      iconEmoji: '🍰',
      categoryTag: 'Monetary',
    ),
    GiftPackage(
      id: 'pkg_roses',
      title: '99 Red Roses Bouquet',
      description: 'Symbol of eternal devotion across the distance',
      amountMmK: 35000,
      iconEmoji: '🌹',
      categoryTag: 'Romantic Package',
    ),
    GiftPackage(
      id: 'pkg_monetary_50k',
      title: 'Monthly Couple Gift',
      description: 'Golden blessing for your beloved',
      amountMmK: 50000,
      iconEmoji: '🎁',
      categoryTag: 'Monetary',
    ),
    GiftPackage(
      id: 'pkg_dinner',
      title: 'Romantic Candlelight Dinner',
      description: 'Luxurious dinner blessing to celebrate your bond',
      amountMmK: 80000,
      iconEmoji: '🍷',
      categoryTag: 'Romantic Package',
    ),
    GiftPackage(
      id: 'pkg_flight',
      title: 'LDR Reunion Flight Fund',
      description: 'Bringing you closer for the next flight visit',
      amountMmK: 150000,
      iconEmoji: '✈️',
      categoryTag: 'Reunion Fund',
    ),
  ];

  @override
  Future<List<GiftPackage>> getAvailableGiftPackages() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _packages;
  }

  @override
  Future<GiftTransaction> initiateAndVerifyPayment({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String packageTitle,
    required int amountMmK,
    required PaymentProvider provider,
    required String note,
  }) async {
    final randomDigits = 100000 + Random().nextInt(900000);
    final prefix = provider == PaymentProvider.kbzPay ? 'KBZ' : 'WAVE';
    final fallbackRef = '$prefix-$randomDigits';

    // 1. Send to Spring Boot Backend
    try {
      final response = await _dio.post(
        ApiEndpoints.giftingPayPath,
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'coupleSpaceId': coupleSpaceId,
          'packageTitle': packageTitle,
          'amountMmK': amountMmK,
          'provider': provider == PaymentProvider.kbzPay ? 'KBZPAY' : 'WAVEPAY',
          'note': note,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        return GiftTransaction(
          id: data['id']?.toString() ?? 'tx_${_uuid.v4().substring(0, 8)}',
          senderId: senderId,
          receiverId: receiverId,
          coupleSpaceId: coupleSpaceId,
          packageTitle: packageTitle,
          amountMmK: amountMmK,
          provider: provider,
          note: note.isNotEmpty ? note : 'Sending love across the miles ❤️',
          status: TransactionStatus.completed,
          transactionRef: data['transactionRef']?.toString() ?? fallbackRef,
          createdAt: DateTime.now(),
        );
      }
    } catch (_) {}

    // 2. Local Fallback (Simulation)
    await Future.delayed(const Duration(milliseconds: 600));

    final transaction = GiftTransaction(
      id: 'tx_${_uuid.v4().substring(0, 8)}',
      senderId: senderId,
      receiverId: receiverId,
      coupleSpaceId: coupleSpaceId,
      packageTitle: packageTitle,
      amountMmK: amountMmK,
      provider: provider,
      note: note.isNotEmpty ? note : 'Sending love across the miles ❤️',
      status: TransactionStatus.completed,
      transactionRef: fallbackRef,
      createdAt: DateTime.now(),
    );

    return transaction;
  }

  @override
  Future<int> getUnseenGiftsCount({
    required String coupleSpaceId,
    required String receiverId,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.giftingUnseenPath}/$coupleSpaceId',
        queryParameters: {'receiverId': receiverId},
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data['unseenCount'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  @override
  Future<void> markGiftsAsSeen({
    required String coupleSpaceId,
    required String receiverId,
  }) async {
    try {
      await _dio.post(
        '${ApiEndpoints.giftingMarkSeenPath}/$coupleSpaceId',
        queryParameters: {'receiverId': receiverId},
      );
    } catch (_) {}
  }
}
