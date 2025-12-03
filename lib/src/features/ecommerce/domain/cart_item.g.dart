// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItemProduct _$CartItemProductFromJson(Map<String, dynamic> json) =>
    _CartItemProduct(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CartItemProductToJson(_CartItemProduct instance) =>
    <String, dynamic>{
      'product': instance.product.toJson(),
      'quantity': instance.quantity,
      'runtimeType': instance.$type,
    };

_CartItemService _$CartItemServiceFromJson(Map<String, dynamic> json) =>
    _CartItemService(
      service: Service.fromJson(json['service'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CartItemServiceToJson(_CartItemService instance) =>
    <String, dynamic>{
      'service': instance.service.toJson(),
      'quantity': instance.quantity,
      'runtimeType': instance.$type,
    };
