import 'package:freezed_annotation/freezed_annotation.dart';

part 'trusted_place_model.freezed.dart';
part 'trusted_place_model.g.dart';

String _stringFromDynamic(dynamic val) => val?.toString() ?? '';

@freezed
abstract class TrustedPlaceModel with _$TrustedPlaceModel {
  const factory TrustedPlaceModel({
    @JsonKey(fromJson: _stringFromDynamic) required String id,
    required String name,
    @Default('home') String iconName,
    required double latitude,
    required double longitude,
    @Default(150.0) double radiusMeters,
    @Default(true) bool notifyArrival,
    @Default(true) bool notifyDeparture,
    required DateTime createdAt,
  }) = _TrustedPlaceModel;

  factory TrustedPlaceModel.fromJson(Map<String, dynamic> json) =>
      _$TrustedPlaceModelFromJson(json);
}
