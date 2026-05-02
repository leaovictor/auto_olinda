import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_member.freezed.dart';
part 'staff_member.g.dart';

@freezed
abstract class StaffMember with _$StaffMember {
  const factory StaffMember({
    required String id,
    required String tenantId,
    required String userId, // Firebase UID
    required String name,
    String? email,
    String? phone,
    @Default('active') String status, // active | inactive | on_leave
    @Default('attendant') String role, // admin | manager | attendant
    @Default([]) List<String> permissions,
    String? imageUrl,
    StaffSchedule? schedule,
    @Default(0.0) double commissionRate,
    @Default(0) int totalAppointments,
    @Default(0) double totalRevenueGenerated,
    DateTime? hiredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _StaffMember;

  factory StaffMember.fromJson(Map<String, dynamic> json) => _$StaffMemberFromJson(json);
}

@freezed
abstract class StaffSchedule with _$StaffSchedule {
  const factory StaffSchedule({
    @Default(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']) List<String> workingDays,
    String? startTime, // "09:00"
    String? endTime,   // "18:00"
    @Default(false) bool hasFixedSchedule,
    Map<String, dynamic>? customSchedule, // { "monday": ["09:00-12:00", "14:00-18:00"] }
  }) = _StaffSchedule;
}
