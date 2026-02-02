import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lavaflow_app/src/shared/utils/timestamp_converter.dart';

part 'subscriber.freezed.dart';
part 'subscriber.g.dart';

@freezed
abstract class Subscriber with _$Subscriber {
  const Subscriber._();

  const factory Subscriber({
    required String id,
    required String userId,
    required String planId,
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() DateTime? endDate,
    @Default(false) bool cancelAtPeriodEnd,
    required String status, // 'active', 'canceled', 'expired'
    String? stripeSubscriptionId,
    @Default(0) int bonusWashes,
    String? type,
    String? linkedPlate,
    String? vehicleCategory,
    String? vehicleId,
    @TimestampConverter() DateTime? lastPlateChange,
  }) = _Subscriber;

  factory Subscriber.fromJson(Map<String, dynamic> json) =>
      _$SubscriberFromJson(json);

  bool get isActive => status == 'active' || status == 'trialing';
}
