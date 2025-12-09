// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminSettings _$AdminSettingsFromJson(
  Map<String, dynamic> json,
) => _AdminSettings(
  openingHour: (json['openingHour'] as num?)?.toInt() ?? 8,
  openingMinute: (json['openingMinute'] as num?)?.toInt() ?? 0,
  closingHour: (json['closingHour'] as num?)?.toInt() ?? 18,
  closingMinute: (json['closingMinute'] as num?)?.toInt() ?? 0,
  bookingSlotDurationMinutes:
      (json['bookingSlotDurationMinutes'] as num?)?.toInt() ?? 60,
  maxBookingsPerSlot: (json['maxBookingsPerSlot'] as num?)?.toInt() ?? 3,
  autoConfirmBookings: json['autoConfirmBookings'] as bool? ?? false,
  pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
  emailNotificationsEnabled: json['emailNotificationsEnabled'] as bool? ?? true,
  holidays:
      (json['holidays'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  paymentProvider: json['paymentProvider'] as String? ?? 'stripe',
  allowCardPayments: json['allowCardPayments'] as bool? ?? true,
  allowPixPayments: json['allowPixPayments'] as bool? ?? true,
);

Map<String, dynamic> _$AdminSettingsToJson(_AdminSettings instance) =>
    <String, dynamic>{
      'openingHour': instance.openingHour,
      'openingMinute': instance.openingMinute,
      'closingHour': instance.closingHour,
      'closingMinute': instance.closingMinute,
      'bookingSlotDurationMinutes': instance.bookingSlotDurationMinutes,
      'maxBookingsPerSlot': instance.maxBookingsPerSlot,
      'autoConfirmBookings': instance.autoConfirmBookings,
      'pushNotificationsEnabled': instance.pushNotificationsEnabled,
      'emailNotificationsEnabled': instance.emailNotificationsEnabled,
      'holidays': instance.holidays,
      'paymentProvider': instance.paymentProvider,
      'allowCardPayments': instance.allowCardPayments,
      'allowPixPayments': instance.allowPixPayments,
    };
