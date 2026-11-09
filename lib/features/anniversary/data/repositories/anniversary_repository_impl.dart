import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/anniversary/data/datasources/anniversary_remote_data_source.dart';
import 'package:thae_nge_lay/features/anniversary/domain/models/anniversary_milestone.dart';
import 'package:thae_nge_lay/features/anniversary/domain/repositories/anniversary_repository.dart';

part 'anniversary_repository_impl.g.dart';

class AnniversaryRepositoryImpl implements AnniversaryRepository {
  final AnniversaryRemoteDataSource _remoteDataSource;

  AnniversaryRepositoryImpl(
      {required AnniversaryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<AnniversaryMilestone>>> getMilestones(
      String coupleSpaceId) async {
    try {
      final list = await _remoteDataSource.getMilestones(coupleSpaceId);
      return Right(list);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnniversaryMilestone>> addMilestone({
    required String coupleSpaceId,
    required String title,
    required DateTime targetDate,
    required bool isRecurringAnnual,
    required String iconEmoji,
    String? note,
  }) async {
    try {
      if (title.trim().isEmpty) {
        return const Left(Failure.unexpected('Please enter a milestone title.'));
      }
      final milestone = await _remoteDataSource.addMilestone(
        coupleSpaceId: coupleSpaceId,
        title: title,
        targetDate: targetDate,
        isRecurringAnnual: isRecurringAnnual,
        iconEmoji: iconEmoji,
        note: note,
      );
      return Right(milestone);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMilestone(String milestoneId) async {
    try {
      await _remoteDataSource.deleteMilestone(milestoneId);
      return const Right(null);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
AnniversaryRepository anniversaryRepository(Ref ref) {
  return AnniversaryRepositoryImpl(
    remoteDataSource: AnniversaryRemoteDataSourceImpl(
      dio: ref.watch(dioClientProvider),
    ),
  );
}
