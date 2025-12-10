// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stripe_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StripeSubscription _$StripeSubscriptionFromJson(Map<String, dynamic> json) =>
    _StripeSubscription(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerEmail: json['customerEmail'] as String?,
      customerName: json['customerName'] as String?,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      interval: json['interval'] as String,
      currentPeriodStart: (json['currentPeriodStart'] as num).toInt(),
      currentPeriodEnd: (json['currentPeriodEnd'] as num).toInt(),
      canceledAt: (json['canceledAt'] as num?)?.toInt(),
      createdAt: (json['createdAt'] as num).toInt(),
    );

Map<String, dynamic> _$StripeSubscriptionToJson(_StripeSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerEmail': instance.customerEmail,
      'customerName': instance.customerName,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'interval': instance.interval,
      'currentPeriodStart': instance.currentPeriodStart,
      'currentPeriodEnd': instance.currentPeriodEnd,
      'canceledAt': instance.canceledAt,
      'createdAt': instance.createdAt,
    };
