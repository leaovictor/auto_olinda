// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BusinessConfig {

 String get openTime;// Opening hour (HH:mm)
 String get closeTime;// Closing hour (HH:mm)
 int get slotDurationMinutes;// Duration per appointment slot
 int get bufferMinutes;// Buffer between appointments
 bool get allowOnlineBooking;// Accept online bookings?
 bool get acceptsWalkIns;// Walk-in customers?
 String get defaultPaymentMethod;// pix | cash | card
 List<String> get workingDays; String? get timezone;// e.g., "America/Sao_Paulo"
 int get maxCarsPerSlot;
/// Create a copy of BusinessConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessConfigCopyWith<BusinessConfig> get copyWith => _$BusinessConfigCopyWithImpl<BusinessConfig>(this as BusinessConfig, _$identity);

  /// Serializes this BusinessConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessConfig&&(identical(other.openTime, openTime) || other.openTime == openTime)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.slotDurationMinutes, slotDurationMinutes) || other.slotDurationMinutes == slotDurationMinutes)&&(identical(other.bufferMinutes, bufferMinutes) || other.bufferMinutes == bufferMinutes)&&(identical(other.allowOnlineBooking, allowOnlineBooking) || other.allowOnlineBooking == allowOnlineBooking)&&(identical(other.acceptsWalkIns, acceptsWalkIns) || other.acceptsWalkIns == acceptsWalkIns)&&(identical(other.defaultPaymentMethod, defaultPaymentMethod) || other.defaultPaymentMethod == defaultPaymentMethod)&&const DeepCollectionEquality().equals(other.workingDays, workingDays)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.maxCarsPerSlot, maxCarsPerSlot) || other.maxCarsPerSlot == maxCarsPerSlot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,openTime,closeTime,slotDurationMinutes,bufferMinutes,allowOnlineBooking,acceptsWalkIns,defaultPaymentMethod,const DeepCollectionEquality().hash(workingDays),timezone,maxCarsPerSlot);

@override
String toString() {
  return 'BusinessConfig(openTime: $openTime, closeTime: $closeTime, slotDurationMinutes: $slotDurationMinutes, bufferMinutes: $bufferMinutes, allowOnlineBooking: $allowOnlineBooking, acceptsWalkIns: $acceptsWalkIns, defaultPaymentMethod: $defaultPaymentMethod, workingDays: $workingDays, timezone: $timezone, maxCarsPerSlot: $maxCarsPerSlot)';
}


}

