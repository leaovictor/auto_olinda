// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionDetails {

 String get status; bool get cancelAtPeriodEnd; int get currentPeriodEnd; SubscriptionPaymentMethod? get paymentMethod;
/// Create a copy of SubscriptionDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionDetailsCopyWith<SubscriptionDetails> get copyWith => _$SubscriptionDetailsCopyWithImpl<SubscriptionDetails>(this as SubscriptionDetails, _$identity);

  /// Serializes this SubscriptionDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionDetails&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) || other.cancelAtPeriodEnd == cancelAtPeriodEnd)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,cancelAtPeriodEnd,currentPeriodEnd,paymentMethod);

@override
String toString() {
  return 'SubscriptionDetails(status: $status, cancelAtPeriodEnd: $cancelAtPeriodEnd, currentPeriodEnd: $currentPeriodEnd, paymentMethod: $paymentMethod)';
}


}

/// @nodoc
abstract mixin class $SubscriptionDetailsCopyWith<$Res>  {
  factory $SubscriptionDetailsCopyWith(SubscriptionDetails value, $Res Function(SubscriptionDetails) _then) = _$SubscriptionDetailsCopyWithImpl;
@useResult
$Res call({
 String status, bool cancelAtPeriodEnd, int currentPeriodEnd, SubscriptionPaymentMethod? paymentMethod
});


$SubscriptionPaymentMethodCopyWith<$Res>? get paymentMethod;

}
/// @nodoc
class _$SubscriptionDetailsCopyWithImpl<$Res>
    implements $SubscriptionDetailsCopyWith<$Res> {
  _$SubscriptionDetailsCopyWithImpl(this._self, this._then);

  final SubscriptionDetails _self;
  final $Res Function(SubscriptionDetails) _then;

/// Create a copy of SubscriptionDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? cancelAtPeriodEnd = null,Object? currentPeriodEnd = null,Object? paymentMethod = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,currentPeriodEnd: null == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as int,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as SubscriptionPaymentMethod?,
  ));
}
/// Create a copy of SubscriptionDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionPaymentMethodCopyWith<$Res>? get paymentMethod {
    if (_self.paymentMethod == null) {
    return null;
  }

  return $SubscriptionPaymentMethodCopyWith<$Res>(_self.paymentMethod!, (value) {
    return _then(_self.copyWith(paymentMethod: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubscriptionDetails].
extension SubscriptionDetailsPatterns on SubscriptionDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionDetails value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionDetails():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionDetails value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  bool cancelAtPeriodEnd,  int currentPeriodEnd,  SubscriptionPaymentMethod? paymentMethod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionDetails() when $default != null:
return $default(_that.status,_that.cancelAtPeriodEnd,_that.currentPeriodEnd,_that.paymentMethod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  bool cancelAtPeriodEnd,  int currentPeriodEnd,  SubscriptionPaymentMethod? paymentMethod)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionDetails():
return $default(_that.status,_that.cancelAtPeriodEnd,_that.currentPeriodEnd,_that.paymentMethod);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  bool cancelAtPeriodEnd,  int currentPeriodEnd,  SubscriptionPaymentMethod? paymentMethod)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionDetails() when $default != null:
return $default(_that.status,_that.cancelAtPeriodEnd,_that.currentPeriodEnd,_that.paymentMethod);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionDetails implements SubscriptionDetails {
  const _SubscriptionDetails({required this.status, required this.cancelAtPeriodEnd, required this.currentPeriodEnd, this.paymentMethod});
  factory _SubscriptionDetails.fromJson(Map<String, dynamic> json) => _$SubscriptionDetailsFromJson(json);

@override final  String status;
@override final  bool cancelAtPeriodEnd;
@override final  int currentPeriodEnd;
@override final  SubscriptionPaymentMethod? paymentMethod;

/// Create a copy of SubscriptionDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionDetailsCopyWith<_SubscriptionDetails> get copyWith => __$SubscriptionDetailsCopyWithImpl<_SubscriptionDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionDetails&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) || other.cancelAtPeriodEnd == cancelAtPeriodEnd)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,cancelAtPeriodEnd,currentPeriodEnd,paymentMethod);

@override
String toString() {
  return 'SubscriptionDetails(status: $status, cancelAtPeriodEnd: $cancelAtPeriodEnd, currentPeriodEnd: $currentPeriodEnd, paymentMethod: $paymentMethod)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionDetailsCopyWith<$Res> implements $SubscriptionDetailsCopyWith<$Res> {
  factory _$SubscriptionDetailsCopyWith(_SubscriptionDetails value, $Res Function(_SubscriptionDetails) _then) = __$SubscriptionDetailsCopyWithImpl;
@override @useResult
$Res call({
 String status, bool cancelAtPeriodEnd, int currentPeriodEnd, SubscriptionPaymentMethod? paymentMethod
});


@override $SubscriptionPaymentMethodCopyWith<$Res>? get paymentMethod;

}
/// @nodoc
class __$SubscriptionDetailsCopyWithImpl<$Res>
    implements _$SubscriptionDetailsCopyWith<$Res> {
  __$SubscriptionDetailsCopyWithImpl(this._self, this._then);

  final _SubscriptionDetails _self;
  final $Res Function(_SubscriptionDetails) _then;

/// Create a copy of SubscriptionDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? cancelAtPeriodEnd = null,Object? currentPeriodEnd = null,Object? paymentMethod = freezed,}) {
  return _then(_SubscriptionDetails(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,currentPeriodEnd: null == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as int,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as SubscriptionPaymentMethod?,
  ));
}

/// Create a copy of SubscriptionDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionPaymentMethodCopyWith<$Res>? get paymentMethod {
    if (_self.paymentMethod == null) {
    return null;
  }

  return $SubscriptionPaymentMethodCopyWith<$Res>(_self.paymentMethod!, (value) {
    return _then(_self.copyWith(paymentMethod: value));
  });
}
}


/// @nodoc
mixin _$SubscriptionPaymentMethod {

 String get brand; String get last4; int get expMonth; int get expYear;
/// Create a copy of SubscriptionPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionPaymentMethodCopyWith<SubscriptionPaymentMethod> get copyWith => _$SubscriptionPaymentMethodCopyWithImpl<SubscriptionPaymentMethod>(this as SubscriptionPaymentMethod, _$identity);

  /// Serializes this SubscriptionPaymentMethod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionPaymentMethod&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.expMonth, expMonth) || other.expMonth == expMonth)&&(identical(other.expYear, expYear) || other.expYear == expYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brand,last4,expMonth,expYear);

@override
String toString() {
  return 'SubscriptionPaymentMethod(brand: $brand, last4: $last4, expMonth: $expMonth, expYear: $expYear)';
}


}

/// @nodoc
abstract mixin class $SubscriptionPaymentMethodCopyWith<$Res>  {
  factory $SubscriptionPaymentMethodCopyWith(SubscriptionPaymentMethod value, $Res Function(SubscriptionPaymentMethod) _then) = _$SubscriptionPaymentMethodCopyWithImpl;
@useResult
$Res call({
 String brand, String last4, int expMonth, int expYear
});




}
/// @nodoc
class _$SubscriptionPaymentMethodCopyWithImpl<$Res>
    implements $SubscriptionPaymentMethodCopyWith<$Res> {
  _$SubscriptionPaymentMethodCopyWithImpl(this._self, this._then);

  final SubscriptionPaymentMethod _self;
  final $Res Function(SubscriptionPaymentMethod) _then;

/// Create a copy of SubscriptionPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? brand = null,Object? last4 = null,Object? expMonth = null,Object? expYear = null,}) {
  return _then(_self.copyWith(
brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,expMonth: null == expMonth ? _self.expMonth : expMonth // ignore: cast_nullable_to_non_nullable
as int,expYear: null == expYear ? _self.expYear : expYear // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionPaymentMethod].
extension SubscriptionPaymentMethodPatterns on SubscriptionPaymentMethod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionPaymentMethod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionPaymentMethod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionPaymentMethod value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPaymentMethod():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionPaymentMethod value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPaymentMethod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String brand,  String last4,  int expMonth,  int expYear)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionPaymentMethod() when $default != null:
return $default(_that.brand,_that.last4,_that.expMonth,_that.expYear);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String brand,  String last4,  int expMonth,  int expYear)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPaymentMethod():
return $default(_that.brand,_that.last4,_that.expMonth,_that.expYear);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String brand,  String last4,  int expMonth,  int expYear)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPaymentMethod() when $default != null:
return $default(_that.brand,_that.last4,_that.expMonth,_that.expYear);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionPaymentMethod implements SubscriptionPaymentMethod {
  const _SubscriptionPaymentMethod({required this.brand, required this.last4, required this.expMonth, required this.expYear});
  factory _SubscriptionPaymentMethod.fromJson(Map<String, dynamic> json) => _$SubscriptionPaymentMethodFromJson(json);

@override final  String brand;
@override final  String last4;
@override final  int expMonth;
@override final  int expYear;

/// Create a copy of SubscriptionPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionPaymentMethodCopyWith<_SubscriptionPaymentMethod> get copyWith => __$SubscriptionPaymentMethodCopyWithImpl<_SubscriptionPaymentMethod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionPaymentMethodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionPaymentMethod&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.expMonth, expMonth) || other.expMonth == expMonth)&&(identical(other.expYear, expYear) || other.expYear == expYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brand,last4,expMonth,expYear);

@override
String toString() {
  return 'SubscriptionPaymentMethod(brand: $brand, last4: $last4, expMonth: $expMonth, expYear: $expYear)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionPaymentMethodCopyWith<$Res> implements $SubscriptionPaymentMethodCopyWith<$Res> {
  factory _$SubscriptionPaymentMethodCopyWith(_SubscriptionPaymentMethod value, $Res Function(_SubscriptionPaymentMethod) _then) = __$SubscriptionPaymentMethodCopyWithImpl;
@override @useResult
$Res call({
 String brand, String last4, int expMonth, int expYear
});




}
/// @nodoc
class __$SubscriptionPaymentMethodCopyWithImpl<$Res>
    implements _$SubscriptionPaymentMethodCopyWith<$Res> {
  __$SubscriptionPaymentMethodCopyWithImpl(this._self, this._then);

  final _SubscriptionPaymentMethod _self;
  final $Res Function(_SubscriptionPaymentMethod) _then;

/// Create a copy of SubscriptionPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? brand = null,Object? last4 = null,Object? expMonth = null,Object? expYear = null,}) {
  return _then(_SubscriptionPaymentMethod(
brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,expMonth: null == expMonth ? _self.expMonth : expMonth // ignore: cast_nullable_to_non_nullable
as int,expYear: null == expYear ? _self.expYear : expYear // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
