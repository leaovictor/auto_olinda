import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_config.freezed.dart';
part 'calendar_config.g.dart';

@freezed
abstract class WeeklySchedule with _$WeeklySchedule {
  const factory WeeklySchedule({
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required bool isOpen,
    required int startHour, // 0-23
    required int endHour, // 0-23
    required int capacityPerHour,
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
