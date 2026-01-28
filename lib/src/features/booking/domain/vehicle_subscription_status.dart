import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_subscription_status.freezed.dart';

@freezed
class VehicleSubscriptionStatus with _$VehicleSubscriptionStatus {
  const factory VehicleSubscriptionStatus.canUseSubscription({
    required int remainingWashes,
  }) = _CanUseSubscription;

  const factory VehicleSubscriptionStatus.requiresCashPayment() =
      _RequiresCashPayment;

  const factory VehicleSubscriptionStatus.subscriptionExhausted() =
      _SubscriptionExhausted;

  const factory VehicleSubscriptionStatus.subscriptionInactive() =
      _SubscriptionInactive;
}

extension VehicleSubscriptionStatusExt on VehicleSubscriptionStatus {
  bool get canUseSubscription => this is _CanUseSubscription;
}
