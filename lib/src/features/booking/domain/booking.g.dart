// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingLog _$BookingLogFromJson(Map<String, dynamic> json) => _BookingLog(
  message: json['message'] as String,
  timestamp: const RobustTimestampConverter().fromJson(json['timestamp']),
  actorId: json['actorId'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  actorRole: json['actorRole'] == null
      ? ActorRole.system
      : const RobustActorRoleConverter().fromJson(json['actorRole'] as String),
  actorName: json['actorName'] as String?,
);

Map<String, dynamic> _$BookingLogToJson(_BookingLog instance) =>
    <String, dynamic>{
      'message': instance.message,
      'timestamp': const RobustTimestampConverter().toJson(instance.timestamp),
      'actorId': instance.actorId,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'actorRole': const RobustActorRoleConverter().toJson(instance.actorRole),
      'actorName': instance.actorName,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.scheduled: 'scheduled',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.checkIn: 'checkIn',
  BookingStatus.washing: 'washing',
  BookingStatus.vacuuming: 'vacuuming',
  BookingStatus.drying: 'drying',
  BookingStatus.polishing: 'polishing',
  BookingStatus.finished: 'finished',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.noShow: 'noShow',
};

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  userId: json['userId'] as String,
  vehicleId: json['vehicleId'] as String,
  serviceIds: (json['serviceIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  productIds:
      (json['productIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  totalPrice: (json['totalPrice'] as num).toDouble(),
  scheduledTime: const RobustTimestampConverter().fromJson(
    json['scheduledTime'],
  ),
  status:
      $enumDecodeNullable(_$BookingStatusEnumMap, json['status']) ??
      BookingStatus.scheduled,
  staffNotes: json['staffNotes'] as String?,
  beforePhotos:
      (json['beforePhotos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  afterPhotos:
      (json['afterPhotos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isRated: json['isRated'] as bool? ?? false,
  rating: (json['rating'] as num?)?.toInt(),
  ratingComment: json['ratingComment'] as String?,
  selectedTags:
      (json['selectedTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  ratedAt: const RobustNullableTimestampConverter().fromJson(json['ratedAt']),
  adminResponse: json['adminResponse'] as String?,
  adminResponseAt: const RobustNullableTimestampConverter().fromJson(
    json['adminResponseAt'],
  ),
  adminResponderId: json['adminResponderId'] as String?,
  logs:
      (json['logs'] as List<dynamic>?)
          ?.map((e) => BookingLog.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  cancellationReason: json['cancellationReason'] as String?,
  cancelledBy: json['cancelledBy'] == null
      ? ActorRole.system
      : const RobustActorRoleConverter().fromJson(
          json['cancelledBy'] as String,
        ),
  cancelledAt: const RobustNullableTimestampConverter().fromJson(
    json['cancelledAt'],
  ),
  paymentStatus:
      $enumDecodeNullable(
        _$BookingPaymentStatusEnumMap,
        json['paymentStatus'],
      ) ??
      BookingPaymentStatus.pending,
  paymentMethod: json['paymentMethod'] as String?,
  paidAt: const RobustNullableTimestampConverter().fromJson(json['paidAt']),
  paidByStaffId: json['paidByStaffId'] as String?,
  createdAt: const RobustNullableTimestampConverter().fromJson(
    json['createdAt'],
  ),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'vehicleId': instance.vehicleId,
  'serviceIds': instance.serviceIds,
  'productIds': instance.productIds,
  'totalPrice': instance.totalPrice,
  'scheduledTime': const RobustTimestampConverter().toJson(
    instance.scheduledTime,
  ),
  'status': _$BookingStatusEnumMap[instance.status]!,
  'staffNotes': instance.staffNotes,
  'beforePhotos': instance.beforePhotos,
  'afterPhotos': instance.afterPhotos,
  'isRated': instance.isRated,
  'rating': instance.rating,
  'ratingComment': instance.ratingComment,
  'selectedTags': instance.selectedTags,
  'ratedAt': const RobustNullableTimestampConverter().toJson(instance.ratedAt),
  'adminResponse': instance.adminResponse,
  'adminResponseAt': const RobustNullableTimestampConverter().toJson(
    instance.adminResponseAt,
  ),
  'adminResponderId': instance.adminResponderId,
  'logs': instance.logs.map((e) => e.toJson()).toList(),
  'cancellationReason': instance.cancellationReason,
  'cancelledBy': const RobustActorRoleConverter().toJson(instance.cancelledBy),
  'cancelledAt': const RobustNullableTimestampConverter().toJson(
    instance.cancelledAt,
  ),
  'paymentStatus': _$BookingPaymentStatusEnumMap[instance.paymentStatus]!,
  'paymentMethod': instance.paymentMethod,
  'paidAt': const RobustNullableTimestampConverter().toJson(instance.paidAt),
  'paidByStaffId': instance.paidByStaffId,
  'createdAt': const RobustNullableTimestampConverter().toJson(
    instance.createdAt,
  ),
};

const _$BookingPaymentStatusEnumMap = {
  BookingPaymentStatus.pending: 'pending',
  BookingPaymentStatus.paid: 'paid',
  BookingPaymentStatus.subscription: 'subscription',
  BookingPaymentStatus.cash: 'cash',
  BookingPaymentStatus.pix: 'pix',
};
