// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  ownerId: json['ownerId'] as String,
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
  logoUrl: json['logoUrl'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  whatsappNumber: json['whatsappNumber'] as String?,
  status: json['status'] as String? ?? 'active',
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  settings: json['settings'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'ownerId': instance.ownerId,
  'address': instance.address?.toJson(),
  'logoUrl': instance.logoUrl,
  'bannerUrl': instance.bannerUrl,
  'phoneNumber': instance.phoneNumber,
  'whatsappNumber': instance.whatsappNumber,
  'status': instance.status,
  'createdAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.createdAt,
    const TimestampConverter().toJson,
  ),
  'settings': instance.settings,
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
