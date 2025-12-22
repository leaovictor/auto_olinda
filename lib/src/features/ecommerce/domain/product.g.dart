// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  isActive: json['isActive'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  imageUrl: json['imageUrl'] as String?,
  category: json['category'] as String?,
  stripePriceId: json['stripePriceId'] as String?,
  createdAt: const TimestampOrNullConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'isActive': instance.isActive,
  'isFeatured': instance.isFeatured,
  'imageUrl': instance.imageUrl,
  'category': instance.category,
  'stripePriceId': instance.stripePriceId,
  'createdAt': const TimestampOrNullConverter().toJson(instance.createdAt),
};
