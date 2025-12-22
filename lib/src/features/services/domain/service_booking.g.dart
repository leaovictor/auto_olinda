// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceBooking _$ServiceBookingFromJson(Map<String, dynamic> json) =>
    _ServiceBooking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      serviceId: json['serviceId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status:
          $enumDecodeNullable(_$ServiceBookingStatusEnumMap, json['status']) ??
          ServiceBookingStatus.pendingApproval,
      paymentStatus:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['paymentStatus']) ??
          PaymentStatus.pending,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      vehicleId: json['vehicleId'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      notes: json['notes'] as String?,
      userName: json['userName'] as String?,
      userPhone: json['userPhone'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ServiceBookingToJson(_ServiceBooking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'serviceId': instance.serviceId,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'totalPrice': instance.totalPrice,
      'status': _$ServiceBookingStatusEnumMap[instance.status]!,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'paidAmount': instance.paidAmount,
      'vehicleId': instance.vehicleId,
      'vehiclePlate': instance.vehiclePlate,
      'vehicleModel': instance.vehicleModel,
      'notes': instance.notes,
      'userName': instance.userName,
      'userPhone': instance.userPhone,
      'rejectionReason': instance.rejectionReason,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ServiceBookingStatusEnumMap = {
  ServiceBookingStatus.pendingApproval: 'pending_approval',
  ServiceBookingStatus.scheduled: 'scheduled',
  ServiceBookingStatus.confirmed: 'confirmed',
  ServiceBookingStatus.inProgress: 'in_progress',
  ServiceBookingStatus.finished: 'finished',
  ServiceBookingStatus.cancelled: 'cancelled',
  ServiceBookingStatus.rejected: 'rejected',
  ServiceBookingStatus.noShow: 'no_show',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.partial: 'partial',
  PaymentStatus.refunded: 'refunded',
};
