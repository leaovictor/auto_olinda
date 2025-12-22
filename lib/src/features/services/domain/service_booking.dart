import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_booking.freezed.dart';
part 'service_booking.g.dart';

/// Status enum for independent service bookings
enum ServiceBookingStatus {
  @JsonValue('pending_approval')
  pendingApproval,
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
  @JsonValue('rejected')
  rejected,
  @JsonValue('no_show')
  noShow,
}

/// Payment status enum for independent service bookings
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('partial')
  partial,
  @JsonValue('refunded')
  refunded,
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
    @Default(ServiceBookingStatus.pendingApproval) ServiceBookingStatus status,
    @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
    @Default(0.0) double paidAmount, // Amount paid so far
    String? vehicleId, // Optional, depends on requiresVehicle
    String? vehiclePlate, // Denormalized for easy display
    String? vehicleModel, // Denormalized for easy display
    String? notes,
    String? userName, // Denormalized for easy display
    String? userPhone,
    String? rejectionReason, // Reason for rejection by admin
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ServiceBooking;

  factory ServiceBooking.fromJson(Map<String, dynamic> json) =>
      _$ServiceBookingFromJson(json);
}
