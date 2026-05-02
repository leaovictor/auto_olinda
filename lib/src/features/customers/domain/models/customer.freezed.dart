// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// **************************************************************************
// FreezedGenerator
// **************************************************************************

import 'dart:core';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';

@_$CustomerCopyWith<$Customer> get copyWith => throw UnsupportedError('copyWith');
class _$CustomerCopyWith<$Res> {
  factory _$CustomerCopyWith(Customer value, $Res Function(Customer) then) =
      ___$CustomerCopyWithImpl<$Res, Customer>;
  $Res call({
    String id,
    String tenantId,
    String name,
    String? email,
    String? phone,
    String? whatsapp,
    String? cpf,
    String? cnpj,
    String status,
    List<CustomerVehicle> vehicles,
    DateTime? firstVisitAt,
    DateTime? lastVisitAt,
    int visitCount,
    double lifetimeValue,
    List<String> activeSubscriptionIds,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class ___$CustomerCopyWithImpl<$Res, $Val extends Customer>
    implements _$CustomerCopyWith<$Res> {
  ___$CustomerCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? whatsapp = freezed,
    Object? cpf = freezed,
    Object? cnpj = freezed,
    Object? status = null,
    Object? vehicles = null,
    Object? firstVisitAt = freezed,
    Object? lastVisitAt = freezed,
    Object? visitCount = null,
    Object? lifetimeValue = null,
    Object? activeSubscriptionIds = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      tenantId: null == tenantId ? _value.tenantId : tenantId as String,
      name: null == name ? _value.name : name as String,
      email: freezed == email ? _value.email : email as String?,
      phone: freezed == phone ? _value.phone : phone as String?,
      whatsapp: freezed == whatsapp ? _value.whatsapp : whatsapp as String?,
      cpf: freezed == cpf ? _value.cpf : cpf as String?,
      cnpj: freezed == cnpj ? _value.cnpj : cnpj as String?,
      status: null == status ? _value.status : status as String,
      vehicles: null == vehicles ? _value.vehicles : vehicles as List<CustomerVehicle>,
      firstVisitAt: freezed == firstVisitAt ? _value.firstVisitAt : firstVisitAt as DateTime?,
      lastVisitAt: freezed == lastVisitAt ? _value.lastVisitAt : lastVisitAt as DateTime?,
      visitCount: null == visitCount ? _value.visitCount : visitCount as int,
      lifetimeValue: null == lifetimeValue ? _value.lifetimeValue : lifetimeValue as double,
      activeSubscriptionIds: null == activeSubscriptionIds ? _value.activeSubscriptionIds : activeSubscriptionIds as List<String>,
      notes: freezed == notes ? _value.notes : notes as String?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ) as $Res);
  }
}

