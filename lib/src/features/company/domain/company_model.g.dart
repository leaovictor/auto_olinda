// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Company _$CompanyFromJson(Map<String, dynamic> json) => _Company(
  id: json['id'] as String,
  name: json['name'] as String,
  ownerId: json['ownerId'] as String,
  logoUrl: json['logoUrl'] as String?,
  primaryColor: json['primaryColor'] as String?,
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
  geoPoint: _geoPointFromJson(json['geoPoint']),
  isActive: json['isActive'] as bool? ?? true,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  openingHours: json['openingHours'] as String? ?? '09:00 - 18:00',
);

Map<String, dynamic> _$CompanyToJson(_Company instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ownerId': instance.ownerId,
  'logoUrl': instance.logoUrl,
  'primaryColor': instance.primaryColor,
  'address': instance.address?.toJson(),
  'geoPoint': _geoPointToJson(instance.geoPoint),
  'isActive': instance.isActive,
  'categories': instance.categories,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'openingHours': instance.openingHours,
};
