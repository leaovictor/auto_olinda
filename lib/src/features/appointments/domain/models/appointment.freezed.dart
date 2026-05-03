// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Appointment {

 String get id; String get tenantId; String get customerId; String? get customerName;// Denormalized for quick display
 String? get vehiclePlate;// Denormalized
 String? get vehicleModel;// Staff Assignment
 String? get staffId; String? get staffName;// Denormalized
// Services
 List<String> get serviceIds; List<ServiceDetail> get serviceDetails;// Denormalized snapshot
// Timing
@RobustTimestampConverter() DateTime get scheduledAt; int? get actualStartAt; int? get actualEndAt; int get estimatedDurationMinutes;// Status & Payment
 AppointmentStatus get status; AppointmentPaymentStatus get paymentStatus;// Pricing
 double get subtotal; double get discount; double get tax; double get total; String? get currency;// Payment links/intents
 String? get paymentIntentId; String? get paymentLinkId;// For customer to pay
// Subscription linkage
 String? get subscriptionId; bool? get usedSubscriptionCredits;// Media
 List<String> get beforePhotos; List<String> get afterPhotos;// Notes
 String? get customerNotes; String? get staffNotes; String? get cancellationReason;// Check-in
@RobustNullableTimestampConverter() DateTime? get checkedInAt;@RobustNullableTimestampConverter() DateTime? get startedAt;@RobustNullableTimestampConverter() DateTime? get completedAt;// Audit
@RobustNullableTimestampConverter() DateTime? get createdAt;@RobustNullableTimestampConverter() DateTime? get updatedAt; String? get createdBy;
/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentCopyWith<Appointment> get copyWith => _$AppointmentCopyWithImpl<Appointment>(this as Appointment, _$identity);

  /// Serializes this Appointment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Appointment&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.vehiclePlate, vehiclePlate) || other.vehiclePlate == vehiclePlate)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&const DeepCollectionEquality().equals(other.serviceIds, serviceIds)&&const DeepCollectionEquality().equals(other.serviceDetails, serviceDetails)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.actualStartAt, actualStartAt) || other.actualStartAt == actualStartAt)&&(identical(other.actualEndAt, actualEndAt) || other.actualEndAt == actualEndAt)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentLinkId, paymentLinkId) || other.paymentLinkId == paymentLinkId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.usedSubscriptionCredits, usedSubscriptionCredits) || other.usedSubscriptionCredits == usedSubscriptionCredits)&&const DeepCollectionEquality().equals(other.beforePhotos, beforePhotos)&&const DeepCollectionEquality().equals(other.afterPhotos, afterPhotos)&&(identical(other.customerNotes, customerNotes) || other.customerNotes == customerNotes)&&(identical(other.staffNotes, staffNotes) || other.staffNotes == staffNotes)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tenantId,customerId,customerName,vehiclePlate,vehicleModel,staffId,staffName,const DeepCollectionEquality().hash(serviceIds),const DeepCollectionEquality().hash(serviceDetails),scheduledAt,actualStartAt,actualEndAt,estimatedDurationMinutes,status,paymentStatus,subtotal,discount,tax,total,currency,paymentIntentId,paymentLinkId,subscriptionId,usedSubscriptionCredits,const DeepCollectionEquality().hash(beforePhotos),const DeepCollectionEquality().hash(afterPhotos),customerNotes,staffNotes,cancellationReason,checkedInAt,startedAt,completedAt,createdAt,updatedAt,createdBy]);

