import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'appointment_enums.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

class RobustTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const RobustTimestampConverter();
  @override DateTime fromJson(dynamic json) => json is Timestamp ? json.toDate() : DateTime.parse(json.toString());
  @override dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}
class RobustNullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const RobustNullableTimestampConverter();
  @override DateTime? fromJson(dynamic json) => json == null ? null : (json is Timestamp ? json.toDate() : DateTime.parse(json.toString()));
  @override dynamic toJson(DateTime? date) => date == null ? null : Timestamp.fromDate(date);
}

@freezed
abstract class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String tenantId,
    required String customerId,
    String? customerName, // Denormalized for quick display
    String? vehiclePlate, // Denormalized
    String? vehicleModel,
    
    // Staff Assignment
    String? staffId,
    String? staffName, // Denormalized
    
    // Services
    required List<String> serviceIds,
    @Default([]) List<ServiceDetail> serviceDetails, // Denormalized snapshot
    
    // Timing
    @RobustTimestampConverter() required DateTime scheduledAt,
    int? actualStartAt,
    int? actualEndAt,
    @Default(30) int estimatedDurationMinutes,
    
    // Status & Payment
    @Default(AppointmentStatus.scheduled) AppointmentStatus status,
    @Default(AppointmentPaymentStatus.pending) AppointmentPaymentStatus paymentStatus,
    
    // Pricing
    @Default(0.0) double subtotal,
    @Default(0.0) double discount,
    @Default(0.0) double tax,
    @Default(0.0) double total,
    String? currency,
    
    // Payment links/intents
    String? paymentIntentId,
    String? paymentLinkId, // For customer to pay
    
    // Subscription linkage
    String? subscriptionId,
    bool? usedSubscriptionCredits,
    
    // Media
    @Default([]) List<String> beforePhotos,
    @Default([]) List<String> afterPhotos,
    
    // Notes
    String? customerNotes,
    String? staffNotes,
    String? cancellationReason,
    
    // Check-in
    @RobustNullableTimestampConverter() DateTime? checkedInAt,
    @RobustNullableTimestampConverter() DateTime? startedAt,
    @RobustNullableTimestampConverter() DateTime? completedAt,
    
    // Audit
    @RobustNullableTimestampConverter() DateTime? createdAt,
    @RobustNullableTimestampConverter() DateTime? updatedAt,
    String? createdBy, // staffId or customer userId
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
}

@freezed
abstract class ServiceDetail with _$ServiceDetail {
  const factory ServiceDetail({
    required String serviceId,
    required String name,
    required double price,
    required int durationMinutes,
  }) = _ServiceDetail;

  factory ServiceDetail.fromJson(Map<String, dynamic> json) =>
      _$ServiceDetailFromJson(json);
}
