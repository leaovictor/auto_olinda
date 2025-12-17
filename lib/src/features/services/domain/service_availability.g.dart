// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_availability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceAvailability _$ServiceAvailabilityFromJson(Map<String, dynamic> json) =>
    _ServiceAvailability(
      date: json['date'] as String,
      serviceId: json['serviceId'] as String,
      isOpen: json['isOpen'] as bool,
      slots: Map<String, int>.from(json['slots'] as Map),
    );

Map<String, dynamic> _$ServiceAvailabilityToJson(
  _ServiceAvailability instance,
) => <String, dynamic>{
  'date': instance.date,
  'serviceId': instance.serviceId,
  'isOpen': instance.isOpen,
  'slots': instance.slots,
};
