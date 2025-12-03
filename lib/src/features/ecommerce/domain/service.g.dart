// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Service _$ServiceFromJson(Map<String, dynamic> json) => _Service(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
  estimatedDuration: Duration(
    microseconds: (json['estimatedDuration'] as num).toInt(),
  ),
  isActive: json['isActive'] as bool? ?? true,
  features: (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  stripeProductId: json['stripeProductId'] as String?,
  stripePriceId: json['stripePriceId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ServiceToJson(_Service instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'imageUrl': instance.imageUrl,
  'estimatedDuration': instance.estimatedDuration.inMicroseconds,
  'isActive': instance.isActive,
  'features': instance.features,
  'stripeProductId': instance.stripeProductId,
  'stripePriceId': instance.stripePriceId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
