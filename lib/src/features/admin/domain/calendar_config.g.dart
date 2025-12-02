// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeeklySchedule _$WeeklyScheduleFromJson(Map<String, dynamic> json) =>
    _WeeklySchedule(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      isOpen: json['isOpen'] as bool,
      startHour: (json['startHour'] as num).toInt(),
      endHour: (json['endHour'] as num).toInt(),
      capacityPerHour: (json['capacityPerHour'] as num).toInt(),
    );

Map<String, dynamic> _$WeeklyScheduleToJson(_WeeklySchedule instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'isOpen': instance.isOpen,
      'startHour': instance.startHour,
      'endHour': instance.endHour,
      'capacityPerHour': instance.capacityPerHour,
    };

_BlockedDate _$BlockedDateFromJson(Map<String, dynamic> json) => _BlockedDate(
  date: DateTime.parse(json['date'] as String),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$BlockedDateToJson(_BlockedDate instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'reason': instance.reason,
    };
