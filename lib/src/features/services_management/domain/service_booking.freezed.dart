// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServiceBooking {

 String get id; String get userId; String get serviceId; DateTime get scheduledTime; double get totalPrice;@ServiceBookingStatusConverter() ServiceBookingStatus get status; PaymentStatus get paymentStatus; double get paidAmount;// Amount paid so far
 String? get vehicleId;// Optional, depends on requiresVehicle
 String? get vehiclePlate;// Denormalized for easy display
 String? get vehicleModel;// Denormalized for easy display
 String? get notes; String? get userName;// Denormalized for easy display
 String? get userPhone; String? get rejectionReason;// Reason for rejection by admin
 DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ServiceBooking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceBookingCopyWith<ServiceBooking> get copyWith => _$ServiceBookingCopyWithImpl<ServiceBooking>(this as ServiceBooking, _$identity);

  /// Serializes this ServiceBooking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehiclePlate, vehiclePlate) || other.vehiclePlate == vehiclePlate)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhone, userPhone) || other.userPhone == userPhone)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,serviceId,scheduledTime,totalPrice,status,paymentStatus,paidAmount,vehicleId,vehiclePlate,vehicleModel,notes,userName,userPhone,rejectionReason,createdAt,updatedAt);

@override
String toString() {
  return 'ServiceBooking(id: $id, userId: $userId, serviceId: $serviceId, scheduledTime: $scheduledTime, totalPrice: $totalPrice, status: $status, paymentStatus: $paymentStatus, paidAmount: $paidAmount, vehicleId: $vehicleId, vehiclePlate: $vehiclePlate, vehicleModel: $vehicleModel, notes: $notes, userName: $userName, userPhone: $userPhone, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ServiceBookingCopyWith<$Res>  {
  factory $ServiceBookingCopyWith(ServiceBooking value, $Res Function(ServiceBooking) _then) = _$ServiceBookingCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String serviceId, DateTime scheduledTime, double totalPrice,@ServiceBookingStatusConverter() ServiceBookingStatus status, PaymentStatus paymentStatus, double paidAmount, String? vehicleId, String? vehiclePlate, String? vehicleModel, String? notes, String? userName, String? userPhone, String? rejectionReason, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ServiceBookingCopyWithImpl<$Res>
    implements $ServiceBookingCopyWith<$Res> {
  _$ServiceBookingCopyWithImpl(this._self, this._then);

  final ServiceBooking _self;
  final $Res Function(ServiceBooking) _then;

/// Create a copy of ServiceBooking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? serviceId = null,Object? scheduledTime = null,Object? totalPrice = null,Object? status = null,Object? paymentStatus = null,Object? paidAmount = null,Object? vehicleId = freezed,Object? vehiclePlate = freezed,Object? vehicleModel = freezed,Object? notes = freezed,Object? userName = freezed,Object? userPhone = freezed,Object? rejectionReason = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ServiceBookingStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,vehiclePlate: freezed == vehiclePlate ? _self.vehiclePlate : vehiclePlate // ignore: cast_nullable_to_non_nullable
as String?,vehicleModel: freezed == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userPhone: freezed == userPhone ? _self.userPhone : userPhone // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceBooking].
extension ServiceBookingPatterns on ServiceBooking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceBooking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceBooking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceBooking value)  $default,){
final _that = this;
switch (_that) {
case _ServiceBooking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceBooking value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceBooking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String serviceId,  DateTime scheduledTime,  double totalPrice, @ServiceBookingStatusConverter()  ServiceBookingStatus status,  PaymentStatus paymentStatus,  double paidAmount,  String? vehicleId,  String? vehiclePlate,  String? vehicleModel,  String? notes,  String? userName,  String? userPhone,  String? rejectionReason,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceBooking() when $default != null:
return $default(_that.id,_that.userId,_that.serviceId,_that.scheduledTime,_that.totalPrice,_that.status,_that.paymentStatus,_that.paidAmount,_that.vehicleId,_that.vehiclePlate,_that.vehicleModel,_that.notes,_that.userName,_that.userPhone,_that.rejectionReason,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String serviceId,  DateTime scheduledTime,  double totalPrice, @ServiceBookingStatusConverter()  ServiceBookingStatus status,  PaymentStatus paymentStatus,  double paidAmount,  String? vehicleId,  String? vehiclePlate,  String? vehicleModel,  String? notes,  String? userName,  String? userPhone,  String? rejectionReason,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ServiceBooking():
return $default(_that.id,_that.userId,_that.serviceId,_that.scheduledTime,_that.totalPrice,_that.status,_that.paymentStatus,_that.paidAmount,_that.vehicleId,_that.vehiclePlate,_that.vehicleModel,_that.notes,_that.userName,_that.userPhone,_that.rejectionReason,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String serviceId,  DateTime scheduledTime,  double totalPrice, @ServiceBookingStatusConverter()  ServiceBookingStatus status,  PaymentStatus paymentStatus,  double paidAmount,  String? vehicleId,  String? vehiclePlate,  String? vehicleModel,  String? notes,  String? userName,  String? userPhone,  String? rejectionReason,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ServiceBooking() when $default != null:
return $default(_that.id,_that.userId,_that.serviceId,_that.scheduledTime,_that.totalPrice,_that.status,_that.paymentStatus,_that.paidAmount,_that.vehicleId,_that.vehiclePlate,_that.vehicleModel,_that.notes,_that.userName,_that.userPhone,_that.rejectionReason,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceBooking implements ServiceBooking {
  const _ServiceBooking({required this.id, required this.userId, required this.serviceId, required this.scheduledTime, required this.totalPrice, @ServiceBookingStatusConverter() this.status = ServiceBookingStatus.pendingApproval, this.paymentStatus = PaymentStatus.pending, this.paidAmount = 0.0, this.vehicleId, this.vehiclePlate, this.vehicleModel, this.notes, this.userName, this.userPhone, this.rejectionReason, this.createdAt, this.updatedAt});
  factory _ServiceBooking.fromJson(Map<String, dynamic> json) => _$ServiceBookingFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String serviceId;
@override final  DateTime scheduledTime;
@override final  double totalPrice;
@override@JsonKey()@ServiceBookingStatusConverter() final  ServiceBookingStatus status;
@override@JsonKey() final  PaymentStatus paymentStatus;
@override@JsonKey() final  double paidAmount;
// Amount paid so far
@override final  String? vehicleId;
// Optional, depends on requiresVehicle
@override final  String? vehiclePlate;
// Denormalized for easy display
@override final  String? vehicleModel;
// Denormalized for easy display
@override final  String? notes;
@override final  String? userName;
// Denormalized for easy display
@override final  String? userPhone;
@override final  String? rejectionReason;
// Reason for rejection by admin
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ServiceBooking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceBookingCopyWith<_ServiceBooking> get copyWith => __$ServiceBookingCopyWithImpl<_ServiceBooking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceBookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehiclePlate, vehiclePlate) || other.vehiclePlate == vehiclePlate)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhone, userPhone) || other.userPhone == userPhone)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,serviceId,scheduledTime,totalPrice,status,paymentStatus,paidAmount,vehicleId,vehiclePlate,vehicleModel,notes,userName,userPhone,rejectionReason,createdAt,updatedAt);

@override
String toString() {
  return 'ServiceBooking(id: $id, userId: $userId, serviceId: $serviceId, scheduledTime: $scheduledTime, totalPrice: $totalPrice, status: $status, paymentStatus: $paymentStatus, paidAmount: $paidAmount, vehicleId: $vehicleId, vehiclePlate: $vehiclePlate, vehicleModel: $vehicleModel, notes: $notes, userName: $userName, userPhone: $userPhone, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ServiceBookingCopyWith<$Res> implements $ServiceBookingCopyWith<$Res> {
  factory _$ServiceBookingCopyWith(_ServiceBooking value, $Res Function(_ServiceBooking) _then) = __$ServiceBookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String serviceId, DateTime scheduledTime, double totalPrice,@ServiceBookingStatusConverter() ServiceBookingStatus status, PaymentStatus paymentStatus, double paidAmount, String? vehicleId, String? vehiclePlate, String? vehicleModel, String? notes, String? userName, String? userPhone, String? rejectionReason, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ServiceBookingCopyWithImpl<$Res>
    implements _$ServiceBookingCopyWith<$Res> {
  __$ServiceBookingCopyWithImpl(this._self, this._then);

  final _ServiceBooking _self;
  final $Res Function(_ServiceBooking) _then;

/// Create a copy of ServiceBooking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? serviceId = null,Object? scheduledTime = null,Object? totalPrice = null,Object? status = null,Object? paymentStatus = null,Object? paidAmount = null,Object? vehicleId = freezed,Object? vehiclePlate = freezed,Object? vehicleModel = freezed,Object? notes = freezed,Object? userName = freezed,Object? userPhone = freezed,Object? rejectionReason = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ServiceBooking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ServiceBookingStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,vehiclePlate: freezed == vehiclePlate ? _self.vehiclePlate : vehiclePlate // ignore: cast_nullable_to_non_nullable
as String?,vehicleModel: freezed == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userPhone: freezed == userPhone ? _self.userPhone : userPhone // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
