import 'package:fpdart/fpdart.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/features/anniversary/domain/models/anniversary_milestone.dart';

abstract interface class AnniversaryRepository {
  Future<Either<Failure, List<AnniversaryMilestone>>> getMilestones(
      String coupleSpaceId);
  Future<Either<Failure, AnniversaryMilestone>> addMilestone({
    required String coupleSpaceId,
    required String title,
    required DateTime targetDate,
    required bool isRecurringAnnual,
    required String iconEmoji,
    String? note,
  });
  Future<Either<Failure, void>> deleteMilestone(String milestoneId);
}
