// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 String get id; String get userId; String get serviceId; double get amount; String get currency; String get status;// paid, pending, failed
 String get method;// stripe, subscription_credit
@TimestampConverter() DateTime get createdAt; String? get bookingId; String? get stripeSessionId;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.method, method) || other.method == method)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.stripeSessionId, stripeSessionId) || other.stripeSessionId == stripeSessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,serviceId,amount,currency,status,method,createdAt,bookingId,stripeSessionId);

@override
String toString() {
  return 'Order(id: $id, userId: $userId, serviceId: $serviceId, amount: $amount, currency: $currency, status: $status, method: $method, createdAt: $createdAt, bookingId: $bookingId, stripeSessionId: $stripeSessionId)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String serviceId, double amount, String currency, String status, String method,@TimestampConverter() DateTime createdAt, String? bookingId, String? stripeSessionId
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? serviceId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? method = null,Object? createdAt = null,Object? bookingId = freezed,Object? stripeSessionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,stripeSessionId: freezed == stripeSessionId ? _self.stripeSessionId : stripeSessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String serviceId,  double amount,  String currency,  String status,  String method, @TimestampConverter()  DateTime createdAt,  String? bookingId,  String? stripeSessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.userId,_that.serviceId,_that.amount,_that.currency,_that.status,_that.method,_that.createdAt,_that.bookingId,_that.stripeSessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String serviceId,  double amount,  String currency,  String status,  String method, @TimestampConverter()  DateTime createdAt,  String? bookingId,  String? stripeSessionId)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.userId,_that.serviceId,_that.amount,_that.currency,_that.status,_that.method,_that.createdAt,_that.bookingId,_that.stripeSessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String serviceId,  double amount,  String currency,  String status,  String method, @TimestampConverter()  DateTime createdAt,  String? bookingId,  String? stripeSessionId)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.userId,_that.serviceId,_that.amount,_that.currency,_that.status,_that.method,_that.createdAt,_that.bookingId,_that.stripeSessionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, required this.userId, required this.serviceId, required this.amount, required this.currency, required this.status, required this.method, @TimestampConverter() required this.createdAt, this.bookingId, this.stripeSessionId});
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String serviceId;
@override final  double amount;
@override final  String currency;
@override final  String status;
// paid, pending, failed
@override final  String method;
// stripe, subscription_credit
@override@TimestampConverter() final  DateTime createdAt;
@override final  String? bookingId;
@override final  String? stripeSessionId;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.method, method) || other.method == method)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.stripeSessionId, stripeSessionId) || other.stripeSessionId == stripeSessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,serviceId,amount,currency,status,method,createdAt,bookingId,stripeSessionId);

@override
String toString() {
  return 'Order(id: $id, userId: $userId, serviceId: $serviceId, amount: $amount, currency: $currency, status: $status, method: $method, createdAt: $createdAt, bookingId: $bookingId, stripeSessionId: $stripeSessionId)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String serviceId, double amount, String currency, String status, String method,@TimestampConverter() DateTime createdAt, String? bookingId, String? stripeSessionId
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? serviceId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? method = null,Object? createdAt = null,Object? bookingId = freezed,Object? stripeSessionId = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,stripeSessionId: freezed == stripeSessionId ? _self.stripeSessionId : stripeSessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
