// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StaffMember _$StaffMemberFromJson(Map<String, dynamic> json) => _StaffMember(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  photoUrl: json['photoUrl'] as String?,
  role: json['role'] as String? ?? 'staff',
  status: json['status'] as String? ?? 'active',
  phoneNumber: json['phoneNumber'] as String?,
  totalBookingsToday: (json['totalBookingsToday'] as num?)?.toInt() ?? 0,
  totalBookingsMonth: (json['totalBookingsMonth'] as num?)?.toInt() ?? 0,
  revenueToday: (json['revenueToday'] as num?)?.toDouble() ?? 0.0,
  revenueMonth: (json['revenueMonth'] as num?)?.toDouble() ?? 0.0,
  avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
  totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
  shiftStart: json['shiftStart'] == null
      ? null
      : DateTime.parse(json['shiftStart'] as String),
  shiftEnd: json['shiftEnd'] == null
      ? null
      : DateTime.parse(json['shiftEnd'] as String),
  isOnShift: json['isOnShift'] as bool? ?? false,
  lastActiveAt: json['lastActiveAt'] == null
      ? null
      : DateTime.parse(json['lastActiveAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$StaffMemberToJson(_StaffMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'role': instance.role,
      'status': instance.status,
      'phoneNumber': instance.phoneNumber,
      'totalBookingsToday': instance.totalBookingsToday,
      'totalBookingsMonth': instance.totalBookingsMonth,
      'revenueToday': instance.revenueToday,
      'revenueMonth': instance.revenueMonth,
      'avgRating': instance.avgRating,
      'totalRatings': instance.totalRatings,
      'shiftStart': instance.shiftStart?.toIso8601String(),
      'shiftEnd': instance.shiftEnd?.toIso8601String(),
      'isOnShift': instance.isOnShift,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_StaffShift _$StaffShiftFromJson(Map<String, dynamic> json) => _StaffShift(
  id: json['id'] as String,
  staffId: json['staffId'] as String,
  staffName: json['staffName'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  isActive: json['isActive'] as bool? ?? false,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$StaffShiftToJson(_StaffShift instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staffId': instance.staffId,
      'staffName': instance.staffName,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'isActive': instance.isActive,
      'notes': instance.notes,
    };

_StaffPerformance _$StaffPerformanceFromJson(Map<String, dynamic> json) =>
    _StaffPerformance(
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      totalBookings: (json['totalBookings'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      avgRating: (json['avgRating'] as num).toDouble(),
      totalRatings: (json['totalRatings'] as num).toInt(),
      dailyStats:
          (json['dailyStats'] as List<dynamic>?)
              ?.map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StaffPerformanceToJson(_StaffPerformance instance) =>
    <String, dynamic>{
      'staffId': instance.staffId,
      'staffName': instance.staffName,
      'totalBookings': instance.totalBookings,
      'totalRevenue': instance.totalRevenue,
      'avgRating': instance.avgRating,
      'totalRatings': instance.totalRatings,
      'dailyStats': instance.dailyStats.map((e) => e.toJson()).toList(),
    };

_DailyStats _$DailyStatsFromJson(Map<String, dynamic> json) => _DailyStats(
  date: DateTime.parse(json['date'] as String),
  bookings: (json['bookings'] as num).toInt(),
  revenue: (json['revenue'] as num).toDouble(),
);

Map<String, dynamic> _$DailyStatsToJson(_DailyStats instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'bookings': instance.bookings,
      'revenue': instance.revenue,
    };
