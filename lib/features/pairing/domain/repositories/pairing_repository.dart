import 'package:fpdart/fpdart.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_space.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';

abstract interface class PairingRepository {
  Future<Either<Failure, String>> getOrCreateInviteCode(String userId);
  Future<Either<Failure, String>> generateNewInviteCode(String userId);
  Future<Either<Failure, CoupleSpace>> pairWithCode({
    required String currentUserId,
    required String inviteCode,
  });
  Future<Either<Failure, CoupleSpace?>> getCoupleSpace(String coupleSpaceId);
  Future<Either<Failure, Map<String, dynamic>>> checkPairingStatus(String userId);
  Future<Either<Failure, CoupleSummary>> getCoupleSummary({
    required String coupleSpaceId,
    String? userId,
  });
  Future<Either<Failure, void>> unpair(String coupleSpaceId);
}
