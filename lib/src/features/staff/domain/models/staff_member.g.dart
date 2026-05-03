// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StaffMember _$StaffMemberFromJson(Map<String, dynamic> json) => _StaffMember(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  status: json['status'] as String? ?? 'active',
  role: json['role'] as String? ?? 'attendant',
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  imageUrl: json['imageUrl'] as String?,
  schedule: json['schedule'] == null
      ? null
      : StaffSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
  commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.0,
  totalAppointments: (json['totalAppointments'] as num?)?.toInt() ?? 0,
  totalRevenueGenerated:
      (json['totalRevenueGenerated'] as num?)?.toDouble() ?? 0,
  hiredAt: json['hiredAt'] == null
      ? null
      : DateTime.parse(json['hiredAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StaffMemberToJson(_StaffMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'status': instance.status,
      'role': instance.role,
      'permissions': instance.permissions,
      'imageUrl': instance.imageUrl,
      'schedule': instance.schedule?.toJson(),
      'commissionRate': instance.commissionRate,
      'totalAppointments': instance.totalAppointments,
      'totalRevenueGenerated': instance.totalRevenueGenerated,
      'hiredAt': instance.hiredAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_StaffSchedule _$StaffScheduleFromJson(Map<String, dynamic> json) =>
    _StaffSchedule(
      workingDays:
          (json['workingDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
          ],
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      hasFixedSchedule: json['hasFixedSchedule'] as bool? ?? false,
      customSchedule: json['customSchedule'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$StaffScheduleToJson(_StaffSchedule instance) =>
    <String, dynamic>{
      'workingDays': instance.workingDays,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'hasFixedSchedule': instance.hasFixedSchedule,
      'customSchedule': instance.customSchedule,
    };
