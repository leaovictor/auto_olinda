// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wash_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WashLog {

 String get id; String? get userId;// null for walk-in (non-registered) customers
 String get bookingId; String get serviceType;// 'subscription' or 'single'
 double get value;@TimestampConverter() DateTime get timestamp; String? get planId;// only for subscribers
 List<String> get serviceIds; String? get vehicleType;
/// Create a copy of WashLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WashLogCopyWith<WashLog> get copyWith => _$WashLogCopyWithImpl<WashLog>(this as WashLog, _$identity);

  /// Serializes this WashLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WashLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.value, value) || other.value == value)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.planId, planId) || other.planId == planId)&&const DeepCollectionEquality().equals(other.serviceIds, serviceIds)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,bookingId,serviceType,value,timestamp,planId,const DeepCollectionEquality().hash(serviceIds),vehicleType);

@override
String toString() {
  return 'WashLog(id: $id, userId: $userId, bookingId: $bookingId, serviceType: $serviceType, value: $value, timestamp: $timestamp, planId: $planId, serviceIds: $serviceIds, vehicleType: $vehicleType)';
}


}

/// @nodoc
abstract mixin class $WashLogCopyWith<$Res>  {
  factory $WashLogCopyWith(WashLog value, $Res Function(WashLog) _then) = _$WashLogCopyWithImpl;
@useResult
$Res call({
 String id, String? userId, String bookingId, String serviceType, double value,@TimestampConverter() DateTime timestamp, String? planId, List<String> serviceIds, String? vehicleType
});




}
/// @nodoc
class _$WashLogCopyWithImpl<$Res>
    implements $WashLogCopyWith<$Res> {
  _$WashLogCopyWithImpl(this._self, this._then);

  final WashLog _self;
  final $Res Function(WashLog) _then;

/// Create a copy of WashLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? bookingId = null,Object? serviceType = null,Object? value = null,Object? timestamp = null,Object? planId = freezed,Object? serviceIds = null,Object? vehicleType = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,serviceIds: null == serviceIds ? _self.serviceIds : serviceIds // ignore: cast_nullable_to_non_nullable
as List<String>,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WashLog].
extension WashLogPatterns on WashLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WashLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WashLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WashLog value)  $default,){
final _that = this;
switch (_that) {
case _WashLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WashLog value)?  $default,){
final _that = this;
switch (_that) {
case _WashLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? userId,  String bookingId,  String serviceType,  double value, @TimestampConverter()  DateTime timestamp,  String? planId,  List<String> serviceIds,  String? vehicleType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WashLog() when $default != null:
return $default(_that.id,_that.userId,_that.bookingId,_that.serviceType,_that.value,_that.timestamp,_that.planId,_that.serviceIds,_that.vehicleType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? userId,  String bookingId,  String serviceType,  double value, @TimestampConverter()  DateTime timestamp,  String? planId,  List<String> serviceIds,  String? vehicleType)  $default,) {final _that = this;
switch (_that) {
case _WashLog():
return $default(_that.id,_that.userId,_that.bookingId,_that.serviceType,_that.value,_that.timestamp,_that.planId,_that.serviceIds,_that.vehicleType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? userId,  String bookingId,  String serviceType,  double value, @TimestampConverter()  DateTime timestamp,  String? planId,  List<String> serviceIds,  String? vehicleType)?  $default,) {final _that = this;
switch (_that) {
case _WashLog() when $default != null:
return $default(_that.id,_that.userId,_that.bookingId,_that.serviceType,_that.value,_that.timestamp,_that.planId,_that.serviceIds,_that.vehicleType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WashLog implements WashLog {
  const _WashLog({required this.id, this.userId, required this.bookingId, required this.serviceType, required this.value, @TimestampConverter() required this.timestamp, this.planId, final  List<String> serviceIds = const [], this.vehicleType}): _serviceIds = serviceIds;
  factory _WashLog.fromJson(Map<String, dynamic> json) => _$WashLogFromJson(json);

@override final  String id;
@override final  String? userId;
// null for walk-in (non-registered) customers
@override final  String bookingId;
@override final  String serviceType;
// 'subscription' or 'single'
@override final  double value;
@override@TimestampConverter() final  DateTime timestamp;
@override final  String? planId;
// only for subscribers
 final  List<String> _serviceIds;
// only for subscribers
@override@JsonKey() List<String> get serviceIds {
  if (_serviceIds is EqualUnmodifiableListView) return _serviceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceIds);
}

@override final  String? vehicleType;

/// Create a copy of WashLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WashLogCopyWith<_WashLog> get copyWith => __$WashLogCopyWithImpl<_WashLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WashLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WashLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.value, value) || other.value == value)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.planId, planId) || other.planId == planId)&&const DeepCollectionEquality().equals(other._serviceIds, _serviceIds)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,bookingId,serviceType,value,timestamp,planId,const DeepCollectionEquality().hash(_serviceIds),vehicleType);

@override
String toString() {
  return 'WashLog(id: $id, userId: $userId, bookingId: $bookingId, serviceType: $serviceType, value: $value, timestamp: $timestamp, planId: $planId, serviceIds: $serviceIds, vehicleType: $vehicleType)';
}


}

/// @nodoc
abstract mixin class _$WashLogCopyWith<$Res> implements $WashLogCopyWith<$Res> {
  factory _$WashLogCopyWith(_WashLog value, $Res Function(_WashLog) _then) = __$WashLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String? userId, String bookingId, String serviceType, double value,@TimestampConverter() DateTime timestamp, String? planId, List<String> serviceIds, String? vehicleType
});




}
/// @nodoc
class __$WashLogCopyWithImpl<$Res>
    implements _$WashLogCopyWith<$Res> {
  __$WashLogCopyWithImpl(this._self, this._then);

  final _WashLog _self;
  final $Res Function(_WashLog) _then;

/// Create a copy of WashLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? bookingId = null,Object? serviceType = null,Object? value = null,Object? timestamp = null,Object? planId = freezed,Object? serviceIds = null,Object? vehicleType = freezed,}) {
  return _then(_WashLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,serviceIds: null == serviceIds ? _self._serviceIds : serviceIds // ignore: cast_nullable_to_non_nullable
as List<String>,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