@override
String toString() {
  return 'Appointment(id: $id, tenantId: $tenantId, customerId: $customerId, customerName: $customerName, vehiclePlate: $vehiclePlate, vehicleModel: $vehicleModel, staffId: $staffId, staffName: $staffName, serviceIds: $serviceIds, serviceDetails: $serviceDetails, scheduledAt: $scheduledAt, actualStartAt: $actualStartAt, actualEndAt: $actualEndAt, estimatedDurationMinutes: $estimatedDurationMinutes, status: $status, paymentStatus: $paymentStatus, subtotal: $subtotal, discount: $discount, tax: $tax, total: $total, currency: $currency, paymentIntentId: $paymentIntentId, paymentLinkId: $paymentLinkId, subscriptionId: $subscriptionId, usedSubscriptionCredits: $usedSubscriptionCredits, beforePhotos: $beforePhotos, afterPhotos: $afterPhotos, customerNotes: $customerNotes, staffNotes: $staffNotes, cancellationReason: $cancellationReason, checkedInAt: $checkedInAt, startedAt: $startedAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class $AppointmentCopyWith<$Res>  {
  factory $AppointmentCopyWith(Appointment value, $Res Function(Appointment) _then) = _$AppointmentCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String customerId, String? customerName, String? vehiclePlate, String? vehicleModel, String? staffId, String? staffName, List<String> serviceIds, List<ServiceDetail> serviceDetails,@RobustTimestampConverter() DateTime scheduledAt, int? actualStartAt, int? actualEndAt, int estimatedDurationMinutes, AppointmentStatus status, AppointmentPaymentStatus paymentStatus, double subtotal, double discount, double tax, double total, String? currency, String? paymentIntentId, String? paymentLinkId, String? subscriptionId, bool? usedSubscriptionCredits, List<String> beforePhotos, List<String> afterPhotos, String? customerNotes, String? staffNotes, String? cancellationReason,@RobustNullableTimestampConverter() DateTime? checkedInAt,@RobustNullableTimestampConverter() DateTime? startedAt,@RobustNullableTimestampConverter() DateTime? completedAt,@RobustNullableTimestampConverter() DateTime? createdAt,@RobustNullableTimestampConverter() DateTime? updatedAt, String? createdBy
});




}
/// @nodoc
class _$AppointmentCopyWithImpl<$Res>
    implements $AppointmentCopyWith<$Res> {
  _$AppointmentCopyWithImpl(this._self, this._then);

  final Appointment _self;
  final $Res Function(Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? customerId = null,Object? customerName = freezed,Object? vehiclePlate = freezed,Object? vehicleModel = freezed,Object? staffId = freezed,Object? staffName = freezed,Object? serviceIds = null,Object? serviceDetails = null,Object? scheduledAt = null,Object? actualStartAt = freezed,Object? actualEndAt = freezed,Object? estimatedDurationMinutes = null,Object? status = null,Object? paymentStatus = null,Object? subtotal = null,Object? discount = null,Object? tax = null,Object? total = null,Object? currency = freezed,Object? paymentIntentId = freezed,Object? paymentLinkId = freezed,Object? subscriptionId = freezed,Object? usedSubscriptionCredits = freezed,Object? beforePhotos = null,Object? afterPhotos = null,Object? customerNotes = freezed,Object? staffNotes = freezed,Object? cancellationReason = freezed,Object? checkedInAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,vehiclePlate: freezed == vehiclePlate ? _self.vehiclePlate : vehiclePlate // ignore: cast_nullable_to_non_nullable
as String?,vehicleModel: freezed == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String?,staffId: freezed == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String?,staffName: freezed == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String?,serviceIds: null == serviceIds ? _self.serviceIds : serviceIds // ignore: cast_nullable_to_non_nullable
as List<String>,serviceDetails: null == serviceDetails ? _self.serviceDetails : serviceDetails // ignore: cast_nullable_to_non_nullable
as List<ServiceDetail>,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,actualStartAt: freezed == actualStartAt ? _self.actualStartAt : actualStartAt // ignore: cast_nullable_to_non_nullable
as int?,actualEndAt: freezed == actualEndAt ? _self.actualEndAt : actualEndAt // ignore: cast_nullable_to_non_nullable
as int?,estimatedDurationMinutes: null == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppointmentStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as AppointmentPaymentStatus,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paymentLinkId: freezed == paymentLinkId ? _self.paymentLinkId : paymentLinkId // ignore: cast_nullable_to_non_nullable
as String?,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,usedSubscriptionCredits: freezed == usedSubscriptionCredits ? _self.usedSubscriptionCredits : usedSubscriptionCredits // ignore: cast_nullable_to_non_nullable
as bool?,beforePhotos: null == beforePhotos ? _self.beforePhotos : beforePhotos // ignore: cast_nullable_to_non_nullable
as List<String>,afterPhotos: null == afterPhotos ? _self.afterPhotos : afterPhotos // ignore: cast_nullable_to_non_nullable
as List<String>,customerNotes: freezed == customerNotes ? _self.customerNotes : customerNotes // ignore: cast_nullable_to_non_nullable
as String?,staffNotes: freezed == staffNotes ? _self.staffNotes : staffNotes // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Appointment].
extension AppointmentPatterns on Appointment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Appointment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Appointment value)  $default,){
final _that = this;
switch (_that) {
case _Appointment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Appointment value)?  $default,){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String customerId,  String? customerName,  String? vehiclePlate,  String? vehicleModel,  String? staffId,  String? staffName,  List<String> serviceIds,  List<ServiceDetail> serviceDetails, @RobustTimestampConverter()  DateTime scheduledAt,  int? actualStartAt,  int? actualEndAt,  int estimatedDurationMinutes,  AppointmentStatus status,  AppointmentPaymentStatus paymentStatus,  double subtotal,  double discount,  double tax,  double total,  String? currency,  String? paymentIntentId,  String? paymentLinkId,  String? subscriptionId,  bool? usedSubscriptionCredits,  List<String> beforePhotos,  List<String> afterPhotos,  String? customerNotes,  String? staffNotes,  String? cancellationReason, @RobustNullableTimestampConverter()  DateTime? checkedInAt, @RobustNullableTimestampConverter()  DateTime? startedAt, @RobustNullableTimestampConverter()  DateTime? completedAt, @RobustNullableTimestampConverter()  DateTime? createdAt, @RobustNullableTimestampConverter()  DateTime? updatedAt,  String? createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.tenantId,_that.customerId,_that.customerName,_that.vehiclePlate,_that.vehicleModel,_that.staffId,_that.staffName,_that.serviceIds,_that.serviceDetails,_that.scheduledAt,_that.actualStartAt,_that.actualEndAt,_that.estimatedDurationMinutes,_that.status,_that.paymentStatus,_that.subtotal,_that.discount,_that.tax,_that.total,_that.currency,_that.paymentIntentId,_that.paymentLinkId,_that.subscriptionId,_that.usedSubscriptionCredits,_that.beforePhotos,_that.afterPhotos,_that.customerNotes,_that.staffNotes,_that.cancellationReason,_that.checkedInAt,_that.startedAt,_that.completedAt,_that.createdAt,_that.updatedAt,_that.createdBy);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String customerId,  String? customerName,  String? vehiclePlate,  String? vehicleModel,  String? staffId,  String? staffName,  List<String> serviceIds,  List<ServiceDetail> serviceDetails, @RobustTimestampConverter()  DateTime scheduledAt,  int? actualStartAt,  int? actualEndAt,  int estimatedDurationMinutes,  AppointmentStatus status,  AppointmentPaymentStatus paymentStatus,  double subtotal,  double discount,  double tax,  double total,  String? currency,  String? paymentIntentId,  String? paymentLinkId,  String? subscriptionId,  bool? usedSubscriptionCredits,  List<String> beforePhotos,  List<String> afterPhotos,  String? customerNotes,  String? staffNotes,  String? cancellationReason, @RobustNullableTimestampConverter()  DateTime? checkedInAt, @RobustNullableTimestampConverter()  DateTime? startedAt, @RobustNullableTimestampConverter()  DateTime? completedAt, @RobustNullableTimestampConverter()  DateTime? createdAt, @RobustNullableTimestampConverter()  DateTime? updatedAt,  String? createdBy)  $default,) {final _that = this;
switch (_that) {
case _Appointment():
return $default(_that.id,_that.tenantId,_that.customerId,_that.customerName,_that.vehiclePlate,_that.vehicleModel,_that.staffId,_that.staffName,_that.serviceIds,_that.serviceDetails,_that.scheduledAt,_that.actualStartAt,_that.actualEndAt,_that.estimatedDurationMinutes,_that.status,_that.paymentStatus,_that.subtotal,_that.discount,_that.tax,_that.total,_that.currency,_that.paymentIntentId,_that.paymentLinkId,_that.subscriptionId,_that.usedSubscriptionCredits,_that.beforePhotos,_that.afterPhotos,_that.customerNotes,_that.staffNotes,_that.cancellationReason,_that.checkedInAt,_that.startedAt,_that.completedAt,_that.createdAt,_that.updatedAt,_that.createdBy);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String customerId,  String? customerName,  String? vehiclePlate,  String? vehicleModel,  String? staffId,  String? staffName,  List<String> serviceIds,  List<ServiceDetail> serviceDetails, @RobustTimestampConverter()  DateTime scheduledAt,  int? actualStartAt,  int? actualEndAt,  int estimatedDurationMinutes,  AppointmentStatus status,  AppointmentPaymentStatus paymentStatus,  double subtotal,  double discount,  double tax,  double total,  String? currency,  String? paymentIntentId,  String? paymentLinkId,  String? subscriptionId,  bool? usedSubscriptionCredits,  List<String> beforePhotos,  List<String> afterPhotos,  String? customerNotes,  String? staffNotes,  String? cancellationReason, @RobustNullableTimestampConverter()  DateTime? checkedInAt, @RobustNullableTimestampConverter()  DateTime? startedAt, @RobustNullableTimestampConverter()  DateTime? completedAt, @RobustNullableTimestampConverter()  DateTime? createdAt, @RobustNullableTimestampConverter()  DateTime? updatedAt,  String? createdBy)?  $default,) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.tenantId,_that.customerId,_that.customerName,_that.vehiclePlate,_that.vehicleModel,_that.staffId,_that.staffName,_that.serviceIds,_that.serviceDetails,_that.scheduledAt,_that.actualStartAt,_that.actualEndAt,_that.estimatedDurationMinutes,_that.status,_that.paymentStatus,_that.subtotal,_that.discount,_that.tax,_that.total,_that.currency,_that.paymentIntentId,_that.paymentLinkId,_that.subscriptionId,_that.usedSubscriptionCredits,_that.beforePhotos,_that.afterPhotos,_that.customerNotes,_that.staffNotes,_that.cancellationReason,_that.checkedInAt,_that.startedAt,_that.completedAt,_that.createdAt,_that.updatedAt,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Appointment implements Appointment {
  const _Appointment({required this.id, required this.tenantId, required this.customerId, this.customerName, this.vehiclePlate, this.vehicleModel, this.staffId, this.staffName, required final  List<String> serviceIds, final  List<ServiceDetail> serviceDetails = const [], @RobustTimestampConverter() required this.scheduledAt, this.actualStartAt, this.actualEndAt, this.estimatedDurationMinutes = 30, this.status = AppointmentStatus.scheduled, this.paymentStatus = AppointmentPaymentStatus.pending, this.subtotal = 0.0, this.discount = 0.0, this.tax = 0.0, this.total = 0.0, this.currency, this.paymentIntentId, this.paymentLinkId, this.subscriptionId, this.usedSubscriptionCredits, final  List<String> beforePhotos = const [], final  List<String> afterPhotos = const [], this.customerNotes, this.staffNotes, this.cancellationReason, @RobustNullableTimestampConverter() this.checkedInAt, @RobustNullableTimestampConverter() this.startedAt, @RobustNullableTimestampConverter() this.completedAt, @RobustNullableTimestampConverter() this.createdAt, @RobustNullableTimestampConverter() this.updatedAt, this.createdBy}): _serviceIds = serviceIds,_serviceDetails = serviceDetails,_beforePhotos = beforePhotos,_afterPhotos = afterPhotos;
  factory _Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String customerId;
@override final  String? customerName;
// Denormalized for quick display
@override final  String? vehiclePlate;
// Denormalized
@override final  String? vehicleModel;
// Staff Assignment
@override final  String? staffId;
@override final  String? staffName;
// Denormalized
// Services
 final  List<String> _serviceIds;
// Denormalized
// Services
@override List<String> get serviceIds {
  if (_serviceIds is EqualUnmodifiableListView) return _serviceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceIds);
}

 final  List<ServiceDetail> _serviceDetails;
