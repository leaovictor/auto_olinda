import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_booking.freezed.dart';
part 'service_booking.g.dart';

/// Status enum for independent service bookings
enum ServiceBookingStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('finished')
  finished,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('no_show')
  noShow,
}

/// Model for an independent service booking
/// Separate from car wash bookings with their own lifecycle
@freezed
abstract class ServiceBooking with _$ServiceBooking {
  const factory ServiceBooking({
    required String id,
    required String userId,
    required String serviceId,
    required DateTime scheduledTime,
    required double totalPrice,
    @Default(ServiceBookingStatus.scheduled) ServiceBookingStatus status,
    String? vehicleId, // Optional, depends on requiresVehicle
    String? notes,
    String? userName, // Denormalized for easy display
    String? userPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ServiceBooking;

  factory ServiceBooking.fromJson(Map<String, dynamic> json) =>
      _$ServiceBookingFromJson(json);
}
