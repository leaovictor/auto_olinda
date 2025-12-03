// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingLog _$BookingLogFromJson(Map<String, dynamic> json) => _BookingLog(
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
);

Map<String, dynamic> _$BookingLogToJson(_BookingLog instance) =>
    <String, dynamic>{
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'status': _$BookingStatusEnumMap[instance.status]!,
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
  totalPrice: (json['totalPrice'] as num).toDouble(),
  scheduledTime: DateTime.parse(json['scheduledTime'] as String),
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
  logs:
      (json['logs'] as List<dynamic>?)
          ?.map((e) => BookingLog.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'vehicleId': instance.vehicleId,
  'serviceIds': instance.serviceIds,
  'totalPrice': instance.totalPrice,
  'scheduledTime': instance.scheduledTime.toIso8601String(),
  'status': _$BookingStatusEnumMap[instance.status]!,
  'staffNotes': instance.staffNotes,
  'beforePhotos': instance.beforePhotos,
  'afterPhotos': instance.afterPhotos,
  'isRated': instance.isRated,
  'rating': instance.rating,
  'ratingComment': instance.ratingComment,
  'logs': instance.logs.map((e) => e.toJson()).toList(),
};
