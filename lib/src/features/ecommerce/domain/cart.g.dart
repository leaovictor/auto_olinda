// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Cart _$CartFromJson(Map<String, dynamic> json) => _Cart(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  appliedCoupon: json['appliedCoupon'] == null
      ? null
      : Coupon.fromJson(json['appliedCoupon'] as Map<String, dynamic>),
  discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$CartToJson(_Cart instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'appliedCoupon': instance.appliedCoupon?.toJson(),
  'discountAmount': instance.discountAmount,
};
