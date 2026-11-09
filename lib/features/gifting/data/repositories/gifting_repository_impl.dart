import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/gifting/data/datasources/gifting_remote_data_source.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_transaction.dart';
import 'package:thae_nge_lay/features/gifting/domain/repositories/gifting_repository.dart';

part 'gifting_repository_impl.g.dart';

class GiftingRepositoryImpl implements GiftingRepository {
  final GiftingRemoteDataSource _remoteDataSource;

  GiftingRepositoryImpl({required GiftingRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<GiftPackage>>> getAvailableGiftPackages() async {
    try {
      final list = await _remoteDataSource.getAvailableGiftPackages();
      return Right(list);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GiftTransaction>> initiateAndVerifyPayment({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String packageTitle,
    required int amountMmK,
    required PaymentProvider provider,
    required String note,
    String? transactionRef,
  }) async {
    try {
      if (amountMmK <= 0) {
        return const Left(Failure.payment('Gift amount must be greater than 0 MMK.'));
      }
      final transaction = await _remoteDataSource.initiateAndVerifyPayment(
        senderId: senderId,
        receiverId: receiverId,
        coupleSpaceId: coupleSpaceId,
        packageTitle: packageTitle,
        amountMmK: amountMmK,
        provider: provider,
        note: note,
        transactionRef: transactionRef,
      );
      return Right(transaction);
    } catch (e) {
      return Left(Failure.payment(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, int>> getUnseenGiftsCount({
    required String coupleSpaceId,
    required String receiverId,
  }) async {
    try {
      final count = await _remoteDataSource.getUnseenGiftsCount(
        coupleSpaceId: coupleSpaceId,
        receiverId: receiverId,
      );
      return Right(count);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markGiftsAsSeen({
    required String coupleSpaceId,
    required String receiverId,
  }) async {
    try {
      await _remoteDataSource.markGiftsAsSeen(
        coupleSpaceId: coupleSpaceId,
        receiverId: receiverId,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
GiftingRepository giftingRepository(Ref ref) {
  return GiftingRepositoryImpl(
    remoteDataSource: GiftingRemoteDataSourceImpl(
      dio: ref.watch(dioClientProvider),
    ),
  );
}
