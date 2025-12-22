// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminEvent _$AdminEventFromJson(Map<String, dynamic> json) => _AdminEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  date: DateTime.parse(json['date'] as String),
  remindAt: json['remindAt'] == null
      ? null
      : DateTime.parse(json['remindAt'] as String),
  type:
      $enumDecodeNullable(_$AdminEventTypeEnumMap, json['type']) ??
      AdminEventType.task,
  isDone: json['isDone'] as bool? ?? false,
  companyId: json['companyId'] as String?,
);

Map<String, dynamic> _$AdminEventToJson(_AdminEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'remindAt': instance.remindAt?.toIso8601String(),
      'type': _$AdminEventTypeEnumMap[instance.type]!,
      'isDone': instance.isDone,
      'companyId': instance.companyId,
    };

const _$AdminEventTypeEnumMap = {
  AdminEventType.task: 'task',
  AdminEventType.payment: 'payment',
  AdminEventType.meeting: 'meeting',
  AdminEventType.other: 'other',
};
