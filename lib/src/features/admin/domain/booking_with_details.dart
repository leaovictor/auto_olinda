import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/domain/app_user.dart';
import '../../booking/domain/booking.dart';
import '../../profile/domain/vehicle.dart';

part 'booking_with_details.freezed.dart';

@freezed
abstract class BookingWithDetails with _$BookingWithDetails {
  const factory BookingWithDetails({
    required Booking booking,
    AppUser? user,
    Vehicle? vehicle,
  }) = _BookingWithDetails;
}
