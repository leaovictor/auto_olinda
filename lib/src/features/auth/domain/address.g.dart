// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  cep: json['cep'] as String,
  street: json['street'] as String,
  number: json['number'] as String,
  complement: json['complement'] as String?,
  neighborhood: json['neighborhood'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'cep': instance.cep,
  'street': instance.street,
  'number': instance.number,
  'complement': instance.complement,
  'neighborhood': instance.neighborhood,
  'city': instance.city,
  'state': instance.state,
};