@override@JsonKey() List<ServiceDetail> get serviceDetails {
  if (_serviceDetails is EqualUnmodifiableListView) return _serviceDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceDetails);
}

// Denormalized snapshot
// Timing
@override@RobustTimestampConverter() final  DateTime scheduledAt;
@override final  int? actualStartAt;
@override final  int? actualEndAt;
@override@JsonKey() final  int estimatedDurationMinutes;
// Status & Payment
@override@JsonKey() final  AppointmentStatus status;
@override@JsonKey() final  AppointmentPaymentStatus paymentStatus;
// Pricing
@override@JsonKey() final  double subtotal;
@override@JsonKey() final  double discount;
@override@JsonKey() final  double tax;
@override@JsonKey() final  double total;
@override final  String? currency;
// Payment links/intents
@override final  String? paymentIntentId;
@override final  String? paymentLinkId;
// For customer to pay
// Subscription linkage
@override final  String? subscriptionId;
@override final  bool? usedSubscriptionCredits;
// Media
 final  List<String> _beforePhotos;
// Media
@override@JsonKey() List<String> get beforePhotos {
  if (_beforePhotos is EqualUnmodifiableListView) return _beforePhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beforePhotos);
}

 final  List<String> _afterPhotos;
@override@JsonKey() List<String> get afterPhotos {
  if (_afterPhotos is EqualUnmodifiableListView) return _afterPhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_afterPhotos);
}

