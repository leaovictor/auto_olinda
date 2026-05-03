// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Customer _$CustomerFromJson(Map<String, dynamic> json) => _Customer(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  name: json['name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  whatsapp: json['whatsapp'] as String?,
  cpf: json['cpf'] as String?,
  cnpj: json['cnpj'] as String?,
  status: json['status'] as String? ?? 'active',
  vehicles:
      (json['vehicles'] as List<dynamic>?)
          ?.map((e) => CustomerVehicle.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  firstVisitAt: json['firstVisitAt'] == null
      ? null
      : DateTime.parse(json['firstVisitAt'] as String),
  lastVisitAt: json['lastVisitAt'] == null
      ? null
      : DateTime.parse(json['lastVisitAt'] as String),
  visitCount: (json['visitCount'] as num?)?.toInt() ?? 0,
  lifetimeValue: (json['lifetimeValue'] as num?)?.toDouble() ?? 0.0,
  activeSubscriptionIds:
      (json['activeSubscriptionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CustomerToJson(_Customer instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'whatsapp': instance.whatsapp,
  'cpf': instance.cpf,
  'cnpj': instance.cnpj,
  'status': instance.status,
  'vehicles': instance.vehicles.map((e) => e.toJson()).toList(),
  'firstVisitAt': instance.firstVisitAt?.toIso8601String(),
  'lastVisitAt': instance.lastVisitAt?.toIso8601String(),
  'visitCount': instance.visitCount,
  'lifetimeValue': instance.lifetimeValue,
  'activeSubscriptionIds': instance.activeSubscriptionIds,
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_CustomerVehicle _$CustomerVehicleFromJson(Map<String, dynamic> json) =>
    _CustomerVehicle(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      plate: json['plate'] as String,
      color: json['color'] as String?,
      vehicleType: json['vehicleType'] as String?,
      imageUrl: json['imageUrl'] as String?,
      visitCount: (json['visitCount'] as num?)?.toInt() ?? 0,
      addedAt: json['addedAt'] == null
          ? null
          : DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$CustomerVehicleToJson(_CustomerVehicle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'brand': instance.brand,
      'model': instance.model,
      'plate': instance.plate,
      'color': instance.color,
      'vehicleType': instance.vehicleType,
      'imageUrl': instance.imageUrl,
      'visitCount': instance.visitCount,
      'addedAt': instance.addedAt?.toIso8601String(),
    };
