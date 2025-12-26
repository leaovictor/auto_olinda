import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:aquaclean_mobile/src/shared/utils/timestamp_converter.dart';

part 'subscription_status_log.freezed.dart';
part 'subscription_status_log.g.dart';

/// Log entry for subscription status changes.
/// Used for calculating churn rate and tracking subscription history.
@freezed
abstract class SubscriptionStatusLog with _$SubscriptionStatusLog {
  const factory SubscriptionStatusLog({
    required String id,
    required String subscriptionId,
    required String userId,
    required String
    previousStatus, // 'none', 'active', 'canceled', 'past_due', 'trialing'
    required String newStatus, // 'active', 'canceled', 'past_due', 'expired'
    @TimestampConverter() required DateTime timestamp,
    String? reason, // e.g., 'user_requested', 'payment_failed', 'plan_change'
    String? planId,
    double? planValue, // Monthly value for MRR calculation
  }) = _SubscriptionStatusLog;

  factory SubscriptionStatusLog.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusLogFromJson(json);
}