// Notes
@override final  String? customerNotes;
@override final  String? staffNotes;
@override final  String? cancellationReason;
// Check-in
@override@RobustNullableTimestampConverter() final  DateTime? checkedInAt;
@override@RobustNullableTimestampConverter() final  DateTime? startedAt;
@override@RobustNullableTimestampConverter() final  DateTime? completedAt;
// Audit
@override@RobustNullableTimestampConverter() final  DateTime? createdAt;
@override@RobustNullableTimestampConverter() final  DateTime? updatedAt;
@override final  String? createdBy;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentCopyWith<_Appointment> get copyWith => __$AppointmentCopyWithImpl<_Appointment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Appointment&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.vehiclePlate, vehiclePlate) || other.vehiclePlate == vehiclePlate)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&const DeepCollectionEquality().equals(other._serviceIds, _serviceIds)&&const DeepCollectionEquality().equals(other._serviceDetails, _serviceDetails)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.actualStartAt, actualStartAt) || other.actualStartAt == actualStartAt)&&(identical(other.actualEndAt, actualEndAt) || other.actualEndAt == actualEndAt)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentLinkId, paymentLinkId) || other.paymentLinkId == paymentLinkId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.usedSubscriptionCredits, usedSubscriptionCredits) || other.usedSubscriptionCredits == usedSubscriptionCredits)&&const DeepCollectionEquality().equals(other._beforePhotos, _beforePhotos)&&const DeepCollectionEquality().equals(other._afterPhotos, _afterPhotos)&&(identical(other.customerNotes, customerNotes) || other.customerNotes == customerNotes)&&(identical(other.staffNotes, staffNotes) || other.staffNotes == staffNotes)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tenantId,customerId,customerName,vehiclePlate,vehicleModel,staffId,staffName,const DeepCollectionEquality().hash(_serviceIds),const DeepCollectionEquality().hash(_serviceDetails),scheduledAt,actualStartAt,actualEndAt,estimatedDurationMinutes,status,paymentStatus,subtotal,discount,tax,total,currency,paymentIntentId,paymentLinkId,subscriptionId,usedSubscriptionCredits,const DeepCollectionEquality().hash(_beforePhotos),const DeepCollectionEquality().hash(_afterPhotos),customerNotes,staffNotes,cancellationReason,checkedInAt,startedAt,completedAt,createdAt,updatedAt,createdBy]);

