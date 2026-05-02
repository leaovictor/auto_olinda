// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionInvoice {

 String get id; int get amountPaid; int get created; String get status; String? get invoicePdf; String? get paymentMethodBrand; String? get paymentMethodLast4;
/// Create a copy of SubscriptionInvoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionInvoiceCopyWith<SubscriptionInvoice> get copyWith => _$SubscriptionInvoiceCopyWithImpl<SubscriptionInvoice>(this as SubscriptionInvoice, _$identity);

  /// Serializes this SubscriptionInvoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionInvoice&&(identical(other.id, id) || other.id == id)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.created, created) || other.created == created)&&(identical(other.status, status) || other.status == status)&&(identical(other.invoicePdf, invoicePdf) || other.invoicePdf == invoicePdf)&&(identical(other.paymentMethodBrand, paymentMethodBrand) || other.paymentMethodBrand == paymentMethodBrand)&&(identical(other.paymentMethodLast4, paymentMethodLast4) || other.paymentMethodLast4 == paymentMethodLast4));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amountPaid,created,status,invoicePdf,paymentMethodBrand,paymentMethodLast4);

@override
String toString() {
  return 'SubscriptionInvoice(id: $id, amountPaid: $amountPaid, created: $created, status: $status, invoicePdf: $invoicePdf, paymentMethodBrand: $paymentMethodBrand, paymentMethodLast4: $paymentMethodLast4)';
}


}

/// @nodoc
abstract mixin class $SubscriptionInvoiceCopyWith<$Res>  {
  factory $SubscriptionInvoiceCopyWith(SubscriptionInvoice value, $Res Function(SubscriptionInvoice) _then) = _$SubscriptionInvoiceCopyWithImpl;
@useResult
$Res call({
 String id, int amountPaid, int created, String status, String? invoicePdf, String? paymentMethodBrand, String? paymentMethodLast4
});




}
/// @nodoc
class _$SubscriptionInvoiceCopyWithImpl<$Res>
    implements $SubscriptionInvoiceCopyWith<$Res> {
  _$SubscriptionInvoiceCopyWithImpl(this._self, this._then);

  final SubscriptionInvoice _self;
  final $Res Function(SubscriptionInvoice) _then;

/// Create a copy of SubscriptionInvoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amountPaid = null,Object? created = null,Object? status = null,Object? invoicePdf = freezed,Object? paymentMethodBrand = freezed,Object? paymentMethodLast4 = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as int,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,invoicePdf: freezed == invoicePdf ? _self.invoicePdf : invoicePdf // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodBrand: freezed == paymentMethodBrand ? _self.paymentMethodBrand : paymentMethodBrand // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodLast4: freezed == paymentMethodLast4 ? _self.paymentMethodLast4 : paymentMethodLast4 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionInvoice].
extension SubscriptionInvoicePatterns on SubscriptionInvoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionInvoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionInvoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionInvoice value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInvoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionInvoice value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInvoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int amountPaid,  int created,  String status,  String? invoicePdf,  String? paymentMethodBrand,  String? paymentMethodLast4)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionInvoice() when $default != null:
return $default(_that.id,_that.amountPaid,_that.created,_that.status,_that.invoicePdf,_that.paymentMethodBrand,_that.paymentMethodLast4);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int amountPaid,  int created,  String status,  String? invoicePdf,  String? paymentMethodBrand,  String? paymentMethodLast4)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInvoice():
return $default(_that.id,_that.amountPaid,_that.created,_that.status,_that.invoicePdf,_that.paymentMethodBrand,_that.paymentMethodLast4);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int amountPaid,  int created,  String status,  String? invoicePdf,  String? paymentMethodBrand,  String? paymentMethodLast4)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInvoice() when $default != null:
return $default(_that.id,_that.amountPaid,_that.created,_that.status,_that.invoicePdf,_that.paymentMethodBrand,_that.paymentMethodLast4);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionInvoice implements SubscriptionInvoice {
  const _SubscriptionInvoice({required this.id, required this.amountPaid, required this.created, required this.status, this.invoicePdf, this.paymentMethodBrand, this.paymentMethodLast4});
  factory _SubscriptionInvoice.fromJson(Map<String, dynamic> json) => _$SubscriptionInvoiceFromJson(json);

@override final  String id;
@override final  int amountPaid;
@override final  int created;
@override final  String status;
@override final  String? invoicePdf;
@override final  String? paymentMethodBrand;
@override final  String? paymentMethodLast4;

/// Create a copy of SubscriptionInvoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionInvoiceCopyWith<_SubscriptionInvoice> get copyWith => __$SubscriptionInvoiceCopyWithImpl<_SubscriptionInvoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionInvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionInvoice&&(identical(other.id, id) || other.id == id)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.created, created) || other.created == created)&&(identical(other.status, status) || other.status == status)&&(identical(other.invoicePdf, invoicePdf) || other.invoicePdf == invoicePdf)&&(identical(other.paymentMethodBrand, paymentMethodBrand) || other.paymentMethodBrand == paymentMethodBrand)&&(identical(other.paymentMethodLast4, paymentMethodLast4) || other.paymentMethodLast4 == paymentMethodLast4));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amountPaid,created,status,invoicePdf,paymentMethodBrand,paymentMethodLast4);

@override
String toString() {
  return 'SubscriptionInvoice(id: $id, amountPaid: $amountPaid, created: $created, status: $status, invoicePdf: $invoicePdf, paymentMethodBrand: $paymentMethodBrand, paymentMethodLast4: $paymentMethodLast4)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionInvoiceCopyWith<$Res> implements $SubscriptionInvoiceCopyWith<$Res> {
  factory _$SubscriptionInvoiceCopyWith(_SubscriptionInvoice value, $Res Function(_SubscriptionInvoice) _then) = __$SubscriptionInvoiceCopyWithImpl;
@override @useResult
$Res call({
 String id, int amountPaid, int created, String status, String? invoicePdf, String? paymentMethodBrand, String? paymentMethodLast4
});




}
/// @nodoc
class __$SubscriptionInvoiceCopyWithImpl<$Res>
    implements _$SubscriptionInvoiceCopyWith<$Res> {
  __$SubscriptionInvoiceCopyWithImpl(this._self, this._then);

  final _SubscriptionInvoice _self;
  final $Res Function(_SubscriptionInvoice) _then;

/// Create a copy of SubscriptionInvoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amountPaid = null,Object? created = null,Object? status = null,Object? invoicePdf = freezed,Object? paymentMethodBrand = freezed,Object? paymentMethodLast4 = freezed,}) {
  return _then(_SubscriptionInvoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as int,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,invoicePdf: freezed == invoicePdf ? _self.invoicePdf : invoicePdf // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodBrand: freezed == paymentMethodBrand ? _self.paymentMethodBrand : paymentMethodBrand // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodLast4: freezed == paymentMethodLast4 ? _self.paymentMethodLast4 : paymentMethodLast4 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
