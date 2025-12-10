import 'package:freezed_annotation/freezed_annotation.dart';

part 'stripe_subscription.freezed.dart';
part 'stripe_subscription.g.dart';

/// Represents a Stripe subscription for financial reporting.
@freezed
abstract class StripeSubscription with _$StripeSubscription {
  const factory StripeSubscription({
    required String id,
    required String customerId,
    String? customerEmail,
    String? customerName,
    required String status,
    required double amount,
    required String currency,
    required String interval,
    required int currentPeriodStart,
    required int currentPeriodEnd,
    int? canceledAt,
    required int createdAt,
  }) = _StripeSubscription;

  factory StripeSubscription.fromJson(Map<String, dynamic> json) =>
      _$StripeSubscriptionFromJson(json);
}
