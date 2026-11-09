import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.server([String? message]) = _ServerFailure;
  const factory Failure.network([String? message]) = _NetworkFailure;
  const factory Failure.auth([String? message]) = _AuthFailure;
  const factory Failure.permission([String? message]) = _PermissionFailure;
  const factory Failure.pairing([String? message]) = _PairingFailure;
  const factory Failure.payment([String? message]) = _PaymentFailure;
  const factory Failure.cache([String? message]) = _CacheFailure;
  const factory Failure.unexpected([String? message]) = _UnexpectedFailure;
}
