// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) =>
    _SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      stripePriceId: json['stripePriceId'] as String? ?? '',
      category: json['category'] as String? ?? 'any',
      washesPerMonth: (json['washesPerMonth'] as num?)?.toInt() ?? 4,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$SubscriptionPlanToJson(_SubscriptionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'features': instance.features,
      'stripePriceId': instance.stripePriceId,
      'category': instance.category,
      'washesPerMonth': instance.washesPerMonth,
      'isActive': instance.isActive,
    };
