// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stripe_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StripeTransaction {

 String get id; String? get customerId; String? get customerEmail; double get amount; String get currency; String get status; String? get description; int get createdAt; bool get paid; bool get refunded; String? get receiptUrl;
/// Create a copy of StripeTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StripeTransactionCopyWith<StripeTransaction> get copyWith => _$StripeTransactionCopyWithImpl<StripeTransaction>(this as StripeTransaction, _$identity);

  /// Serializes this StripeTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StripeTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.refunded, refunded) || other.refunded == refunded)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,customerEmail,amount,currency,status,description,createdAt,paid,refunded,receiptUrl);

@override
String toString() {
  return 'StripeTransaction(id: $id, customerId: $customerId, customerEmail: $customerEmail, amount: $amount, currency: $currency, status: $status, description: $description, createdAt: $createdAt, paid: $paid, refunded: $refunded, receiptUrl: $receiptUrl)';
}


}

/// @nodoc
abstract mixin class $StripeTransactionCopyWith<$Res>  {
  factory $StripeTransactionCopyWith(StripeTransaction value, $Res Function(StripeTransaction) _then) = _$StripeTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String? customerId, String? customerEmail, double amount, String currency, String status, String? description, int createdAt, bool paid, bool refunded, String? receiptUrl
});




}
/// @nodoc
class _$StripeTransactionCopyWithImpl<$Res>
    implements $StripeTransactionCopyWith<$Res> {
  _$StripeTransactionCopyWithImpl(this._self, this._then);

  final StripeTransaction _self;
  final $Res Function(StripeTransaction) _then;

/// Create a copy of StripeTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = freezed,Object? customerEmail = freezed,Object? amount = null,Object? currency = null,Object? status = null,Object? description = freezed,Object? createdAt = null,Object? paid = null,Object? refunded = null,Object? receiptUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,refunded: null == refunded ? _self.refunded : refunded // ignore: cast_nullable_to_non_nullable
as bool,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StripeTransaction].
extension StripeTransactionPatterns on StripeTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StripeTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StripeTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StripeTransaction value)  $default,){
final _that = this;
switch (_that) {
case _StripeTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StripeTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _StripeTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? customerId,  String? customerEmail,  double amount,  String currency,  String status,  String? description,  int createdAt,  bool paid,  bool refunded,  String? receiptUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StripeTransaction() when $default != null:
return $default(_that.id,_that.customerId,_that.customerEmail,_that.amount,_that.currency,_that.status,_that.description,_that.createdAt,_that.paid,_that.refunded,_that.receiptUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? customerId,  String? customerEmail,  double amount,  String currency,  String status,  String? description,  int createdAt,  bool paid,  bool refunded,  String? receiptUrl)  $default,) {final _that = this;
switch (_that) {
case _StripeTransaction():
return $default(_that.id,_that.customerId,_that.customerEmail,_that.amount,_that.currency,_that.status,_that.description,_that.createdAt,_that.paid,_that.refunded,_that.receiptUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? customerId,  String? customerEmail,  double amount,  String currency,  String status,  String? description,  int createdAt,  bool paid,  bool refunded,  String? receiptUrl)?  $default,) {final _that = this;
switch (_that) {
case _StripeTransaction() when $default != null:
return $default(_that.id,_that.customerId,_that.customerEmail,_that.amount,_that.currency,_that.status,_that.description,_that.createdAt,_that.paid,_that.refunded,_that.receiptUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StripeTransaction implements StripeTransaction {
  const _StripeTransaction({required this.id, this.customerId, this.customerEmail, required this.amount, required this.currency, required this.status, this.description, required this.createdAt, required this.paid, required this.refunded, this.receiptUrl});
  factory _StripeTransaction.fromJson(Map<String, dynamic> json) => _$StripeTransactionFromJson(json);

@override final  String id;
@override final  String? customerId;
@override final  String? customerEmail;
@override final  double amount;
@override final  String currency;
@override final  String status;
@override final  String? description;
@override final  int createdAt;
@override final  bool paid;
@override final  bool refunded;
@override final  String? receiptUrl;

/// Create a copy of StripeTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StripeTransactionCopyWith<_StripeTransaction> get copyWith => __$StripeTransactionCopyWithImpl<_StripeTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StripeTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StripeTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.refunded, refunded) || other.refunded == refunded)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,customerEmail,amount,currency,status,description,createdAt,paid,refunded,receiptUrl);

@override
String toString() {
  return 'StripeTransaction(id: $id, customerId: $customerId, customerEmail: $customerEmail, amount: $amount, currency: $currency, status: $status, description: $description, createdAt: $createdAt, paid: $paid, refunded: $refunded, receiptUrl: $receiptUrl)';
}


}

/// @nodoc
abstract mixin class _$StripeTransactionCopyWith<$Res> implements $StripeTransactionCopyWith<$Res> {
  factory _$StripeTransactionCopyWith(_StripeTransaction value, $Res Function(_StripeTransaction) _then) = __$StripeTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? customerId, String? customerEmail, double amount, String currency, String status, String? description, int createdAt, bool paid, bool refunded, String? receiptUrl
});




}
/// @nodoc
class __$StripeTransactionCopyWithImpl<$Res>
    implements _$StripeTransactionCopyWith<$Res> {
  __$StripeTransactionCopyWithImpl(this._self, this._then);

  final _StripeTransaction _self;
  final $Res Function(_StripeTransaction) _then;

/// Create a copy of StripeTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = freezed,Object? customerEmail = freezed,Object? amount = null,Object? currency = null,Object? status = null,Object? description = freezed,Object? createdAt = null,Object? paid = null,Object? refunded = null,Object? receiptUrl = freezed,}) {
  return _then(_StripeTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,refunded: null == refunded ? _self.refunded : refunded // ignore: cast_nullable_to_non_nullable
as bool,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
