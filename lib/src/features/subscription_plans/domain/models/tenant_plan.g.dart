// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TenantPlan _$TenantPlanFromJson(Map<String, dynamic> json) => _TenantPlan(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String?,
  washesIncluded: (json['washesIncluded'] as num).toInt(),
  period: json['period'] as String,
  rollover: json['rollover'] as bool? ?? false,
  rolloverLimit: (json['rolloverLimit'] as num?)?.toInt() ?? 0,
  minContractMonths: (json['minContractMonths'] as num?)?.toInt() ?? 0,
  autoRenew: json['autoRenew'] as bool? ?? true,
  isActive: json['isActive'] as bool? ?? true,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  includedServiceIds: (json['includedServiceIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TenantPlanToJson(_TenantPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'washesIncluded': instance.washesIncluded,
      'period': instance.period,
      'rollover': instance.rollover,
      'rolloverLimit': instance.rolloverLimit,
      'minContractMonths': instance.minContractMonths,
      'autoRenew': instance.autoRenew,
      'isActive': instance.isActive,
      'sortOrder': instance.sortOrder,
      'includedServiceIds': instance.includedServiceIds,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
