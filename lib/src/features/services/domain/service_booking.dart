import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_booking.freezed.dart';
part 'service_booking.g.dart';

/// Custom converter that handles both camelCase and snake_case status values
/// for backwards compatibility with existing Firestore data
class ServiceBookingStatusConverter
    implements JsonConverter<ServiceBookingStatus, String> {
  const ServiceBookingStatusConverter();

  static const _snakeCaseToEnum = {
    'pending_approval': ServiceBookingStatus.pendingApproval,
    'scheduled': ServiceBookingStatus.scheduled,
    'confirmed': ServiceBookingStatus.confirmed,
    'in_progress': ServiceBookingStatus.inProgress,
    'finished': ServiceBookingStatus.finished,
    'cancelled': ServiceBookingStatus.cancelled,
    'rejected': ServiceBookingStatus.rejected,
    'no_show': ServiceBookingStatus.noShow,
  };

  // Legacy camelCase mappings for backwards compatibility
  static const _camelCaseToEnum = {
    'pendingApproval': ServiceBookingStatus.pendingApproval,
    'inProgress': ServiceBookingStatus.inProgress,
    'noShow': ServiceBookingStatus.noShow,
  };

  @override
  ServiceBookingStatus fromJson(String json) {
    // First try snake_case (correct format)
    if (_snakeCaseToEnum.containsKey(json)) {
      return _snakeCaseToEnum[json]!;
    }
    // Fallback to camelCase (legacy format)
    if (_camelCaseToEnum.containsKey(json)) {
      return _camelCaseToEnum[json]!;
    }
    // Default fallback
    return ServiceBookingStatus.pendingApproval;
  }

  @override
  String toJson(ServiceBookingStatus object) {
    // Always write in snake_case (correct format)
    return _snakeCaseToEnum.entries.firstWhere((e) => e.value == object).key;
  }
}

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
    @Default(ServiceBookingStatus.pendingApproval)
    @ServiceBookingStatusConverter()
    ServiceBookingStatus status,
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
