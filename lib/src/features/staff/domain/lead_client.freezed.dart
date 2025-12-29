// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeadClient {

 String get plate; String get phoneNumber; String get vehicleModel; LeadStatus get status; String? get uid; String? get fcmToken;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get lastServiceAt;
/// Create a copy of LeadClient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadClientCopyWith<LeadClient> get copyWith => _$LeadClientCopyWithImpl<LeadClient>(this as LeadClient, _$identity);

  /// Serializes this LeadClient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeadClient&&(identical(other.plate, plate) || other.plate == plate)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.status, status) || other.status == status)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastServiceAt, lastServiceAt) || other.lastServiceAt == lastServiceAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plate,phoneNumber,vehicleModel,status,uid,fcmToken,createdAt,lastServiceAt);

@override
String toString() {
  return 'LeadClient(plate: $plate, phoneNumber: $phoneNumber, vehicleModel: $vehicleModel, status: $status, uid: $uid, fcmToken: $fcmToken, createdAt: $createdAt, lastServiceAt: $lastServiceAt)';
}


}

/// @nodoc
abstract mixin class $LeadClientCopyWith<$Res>  {
  factory $LeadClientCopyWith(LeadClient value, $Res Function(LeadClient) _then) = _$LeadClientCopyWithImpl;
@useResult
$Res call({
 String plate, String phoneNumber, String vehicleModel, LeadStatus status, String? uid, String? fcmToken,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime lastServiceAt
});




}
/// @nodoc
class _$LeadClientCopyWithImpl<$Res>
    implements $LeadClientCopyWith<$Res> {
  _$LeadClientCopyWithImpl(this._self, this._then);

  final LeadClient _self;
  final $Res Function(LeadClient) _then;

/// Create a copy of LeadClient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plate = null,Object? phoneNumber = null,Object? vehicleModel = null,Object? status = null,Object? uid = freezed,Object? fcmToken = freezed,Object? createdAt = null,Object? lastServiceAt = null,}) {
  return _then(_self.copyWith(
plate: null == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,vehicleModel: null == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeadStatus,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastServiceAt: null == lastServiceAt ? _self.lastServiceAt : lastServiceAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LeadClient].
extension LeadClientPatterns on LeadClient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeadClient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeadClient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeadClient value)  $default,){
final _that = this;
switch (_that) {
case _LeadClient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeadClient value)?  $default,){
final _that = this;
switch (_that) {
case _LeadClient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String plate,  String phoneNumber,  String vehicleModel,  LeadStatus status,  String? uid,  String? fcmToken, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime lastServiceAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeadClient() when $default != null:
return $default(_that.plate,_that.phoneNumber,_that.vehicleModel,_that.status,_that.uid,_that.fcmToken,_that.createdAt,_that.lastServiceAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String plate,  String phoneNumber,  String vehicleModel,  LeadStatus status,  String? uid,  String? fcmToken, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime lastServiceAt)  $default,) {final _that = this;
switch (_that) {
case _LeadClient():
return $default(_that.plate,_that.phoneNumber,_that.vehicleModel,_that.status,_that.uid,_that.fcmToken,_that.createdAt,_that.lastServiceAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String plate,  String phoneNumber,  String vehicleModel,  LeadStatus status,  String? uid,  String? fcmToken, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime lastServiceAt)?  $default,) {final _that = this;
switch (_that) {
case _LeadClient() when $default != null:
return $default(_that.plate,_that.phoneNumber,_that.vehicleModel,_that.status,_that.uid,_that.fcmToken,_that.createdAt,_that.lastServiceAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeadClient implements LeadClient {
  const _LeadClient({required this.plate, required this.phoneNumber, required this.vehicleModel, required this.status, this.uid, this.fcmToken, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.lastServiceAt});
  factory _LeadClient.fromJson(Map<String, dynamic> json) => _$LeadClientFromJson(json);

@override final  String plate;
@override final  String phoneNumber;
@override final  String vehicleModel;
@override final  LeadStatus status;
@override final  String? uid;
@override final  String? fcmToken;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime lastServiceAt;

/// Create a copy of LeadClient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadClientCopyWith<_LeadClient> get copyWith => __$LeadClientCopyWithImpl<_LeadClient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeadClientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeadClient&&(identical(other.plate, plate) || other.plate == plate)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.status, status) || other.status == status)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastServiceAt, lastServiceAt) || other.lastServiceAt == lastServiceAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plate,phoneNumber,vehicleModel,status,uid,fcmToken,createdAt,lastServiceAt);

@override
String toString() {
  return 'LeadClient(plate: $plate, phoneNumber: $phoneNumber, vehicleModel: $vehicleModel, status: $status, uid: $uid, fcmToken: $fcmToken, createdAt: $createdAt, lastServiceAt: $lastServiceAt)';
}


}

/// @nodoc
abstract mixin class _$LeadClientCopyWith<$Res> implements $LeadClientCopyWith<$Res> {
  factory _$LeadClientCopyWith(_LeadClient value, $Res Function(_LeadClient) _then) = __$LeadClientCopyWithImpl;
@override @useResult
$Res call({
 String plate, String phoneNumber, String vehicleModel, LeadStatus status, String? uid, String? fcmToken,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime lastServiceAt
});




}
/// @nodoc
class __$LeadClientCopyWithImpl<$Res>
    implements _$LeadClientCopyWith<$Res> {
  __$LeadClientCopyWithImpl(this._self, this._then);

  final _LeadClient _self;
  final $Res Function(_LeadClient) _then;

/// Create a copy of LeadClient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plate = null,Object? phoneNumber = null,Object? vehicleModel = null,Object? status = null,Object? uid = freezed,Object? fcmToken = freezed,Object? createdAt = null,Object? lastServiceAt = null,}) {
  return _then(_LeadClient(
plate: null == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,vehicleModel: null == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeadStatus,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastServiceAt: null == lastServiceAt ? _self.lastServiceAt : lastServiceAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
