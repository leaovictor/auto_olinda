import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum BookingStatus {
  scheduled, // AGENDADO
  confirmed, // CONFIRMADO
  checkIn, // CHECK IN
  washing, // LAVANDO
  vacuuming, // ASPIRANDO
  drying, // SECANDO
  polishing, // EM POLIMENTO
  finished, // FINALIZADO
  cancelled, // CANCELADO
  noShow, // NAO COMPARECEU
}

@freezed
abstract class BookingLog with _$BookingLog {
  const factory BookingLog({
    required String message,
    required DateTime timestamp,
    required String actorId, // User ID who performed the action
    required BookingStatus status,
  }) = _BookingLog;

  factory BookingLog.fromJson(Map<String, dynamic> json) =>
      _$BookingLogFromJson(json);
}

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String userId,
    required String vehicleId,
    required List<String> serviceIds,
    required double totalPrice,
    required DateTime scheduledTime,
    @Default(BookingStatus.scheduled) BookingStatus status,
    String? staffNotes,
    @Default([]) List<String> beforePhotos,
    @Default([]) List<String> afterPhotos,
    @Default([]) List<BookingLog> logs,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
