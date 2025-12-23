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
  validFrom: const TimestampConverter().fromJson(json['validFrom']),
  validUntil: const TimestampConverter().fromJson(json['validUntil']),
  maxUses: (json['maxUses'] as num?)?.toInt(),
  usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  minimumPurchase: (json['minimumPurchase'] as num?)?.toDouble(),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
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
  'validFrom': _$JsonConverterToJson<dynamic, DateTime>(
    instance.validFrom,
    const TimestampConverter().toJson,
  ),
  'validUntil': _$JsonConverterToJson<dynamic, DateTime>(
    instance.validUntil,
    const TimestampConverter().toJson,
  ),
  'maxUses': instance.maxUses,
  'usedCount': instance.usedCount,
  'isActive': instance.isActive,
  'minimumPurchase': instance.minimumPurchase,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
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

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
