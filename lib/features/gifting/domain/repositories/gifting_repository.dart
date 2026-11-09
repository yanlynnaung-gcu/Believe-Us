import 'package:fpdart/fpdart.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_transaction.dart';

abstract interface class GiftingRepository {
  Future<Either<Failure, List<GiftPackage>>> getAvailableGiftPackages();
  Future<Either<Failure, GiftTransaction>> initiateAndVerifyPayment({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String packageTitle,
    required int amountMmK,
    required PaymentProvider provider,
    required String note,
  });
  Future<Either<Failure, int>> getUnseenGiftsCount({
    required String coupleSpaceId,
    required String receiverId,
  });
  Future<Either<Failure, void>> markGiftsAsSeen({
    required String coupleSpaceId,
    required String receiverId,
  });
}
