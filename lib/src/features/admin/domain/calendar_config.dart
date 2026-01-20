import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_config.freezed.dart';
part 'calendar_config.g.dart';

@freezed
abstract class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    required String time, // "08:00"
    required int capacity,
    @Default(false) bool isBlocked,
    @Default([]) List<String> allowedCategories, // If empty, all allowed
  }) = _TimeSlot;

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);
}

@freezed
abstract class WeeklySchedule with _$WeeklySchedule {
  const factory WeeklySchedule({
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required bool isOpen,
    required int startHour, // 0-23
    required int endHour, // 0-23
    @Deprecated('Use slots instead') @Default(0) int capacityPerHour,
    @Default([]) List<TimeSlot> slots,
  }) = _WeeklySchedule;

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) =>
      _$WeeklyScheduleFromJson(json);
}

@freezed
abstract class BlockedDate with _$BlockedDate {
  const factory BlockedDate({required DateTime date, String? reason}) =
      _BlockedDate;

  factory BlockedDate.fromJson(Map<String, dynamic> json) =>
      _$BlockedDateFromJson(json);
}
