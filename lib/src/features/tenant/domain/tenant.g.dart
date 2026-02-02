// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tenant _$TenantFromJson(Map<String, dynamic> json) => _Tenant(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  ownerId: json['ownerId'] as String,
  stripeCustomerId: json['stripeCustomerId'] as String?,
  branding: TenantBranding.fromJson(json['branding'] as Map<String, dynamic>),
  domains: TenantDomains.fromJson(json['domains'] as Map<String, dynamic>),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$TenantToJson(_Tenant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'ownerId': instance.ownerId,
  'stripeCustomerId': instance.stripeCustomerId,
  'branding': instance.branding.toJson(),
  'domains': instance.domains.toJson(),
  'createdAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.createdAt,
    const TimestampConverter().toJson,
  ),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_TenantBranding _$TenantBrandingFromJson(Map<String, dynamic> json) =>
    _TenantBranding(
      logoUrl: json['logoUrl'] as String?,
      primaryColor: json['primaryColor'] as String,
    );

Map<String, dynamic> _$TenantBrandingToJson(_TenantBranding instance) =>
    <String, dynamic>{
      'logoUrl': instance.logoUrl,
      'primaryColor': instance.primaryColor,
    };

_TenantDomains _$TenantDomainsFromJson(Map<String, dynamic> json) =>
    _TenantDomains(
      subdomain: json['subdomain'] as String,
      customDomain: json['customDomain'] as String?,
      domainVerified: json['domainVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$TenantDomainsToJson(_TenantDomains instance) =>
    <String, dynamic>{
      'subdomain': instance.subdomain,
      'customDomain': instance.customDomain,
      'domainVerified': instance.domainVerified,
    };
