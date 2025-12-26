// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_status_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionStatusLog _$SubscriptionStatusLogFromJson(
  Map<String, dynamic> json,
) => _SubscriptionStatusLog(
  id: json['id'] as String,
  subscriptionId: json['subscriptionId'] as String,
  userId: json['userId'] as String,
  previousStatus: json['previousStatus'] as String,
  newStatus: json['newStatus'] as String,
  timestamp: const TimestampConverter().fromJson(json['timestamp']),
  reason: json['reason'] as String?,
  planId: json['planId'] as String?,
  planValue: (json['planValue'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SubscriptionStatusLogToJson(
  _SubscriptionStatusLog instance,
) => <String, dynamic>{
  'id': instance.id,
  'subscriptionId': instance.subscriptionId,
  'userId': instance.userId,
  'previousStatus': instance.previousStatus,
  'newStatus': instance.newStatus,
  'timestamp': const TimestampConverter().toJson(instance.timestamp),
  'reason': instance.reason,
  'planId': instance.planId,
  'planValue': instance.planValue,
};
