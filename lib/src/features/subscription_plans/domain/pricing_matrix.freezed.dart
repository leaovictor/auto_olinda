// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_matrix.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PricingMatrix {

/// Prices mapped by vehicle category and service type
/// Structure: { VehicleCategory: { serviceType: price } }
 Map<String, Map<String, double>> get prices;/// Last update timestamp
 DateTime get updatedAt;
/// Create a copy of PricingMatrix
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricingMatrixCopyWith<PricingMatrix> get copyWith => _$PricingMatrixCopyWithImpl<PricingMatrix>(this as PricingMatrix, _$identity);

  /// Serializes this PricingMatrix to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricingMatrix&&const DeepCollectionEquality().equals(other.prices, prices)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(prices),updatedAt);

@override
String toString() {
  return 'PricingMatrix(prices: $prices, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PricingMatrixCopyWith<$Res>  {
  factory $PricingMatrixCopyWith(PricingMatrix value, $Res Function(PricingMatrix) _then) = _$PricingMatrixCopyWithImpl;
@useResult
$Res call({
 Map<String, Map<String, double>> prices, DateTime updatedAt
});




}
/// @nodoc
class _$PricingMatrixCopyWithImpl<$Res>
    implements $PricingMatrixCopyWith<$Res> {
  _$PricingMatrixCopyWithImpl(this._self, this._then);

  final PricingMatrix _self;
  final $Res Function(PricingMatrix) _then;

/// Create a copy of PricingMatrix
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prices = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
prices: null == prices ? _self.prices : prices // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, double>>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PricingMatrix].
extension PricingMatrixPatterns on PricingMatrix {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricingMatrix value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricingMatrix() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricingMatrix value)  $default,){
final _that = this;
switch (_that) {
case _PricingMatrix():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricingMatrix value)?  $default,){
final _that = this;
switch (_that) {
case _PricingMatrix() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, Map<String, double>> prices,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricingMatrix() when $default != null:
return $default(_that.prices,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, Map<String, double>> prices,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PricingMatrix():
return $default(_that.prices,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, Map<String, double>> prices,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PricingMatrix() when $default != null:
return $default(_that.prices,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PricingMatrix implements PricingMatrix {
  const _PricingMatrix({required final  Map<String, Map<String, double>> prices, required this.updatedAt}): _prices = prices;
  factory _PricingMatrix.fromJson(Map<String, dynamic> json) => _$PricingMatrixFromJson(json);

/// Prices mapped by vehicle category and service type
/// Structure: { VehicleCategory: { serviceType: price } }
 final  Map<String, Map<String, double>> _prices;
/// Prices mapped by vehicle category and service type
/// Structure: { VehicleCategory: { serviceType: price } }
@override Map<String, Map<String, double>> get prices {
  if (_prices is EqualUnmodifiableMapView) return _prices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_prices);
}

/// Last update timestamp
@override final  DateTime updatedAt;

/// Create a copy of PricingMatrix
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricingMatrixCopyWith<_PricingMatrix> get copyWith => __$PricingMatrixCopyWithImpl<_PricingMatrix>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PricingMatrixToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricingMatrix&&const DeepCollectionEquality().equals(other._prices, _prices)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_prices),updatedAt);

@override
String toString() {
  return 'PricingMatrix(prices: $prices, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PricingMatrixCopyWith<$Res> implements $PricingMatrixCopyWith<$Res> {
  factory _$PricingMatrixCopyWith(_PricingMatrix value, $Res Function(_PricingMatrix) _then) = __$PricingMatrixCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Map<String, double>> prices, DateTime updatedAt
});




}
/// @nodoc
class __$PricingMatrixCopyWithImpl<$Res>
    implements _$PricingMatrixCopyWith<$Res> {
  __$PricingMatrixCopyWithImpl(this._self, this._then);

  final _PricingMatrix _self;
  final $Res Function(_PricingMatrix) _then;

/// Create a copy of PricingMatrix
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prices = null,Object? updatedAt = null,}) {
  return _then(_PricingMatrix(
prices: null == prices ? _self._prices : prices // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, double>>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
