// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActiveService _$ActiveServiceFromJson(Map<String, dynamic> json) =>
    _ActiveService(
      id: json['id'] as String,
      plate: json['plate'] as String? ?? '',
      vehicleModel: json['vehicleModel'] as String? ?? '',
      status:
          $enumDecodeNullable(_$ServiceStatusEnumMap, json['status']) ??
          ServiceStatus.fila,
      startedAt: const TimestampConverter().fromJson(
        json['startedAt'] as Timestamp,
      ),
      finishedAt: const NullableTimestampConverter().fromJson(
        json['finishedAt'] as Timestamp?,
      ),
      staffId: json['staffId'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? '',
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      clientLink: json['clientLink'] as String? ?? '',
    );

Map<String, dynamic> _$ActiveServiceToJson(
  _ActiveService instance,
) => <String, dynamic>{
  'id': instance.id,
  'plate': instance.plate,
  'vehicleModel': instance.vehicleModel,
  'status': _$ServiceStatusEnumMap[instance.status]!,
  'startedAt': const TimestampConverter().toJson(instance.startedAt),
  'finishedAt': const NullableTimestampConverter().toJson(instance.finishedAt),
  'staffId': instance.staffId,
  'serviceType': instance.serviceType,
  'photos': instance.photos,
  'clientLink': instance.clientLink,
};

const _$ServiceStatusEnumMap = {
  ServiceStatus.fila: 'fila',
  ServiceStatus.lavando: 'lavando',
  ServiceStatus.pronto: 'pronto',
  ServiceStatus.entregue: 'entregue',
};
