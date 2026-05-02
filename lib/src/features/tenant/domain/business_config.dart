import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_config.freezed.dart';
part 'business_config.g.dart';

@freezed
abstract class BusinessConfig with _$BusinessConfig {
  const factory BusinessConfig({
    @Default('08:00') String openTime,          // Opening hour (HH:mm)
    @Default('18:00') String closeTime,         // Closing hour (HH:mm)
    @Default(30) int slotDurationMinutes,       // Duration per appointment slot
    @Default(0) int bufferMinutes,              // Buffer between appointments
    @Default(true) bool allowOnlineBooking,     // Accept online bookings?
    @Default(true) bool acceptsWalkIns,         // Walk-in customers?
    @Default('pix') String defaultPaymentMethod, // pix | cash | card
    @Default(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']) List<String> workingDays,
    String? timezone,                            // e.g., "America/Sao_Paulo"
    @Default(1) int maxCarsPerSlot,              // Concurrent cars per slot
  }) = _BusinessConfig;

  factory BusinessConfig.fromJson(Map<String, dynamic> json) => _$BusinessConfigFromJson(json);
}