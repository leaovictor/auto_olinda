// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tenant _$TenantFromJson(Map<String, dynamic> json) => _Tenant(
  id: json['id'] as String,
  name: json['name'] as String,
  ownerUid: json['ownerUid'] as String,
  status: json['status'] as String? ?? 'active',
  plan: json['plan'] as String? ?? 'starter',
  logoUrl: json['logoUrl'] as String?,
  primaryColor: json['primaryColor'] as String? ?? '#1A73E8',
  stripeConnectAccountId: json['stripeConnectAccountId'] as String?,
  stripeConnectOnboarded: json['stripeConnectOnboarded'] as bool? ?? false,
  platformFeePercent: (json['platformFeePercent'] as num?)?.toInt() ?? 5,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  settings: json['settings'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$TenantToJson(_Tenant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ownerUid': instance.ownerUid,
  'status': instance.status,
  'plan': instance.plan,
  'logoUrl': instance.logoUrl,
  'primaryColor': instance.primaryColor,
  'stripeConnectAccountId': instance.stripeConnectAccountId,
  'stripeConnectOnboarded': instance.stripeConnectOnboarded,
  'platformFeePercent': instance.platformFeePercent,
  'phone': instance.phone,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'settings': instance.settings,
};
