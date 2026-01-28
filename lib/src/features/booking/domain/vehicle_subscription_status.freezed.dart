// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_subscription_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VehicleSubscriptionStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleSubscriptionStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VehicleSubscriptionStatus()';
}


}

/// @nodoc
class $VehicleSubscriptionStatusCopyWith<$Res>  {
$VehicleSubscriptionStatusCopyWith(VehicleSubscriptionStatus _, $Res Function(VehicleSubscriptionStatus) __);
}


/// Adds pattern-matching-related methods to [VehicleSubscriptionStatus].
extension VehicleSubscriptionStatusPatterns on VehicleSubscriptionStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CanUseSubscription value)?  canUseSubscription,TResult Function( _RequiresCashPayment value)?  requiresCashPayment,TResult Function( _SubscriptionExhausted value)?  subscriptionExhausted,TResult Function( _SubscriptionInactive value)?  subscriptionInactive,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CanUseSubscription() when canUseSubscription != null:
return canUseSubscription(_that);case _RequiresCashPayment() when requiresCashPayment != null:
return requiresCashPayment(_that);case _SubscriptionExhausted() when subscriptionExhausted != null:
return subscriptionExhausted(_that);case _SubscriptionInactive() when subscriptionInactive != null:
return subscriptionInactive(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CanUseSubscription value)  canUseSubscription,required TResult Function( _RequiresCashPayment value)  requiresCashPayment,required TResult Function( _SubscriptionExhausted value)  subscriptionExhausted,required TResult Function( _SubscriptionInactive value)  subscriptionInactive,}){
final _that = this;
switch (_that) {
case _CanUseSubscription():
return canUseSubscription(_that);case _RequiresCashPayment():
return requiresCashPayment(_that);case _SubscriptionExhausted():
return subscriptionExhausted(_that);case _SubscriptionInactive():
return subscriptionInactive(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CanUseSubscription value)?  canUseSubscription,TResult? Function( _RequiresCashPayment value)?  requiresCashPayment,TResult? Function( _SubscriptionExhausted value)?  subscriptionExhausted,TResult? Function( _SubscriptionInactive value)?  subscriptionInactive,}){
final _that = this;
switch (_that) {
case _CanUseSubscription() when canUseSubscription != null:
return canUseSubscription(_that);case _RequiresCashPayment() when requiresCashPayment != null:
return requiresCashPayment(_that);case _SubscriptionExhausted() when subscriptionExhausted != null:
return subscriptionExhausted(_that);case _SubscriptionInactive() when subscriptionInactive != null:
return subscriptionInactive(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int remainingWashes)?  canUseSubscription,TResult Function()?  requiresCashPayment,TResult Function()?  subscriptionExhausted,TResult Function()?  subscriptionInactive,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CanUseSubscription() when canUseSubscription != null:
return canUseSubscription(_that.remainingWashes);case _RequiresCashPayment() when requiresCashPayment != null:
return requiresCashPayment();case _SubscriptionExhausted() when subscriptionExhausted != null:
return subscriptionExhausted();case _SubscriptionInactive() when subscriptionInactive != null:
return subscriptionInactive();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int remainingWashes)  canUseSubscription,required TResult Function()  requiresCashPayment,required TResult Function()  subscriptionExhausted,required TResult Function()  subscriptionInactive,}) {final _that = this;
switch (_that) {
case _CanUseSubscription():
return canUseSubscription(_that.remainingWashes);case _RequiresCashPayment():
return requiresCashPayment();case _SubscriptionExhausted():
return subscriptionExhausted();case _SubscriptionInactive():
return subscriptionInactive();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int remainingWashes)?  canUseSubscription,TResult? Function()?  requiresCashPayment,TResult? Function()?  subscriptionExhausted,TResult? Function()?  subscriptionInactive,}) {final _that = this;
switch (_that) {
case _CanUseSubscription() when canUseSubscription != null:
return canUseSubscription(_that.remainingWashes);case _RequiresCashPayment() when requiresCashPayment != null:
return requiresCashPayment();case _SubscriptionExhausted() when subscriptionExhausted != null:
return subscriptionExhausted();case _SubscriptionInactive() when subscriptionInactive != null:
return subscriptionInactive();case _:
  return null;

}
}

}

/// @nodoc


class _CanUseSubscription implements VehicleSubscriptionStatus {
  const _CanUseSubscription({required this.remainingWashes});
  

 final  int remainingWashes;

/// Create a copy of VehicleSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CanUseSubscriptionCopyWith<_CanUseSubscription> get copyWith => __$CanUseSubscriptionCopyWithImpl<_CanUseSubscription>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CanUseSubscription&&(identical(other.remainingWashes, remainingWashes) || other.remainingWashes == remainingWashes));
}


@override
int get hashCode => Object.hash(runtimeType,remainingWashes);

@override
String toString() {
  return 'VehicleSubscriptionStatus.canUseSubscription(remainingWashes: $remainingWashes)';
}


}

/// @nodoc
abstract mixin class _$CanUseSubscriptionCopyWith<$Res> implements $VehicleSubscriptionStatusCopyWith<$Res> {
  factory _$CanUseSubscriptionCopyWith(_CanUseSubscription value, $Res Function(_CanUseSubscription) _then) = __$CanUseSubscriptionCopyWithImpl;
@useResult
$Res call({
 int remainingWashes
});




}
/// @nodoc
class __$CanUseSubscriptionCopyWithImpl<$Res>
    implements _$CanUseSubscriptionCopyWith<$Res> {
  __$CanUseSubscriptionCopyWithImpl(this._self, this._then);

  final _CanUseSubscription _self;
  final $Res Function(_CanUseSubscription) _then;

/// Create a copy of VehicleSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? remainingWashes = null,}) {
  return _then(_CanUseSubscription(
remainingWashes: null == remainingWashes ? _self.remainingWashes : remainingWashes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _RequiresCashPayment implements VehicleSubscriptionStatus {
  const _RequiresCashPayment();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequiresCashPayment);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VehicleSubscriptionStatus.requiresCashPayment()';
}


}




/// @nodoc


class _SubscriptionExhausted implements VehicleSubscriptionStatus {
  const _SubscriptionExhausted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionExhausted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VehicleSubscriptionStatus.subscriptionExhausted()';
}


}




/// @nodoc


class _SubscriptionInactive implements VehicleSubscriptionStatus {
  const _SubscriptionInactive();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionInactive);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VehicleSubscriptionStatus.subscriptionInactive()';
}


}




// dart format on
