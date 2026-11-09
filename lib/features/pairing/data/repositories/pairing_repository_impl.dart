import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/pairing/data/datasources/pairing_remote_data_source.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_space.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';
import 'package:thae_nge_lay/features/pairing/domain/repositories/pairing_repository.dart';

part 'pairing_repository_impl.g.dart';

class PairingRepositoryImpl implements PairingRepository {
  final PairingRemoteDataSource _remoteDataSource;

  PairingRepositoryImpl({required PairingRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, String>> getOrCreateInviteCode(String userId) async {
    try {
      final code = await _remoteDataSource.getOrCreateInviteCode(userId);
      return Right(code);
    } catch (e) {
      return Left(Failure.server(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, String>> generateNewInviteCode(String userId) async {
    try {
      final code = await _remoteDataSource.generateNewInviteCode(userId);
      return Right(code);
    } catch (e) {
      return Left(Failure.server(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, CoupleSpace>> pairWithCode({
    required String currentUserId,
    required String inviteCode,
  }) async {
    try {
      if (inviteCode.trim().length != 6) {
        return const Left(Failure.pairing('Invite code must be exactly 6 characters.'));
      }
      final space = await _remoteDataSource.pairWithCode(
        currentUserId: currentUserId,
        inviteCode: inviteCode,
      );
      return Right(space);
    } catch (e) {
      return Left(Failure.pairing(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, CoupleSpace?>> getCoupleSpace(
      String coupleSpaceId) async {
    try {
      final space = await _remoteDataSource.getCoupleSpace(coupleSpaceId);
      return Right(space);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkPairingStatus(
      String userId) async {
    try {
      final status = await _remoteDataSource.checkPairingStatus(userId);
      return Right(status);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CoupleSummary>> getCoupleSummary({
    required String coupleSpaceId,
    String? userId,
  }) async {
    try {
      final summary = await _remoteDataSource.getCoupleSummary(
        coupleSpaceId: coupleSpaceId,
        userId: userId,
      );
      return Right(summary);
    } catch (e) {
      return Left(Failure.server(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> unpair(String coupleSpaceId) async {
    try {
      await _remoteDataSource.unpair(coupleSpaceId);
      return const Right(null);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
PairingRepository pairingRepository(Ref ref) {
  return PairingRepositoryImpl(
    remoteDataSource: PairingRemoteDataSourceImpl(
      dio: ref.watch(dioClientProvider),
    ),
  );
}
