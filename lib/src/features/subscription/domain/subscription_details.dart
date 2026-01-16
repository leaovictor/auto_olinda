import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_details.freezed.dart';
part 'subscription_details.g.dart';

@freezed
sealed class SubscriptionDetails with _$SubscriptionDetails {
  const factory SubscriptionDetails({
    required String status,
    required bool cancelAtPeriodEnd,
    required int currentPeriodEnd,
    SubscriptionPaymentMethod? paymentMethod,
  }) = _SubscriptionDetails;

  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionDetailsFromJson(json);
}

@freezed
sealed class SubscriptionPaymentMethod with _$SubscriptionPaymentMethod {
  const factory SubscriptionPaymentMethod({
    required String brand,
    required String last4,
    required int expMonth,
    required int expYear,
  }) = _SubscriptionPaymentMethod;

  factory SubscriptionPaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPaymentMethodFromJson(json);
}