/// @nodoc
abstract mixin class $BusinessConfigCopyWith<$Res>  {
  factory $BusinessConfigCopyWith(BusinessConfig value, $Res Function(BusinessConfig) _then) = _$BusinessConfigCopyWithImpl;
@useResult
$Res call({
 String openTime, String closeTime, int slotDurationMinutes, int bufferMinutes, bool allowOnlineBooking, bool acceptsWalkIns, String defaultPaymentMethod, List<String> workingDays, String? timezone, int maxCarsPerSlot
});




}
/// @nodoc
class _$BusinessConfigCopyWithImpl<$Res>
    implements $BusinessConfigCopyWith<$Res> {
  _$BusinessConfigCopyWithImpl(this._self, this._then);

  final BusinessConfig _self;
  final $Res Function(BusinessConfig) _then;

/// Create a copy of BusinessConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? openTime = null,Object? closeTime = null,Object? slotDurationMinutes = null,Object? bufferMinutes = null,Object? allowOnlineBooking = null,Object? acceptsWalkIns = null,Object? defaultPaymentMethod = null,Object? workingDays = null,Object? timezone = freezed,Object? maxCarsPerSlot = null,}) {
  return _then(_self.copyWith(
openTime: null == openTime ? _self.openTime : openTime // ignore: cast_nullable_to_non_nullable
as String,closeTime: null == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as String,slotDurationMinutes: null == slotDurationMinutes ? _self.slotDurationMinutes : slotDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferMinutes: null == bufferMinutes ? _self.bufferMinutes : bufferMinutes // ignore: cast_nullable_to_non_nullable
as int,allowOnlineBooking: null == allowOnlineBooking ? _self.allowOnlineBooking : allowOnlineBooking // ignore: cast_nullable_to_non_nullable
as bool,acceptsWalkIns: null == acceptsWalkIns ? _self.acceptsWalkIns : acceptsWalkIns // ignore: cast_nullable_to_non_nullable
as bool,defaultPaymentMethod: null == defaultPaymentMethod ? _self.defaultPaymentMethod : defaultPaymentMethod // ignore: cast_nullable_to_non_nullable
as String,workingDays: null == workingDays ? _self.workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as List<String>,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,maxCarsPerSlot: null == maxCarsPerSlot ? _self.maxCarsPerSlot : maxCarsPerSlot // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessConfig].
extension BusinessConfigPatterns on BusinessConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessConfig value)  $default,){
final _that = this;
switch (_that) {
case _BusinessConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessConfig value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String openTime,  String closeTime,  int slotDurationMinutes,  int bufferMinutes,  bool allowOnlineBooking,  bool acceptsWalkIns,  String defaultPaymentMethod,  List<String> workingDays,  String? timezone,  int maxCarsPerSlot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessConfig() when $default != null:
return $default(_that.openTime,_that.closeTime,_that.slotDurationMinutes,_that.bufferMinutes,_that.allowOnlineBooking,_that.acceptsWalkIns,_that.defaultPaymentMethod,_that.workingDays,_that.timezone,_that.maxCarsPerSlot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String openTime,  String closeTime,  int slotDurationMinutes,  int bufferMinutes,  bool allowOnlineBooking,  bool acceptsWalkIns,  String defaultPaymentMethod,  List<String> workingDays,  String? timezone,  int maxCarsPerSlot)  $default,) {final _that = this;
switch (_that) {
case _BusinessConfig():
return $default(_that.openTime,_that.closeTime,_that.slotDurationMinutes,_that.bufferMinutes,_that.allowOnlineBooking,_that.acceptsWalkIns,_that.defaultPaymentMethod,_that.workingDays,_that.timezone,_that.maxCarsPerSlot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String openTime,  String closeTime,  int slotDurationMinutes,  int bufferMinutes,  bool allowOnlineBooking,  bool acceptsWalkIns,  String defaultPaymentMethod,  List<String> workingDays,  String? timezone,  int maxCarsPerSlot)?  $default,) {final _that = this;
switch (_that) {
case _BusinessConfig() when $default != null:
return $default(_that.openTime,_that.closeTime,_that.slotDurationMinutes,_that.bufferMinutes,_that.allowOnlineBooking,_that.acceptsWalkIns,_that.defaultPaymentMethod,_that.workingDays,_that.timezone,_that.maxCarsPerSlot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessConfig implements BusinessConfig {
  const _BusinessConfig({this.openTime = '08:00', this.closeTime = '18:00', this.slotDurationMinutes = 30, this.bufferMinutes = 0, this.allowOnlineBooking = true, this.acceptsWalkIns = true, this.defaultPaymentMethod = 'pix', final  List<String> workingDays = const ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'], this.timezone, this.maxCarsPerSlot = 1}): _workingDays = workingDays;
  factory _BusinessConfig.fromJson(Map<String, dynamic> json) => _$BusinessConfigFromJson(json);

@override@JsonKey() final  String openTime;
// Opening hour (HH:mm)
@override@JsonKey() final  String closeTime;
// Closing hour (HH:mm)
@override@JsonKey() final  int slotDurationMinutes;
// Duration per appointment slot
@override@JsonKey() final  int bufferMinutes;
// Buffer between appointments
@override@JsonKey() final  bool allowOnlineBooking;
// Accept online bookings?
@override@JsonKey() final  bool acceptsWalkIns;
// Walk-in customers?
@override@JsonKey() final  String defaultPaymentMethod;
// pix | cash | card
 final  List<String> _workingDays;
// pix | cash | card
@override@JsonKey() List<String> get workingDays {
  if (_workingDays is EqualUnmodifiableListView) return _workingDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workingDays);
}

@override final  String? timezone;
// e.g., "America/Sao_Paulo"
@override@JsonKey() final  int maxCarsPerSlot;

/// Create a copy of BusinessConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessConfigCopyWith<_BusinessConfig> get copyWith => __$BusinessConfigCopyWithImpl<_BusinessConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessConfig&&(identical(other.openTime, openTime) || other.openTime == openTime)&&(identical(other.closeTime, closeTime) || other.closeTime == closeTime)&&(identical(other.slotDurationMinutes, slotDurationMinutes) || other.slotDurationMinutes == slotDurationMinutes)&&(identical(other.bufferMinutes, bufferMinutes) || other.bufferMinutes == bufferMinutes)&&(identical(other.allowOnlineBooking, allowOnlineBooking) || other.allowOnlineBooking == allowOnlineBooking)&&(identical(other.acceptsWalkIns, acceptsWalkIns) || other.acceptsWalkIns == acceptsWalkIns)&&(identical(other.defaultPaymentMethod, defaultPaymentMethod) || other.defaultPaymentMethod == defaultPaymentMethod)&&const DeepCollectionEquality().equals(other._workingDays, _workingDays)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.maxCarsPerSlot, maxCarsPerSlot) || other.maxCarsPerSlot == maxCarsPerSlot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,openTime,closeTime,slotDurationMinutes,bufferMinutes,allowOnlineBooking,acceptsWalkIns,defaultPaymentMethod,const DeepCollectionEquality().hash(_workingDays),timezone,maxCarsPerSlot);

@override
String toString() {
  return 'BusinessConfig(openTime: $openTime, closeTime: $closeTime, slotDurationMinutes: $slotDurationMinutes, bufferMinutes: $bufferMinutes, allowOnlineBooking: $allowOnlineBooking, acceptsWalkIns: $acceptsWalkIns, defaultPaymentMethod: $defaultPaymentMethod, workingDays: $workingDays, timezone: $timezone, maxCarsPerSlot: $maxCarsPerSlot)';
}


}

/// @nodoc
abstract mixin class _$BusinessConfigCopyWith<$Res> implements $BusinessConfigCopyWith<$Res> {
  factory _$BusinessConfigCopyWith(_BusinessConfig value, $Res Function(_BusinessConfig) _then) = __$BusinessConfigCopyWithImpl;
@override @useResult
$Res call({
 String openTime, String closeTime, int slotDurationMinutes, int bufferMinutes, bool allowOnlineBooking, bool acceptsWalkIns, String defaultPaymentMethod, List<String> workingDays, String? timezone, int maxCarsPerSlot
});




}
/// @nodoc
class __$BusinessConfigCopyWithImpl<$Res>
    implements _$BusinessConfigCopyWith<$Res> {
  __$BusinessConfigCopyWithImpl(this._self, this._then);

  final _BusinessConfig _self;
  final $Res Function(_BusinessConfig) _then;

/// Create a copy of BusinessConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? openTime = null,Object? closeTime = null,Object? slotDurationMinutes = null,Object? bufferMinutes = null,Object? allowOnlineBooking = null,Object? acceptsWalkIns = null,Object? defaultPaymentMethod = null,Object? workingDays = null,Object? timezone = freezed,Object? maxCarsPerSlot = null,}) {
  return _then(_BusinessConfig(
openTime: null == openTime ? _self.openTime : openTime // ignore: cast_nullable_to_non_nullable
as String,closeTime: null == closeTime ? _self.closeTime : closeTime // ignore: cast_nullable_to_non_nullable
as String,slotDurationMinutes: null == slotDurationMinutes ? _self.slotDurationMinutes : slotDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferMinutes: null == bufferMinutes ? _self.bufferMinutes : bufferMinutes // ignore: cast_nullable_to_non_nullable
as int,allowOnlineBooking: null == allowOnlineBooking ? _self.allowOnlineBooking : allowOnlineBooking // ignore: cast_nullable_to_non_nullable
as bool,acceptsWalkIns: null == acceptsWalkIns ? _self.acceptsWalkIns : acceptsWalkIns // ignore: cast_nullable_to_non_nullable
as bool,defaultPaymentMethod: null == defaultPaymentMethod ? _self.defaultPaymentMethod : defaultPaymentMethod // ignore: cast_nullable_to_non_nullable
as String,workingDays: null == workingDays ? _self._workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as List<String>,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,maxCarsPerSlot: null == maxCarsPerSlot ? _self.maxCarsPerSlot : maxCarsPerSlot // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
