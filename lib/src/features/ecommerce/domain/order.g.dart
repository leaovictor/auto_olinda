// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  userId: json['userId'] as String,
  serviceId: json['serviceId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: json['status'] as String,
  method: json['method'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  bookingId: json['bookingId'] as String?,
  stripeSessionId: json['stripeSessionId'] as String?,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'serviceId': instance.serviceId,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': instance.status,
  'method': instance.method,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'bookingId': instance.bookingId,
  'stripeSessionId': instance.stripeSessionId,
};
