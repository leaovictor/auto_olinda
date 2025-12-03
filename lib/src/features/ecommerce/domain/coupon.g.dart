// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coupon _$CouponFromJson(Map<String, dynamic> json) => _Coupon(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  type: $enumDecode(_$CouponTypeEnumMap, json['type']),
  value: (json['value'] as num).toDouble(),
  applicableTo: (json['applicableTo'] as List<dynamic>)
      .map((e) => $enumDecode(_$CouponApplicableToEnumMap, e))
      .toList(),
  validFrom: json['validFrom'] == null
      ? null
      : DateTime.parse(json['validFrom'] as String),
  validUntil: json['validUntil'] == null
      ? null
      : DateTime.parse(json['validUntil'] as String),
  maxUses: (json['maxUses'] as num?)?.toInt(),
  usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  stripeCouponId: json['stripeCouponId'] as String?,
  minimumPurchase: (json['minimumPurchase'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CouponToJson(_Coupon instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'type': _$CouponTypeEnumMap[instance.type]!,
  'value': instance.value,
  'applicableTo': instance.applicableTo
      .map((e) => _$CouponApplicableToEnumMap[e]!)
      .toList(),
  'validFrom': instance.validFrom?.toIso8601String(),
  'validUntil': instance.validUntil?.toIso8601String(),
  'maxUses': instance.maxUses,
  'usedCount': instance.usedCount,
  'isActive': instance.isActive,
  'stripeCouponId': instance.stripeCouponId,
  'minimumPurchase': instance.minimumPurchase,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$CouponTypeEnumMap = {
  CouponType.percentage: 'percentage',
  CouponType.fixed: 'fixed',
};

const _$CouponApplicableToEnumMap = {
  CouponApplicableTo.products: 'products',
  CouponApplicableTo.services: 'services',
  CouponApplicableTo.subscriptions: 'subscriptions',
};