@override
String toString() {
  return 'Appointment(id: $id, tenantId: $tenantId, customerId: $customerId, customerName: $customerName, vehiclePlate: $vehiclePlate, vehicleModel: $vehicleModel, staffId: $staffId, staffName: $staffName, serviceIds: $serviceIds, serviceDetails: $serviceDetails, scheduledAt: $scheduledAt, actualStartAt: $actualStartAt, actualEndAt: $actualEndAt, estimatedDurationMinutes: $estimatedDurationMinutes, status: $status, paymentStatus: $paymentStatus, subtotal: $subtotal, discount: $discount, tax: $tax, total: $total, currency: $currency, paymentIntentId: $paymentIntentId, paymentLinkId: $paymentLinkId, subscriptionId: $subscriptionId, usedSubscriptionCredits: $usedSubscriptionCredits, beforePhotos: $beforePhotos, afterPhotos: $afterPhotos, customerNotes: $customerNotes, staffNotes: $staffNotes, cancellationReason: $cancellationReason, checkedInAt: $checkedInAt, startedAt: $startedAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$AppointmentCopyWith<$Res> implements $AppointmentCopyWith<$Res> {
  factory _$AppointmentCopyWith(_Appointment value, $Res Function(_Appointment) _then) = __$AppointmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String customerId, String? customerName, String? vehiclePlate, String? vehicleModel, String? staffId, String? staffName, List<String> serviceIds, List<ServiceDetail> serviceDetails,@RobustTimestampConverter() DateTime scheduledAt, int? actualStartAt, int? actualEndAt, int estimatedDurationMinutes, AppointmentStatus status, AppointmentPaymentStatus paymentStatus, double subtotal, double discount, double tax, double total, String? currency, String? paymentIntentId, String? paymentLinkId, String? subscriptionId, bool? usedSubscriptionCredits, List<String> beforePhotos, List<String> afterPhotos, String? customerNotes, String? staffNotes, String? cancellationReason,@RobustNullableTimestampConverter() DateTime? checkedInAt,@RobustNullableTimestampConverter() DateTime? startedAt,@RobustNullableTimestampConverter() DateTime? completedAt,@RobustNullableTimestampConverter() DateTime? createdAt,@RobustNullableTimestampConverter() DateTime? updatedAt, String? createdBy
});




}
/// @nodoc
class __$AppointmentCopyWithImpl<$Res>
    implements _$AppointmentCopyWith<$Res> {
  __$AppointmentCopyWithImpl(this._self, this._then);

  final _Appointment _self;
  final $Res Function(_Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? customerId = null,Object? customerName = freezed,Object? vehiclePlate = freezed,Object? vehicleModel = freezed,Object? staffId = freezed,Object? staffName = freezed,Object? serviceIds = null,Object? serviceDetails = null,Object? scheduledAt = null,Object? actualStartAt = freezed,Object? actualEndAt = freezed,Object? estimatedDurationMinutes = null,Object? status = null,Object? paymentStatus = null,Object? subtotal = null,Object? discount = null,Object? tax = null,Object? total = null,Object? currency = freezed,Object? paymentIntentId = freezed,Object? paymentLinkId = freezed,Object? subscriptionId = freezed,Object? usedSubscriptionCredits = freezed,Object? beforePhotos = null,Object? afterPhotos = null,Object? customerNotes = freezed,Object? staffNotes = freezed,Object? cancellationReason = freezed,Object? checkedInAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdBy = freezed,}) {
  return _then(_Appointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,vehiclePlate: freezed == vehiclePlate ? _self.vehiclePlate : vehiclePlate // ignore: cast_nullable_to_non_nullable
as String?,vehicleModel: freezed == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String?,staffId: freezed == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String?,staffName: freezed == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String?,serviceIds: null == serviceIds ? _self._serviceIds : serviceIds // ignore: cast_nullable_to_non_nullable
as List<String>,serviceDetails: null == serviceDetails ? _self._serviceDetails : serviceDetails // ignore: cast_nullable_to_non_nullable
as List<ServiceDetail>,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,actualStartAt: freezed == actualStartAt ? _self.actualStartAt : actualStartAt // ignore: cast_nullable_to_non_nullable
as int?,actualEndAt: freezed == actualEndAt ? _self.actualEndAt : actualEndAt // ignore: cast_nullable_to_non_nullable
as int?,estimatedDurationMinutes: null == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppointmentStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as AppointmentPaymentStatus,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paymentLinkId: freezed == paymentLinkId ? _self.paymentLinkId : paymentLinkId // ignore: cast_nullable_to_non_nullable
as String?,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,usedSubscriptionCredits: freezed == usedSubscriptionCredits ? _self.usedSubscriptionCredits : usedSubscriptionCredits // ignore: cast_nullable_to_non_nullable
as bool?,beforePhotos: null == beforePhotos ? _self._beforePhotos : beforePhotos // ignore: cast_nullable_to_non_nullable
as List<String>,afterPhotos: null == afterPhotos ? _self._afterPhotos : afterPhotos // ignore: cast_nullable_to_non_nullable
as List<String>,customerNotes: freezed == customerNotes ? _self.customerNotes : customerNotes // ignore: cast_nullable_to_non_nullable
as String?,staffNotes: freezed == staffNotes ? _self.staffNotes : staffNotes // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ServiceDetail {

 String get serviceId; String get name; double get price; int get durationMinutes;
/// Create a copy of ServiceDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceDetailCopyWith<ServiceDetail> get copyWith => _$ServiceDetailCopyWithImpl<ServiceDetail>(this as ServiceDetail, _$identity);

  /// Serializes this ServiceDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceDetail&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serviceId,name,price,durationMinutes);

@override
String toString() {
  return 'ServiceDetail(serviceId: $serviceId, name: $name, price: $price, durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class $ServiceDetailCopyWith<$Res>  {
  factory $ServiceDetailCopyWith(ServiceDetail value, $Res Function(ServiceDetail) _then) = _$ServiceDetailCopyWithImpl;
@useResult
$Res call({
 String serviceId, String name, double price, int durationMinutes
});




}
/// @nodoc
class _$ServiceDetailCopyWithImpl<$Res>
    implements $ServiceDetailCopyWith<$Res> {
  _$ServiceDetailCopyWithImpl(this._self, this._then);

  final ServiceDetail _self;
  final $Res Function(ServiceDetail) _then;

/// Create a copy of ServiceDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serviceId = null,Object? name = null,Object? price = null,Object? durationMinutes = null,}) {
  return _then(_self.copyWith(
serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceDetail].
extension ServiceDetailPatterns on ServiceDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceDetail value)  $default,){
final _that = this;
switch (_that) {
case _ServiceDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serviceId,  String name,  double price,  int durationMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceDetail() when $default != null:
return $default(_that.serviceId,_that.name,_that.price,_that.durationMinutes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serviceId,  String name,  double price,  int durationMinutes)  $default,) {final _that = this;
switch (_that) {
case _ServiceDetail():
return $default(_that.serviceId,_that.name,_that.price,_that.durationMinutes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serviceId,  String name,  double price,  int durationMinutes)?  $default,) {final _that = this;
switch (_that) {
case _ServiceDetail() when $default != null:
return $default(_that.serviceId,_that.name,_that.price,_that.durationMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceDetail implements ServiceDetail {
  const _ServiceDetail({required this.serviceId, required this.name, required this.price, required this.durationMinutes});
  factory _ServiceDetail.fromJson(Map<String, dynamic> json) => _$ServiceDetailFromJson(json);

@override final  String serviceId;
@override final  String name;
@override final  double price;
@override final  int durationMinutes;

/// Create a copy of ServiceDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceDetailCopyWith<_ServiceDetail> get copyWith => __$ServiceDetailCopyWithImpl<_ServiceDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceDetail&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serviceId,name,price,durationMinutes);

@override
String toString() {
  return 'ServiceDetail(serviceId: $serviceId, name: $name, price: $price, durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class _$ServiceDetailCopyWith<$Res> implements $ServiceDetailCopyWith<$Res> {
  factory _$ServiceDetailCopyWith(_ServiceDetail value, $Res Function(_ServiceDetail) _then) = __$ServiceDetailCopyWithImpl;
@override @useResult
$Res call({
 String serviceId, String name, double price, int durationMinutes
});




}
/// @nodoc
class __$ServiceDetailCopyWithImpl<$Res>
    implements _$ServiceDetailCopyWith<$Res> {
  __$ServiceDetailCopyWithImpl(this._self, this._then);

  final _ServiceDetail _self;
  final $Res Function(_ServiceDetail) _then;

/// Create a copy of ServiceDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serviceId = null,Object? name = null,Object? price = null,Object? durationMinutes = null,}) {
  return _then(_ServiceDetail(
serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
