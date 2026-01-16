// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionDetails _$SubscriptionDetailsFromJson(Map<String, dynamic> json) =>
    _SubscriptionDetails(
      status: json['status'] as String,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool,
      currentPeriodEnd: (json['currentPeriodEnd'] as num).toInt(),
      paymentMethod: json['paymentMethod'] == null
          ? null
          : SubscriptionPaymentMethod.fromJson(
              json['paymentMethod'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SubscriptionDetailsToJson(
  _SubscriptionDetails instance,
) => <String, dynamic>{
  'status': instance.status,
  'cancelAtPeriodEnd': instance.cancelAtPeriodEnd,
  'currentPeriodEnd': instance.currentPeriodEnd,
  'paymentMethod': instance.paymentMethod?.toJson(),
};

_SubscriptionPaymentMethod _$SubscriptionPaymentMethodFromJson(
  Map<String, dynamic> json,
) => _SubscriptionPaymentMethod(
  brand: json['brand'] as String,
  last4: json['last4'] as String,
  expMonth: (json['expMonth'] as num).toInt(),
  expYear: (json['expYear'] as num).toInt(),
);

Map<String, dynamic> _$SubscriptionPaymentMethodToJson(
  _SubscriptionPaymentMethod instance,
) => <String, dynamic>{
  'brand': instance.brand,
  'last4': instance.last4,
  'expMonth': instance.expMonth,
  'expYear': instance.expYear,
};
