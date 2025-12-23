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

/// Role of the actor who performed an action
enum ActorRole {
  client, // Cliente que fez o agendamento
  admin, // Administrador do lava-jato
  staff, // Funcionário
  system, // Sistema automático
}

@freezed
abstract class BookingLog with _$BookingLog {
  const factory BookingLog({
    required String message,
    required DateTime timestamp,
    required String actorId, // User ID who performed the action
    required BookingStatus status,
    @Default(ActorRole.system)
    ActorRole actorRole, // Role: client, admin, staff, system
    String? actorName, // Display name for audit trail
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
    @Default([])
    List<String> productIds, // Additional products (paid even for subscribers)
    required double totalPrice,
    required DateTime scheduledTime,
    @Default(BookingStatus.scheduled) BookingStatus status,
    String? staffNotes,
    @Default([]) List<String> beforePhotos,
    @Default([]) List<String> afterPhotos,
    @Default(false) bool isRated,
    int? rating,
    String? ratingComment,
    @Default([]) List<BookingLog> logs,
    // Cancellation info for easy access
    String? cancellationReason,
    @Default(ActorRole.system) ActorRole cancelledBy,
    DateTime? cancelledAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
