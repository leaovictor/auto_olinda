import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_settings.freezed.dart';
part 'admin_settings.g.dart';

/// Admin system settings model
@freezed
abstract class AdminSettings with _$AdminSettings {
  const factory AdminSettings({
    // Business Hours
    @Default(8) int openingHour,
    @Default(0) int openingMinute,
    @Default(18) int closingHour,
    @Default(0) int closingMinute,

    // Booking Settings
    @Default(60) int bookingSlotDurationMinutes,
    @Default(3) int maxBookingsPerSlot,
    @Default(false) bool autoConfirmBookings,

    // Notification Preferences
    @Default(true) bool pushNotificationsEnabled,
    @Default(true) bool emailNotificationsEnabled,

    // Holidays (list of date strings in yyyy-MM-dd format)
    @Default([]) List<String> holidays,

    // Payment Settings
    @Default('stripe') String paymentProvider,
    @Default(true) bool allowCardPayments,
    @Default(true) bool allowPixPayments,
  }) = _AdminSettings;

  factory AdminSettings.fromJson(Map<String, dynamic> json) =>
      _$AdminSettingsFromJson(json);
}
