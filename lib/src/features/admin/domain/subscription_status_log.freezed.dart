// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_status_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionStatusLog {

 String get id; String get subscriptionId; String get userId; String get previousStatus;// 'none', 'active', 'canceled', 'past_due', 'trialing'
 String get newStatus;// 'active', 'canceled', 'past_due', 'expired'
@TimestampConverter() DateTime get timestamp; String? get reason;// e.g., 'user_requested', 'payment_failed', 'plan_change'
 String? get planId; double? get planValue;
/// Create a copy of SubscriptionStatusLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStatusLogCopyWith<SubscriptionStatusLog> get copyWith => _$SubscriptionStatusLogCopyWithImpl<SubscriptionStatusLog>(this as SubscriptionStatusLog, _$identity);

  /// Serializes this SubscriptionStatusLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionStatusLog&&(identical(other.id, id) || other.id == id)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.previousStatus, previousStatus) || other.previousStatus == previousStatus)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planValue, planValue) || other.planValue == planValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subscriptionId,userId,previousStatus,newStatus,timestamp,reason,planId,planValue);

@override
String toString() {
  return 'SubscriptionStatusLog(id: $id, subscriptionId: $subscriptionId, userId: $userId, previousStatus: $previousStatus, newStatus: $newStatus, timestamp: $timestamp, reason: $reason, planId: $planId, planValue: $planValue)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStatusLogCopyWith<$Res>  {
  factory $SubscriptionStatusLogCopyWith(SubscriptionStatusLog value, $Res Function(SubscriptionStatusLog) _then) = _$SubscriptionStatusLogCopyWithImpl;
@useResult
$Res call({
 String id, String subscriptionId, String userId, String previousStatus, String newStatus,@TimestampConverter() DateTime timestamp, String? reason, String? planId, double? planValue
});




}
/// @nodoc
class _$SubscriptionStatusLogCopyWithImpl<$Res>
    implements $SubscriptionStatusLogCopyWith<$Res> {
  _$SubscriptionStatusLogCopyWithImpl(this._self, this._then);

  final SubscriptionStatusLog _self;
  final $Res Function(SubscriptionStatusLog) _then;

/// Create a copy of SubscriptionStatusLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subscriptionId = null,Object? userId = null,Object? previousStatus = null,Object? newStatus = null,Object? timestamp = null,Object? reason = freezed,Object? planId = freezed,Object? planValue = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,previousStatus: null == previousStatus ? _self.previousStatus : previousStatus // ignore: cast_nullable_to_non_nullable
as String,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,planValue: freezed == planValue ? _self.planValue : planValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionStatusLog].
extension SubscriptionStatusLogPatterns on SubscriptionStatusLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionStatusLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionStatusLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionStatusLog value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatusLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionStatusLog value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatusLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String subscriptionId,  String userId,  String previousStatus,  String newStatus, @TimestampConverter()  DateTime timestamp,  String? reason,  String? planId,  double? planValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionStatusLog() when $default != null:
return $default(_that.id,_that.subscriptionId,_that.userId,_that.previousStatus,_that.newStatus,_that.timestamp,_that.reason,_that.planId,_that.planValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String subscriptionId,  String userId,  String previousStatus,  String newStatus, @TimestampConverter()  DateTime timestamp,  String? reason,  String? planId,  double? planValue)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatusLog():
return $default(_that.id,_that.subscriptionId,_that.userId,_that.previousStatus,_that.newStatus,_that.timestamp,_that.reason,_that.planId,_that.planValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String subscriptionId,  String userId,  String previousStatus,  String newStatus, @TimestampConverter()  DateTime timestamp,  String? reason,  String? planId,  double? planValue)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatusLog() when $default != null:
return $default(_that.id,_that.subscriptionId,_that.userId,_that.previousStatus,_that.newStatus,_that.timestamp,_that.reason,_that.planId,_that.planValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionStatusLog implements SubscriptionStatusLog {
  const _SubscriptionStatusLog({required this.id, required this.subscriptionId, required this.userId, required this.previousStatus, required this.newStatus, @TimestampConverter() required this.timestamp, this.reason, this.planId, this.planValue});
  factory _SubscriptionStatusLog.fromJson(Map<String, dynamic> json) => _$SubscriptionStatusLogFromJson(json);

@override final  String id;
@override final  String subscriptionId;
@override final  String userId;
@override final  String previousStatus;
// 'none', 'active', 'canceled', 'past_due', 'trialing'
@override final  String newStatus;
// 'active', 'canceled', 'past_due', 'expired'
@override@TimestampConverter() final  DateTime timestamp;
@override final  String? reason;
// e.g., 'user_requested', 'payment_failed', 'plan_change'
@override final  String? planId;
@override final  double? planValue;

/// Create a copy of SubscriptionStatusLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionStatusLogCopyWith<_SubscriptionStatusLog> get copyWith => __$SubscriptionStatusLogCopyWithImpl<_SubscriptionStatusLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionStatusLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionStatusLog&&(identical(other.id, id) || other.id == id)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.previousStatus, previousStatus) || other.previousStatus == previousStatus)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planValue, planValue) || other.planValue == planValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subscriptionId,userId,previousStatus,newStatus,timestamp,reason,planId,planValue);

@override
String toString() {
  return 'SubscriptionStatusLog(id: $id, subscriptionId: $subscriptionId, userId: $userId, previousStatus: $previousStatus, newStatus: $newStatus, timestamp: $timestamp, reason: $reason, planId: $planId, planValue: $planValue)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionStatusLogCopyWith<$Res> implements $SubscriptionStatusLogCopyWith<$Res> {
  factory _$SubscriptionStatusLogCopyWith(_SubscriptionStatusLog value, $Res Function(_SubscriptionStatusLog) _then) = __$SubscriptionStatusLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String subscriptionId, String userId, String previousStatus, String newStatus,@TimestampConverter() DateTime timestamp, String? reason, String? planId, double? planValue
});




}
/// @nodoc
class __$SubscriptionStatusLogCopyWithImpl<$Res>
    implements _$SubscriptionStatusLogCopyWith<$Res> {
  __$SubscriptionStatusLogCopyWithImpl(this._self, this._then);

  final _SubscriptionStatusLog _self;
  final $Res Function(_SubscriptionStatusLog) _then;

/// Create a copy of SubscriptionStatusLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subscriptionId = null,Object? userId = null,Object? previousStatus = null,Object? newStatus = null,Object? timestamp = null,Object? reason = freezed,Object? planId = freezed,Object? planValue = freezed,}) {
  return _then(_SubscriptionStatusLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,previousStatus: null == previousStatus ? _self.previousStatus : previousStatus // ignore: cast_nullable_to_non_nullable
as String,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,planValue: freezed == planValue ? _self.planValue : planValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
