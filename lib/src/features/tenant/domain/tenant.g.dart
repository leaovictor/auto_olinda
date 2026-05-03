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
  stripeAccountId: json['stripeAccountId'] as String?,
  stripeOnboarded: json['stripeOnboarded'] as bool? ?? false,
  platformFeePercent: (json['platformFeePercent'] as num?)?.toInt() ?? 10,
  logoUrl: json['logoUrl'] as String?,
  coverImageUrl: json['coverImageUrl'] as String?,
  primaryColor: json['primaryColor'] as String? ?? '#0066CC',
  secondaryColor: json['secondaryColor'] as String?,
  phone: json['phone'] as String?,
  whatsapp: json['whatsapp'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['zipCode'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  businessConfig: json['businessConfig'] == null
      ? null
      : BusinessConfig.fromJson(json['businessConfig'] as Map<String, dynamic>),
  maxStaffCount: (json['maxStaffCount'] as num?)?.toInt() ?? 5,
  maxActiveServices: (json['maxActiveServices'] as num?)?.toInt() ?? 100,
  hasLoyaltyProgram: json['hasLoyaltyProgram'] as bool? ?? false,
  sendAutomatedReminders: json['sendAutomatedReminders'] as bool? ?? false,
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  subscriptionStatus: json['subscriptionStatus'] as String? ?? 'trial',
  trialEndsAt: json['trialEndsAt'] == null
      ? null
      : DateTime.parse(json['trialEndsAt'] as String),
  trialDays: (json['trialDays'] as num?)?.toInt() ?? 14,
  subscriptionEndsAt: json['subscriptionEndsAt'] == null
      ? null
      : DateTime.parse(json['subscriptionEndsAt'] as String),
  staffIds:
      (json['staffIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  customFields: json['customFields'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$TenantToJson(_Tenant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ownerUid': instance.ownerUid,
  'status': instance.status,
  'stripeAccountId': instance.stripeAccountId,
  'stripeOnboarded': instance.stripeOnboarded,
  'platformFeePercent': instance.platformFeePercent,
  'logoUrl': instance.logoUrl,
  'coverImageUrl': instance.coverImageUrl,
  'primaryColor': instance.primaryColor,
  'secondaryColor': instance.secondaryColor,
  'phone': instance.phone,
  'whatsapp': instance.whatsapp,
  'email': instance.email,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'zipCode': instance.zipCode,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'businessConfig': instance.businessConfig?.toJson(),
  'maxStaffCount': instance.maxStaffCount,
  'maxActiveServices': instance.maxActiveServices,
  'hasLoyaltyProgram': instance.hasLoyaltyProgram,
  'sendAutomatedReminders': instance.sendAutomatedReminders,
  'notificationsEnabled': instance.notificationsEnabled,
  'subscriptionStatus': instance.subscriptionStatus,
  'trialEndsAt': instance.trialEndsAt?.toIso8601String(),
  'trialDays': instance.trialDays,
  'subscriptionEndsAt': instance.subscriptionEndsAt?.toIso8601String(),
  'staffIds': instance.staffIds,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'customFields': instance.customFields,
};
