import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_member.freezed.dart';
part 'staff_member.g.dart';

/// Represents a staff member with their performance metrics
@freezed
abstract class StaffMember with _$StaffMember {
  const factory StaffMember({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
    @Default('staff') String role,
    @Default('active') String status,
    String? phoneNumber,
    // Performance metrics
    @Default(0) int totalBookingsToday,
    @Default(0) int totalBookingsMonth,
    @Default(0.0) double revenueToday,
    @Default(0.0) double revenueMonth,
    @Default(0.0) double avgRating,
    @Default(0) int totalRatings,
    // Shift info
    DateTime? shiftStart,
    DateTime? shiftEnd,
    @Default(false) bool isOnShift,
    // Timestamps
    DateTime? lastActiveAt,
    DateTime? createdAt,
  }) = _StaffMember;

  factory StaffMember.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberFromJson(json);
}

/// Represents a work shift for a staff member
@freezed
abstract class StaffShift with _$StaffShift {
  const factory StaffShift({
    required String id,
    required String staffId,
    required String staffName,
    required DateTime startTime,
    required DateTime endTime,
    @Default(false) bool isActive,
    String? notes,
  }) = _StaffShift;

  factory StaffShift.fromJson(Map<String, dynamic> json) =>
      _$StaffShiftFromJson(json);
}

/// Staff performance stats for a given period
@freezed
abstract class StaffPerformance with _$StaffPerformance {
  const factory StaffPerformance({
    required String staffId,
    required String staffName,
    required int totalBookings,
    required double totalRevenue,
    required double avgRating,
    required int totalRatings,
    // Daily breakdown (last 7 days)
    @Default([]) List<DailyStats> dailyStats,
  }) = _StaffPerformance;

  factory StaffPerformance.fromJson(Map<String, dynamic> json) =>
      _$StaffPerformanceFromJson(json);
}

/// Daily stats for performance tracking
@freezed
abstract class DailyStats with _$DailyStats {
  const factory DailyStats({
    required DateTime date,
    required int bookings,
    required double revenue,
  }) = _DailyStats;

  factory DailyStats.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsFromJson(json);
}
