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
  role: json['role'] as String? ?? 'client',
  fcmToken: json['fcmToken'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  isWhatsApp: json['isWhatsApp'] as bool? ?? false,
  status: json['status'] as String? ?? 'active',
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
  ndaAcceptedVersion: json['ndaAcceptedVersion'] as String?,
  ndaAcceptedAt: const TimestampConverter().fromJson(json['ndaAcceptedAt']),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'role': instance.role,
  'fcmToken': instance.fcmToken,
  'phoneNumber': instance.phoneNumber,
  'isWhatsApp': instance.isWhatsApp,
  'status': instance.status,
  'address': instance.address?.toJson(),
  'ndaAcceptedVersion': instance.ndaAcceptedVersion,
  'ndaAcceptedAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.ndaAcceptedAt,
    const TimestampConverter().toJson,
  ),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
