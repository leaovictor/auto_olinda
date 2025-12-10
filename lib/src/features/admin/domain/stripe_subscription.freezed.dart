// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stripe_subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StripeSubscription {

 String get id; String get customerId; String? get customerEmail; String? get customerName; String get status; double get amount; String get currency; String get interval; int get currentPeriodStart; int get currentPeriodEnd; int? get canceledAt; int get createdAt;
/// Create a copy of StripeSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StripeSubscriptionCopyWith<StripeSubscription> get copyWith => _$StripeSubscriptionCopyWithImpl<StripeSubscription>(this as StripeSubscription, _$identity);

  /// Serializes this StripeSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StripeSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.currentPeriodStart, currentPeriodStart) || other.currentPeriodStart == currentPeriodStart)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.canceledAt, canceledAt) || other.canceledAt == canceledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,customerEmail,customerName,status,amount,currency,interval,currentPeriodStart,currentPeriodEnd,canceledAt,createdAt);

@override
String toString() {
  return 'StripeSubscription(id: $id, customerId: $customerId, customerEmail: $customerEmail, customerName: $customerName, status: $status, amount: $amount, currency: $currency, interval: $interval, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, canceledAt: $canceledAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $StripeSubscriptionCopyWith<$Res>  {
  factory $StripeSubscriptionCopyWith(StripeSubscription value, $Res Function(StripeSubscription) _then) = _$StripeSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String customerId, String? customerEmail, String? customerName, String status, double amount, String currency, String interval, int currentPeriodStart, int currentPeriodEnd, int? canceledAt, int createdAt
});




}
/// @nodoc
class _$StripeSubscriptionCopyWithImpl<$Res>
    implements $StripeSubscriptionCopyWith<$Res> {
  _$StripeSubscriptionCopyWithImpl(this._self, this._then);

  final StripeSubscription _self;
  final $Res Function(StripeSubscription) _then;

/// Create a copy of StripeSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = null,Object? customerEmail = freezed,Object? customerName = freezed,Object? status = null,Object? amount = null,Object? currency = null,Object? interval = null,Object? currentPeriodStart = null,Object? currentPeriodEnd = null,Object? canceledAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String,currentPeriodStart: null == currentPeriodStart ? _self.currentPeriodStart : currentPeriodStart // ignore: cast_nullable_to_non_nullable
as int,currentPeriodEnd: null == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as int,canceledAt: freezed == canceledAt ? _self.canceledAt : canceledAt // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StripeSubscription].
extension StripeSubscriptionPatterns on StripeSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StripeSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StripeSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StripeSubscription value)  $default,){
final _that = this;
switch (_that) {
case _StripeSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StripeSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _StripeSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerId,  String? customerEmail,  String? customerName,  String status,  double amount,  String currency,  String interval,  int currentPeriodStart,  int currentPeriodEnd,  int? canceledAt,  int createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StripeSubscription() when $default != null:
return $default(_that.id,_that.customerId,_that.customerEmail,_that.customerName,_that.status,_that.amount,_that.currency,_that.interval,_that.currentPeriodStart,_that.currentPeriodEnd,_that.canceledAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerId,  String? customerEmail,  String? customerName,  String status,  double amount,  String currency,  String interval,  int currentPeriodStart,  int currentPeriodEnd,  int? canceledAt,  int createdAt)  $default,) {final _that = this;
switch (_that) {
case _StripeSubscription():
return $default(_that.id,_that.customerId,_that.customerEmail,_that.customerName,_that.status,_that.amount,_that.currency,_that.interval,_that.currentPeriodStart,_that.currentPeriodEnd,_that.canceledAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerId,  String? customerEmail,  String? customerName,  String status,  double amount,  String currency,  String interval,  int currentPeriodStart,  int currentPeriodEnd,  int? canceledAt,  int createdAt)?  $default,) {final _that = this;
switch (_that) {
case _StripeSubscription() when $default != null:
return $default(_that.id,_that.customerId,_that.customerEmail,_that.customerName,_that.status,_that.amount,_that.currency,_that.interval,_that.currentPeriodStart,_that.currentPeriodEnd,_that.canceledAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StripeSubscription implements StripeSubscription {
  const _StripeSubscription({required this.id, required this.customerId, this.customerEmail, this.customerName, required this.status, required this.amount, required this.currency, required this.interval, required this.currentPeriodStart, required this.currentPeriodEnd, this.canceledAt, required this.createdAt});
  factory _StripeSubscription.fromJson(Map<String, dynamic> json) => _$StripeSubscriptionFromJson(json);

@override final  String id;
@override final  String customerId;
@override final  String? customerEmail;
@override final  String? customerName;
@override final  String status;
@override final  double amount;
@override final  String currency;
@override final  String interval;
@override final  int currentPeriodStart;
@override final  int currentPeriodEnd;
@override final  int? canceledAt;
@override final  int createdAt;

/// Create a copy of StripeSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StripeSubscriptionCopyWith<_StripeSubscription> get copyWith => __$StripeSubscriptionCopyWithImpl<_StripeSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StripeSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StripeSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.currentPeriodStart, currentPeriodStart) || other.currentPeriodStart == currentPeriodStart)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.canceledAt, canceledAt) || other.canceledAt == canceledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,customerEmail,customerName,status,amount,currency,interval,currentPeriodStart,currentPeriodEnd,canceledAt,createdAt);

@override
String toString() {
  return 'StripeSubscription(id: $id, customerId: $customerId, customerEmail: $customerEmail, customerName: $customerName, status: $status, amount: $amount, currency: $currency, interval: $interval, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, canceledAt: $canceledAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StripeSubscriptionCopyWith<$Res> implements $StripeSubscriptionCopyWith<$Res> {
  factory _$StripeSubscriptionCopyWith(_StripeSubscription value, $Res Function(_StripeSubscription) _then) = __$StripeSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerId, String? customerEmail, String? customerName, String status, double amount, String currency, String interval, int currentPeriodStart, int currentPeriodEnd, int? canceledAt, int createdAt
});




}
/// @nodoc
class __$StripeSubscriptionCopyWithImpl<$Res>
    implements _$StripeSubscriptionCopyWith<$Res> {
  __$StripeSubscriptionCopyWithImpl(this._self, this._then);

  final _StripeSubscription _self;
  final $Res Function(_StripeSubscription) _then;

/// Create a copy of StripeSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = null,Object? customerEmail = freezed,Object? customerName = freezed,Object? status = null,Object? amount = null,Object? currency = null,Object? interval = null,Object? currentPeriodStart = null,Object? currentPeriodEnd = null,Object? canceledAt = freezed,Object? createdAt = null,}) {
  return _then(_StripeSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String,currentPeriodStart: null == currentPeriodStart ? _self.currentPeriodStart : currentPeriodStart // ignore: cast_nullable_to_non_nullable
as int,currentPeriodEnd: null == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as int,canceledAt: freezed == canceledAt ? _self.canceledAt : canceledAt // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
