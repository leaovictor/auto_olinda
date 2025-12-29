// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeadClient _$LeadClientFromJson(Map<String, dynamic> json) => _LeadClient(
  plate: json['plate'] as String,
  phoneNumber: json['phoneNumber'] as String,
  vehicleModel: json['vehicleModel'] as String,
  status: $enumDecode(_$LeadStatusEnumMap, json['status']),
  uid: json['uid'] as String?,
  fcmToken: json['fcmToken'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  lastServiceAt: const TimestampConverter().fromJson(
    json['lastServiceAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$LeadClientToJson(
  _LeadClient instance,
) => <String, dynamic>{
  'plate': instance.plate,
  'phoneNumber': instance.phoneNumber,
  'vehicleModel': instance.vehicleModel,
  'status': _$LeadStatusEnumMap[instance.status]!,
  'uid': instance.uid,
  'fcmToken': instance.fcmToken,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'lastServiceAt': const TimestampConverter().toJson(instance.lastServiceAt),
};

const _$LeadStatusEnumMap = {
  LeadStatus.leadNaoCadastrado: 'lead_nao_cadastrado',
  LeadStatus.converted: 'converted',
};
