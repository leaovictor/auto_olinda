// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// **************************************************************************
// FreezedGenerator
// **************************************************************************

import 'dart:core';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_member.freezed.dart';

@_$StaffMemberCopyWith<$StaffMember> get copyWith => throw UnsupportedError('copyWith');
class _$StaffMemberCopyWith<$Res> {
  factory _$StaffMemberCopyWith(StaffMember value, $Res Function(StaffMember) then) =
      ___$StaffMemberCopyWithImpl<$Res, StaffMember>;
  $Res call({
    String id,
    String tenantId,
    String userId,
    String name,
    String? email,
    String? phone,
    String status,
    String role,
    List<String> permissions,
    String? imageUrl,
    StaffSchedule? schedule,
    double commissionRate,
    int totalAppointments,
    double totalRevenueGenerated,
    DateTime? hiredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class ___$StaffMemberCopyWithImpl<$Res, $Val extends StaffMember>
    implements _$StaffMemberCopyWith<$Res> {
  ___$StaffMemberCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? userId = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? status = null,
    Object? role = null,
    Object? permissions = null,
    Object? imageUrl = freezed,
    Object? schedule = freezed,
    Object? commissionRate = null,
    Object? totalAppointments = null,
    Object? totalRevenueGenerated = null,
    Object? hiredAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      tenantId: null == tenantId ? _value.tenantId : tenantId as String,
      userId: null == userId ? _value.userId : userId as String,
      name: null == name ? _value.name : name as String,
      email: freezed == email ? _value.email : email as String?,
      phone: freezed == phone ? _value.phone : phone as String?,
      status: null == status ? _value.status : status as String,
      role: null == role ? _value.role : role as String,
      permissions: null == permissions ? _value.permissions : permissions as List<String>,
      imageUrl: freezed == imageUrl ? _value.imageUrl : imageUrl as String?,
      schedule: freezed == schedule ? _value.schedule : schedule as StaffSchedule?,
      commissionRate: null == commissionRate ? _value.commissionRate : commissionRate as double,
      totalAppointments: null == totalAppointments ? _value.totalAppointments : totalAppointments as int,
      totalRevenueGenerated: null == totalRevenueGenerated ? _value.totalRevenueGenerated : totalRevenueGenerated as double,
      hiredAt: freezed == hiredAt ? _value.hiredAt : hiredAt as DateTime?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ) as $Res);
  }
}

