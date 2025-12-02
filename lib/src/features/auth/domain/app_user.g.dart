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
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
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
  'address': instance.address?.toJson(),
};
