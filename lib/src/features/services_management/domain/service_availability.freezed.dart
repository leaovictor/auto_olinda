// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_availability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServiceAvailability {

 String get date;// YYYY-MM-DD
 String get serviceId;// Which independent service
 bool get isOpen; Map<String, int> get slots;
/// Create a copy of ServiceAvailability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceAvailabilityCopyWith<ServiceAvailability> get copyWith => _$ServiceAvailabilityCopyWithImpl<ServiceAvailability>(this as ServiceAvailability, _$identity);

  /// Serializes this ServiceAvailability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceAvailability&&(identical(other.date, date) || other.date == date)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&const DeepCollectionEquality().equals(other.slots, slots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,serviceId,isOpen,const DeepCollectionEquality().hash(slots));

@override
String toString() {
  return 'ServiceAvailability(date: $date, serviceId: $serviceId, isOpen: $isOpen, slots: $slots)';
}


}

/// @nodoc
abstract mixin class $ServiceAvailabilityCopyWith<$Res>  {
  factory $ServiceAvailabilityCopyWith(ServiceAvailability value, $Res Function(ServiceAvailability) _then) = _$ServiceAvailabilityCopyWithImpl;
@useResult
$Res call({
 String date, String serviceId, bool isOpen, Map<String, int> slots
});




}
/// @nodoc
class _$ServiceAvailabilityCopyWithImpl<$Res>
    implements $ServiceAvailabilityCopyWith<$Res> {
  _$ServiceAvailabilityCopyWithImpl(this._self, this._then);

  final ServiceAvailability _self;
  final $Res Function(ServiceAvailability) _then;

/// Create a copy of ServiceAvailability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? serviceId = null,Object? isOpen = null,Object? slots = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceAvailability].
extension ServiceAvailabilityPatterns on ServiceAvailability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceAvailability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceAvailability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceAvailability value)  $default,){
final _that = this;
switch (_that) {
case _ServiceAvailability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceAvailability value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceAvailability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String serviceId,  bool isOpen,  Map<String, int> slots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceAvailability() when $default != null:
return $default(_that.date,_that.serviceId,_that.isOpen,_that.slots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String serviceId,  bool isOpen,  Map<String, int> slots)  $default,) {final _that = this;
switch (_that) {
case _ServiceAvailability():
return $default(_that.date,_that.serviceId,_that.isOpen,_that.slots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String serviceId,  bool isOpen,  Map<String, int> slots)?  $default,) {final _that = this;
switch (_that) {
case _ServiceAvailability() when $default != null:
return $default(_that.date,_that.serviceId,_that.isOpen,_that.slots);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceAvailability implements ServiceAvailability {
  const _ServiceAvailability({required this.date, required this.serviceId, required this.isOpen, required final  Map<String, int> slots}): _slots = slots;
  factory _ServiceAvailability.fromJson(Map<String, dynamic> json) => _$ServiceAvailabilityFromJson(json);

@override final  String date;
// YYYY-MM-DD
@override final  String serviceId;
// Which independent service
@override final  bool isOpen;
 final  Map<String, int> _slots;
@override Map<String, int> get slots {
  if (_slots is EqualUnmodifiableMapView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_slots);
}


/// Create a copy of ServiceAvailability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceAvailabilityCopyWith<_ServiceAvailability> get copyWith => __$ServiceAvailabilityCopyWithImpl<_ServiceAvailability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceAvailabilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceAvailability&&(identical(other.date, date) || other.date == date)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&const DeepCollectionEquality().equals(other._slots, _slots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,serviceId,isOpen,const DeepCollectionEquality().hash(_slots));

@override
String toString() {
  return 'ServiceAvailability(date: $date, serviceId: $serviceId, isOpen: $isOpen, slots: $slots)';
}


}

/// @nodoc
abstract mixin class _$ServiceAvailabilityCopyWith<$Res> implements $ServiceAvailabilityCopyWith<$Res> {
  factory _$ServiceAvailabilityCopyWith(_ServiceAvailability value, $Res Function(_ServiceAvailability) _then) = __$ServiceAvailabilityCopyWithImpl;
@override @useResult
$Res call({
 String date, String serviceId, bool isOpen, Map<String, int> slots
});




}
/// @nodoc
class __$ServiceAvailabilityCopyWithImpl<$Res>
    implements _$ServiceAvailabilityCopyWith<$Res> {
  __$ServiceAvailabilityCopyWithImpl(this._self, this._then);

  final _ServiceAvailability _self;
  final $Res Function(_ServiceAvailability) _then;

/// Create a copy of ServiceAvailability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? serviceId = null,Object? isOpen = null,Object? slots = null,}) {
  return _then(_ServiceAvailability(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
