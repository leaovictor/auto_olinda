import 'package:cloud_firestore/cloud_firestore.dart';
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
    return ActorRole.values.firstWhere(
      (e) => e.name == json,
      orElse: () {
        // If it looks like a UID (long string), treat as system/client without warning
        if (json.length > 15) {
          return ActorRole.client;
        }
        print('⚠️ Warning: Invalid ActorRole "$json". Defaulting to "client".');
        return ActorRole.client;
      },
    );
  }

  @override
  String toJson(ActorRole object) => object.name;
}

/// Robust converter for DateTime that handles Firestore Timestamp objects
class RobustTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const RobustTimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();
    if (json is DateTime) return json;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json) ?? DateTime.now();
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    try {
      final dynamic timestamp = json;
      if (timestamp.toDate != null) {
        return (timestamp.toDate() as DateTime);
      }
    } catch (_) {}
    print('⚠️ Warning: Could not parse timestamp from $json');
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime object) => object.toIso8601String();
}

/// Nullable version
class RobustNullableTimestampConverter
    implements JsonConverter<DateTime?, dynamic> {
  const RobustNullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    return const RobustTimestampConverter().fromJson(json);
  }

  @override
  dynamic toJson(DateTime? object) => object?.toIso8601String();
}

@freezed
abstract class BookingLog with _$BookingLog {
  const factory BookingLog({
    required String message,
    @RobustTimestampConverter() required DateTime timestamp,
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
    @RobustTimestampConverter() required DateTime scheduledTime,
    @Default(BookingStatus.scheduled) BookingStatus status,
    String? staffNotes,
    @Default([]) List<String> beforePhotos,
    @Default([]) List<String> afterPhotos,
    @Default(false) bool isRated,
    int? rating,
    String? ratingComment,
    @Default([])
    List<String> selectedTags, // IDs das tags selecionadas na avaliação
    @RobustNullableTimestampConverter()
    DateTime? ratedAt, // Quando foi avaliado
    String? adminResponse, // Resposta do admin à avaliação
    @RobustNullableTimestampConverter()
    DateTime? adminResponseAt, // Quando o admin respondeu
    String? adminResponderId, // ID do admin que respondeu
    @Default([]) List<BookingLog> logs,
    // Cancellation info for easy access
    String? cancellationReason,
    @RobustActorRoleConverter()
    @Default(ActorRole.system)
    ActorRole cancelledBy,
    @RobustNullableTimestampConverter() DateTime? cancelledAt,
    // Penalty tracking (for late cancellations and no-shows)
    @Default(false) bool? penaltyApplied, // If true, consumes a credit
    @Default(false) bool? strikeApplied, // If true, triggers 24h block
    // Payment tracking
    @Default(BookingPaymentStatus.pending) BookingPaymentStatus paymentStatus,
    String? paymentMethod, // e.g., 'pix', 'card', 'cash'
    @RobustNullableTimestampConverter() DateTime? paidAt,
    String? paidByStaffId, // Staff who confirmed payment
    @RobustNullableTimestampConverter()
    DateTime? createdAt, // Creation timestamp
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
