// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
  category: $enumDecode(_$ProductCategoryEnumMap, json['category']),
  isActive: json['isActive'] as bool? ?? true,
  stock: (json['stock'] as num?)?.toInt() ?? 0,
  stripeProductId: json['stripeProductId'] as String?,
  stripePriceId: json['stripePriceId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'imageUrl': instance.imageUrl,
  'category': _$ProductCategoryEnumMap[instance.category]!,
  'isActive': instance.isActive,
  'stock': instance.stock,
  'stripeProductId': instance.stripeProductId,
  'stripePriceId': instance.stripePriceId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$ProductCategoryEnumMap = {
  ProductCategory.carCare: 'car_care',
  ProductCategory.accessories: 'accessories',
  ProductCategory.cleaning: 'cleaning',
  ProductCategory.other: 'other',
};
