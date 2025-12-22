import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/domain/app_user.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/service_package.dart';
import '../../profile/domain/vehicle.dart';
import '../../services/domain/service_booking.dart';
import '../../services/domain/independent_service.dart';

part 'new_booking_notification_data.freezed.dart';

/// Enum to distinguish between car wash and aesthetic service bookings
enum NewBookingType { carWash, aesthetic }

/// Data class containing all necessary information for displaying
/// a premium new booking notification
@freezed
abstract class NewBookingNotificationData with _$NewBookingNotificationData {
  const factory NewBookingNotificationData({
    required String bookingId,
    required NewBookingType type,
    required DateTime scheduledTime,
    required double totalPrice,
    required DateTime createdAt,

    // Client info
    String? clientName,
    String? clientPhone,
    String? clientPhotoUrl,

    // Vehicle info (for car wash or aesthetic that requires vehicle)
    String? vehiclePlate,
    String? vehicleModel,
    String? vehicleBrand,

    // Service info
    String? serviceName,
    @Default([])
    List<String> serviceNames, // For car wash with multiple services
  }) = _NewBookingNotificationData;

  /// Create from car wash booking with details
  factory NewBookingNotificationData.fromCarWash({
    required Booking booking,
    AppUser? user,
    Vehicle? vehicle,
    List<ServicePackage> services = const [],
  }) {
    return NewBookingNotificationData(
      bookingId: booking.id,
      type: NewBookingType.carWash,
      scheduledTime: booking.scheduledTime,
      totalPrice: booking.totalPrice,
      createdAt: DateTime.now(),
      clientName: user?.displayName,
      clientPhone: user?.phoneNumber,
      clientPhotoUrl: user?.photoUrl,
      vehiclePlate: vehicle?.plate,
      vehicleModel: vehicle?.model,
      vehicleBrand: vehicle?.brand,
      serviceNames: services.map((s) => s.title).toList(),
    );
  }

  /// Create from aesthetic service booking
  factory NewBookingNotificationData.fromAesthetic({
    required ServiceBooking booking,
    IndependentService? service,
  }) {
    return NewBookingNotificationData(
      bookingId: booking.id,
      type: NewBookingType.aesthetic,
      scheduledTime: booking.scheduledTime,
      totalPrice: booking.totalPrice,
      createdAt: booking.createdAt ?? DateTime.now(),
      clientName: booking.userName,
      clientPhone: booking.userPhone,
      vehiclePlate: booking.vehiclePlate,
      vehicleModel: booking.vehicleModel,
      serviceName: service?.title,
    );
  }
}
