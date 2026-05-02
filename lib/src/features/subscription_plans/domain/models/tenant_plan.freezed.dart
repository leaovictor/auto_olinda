// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// **************************************************************************
// FreezedGenerator
// **************************************************************************

import 'dart:core';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_plan.freezed.dart';

@_$TenantPlanCopyWith<$TenantPlan> get copyWith => throw UnsupportedError('copyWith');
class _$TenantPlanCopyWith<$Res> {
  factory _$TenantPlanCopyWith(TenantPlan value, $Res Function(TenantPlan) then) =
      ___$TenantPlanCopyWithImpl<$Res, TenantPlan>;
  $Res call({
    String id,
    String tenantId,
    String name,
    String? description,
    double price,
    String? currency,
    int washesIncluded,
    String period,
    bool rollover,
    int rolloverLimit,
    int minContractMonths,
    bool autoRenew,
    bool isActive,
    int sortOrder,
    List<String>? includedServiceIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class ___$TenantPlanCopyWithImpl<$Res, $Val extends TenantPlan>
    implements _$TenantPlanCopyWith<$Res> {
  ___$TenantPlanCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? currency = freezed,
    Object? washesIncluded = null,
    Object? period = null,
    Object? rollover = null,
    Object? rolloverLimit = null,
    Object? minContractMonths = null,
    Object? autoRenew = null,
    Object? isActive = null,
    Object? sortOrder = null,
    Object? includedServiceIds = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      tenantId: null == tenantId ? _value.tenantId : tenantId as String,
      name: null == name ? _value.name : name as String,
      description: freezed == description ? _value.description : description as String?,
      price: null == price ? _value.price : price as double,
      currency: freezed == currency ? _value.currency : currency as String?,
      washesIncluded: null == washesIncluded ? _value.washesIncluded : washesIncluded as int,
      period: null == period ? _value.period : period as String,
      rollover: null == rollover ? _value.rollover : rollover as bool,
      rolloverLimit: null == rolloverLimit ? _value.rolloverLimit : rolloverLimit as int,
      minContractMonths: null == minContractMonths ? _value.minContractMonths : minContractMonths as int,
      autoRenew: null == autoRenew ? _value.autoRenew : autoRenew as bool,
      isActive: null == isActive ? _value.isActive : isActive as bool,
      sortOrder: null == sortOrder ? _value.sortOrder : sortOrder as int,
      includedServiceIds: freezed == includedServiceIds ? _value.includedServiceIds : includedServiceIds as List<String>?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ) as $Res);
  }
}

abstract class _$$TenantPlanCopyWith<$Res> implements _$TenantPlanCopyWith<$Res> {
  factory _$$TenantPlanCopyWith(_TenantPlan value, $Res Function(_TenantPlan) then) =
      __$$TenantPlanCopyWithImpl<$Res, _TenantPlan>;
  @override
  $Res call({
    String id,
    String tenantId,
    String name,
    String? description,
    double price,
    String? currency,
    int washesIncluded,
    String period,
    bool rollover,
    int rolloverLimit,
    int minContractMonths,
    bool autoRenew,
    bool isActive,
    int sortOrder,
    List<String>? includedServiceIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class __$$TenantPlanCopyWithImpl<$Res, $Val extends _TenantPlan>
    extends ___$TenantPlanCopyWithImpl<$Res, $Val>
    implements _$$TenantPlanCopyWith<$Res> {
  __$$TenantPlanCopyWithImpl(_TenantPlan _value, $Res Function(_TenantPlan) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? currency = freezed,
    Object? washesIncluded = null,
    Object? period = null,
    Object? rollover = null,
    Object? rolloverLimit = null,
    Object? minContractMonths = null,
    Object? autoRenew = null,
    Object? isActive = null,
    Object? sortOrder = null,
    Object? includedServiceIds = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_TenantPlan(
      id: null == id ? _value.id : id as String,
      tenantId: null == tenantId ? _value.tenantId : tenantId as String,
      name: null == name ? _value.name : name as String,
      description: freezed == description ? _value.description : description as String?,
      price: null == price ? _value.price : price as double,
      currency: freezed == currency ? _value.currency : currency as String?,
      washesIncluded: null == washesIncluded ? _value.washesIncluded : washesIncluded as int,
      period: null == period ? _value.period : period as String,
      rollover: null == rollover ? _value.rollover : rollover as bool,
      rolloverLimit: null == rolloverLimit ? _value.rolloverLimit : rolloverLimit as int,
      minContractMonths: null == minContractMonths ? _value.minContractMonths : minContractMonths as int,
      autoRenew: null == autoRenew ? _value.autoRenew : autoRenew as bool,
      isActive: null == isActive ? _value.isActive : isActive as bool,
      sortOrder: null == sortOrder ? _value.sortOrder : sortOrder as int,
      includedServiceIds: freezed == includedServiceIds ? _value.includedServiceIds : includedServiceIds as List<String>?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ));
  }
}

@JsonSerializable()
class _TenantPlan implements TenantPlan {
  const _TenantPlan({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    required this.price,
    this.currency,
    required this.washesIncluded,
    required this.period,
    @Default(false) this.rollover,
    @Default(0) this.rolloverLimit,
    @Default(0) this.minContractMonths,
    @Default(true) this.autoRenew,
    @Default(true) this.isActive,
    @Default(0) this.sortOrder,
    this.includedServiceIds,
    this.createdAt,
    this.updatedAt,
  });

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double price;
  @override
  final String? currency;
  @override
  final int washesIncluded;
  @override
  final String period;
  @override
  @Default(false)
  final bool rollover;
  @override
  @Default(0)
  final int rolloverLimit;
  @override
  @Default(0)
  final int minContractMonths;
  @override
  @Default(true)
  final bool autoRenew;
  @override
  @Default(true)
  final bool isActive;
  @override
  @Default(0)
  final int sortOrder;
  @override
  final List<String>? includedServiceIds;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TenantPlan(id: $id, tenantId: $tenantId, name: $name, description: $description, price: $price, currency: $currency, washesIncluded: $washesIncluded, period: $period, rollover: $rollover, rolloverLimit: $rolloverLimit, minContractMonths: $minContractMonths, autoRenew: $autoRenew, isActive: $isActive, sortOrder: $sortOrder, includedServiceIds: $includedServiceIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TenantPlan &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) || other.tenantId == tenantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) || other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) || other.currency == currency) &&
            (identical(other.washesIncluded, washesIncluded) || other.washesIncluded == washesIncluded) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.rollover, rollover) || other.rollover == rollover) &&
            (identical(other.rolloverLimit, rolloverLimit) || other.rolloverLimit == rolloverLimit) &&
            (identical(other.minContractMonths, minContractMonths) || other.minContractMonths == minContractMonths) &&
            (identical(other.autoRenew, autoRenew) || other.autoRenew == autoRenew) &&
            (identical(other.isActive, isActive) || other.isActive == isActive) &&
            (identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder) &&
            const DeepCollectionEquality().equals(other.includedServiceIds, includedServiceIds) &&
            (identical(other.createdAt, createdAt) || other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      name,
      description,
      price,
      currency,
      washesIncluded,
      period,
      rollover,
      rolloverLimit,
      minContractMonths,
      autoRenew,
      isActive,
      sortOrder,
      const DeepCollectionEquality().hash(includedServiceIds),
      createdAt,
      updatedAt);

  factory TenantPlan.fromJson(Map<String, dynamic> json) => _$TenantPlanFromJson(json);
}
