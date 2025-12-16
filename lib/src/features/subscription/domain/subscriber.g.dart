// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriber.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Subscriber _$SubscriberFromJson(Map<String, dynamic> json) => _Subscriber(
  id: json['id'] as String,
  userId: json['userId'] as String,
  planId: json['planId'] as String,
  startDate: const TimestampConverter().fromJson(json['startDate']),
  endDate: const TimestampConverter().fromJson(json['endDate']),
  cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
  status: json['status'] as String,
  stripeSubscriptionId: json['stripeSubscriptionId'] as String?,
  bonusWashes: (json['bonusWashes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SubscriberToJson(_Subscriber instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'planId': instance.planId,
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'endDate': _$JsonConverterToJson<dynamic, DateTime>(
        instance.endDate,
        const TimestampConverter().toJson,
      ),
      'cancelAtPeriodEnd': instance.cancelAtPeriodEnd,
      'status': instance.status,
      'stripeSubscriptionId': instance.stripeSubscriptionId,
      'bonusWashes': instance.bonusWashes,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
