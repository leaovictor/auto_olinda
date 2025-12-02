// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_with_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookingWithDetails {

 Booking get booking; AppUser? get user; Vehicle? get vehicle;
/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingWithDetailsCopyWith<BookingWithDetails> get copyWith => _$BookingWithDetailsCopyWithImpl<BookingWithDetails>(this as BookingWithDetails, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingWithDetails&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.user, user) || other.user == user)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle));
}


@override
int get hashCode => Object.hash(runtimeType,booking,user,vehicle);

@override
String toString() {
  return 'BookingWithDetails(booking: $booking, user: $user, vehicle: $vehicle)';
}


}

/// @nodoc
abstract mixin class $BookingWithDetailsCopyWith<$Res>  {
  factory $BookingWithDetailsCopyWith(BookingWithDetails value, $Res Function(BookingWithDetails) _then) = _$BookingWithDetailsCopyWithImpl;
@useResult
$Res call({
 Booking booking, AppUser? user, Vehicle? vehicle
});


$BookingCopyWith<$Res> get booking;$AppUserCopyWith<$Res>? get user;$VehicleCopyWith<$Res>? get vehicle;

}
/// @nodoc
class _$BookingWithDetailsCopyWithImpl<$Res>
    implements $BookingWithDetailsCopyWith<$Res> {
  _$BookingWithDetailsCopyWithImpl(this._self, this._then);

  final BookingWithDetails _self;
  final $Res Function(BookingWithDetails) _then;

/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? booking = null,Object? user = freezed,Object? vehicle = freezed,}) {
  return _then(_self.copyWith(
booking: null == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AppUser?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as Vehicle?,
  ));
}
/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingCopyWith<$Res> get booking {
  
  return $BookingCopyWith<$Res>(_self.booking, (value) {
    return _then(_self.copyWith(booking: value));
  });
}/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AppUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $VehicleCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookingWithDetails].
extension BookingWithDetailsPatterns on BookingWithDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingWithDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingWithDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingWithDetails value)  $default,){
final _that = this;
switch (_that) {
case _BookingWithDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingWithDetails value)?  $default,){
final _that = this;
switch (_that) {
case _BookingWithDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Booking booking,  AppUser? user,  Vehicle? vehicle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingWithDetails() when $default != null:
return $default(_that.booking,_that.user,_that.vehicle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Booking booking,  AppUser? user,  Vehicle? vehicle)  $default,) {final _that = this;
switch (_that) {
case _BookingWithDetails():
return $default(_that.booking,_that.user,_that.vehicle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Booking booking,  AppUser? user,  Vehicle? vehicle)?  $default,) {final _that = this;
switch (_that) {
case _BookingWithDetails() when $default != null:
return $default(_that.booking,_that.user,_that.vehicle);case _:
  return null;

}
}

}

/// @nodoc


class _BookingWithDetails implements BookingWithDetails {
  const _BookingWithDetails({required this.booking, this.user, this.vehicle});
  

@override final  Booking booking;
@override final  AppUser? user;
@override final  Vehicle? vehicle;

/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingWithDetailsCopyWith<_BookingWithDetails> get copyWith => __$BookingWithDetailsCopyWithImpl<_BookingWithDetails>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingWithDetails&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.user, user) || other.user == user)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle));
}


@override
int get hashCode => Object.hash(runtimeType,booking,user,vehicle);

@override
String toString() {
  return 'BookingWithDetails(booking: $booking, user: $user, vehicle: $vehicle)';
}


}

/// @nodoc
abstract mixin class _$BookingWithDetailsCopyWith<$Res> implements $BookingWithDetailsCopyWith<$Res> {
  factory _$BookingWithDetailsCopyWith(_BookingWithDetails value, $Res Function(_BookingWithDetails) _then) = __$BookingWithDetailsCopyWithImpl;
@override @useResult
$Res call({
 Booking booking, AppUser? user, Vehicle? vehicle
});


@override $BookingCopyWith<$Res> get booking;@override $AppUserCopyWith<$Res>? get user;@override $VehicleCopyWith<$Res>? get vehicle;

}
/// @nodoc
class __$BookingWithDetailsCopyWithImpl<$Res>
    implements _$BookingWithDetailsCopyWith<$Res> {
  __$BookingWithDetailsCopyWithImpl(this._self, this._then);

  final _BookingWithDetails _self;
  final $Res Function(_BookingWithDetails) _then;

/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? booking = null,Object? user = freezed,Object? vehicle = freezed,}) {
  return _then(_BookingWithDetails(
booking: null == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AppUser?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as Vehicle?,
  ));
}

/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingCopyWith<$Res> get booking {
  
  return $BookingCopyWith<$Res>(_self.booking, (value) {
    return _then(_self.copyWith(booking: value));
  });
}/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AppUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of BookingWithDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $VehicleCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}
}

// dart format on
