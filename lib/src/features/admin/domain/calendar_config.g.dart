// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => _TimeSlot(
  time: json['time'] as String,
  capacity: (json['capacity'] as num).toInt(),
  isBlocked: json['isBlocked'] as bool? ?? false,
  allowedCategories:
      (json['allowedCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$TimeSlotToJson(_TimeSlot instance) => <String, dynamic>{
  'time': instance.time,
  'capacity': instance.capacity,
  'isBlocked': instance.isBlocked,
  'allowedCategories': instance.allowedCategories,
};

_WeeklySchedule _$WeeklyScheduleFromJson(Map<String, dynamic> json) =>
    _WeeklySchedule(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      isOpen: json['isOpen'] as bool,
      startHour: (json['startHour'] as num).toInt(),
      endHour: (json['endHour'] as num).toInt(),
      capacityPerHour: (json['capacityPerHour'] as num?)?.toInt() ?? 0,
      slots:
          (json['slots'] as List<dynamic>?)
              ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WeeklyScheduleToJson(_WeeklySchedule instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'isOpen': instance.isOpen,
      'startHour': instance.startHour,
      'endHour': instance.endHour,
      'capacityPerHour': instance.capacityPerHour,
      'slots': instance.slots.map((e) => e.toJson()).toList(),
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
