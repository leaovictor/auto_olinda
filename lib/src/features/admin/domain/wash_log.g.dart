// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wash_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WashLog _$WashLogFromJson(Map<String, dynamic> json) => _WashLog(
  id: json['id'] as String,
  userId: json['userId'] as String?,
  bookingId: json['bookingId'] as String,
  serviceType: json['serviceType'] as String,
  value: (json['value'] as num).toDouble(),
  timestamp: const TimestampConverter().fromJson(json['timestamp']),
  planId: json['planId'] as String?,
  serviceIds:
      (json['serviceIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  vehicleType: json['vehicleType'] as String?,
);

Map<String, dynamic> _$WashLogToJson(_WashLog instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'bookingId': instance.bookingId,
  'serviceType': instance.serviceType,
  'value': instance.value,
  'timestamp': const TimestampConverter().toJson(instance.timestamp),
  'planId': instance.planId,
  'serviceIds': instance.serviceIds,
  'vehicleType': instance.vehicleType,
};
