import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:aquaclean_mobile/src/shared/utils/timestamp_converter.dart';

part 'fcm_notification_log.freezed.dart';
part 'fcm_notification_log.g.dart';

/// Log entry for FCM notifications sent.
/// Used for tracking notification efficiency and proving system value.
@freezed
abstract class FcmNotificationLog with _$FcmNotificationLog {
  const factory FcmNotificationLog({
    required String id,
    required String userId,
    required String
    notificationType, // 'carro_pronto', 'status_update', 'reminder', 'promo'
    String? bookingId,
    @TimestampConverter() required DateTime sentAt,
    @Default(true) bool delivered,
    String? title,
    String? body,
  }) = _FcmNotificationLog;

  factory FcmNotificationLog.fromJson(Map<String, dynamic> json) =>
      _$FcmNotificationLogFromJson(json);
}

/// FCM notification efficiency metrics
class FcmEfficiencyMetrics {
  final int totalNotificationsThisMonth;
  final int carrosProntosCount;
  final int statusUpdatesCount;
  final int remindersCount;
  final int promosCount;
  final double
  estimatedTimeSavedMinutes; // Assuming 2 minutes per manual notification

  const FcmEfficiencyMetrics({
    required this.totalNotificationsThisMonth,
    required this.carrosProntosCount,
    required this.statusUpdatesCount,
    required this.remindersCount,
    required this.promosCount,
    required this.estimatedTimeSavedMinutes,
  });

  static const empty = FcmEfficiencyMetrics(
    totalNotificationsThisMonth: 0,
    carrosProntosCount: 0,
    statusUpdatesCount: 0,
    remindersCount: 0,
    promosCount: 0,
    estimatedTimeSavedMinutes: 0,
  );

  /// Factory to calculate from logs
  factory FcmEfficiencyMetrics.fromLogs(List<FcmNotificationLog> logs) {
    final carrosProntos = logs
        .where((l) => l.notificationType == 'carro_pronto')
        .length;
    final statusUpdates = logs
        .where((l) => l.notificationType == 'status_update')
        .length;
    final reminders = logs
        .where((l) => l.notificationType == 'reminder')
        .length;
    final promos = logs.where((l) => l.notificationType == 'promo').length;
    final total = logs.length;

    // Assume each notification saves 2 minutes of manual work
    final timeSaved = total * 2.0;

    return FcmEfficiencyMetrics(
      totalNotificationsThisMonth: total,
      carrosProntosCount: carrosProntos,
      statusUpdatesCount: statusUpdates,
      remindersCount: reminders,
      promosCount: promos,
      estimatedTimeSavedMinutes: timeSaved,
    );
  }
}