abstract class _$$CustomerCopyWith<$Res> implements _$CustomerCopyWith<$Res> {
  factory _$$CustomerCopyWith(_Customer value, $Res Function(_Customer) then) =
      __$$CustomerCopyWithImpl<$Res, _Customer>;
  @override
  $Res call({
    String id,
    String tenantId,
    String name,
    String? email,
    String? phone,
    String? whatsapp,
    String? cpf,
    String? cnpj,
    String status,
    List<CustomerVehicle> vehicles,
    DateTime? firstVisitAt,
    DateTime? lastVisitAt,
    int visitCount,
    double lifetimeValue,
    List<String> activeSubscriptionIds,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class __$$CustomerCopyWithImpl<$Res, $Val extends _Customer>
    extends ___$CustomerCopyWithImpl<$Res, $Val>
    implements _$$CustomerCopyWith<$Res> {
  __$$CustomerCopyWithImpl(_Customer _value, $Res Function(_Customer) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? whatsapp = freezed,
    Object? cpf = freezed,
    Object? cnpj = freezed,
    Object? status = null,
    Object? vehicles = null,
    Object? firstVisitAt = freezed,
    Object? lastVisitAt = freezed,
    Object? visitCount = null,
    Object? lifetimeValue = null,
    Object? activeSubscriptionIds = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Customer(
      id: null == id ? _value.id : id as String,
      tenantId: null == tenantId ? _value.tenantId : tenantId as String,
      name: null == name ? _value.name : name as String,
      email: freezed == email ? _value.email : email as String?,
      phone: freezed == phone ? _value.phone : phone as String?,
      whatsapp: freezed == whatsapp ? _value.whatsapp : whatsapp as String?,
      cpf: freezed == cpf ? _value.cpf : cpf as String?,
      cnpj: freezed == cnpj ? _value.cnpj : cnpj as String?,
      status: null == status ? _value.status : status as String,
      vehicles: null == vehicles ? _value.vehicles : vehicles as List<CustomerVehicle>,
      firstVisitAt: freezed == firstVisitAt ? _value.firstVisitAt : firstVisitAt as DateTime?,
      lastVisitAt: freezed == lastVisitAt ? _value.lastVisitAt : lastVisitAt as DateTime?,
      visitCount: null == visitCount ? _value.visitCount : visitCount as int,
      lifetimeValue: null == lifetimeValue ? _value.lifetimeValue : lifetimeValue as double,
      activeSubscriptionIds: null == activeSubscriptionIds ? _value.activeSubscriptionIds : activeSubscriptionIds as List<String>,
      notes: freezed == notes ? _value.notes : notes as String?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ));
  }
}

@JsonSerializable()
class _Customer implements Customer {
  const _Customer({
    required this.id,
    required this.tenantId,
    required this.name,
    this.email,
    this.phone,
    this.whatsapp,
    this.cpf,
    this.cnpj,
    @Default('active') this.status,
    @Default([]) this.vehicles,
    this.firstVisitAt,
    this.lastVisitAt,
    @Default(0) this.visitCount,
    @Default(0.0) this.lifetimeValue,
    @Default([]) this.activeSubscriptionIds,
    this.notes,
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
  final String? email;
  @override
  final String? phone;
  @override
  final String? whatsapp;
  @override
  final String? cpf;
  @override
  final String? cnpj;
  @override
  @Default('active')
  final String status;
  @override
  @Default([])
  final List<CustomerVehicle> vehicles;
  @override
  final DateTime? firstVisitAt;
  @override
  final DateTime? lastVisitAt;
  @override
  @Default(0)
  final int visitCount;
  @override
  @Default(0.0)
  final double lifetimeValue;
  @override
  @Default([])
  final List<String> activeSubscriptionIds;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Customer(id: $id, tenantId: $tenantId, name: $name, email: $email, phone: $phone, whatsapp: $whatsapp, cpf: $cpf, cnpj: $cnpj, status: $status, vehicles: $vehicles, firstVisitAt: $firstVisitAt, lastVisitAt: $lastVisitAt, visitCount: $visitCount, lifetimeValue: $lifetimeValue, activeSubscriptionIds: $activeSubscriptionIds, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Customer &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) || other.tenantId == tenantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp) &&
            (identical(other.cpf, cpf) || other.cpf == cpf) &&
            (identical(other.cnpj, cnpj) || other.cnpj == cnpj) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.vehicles, vehicles) &&
            (identical(other.firstVisitAt, firstVisitAt) ||
                other.firstVisitAt == firstVisitAt) &&
            (identical(other.lastVisitAt, lastVisitAt) ||
                other.lastVisitAt == lastVisitAt) &&
            (identical(other.visitCount, visitCount) ||
                other.visitCount == visitCount) &&
            (identical(other.lifetimeValue, lifetimeValue) ||
                other.lifetimeValue == lifetimeValue) &&
            const DeepCollectionEquality()
                .equals(other.activeSubscriptionIds, activeSubscriptionIds) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      name,
      email,
      phone,
      whatsapp,
      cpf,
      cnpj,
      status,
      const DeepCollectionEquality().hash(vehicles),
      firstVisitAt,
      lastVisitAt,
      visitCount,
      lifetimeValue,
      const DeepCollectionEquality().hash(activeSubscriptionIds),
      notes,
      createdAt,
      updatedAt);

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}

@JsonSerializable()
class _CustomerVehicle implements CustomerVehicle {
  const _CustomerVehicle({
    required this.id,
    required this.customerId,
    required this.brand,
    required this.model,
    required this.plate,
    this.color,
    this.vehicleType,
    this.imageUrl,
    @Default(0) this.visitCount,
    this.addedAt,
  });

  @override
  final String id;
  @override
  final String customerId;
  @override
  final String brand;
  @override
  final String model;
  @override
  final String plate;
  @override
  final String? color;
  @override
  final String? vehicleType;
  @override
  final String? imageUrl;
  @override
  @Default(0)
  final int visitCount;
  @override
  final DateTime? addedAt;

  @override
  String toString() {
    return 'CustomerVehicle(id: $id, customerId: $customerId, brand: $brand, model: $model, plate: $plate, color: $color, vehicleType: $vehicleType, imageUrl: $imageUrl, visitCount: $visitCount, addedAt: $addedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CustomerVehicle &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.plate, plate) || other.plate == plate) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.visitCount, visitCount) ||
                other.visitCount == visitCount) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerId,
      brand,
      model,
      plate,
      color,
      vehicleType,
      imageUrl,
      visitCount,
      addedAt);

  factory CustomerVehicle.fromJson(Map<String, dynamic> json) =>
      _$CustomerVehicleFromJson(json);
}
