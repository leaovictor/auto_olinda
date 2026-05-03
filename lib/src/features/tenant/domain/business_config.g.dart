// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BusinessConfig _$BusinessConfigFromJson(Map<String, dynamic> json) =>
    _BusinessConfig(
      openTime: json['openTime'] as String? ?? '08:00',
      closeTime: json['closeTime'] as String? ?? '18:00',
      slotDurationMinutes: (json['slotDurationMinutes'] as num?)?.toInt() ?? 30,
      bufferMinutes: (json['bufferMinutes'] as num?)?.toInt() ?? 0,
      allowOnlineBooking: json['allowOnlineBooking'] as bool? ?? true,
      acceptsWalkIns: json['acceptsWalkIns'] as bool? ?? true,
      defaultPaymentMethod: json['defaultPaymentMethod'] as String? ?? 'pix',
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
      timezone: json['timezone'] as String?,
      maxCarsPerSlot: (json['maxCarsPerSlot'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$BusinessConfigToJson(_BusinessConfig instance) =>
    <String, dynamic>{
      'openTime': instance.openTime,
      'closeTime': instance.closeTime,
      'slotDurationMinutes': instance.slotDurationMinutes,
      'bufferMinutes': instance.bufferMinutes,
      'allowOnlineBooking': instance.allowOnlineBooking,
      'acceptsWalkIns': instance.acceptsWalkIns,
      'defaultPaymentMethod': instance.defaultPaymentMethod,
      'workingDays': instance.workingDays,
      'timezone': instance.timezone,
      'maxCarsPerSlot': instance.maxCarsPerSlot,
    };
