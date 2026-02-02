import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lavaflow_app/src/shared/utils/timestamp_converter.dart';

part 'wash_log.freezed.dart';
part 'wash_log.g.dart';

/// Log entry for each wash/service completion.
/// Used for calculating usage frequency and revenue metrics.
@freezed
abstract class WashLog with _$WashLog {
  const factory WashLog({
    required String id,
    String? userId, // null for walk-in (non-registered) customers
    required String bookingId,
    required String serviceType, // 'subscription' or 'single'
    required double value,
    @TimestampConverter() required DateTime timestamp,
    String? planId, // only for subscribers
    @Default([]) List<String> serviceIds,
    String? vehicleType, // 'car', 'suv', 'motorcycle', etc.
  }) = _WashLog;

  factory WashLog.fromJson(Map<String, dynamic> json) =>
      _$WashLogFromJson(json);
}

/// Wash frequency metrics summary
class WashFrequencyMetrics {
  final double subscriberAverage; // Average washes per month for subscribers
  final double
  nonSubscriberAverage; // Average washes per month for non-subscribers
  final int totalWashesToday;
  final int subscriberWashesToday;
  final int singleWashesToday;
  final double totalRevenueToday;

  const WashFrequencyMetrics({
    required this.subscriberAverage,
    required this.nonSubscriberAverage,
    required this.totalWashesToday,
    required this.subscriberWashesToday,
    required this.singleWashesToday,
    required this.totalRevenueToday,
  });

  static const empty = WashFrequencyMetrics(
    subscriberAverage: 0,
    nonSubscriberAverage: 0,
    totalWashesToday: 0,
    subscriberWashesToday: 0,
    singleWashesToday: 0,
    totalRevenueToday: 0,
  );
}
