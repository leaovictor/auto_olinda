// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  role: json['role'] as String? ?? 'customer',
  tenantId: json['tenantId'] as String?,
  fcmToken: json['fcmToken'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  cpf: json['cpf'] as String?,
  isWhatsApp: json['isWhatsApp'] as bool? ?? false,
  status: json['status'] as String? ?? 'active',
  subscriptionStatus: json['subscriptionStatus'] as String? ?? 'none',
  subscriptionUpdatedAt: const TimestampConverter().fromJson(
    json['subscriptionUpdatedAt'],
  ),
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
  ndaAcceptedVersion: json['ndaAcceptedVersion'] as String?,
  ndaAcceptedAt: const TimestampConverter().fromJson(json['ndaAcceptedAt']),
  lastAccessAt: const TimestampConverter().fromJson(json['lastAccessAt']),
  strikeUntil: const TimestampConverter().fromJson(json['strikeUntil']),
  lastStrikeReason: json['lastStrikeReason'] as String?,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'role': instance.role,
  'tenantId': instance.tenantId,
  'fcmToken': instance.fcmToken,
  'phoneNumber': instance.phoneNumber,
  'cpf': instance.cpf,
  'isWhatsApp': instance.isWhatsApp,
  'status': instance.status,
  'subscriptionStatus': instance.subscriptionStatus,
  'subscriptionUpdatedAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.subscriptionUpdatedAt,
    const TimestampConverter().toJson,
  ),
  'address': instance.address?.toJson(),
  'ndaAcceptedVersion': instance.ndaAcceptedVersion,
  'ndaAcceptedAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.ndaAcceptedAt,
    const TimestampConverter().toJson,
  ),
  'lastAccessAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.lastAccessAt,
    const TimestampConverter().toJson,
  ),
  'strikeUntil': _$JsonConverterToJson<dynamic, DateTime>(
    instance.strikeUntil,
    const TimestampConverter().toJson,
  ),
  'lastStrikeReason': instance.lastStrikeReason,
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