abstract class _$$StaffMemberCopyWith<$Res> implements _$StaffMemberCopyWith<$Res> {
  factory _$$StaffMemberCopyWith(_StaffMember value, $Res Function(_StaffMember) then) =
      __$$StaffMemberCopyWithImpl<$Res, _StaffMember>;
  @override
  $Res call({
    String id,
    String tenantId,
    String userId,
    String name,
    String? email,
    String? phone,
    String status,
    String role,
    List<String> permissions,
    String? imageUrl,
    StaffSchedule? schedule,
    double commissionRate,
    int totalAppointments,
    double totalRevenueGenerated,
    DateTime? hiredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class __$$StaffMemberCopyWithImpl<$Res, $Val extends _StaffMember>
    extends ___$StaffMemberCopyWithImpl<$Res, $Val>
    implements _$$StaffMemberCopyWith<$Res> {
  __$$StaffMemberCopyWithImpl(_StaffMember _value, $Res Function(_StaffMember) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? userId = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? status = null,
    Object? role = null,
    Object? permissions = null,
    Object? imageUrl = freezed,
    Object? schedule = freezed,
    Object? commissionRate = null,
    Object? totalAppointments = null,
    Object? totalRevenueGenerated = null,
    Object? hiredAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_StaffMember(
      id: null == id ? _value.id : id as String,
      tenantId: null == tenantId ? _value.tenantId : tenantId as String,
      userId: null == userId ? _value.userId : userId as String,
      name: null == name ? _value.name : name as String,
      email: freezed == email ? _value.email : email as String?,
      phone: freezed == phone ? _value.phone : phone as String?,
      status: null == status ? _value.status : status as String,
      role: null == role ? _value.role : role as String,
      permissions: null == permissions ? _value.permissions : permissions as List<String>,
      imageUrl: freezed == imageUrl ? _value.imageUrl : imageUrl as String?,
      schedule: freezed == schedule ? _value.schedule : schedule as StaffSchedule?,
      commissionRate: null == commissionRate ? _value.commissionRate : commissionRate as double,
      totalAppointments: null == totalAppointments ? _value.totalAppointments : totalAppointments as int,
      totalRevenueGenerated: null == totalRevenueGenerated ? _value.totalRevenueGenerated : totalRevenueGenerated as double,
      hiredAt: freezed == hiredAt ? _value.hiredAt : hiredAt as DateTime?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ));
  }
}

@JsonSerializable()
class _StaffMember implements StaffMember {
  const _StaffMember({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    @Default('active') this.status,
    @Default('attendant') this.role,
    @Default([]) this.permissions,
    this.imageUrl,
    this.schedule,
    @Default(0.0) this.commissionRate,
    @Default(0) this.totalAppointments,
    @Default(0) this.totalRevenueGenerated,
    this.hiredAt,
    this.createdAt,
    this.updatedAt,
  });

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  @Default('active')
  final String status;
  @override
  @Default('attendant')
  final String role;
  @override
  @Default([])
  final List<String> permissions;
  @override
  final String? imageUrl;
  @override
  final StaffSchedule? schedule;
  @override
  @Default(0.0)
  final double commissionRate;
  @override
  @Default(0)
  final int totalAppointments;
  @override
  @Default(0)
  final double totalRevenueGenerated;
  @override
  final DateTime? hiredAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'StaffMember(id: $id, tenantId: $tenantId, userId: $userId, name: $name, email: $email, phone: $phone, status: $status, role: $role, permissions: $permissions, imageUrl: $imageUrl, schedule: $schedule, commissionRate: $commissionRate, totalAppointments: $totalAppointments, totalRevenueGenerated: $totalRevenueGenerated, hiredAt: $hiredAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StaffMember &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) || other.tenantId == tenantId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.role, role) || other.role == role) &&
            const DeepCollectionEquality().equals(other.permissions, permissions) &&
            (identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl) &&
            (identical(other.schedule, schedule) || other.schedule == schedule) &&
            (identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate) &&
            (identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments) &&
            (identical(other.totalRevenueGenerated, totalRevenueGenerated) || other.totalRevenueGenerated == totalRevenueGenerated) &&
            (identical(other.hiredAt, hiredAt) || other.hiredAt == hiredAt) &&
            (identical(other.createdAt, createdAt) || other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      userId,
      name,
      email,
      phone,
      status,
      role,
      const DeepCollectionEquality().hash(permissions),
      imageUrl,
      schedule,
      commissionRate,
      totalAppointments,
      totalRevenueGenerated,
      hiredAt,
      createdAt,
      updatedAt);

  factory StaffMember.fromJson(Map<String, dynamic> json) => _$StaffMemberFromJson(json);
}

@JsonSerializable()
class _StaffSchedule implements StaffSchedule {
  const _StaffSchedule({
    @Default(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']) this.workingDays,
    this.startTime,
    this.endTime,
    @Default(false) this.hasFixedSchedule,
    this.customSchedule,
  });

  @override
  @Default(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'])
  final List<String> workingDays;
  @override
  final String? startTime;
  @override
  final String? endTime;
  @override
  @Default(false)
  final bool hasFixedSchedule;
  @override
  final Map<String, dynamic>? customSchedule;

  @override
  String toString() {
    return 'StaffSchedule(workingDays: $workingDays, startTime: $startTime, endTime: $endTime, hasFixedSchedule: $hasFixedSchedule, customSchedule: $customSchedule)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StaffSchedule &&
            (identical(other.workingDays, workingDays) ||
                const DeepCollectionEquality().equals(other.workingDays, workingDays)) &&
            (identical(other.startTime, startTime) || other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.hasFixedSchedule, hasFixedSchedule) ||
                other.hasFixedSchedule == hasFixedSchedule) &&
            (identical(other.customSchedule, customSchedule) ||
                other.customSchedule == customSchedule));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(workingDays),
      startTime,
      endTime,
      hasFixedSchedule,
      customSchedule);

  factory StaffSchedule.fromJson(Map<String, dynamic> json) => _$StaffScheduleFromJson(json);
}
