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

/// Payment status for bookings
enum BookingPaymentStatus {
  pending, // Aguardando pagamento
  paid, // Pago
  subscription, // Coberto por assinatura
  cash, // Pago em dinheiro (staff confirmou)
  pix, // Pago via PIX
}

class RobustActorRoleConverter implements JsonConverter<ActorRole, String> {
  const RobustActorRoleConverter();

  @override
  ActorRole fromJson(String json) {
    // Check if it's a valid enum value
    return ActorRole.values.firstWhere(
      (e) => e.name == json,
      orElse: () {
        // Fallback for known issues:
        // If it looks like a UID (length > 20), assume it's a client or system based on context?
        // Actually, safe bet is 'client' if we don't know, or 'system'.
        // But likely most corrupted data comes from clients cancelling.
        print('⚠️ Warning: Invalid ActorRole "$json". Defaulting to "client".');
        return ActorRole.client;
      },
    );
  }

  @override
  String toJson(ActorRole object) => object.name;
}

@freezed
abstract class BookingLog with _$BookingLog {
  const factory BookingLog({
    required String message,
    required DateTime timestamp,
    required String actorId, // User ID who performed the action
    required BookingStatus status,
    @RobustActorRoleConverter()
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
    @RobustActorRoleConverter()
    @Default(ActorRole.system)
    ActorRole cancelledBy,
    DateTime? cancelledAt,
    // Payment tracking
    @Default(BookingPaymentStatus.pending) BookingPaymentStatus paymentStatus,
    String? paymentMethod, // e.g., 'pix', 'card', 'cash'
    DateTime? paidAt,
    String? paidByStaffId, // Staff who confirmed payment
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
