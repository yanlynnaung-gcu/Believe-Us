import 'package:freezed_annotation/freezed_annotation.dart';

part 'gift_package.freezed.dart';
part 'gift_package.g.dart';

enum PaymentProvider {
  kbzPay,
  wavePay,
}

@freezed
abstract class GiftPackage with _$GiftPackage {
  const factory GiftPackage({
    required String id,
    required String title,
    required String description,
    required int amountMmK,
    required String iconEmoji,
    @Default(false) bool isCustomMonetary,
    String? categoryTag,
  }) = _GiftPackage;

  factory GiftPackage.fromJson(Map<String, dynamic> json) =>
      _$GiftPackageFromJson(json);
}
