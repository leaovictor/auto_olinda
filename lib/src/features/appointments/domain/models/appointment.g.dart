// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Appointment _$AppointmentFromJson(Map<String, dynamic> json) => _Appointment(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  customerId: json['customerId'] as String,
  customerName: json['customerName'] as String?,
  vehiclePlate: json['vehiclePlate'] as String?,
  vehicleModel: json['vehicleModel'] as String?,
  staffId: json['staffId'] as String?,
  staffName: json['staffName'] as String?,
  serviceIds: (json['serviceIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  serviceDetails:
      (json['serviceDetails'] as List<dynamic>?)
          ?.map((e) => ServiceDetail.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  scheduledAt: const RobustTimestampConverter().fromJson(json['scheduledAt']),
  actualStartAt: (json['actualStartAt'] as num?)?.toInt(),
  actualEndAt: (json['actualEndAt'] as num?)?.toInt(),
  estimatedDurationMinutes:
      (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 30,
  status:
      $enumDecodeNullable(_$AppointmentStatusEnumMap, json['status']) ??
      AppointmentStatus.scheduled,
  paymentStatus:
      $enumDecodeNullable(
        _$AppointmentPaymentStatusEnumMap,
        json['paymentStatus'],
      ) ??
      AppointmentPaymentStatus.pending,
  subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
  discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
  tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
  total: (json['total'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String?,
  paymentIntentId: json['paymentIntentId'] as String?,
  paymentLinkId: json['paymentLinkId'] as String?,
  subscriptionId: json['subscriptionId'] as String?,
  usedSubscriptionCredits: json['usedSubscriptionCredits'] as bool?,
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
  customerNotes: json['customerNotes'] as String?,
  staffNotes: json['staffNotes'] as String?,
  cancellationReason: json['cancellationReason'] as String?,
  checkedInAt: const RobustNullableTimestampConverter().fromJson(
    json['checkedInAt'],
  ),
  startedAt: const RobustNullableTimestampConverter().fromJson(
    json['startedAt'],
  ),
  completedAt: const RobustNullableTimestampConverter().fromJson(
    json['completedAt'],
  ),
  createdAt: const RobustNullableTimestampConverter().fromJson(
    json['createdAt'],
  ),
  updatedAt: const RobustNullableTimestampConverter().fromJson(
    json['updatedAt'],
  ),
  createdBy: json['createdBy'] as String?,
);

Map<String, dynamic> _$AppointmentToJson(
  _Appointment instance,
) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'vehiclePlate': instance.vehiclePlate,
  'vehicleModel': instance.vehicleModel,
  'staffId': instance.staffId,
  'staffName': instance.staffName,
  'serviceIds': instance.serviceIds,
  'serviceDetails': instance.serviceDetails.map((e) => e.toJson()).toList(),
  'scheduledAt': const RobustTimestampConverter().toJson(instance.scheduledAt),
  'actualStartAt': instance.actualStartAt,
  'actualEndAt': instance.actualEndAt,
  'estimatedDurationMinutes': instance.estimatedDurationMinutes,
  'status': _$AppointmentStatusEnumMap[instance.status]!,
  'paymentStatus': _$AppointmentPaymentStatusEnumMap[instance.paymentStatus]!,
  'subtotal': instance.subtotal,
  'discount': instance.discount,
  'tax': instance.tax,
  'total': instance.total,
  'currency': instance.currency,
  'paymentIntentId': instance.paymentIntentId,
  'paymentLinkId': instance.paymentLinkId,
  'subscriptionId': instance.subscriptionId,
  'usedSubscriptionCredits': instance.usedSubscriptionCredits,
  'beforePhotos': instance.beforePhotos,
  'afterPhotos': instance.afterPhotos,
  'customerNotes': instance.customerNotes,
  'staffNotes': instance.staffNotes,
  'cancellationReason': instance.cancellationReason,
  'checkedInAt': const RobustNullableTimestampConverter().toJson(
    instance.checkedInAt,
  ),
  'startedAt': const RobustNullableTimestampConverter().toJson(
    instance.startedAt,
  ),
  'completedAt': const RobustNullableTimestampConverter().toJson(
    instance.completedAt,
  ),
  'createdAt': const RobustNullableTimestampConverter().toJson(
    instance.createdAt,
  ),
  'updatedAt': const RobustNullableTimestampConverter().toJson(
    instance.updatedAt,
  ),
  'createdBy': instance.createdBy,
};

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.scheduled: 'scheduled',
  AppointmentStatus.confirmed: 'confirmed',
  AppointmentStatus.inProgress: 'inProgress',
  AppointmentStatus.completed: 'completed',
  AppointmentStatus.cancelled: 'cancelled',
  AppointmentStatus.noShow: 'noShow',
};

const _$AppointmentPaymentStatusEnumMap = {
  AppointmentPaymentStatus.pending: 'pending',
  AppointmentPaymentStatus.paid: 'paid',
  AppointmentPaymentStatus.partiallyPaid: 'partiallyPaid',
  AppointmentPaymentStatus.refunded: 'refunded',
  AppointmentPaymentStatus.failed: 'failed',
};

_ServiceDetail _$ServiceDetailFromJson(Map<String, dynamic> json) =>
    _ServiceDetail(
      serviceId: json['serviceId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$ServiceDetailToJson(_ServiceDetail instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'name': instance.name,
      'price': instance.price,
      'durationMinutes': instance.durationMinutes,
    };
