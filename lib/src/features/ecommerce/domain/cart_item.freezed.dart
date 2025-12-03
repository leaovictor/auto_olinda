// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
CartItem _$CartItemFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'product':
          return _CartItemProduct.fromJson(
            json
          );
                case 'service':
          return _CartItemService.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'CartItem',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$CartItem {

 int get quantity;
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemCopyWith<CartItem> get copyWith => _$CartItemCopyWithImpl<CartItem>(this as CartItem, _$identity);

  /// Serializes this CartItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItem&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quantity);

@override
String toString() {
  return 'CartItem(quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $CartItemCopyWith<$Res>  {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) _then) = _$CartItemCopyWithImpl;
@useResult
$Res call({
 int quantity
});




}
/// @nodoc
class _$CartItemCopyWithImpl<$Res>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._self, this._then);

  final CartItem _self;
  final $Res Function(CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quantity = null,}) {
  return _then(_self.copyWith(
quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CartItem].
extension CartItemPatterns on CartItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CartItemProduct value)?  product,TResult Function( _CartItemService value)?  service,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItemProduct() when product != null:
return product(_that);case _CartItemService() when service != null:
return service(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CartItemProduct value)  product,required TResult Function( _CartItemService value)  service,}){
final _that = this;
switch (_that) {
case _CartItemProduct():
return product(_that);case _CartItemService():
return service(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CartItemProduct value)?  product,TResult? Function( _CartItemService value)?  service,}){
final _that = this;
switch (_that) {
case _CartItemProduct() when product != null:
return product(_that);case _CartItemService() when service != null:
return service(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Product product,  int quantity)?  product,TResult Function( Service service,  int quantity)?  service,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItemProduct() when product != null:
return product(_that.product,_that.quantity);case _CartItemService() when service != null:
return service(_that.service,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Product product,  int quantity)  product,required TResult Function( Service service,  int quantity)  service,}) {final _that = this;
switch (_that) {
case _CartItemProduct():
return product(_that.product,_that.quantity);case _CartItemService():
return service(_that.service,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Product product,  int quantity)?  product,TResult? Function( Service service,  int quantity)?  service,}) {final _that = this;
switch (_that) {
case _CartItemProduct() when product != null:
return product(_that.product,_that.quantity);case _CartItemService() when service != null:
return service(_that.service,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItemProduct implements CartItem {
  const _CartItemProduct({required this.product, this.quantity = 1, final  String? $type}): $type = $type ?? 'product';
  factory _CartItemProduct.fromJson(Map<String, dynamic> json) => _$CartItemProductFromJson(json);

 final  Product product;
@override@JsonKey() final  int quantity;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemProductCopyWith<_CartItemProduct> get copyWith => __$CartItemProductCopyWithImpl<_CartItemProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItemProduct&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,product,quantity);

@override
String toString() {
  return 'CartItem.product(product: $product, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$CartItemProductCopyWith<$Res> implements $CartItemCopyWith<$Res> {
  factory _$CartItemProductCopyWith(_CartItemProduct value, $Res Function(_CartItemProduct) _then) = __$CartItemProductCopyWithImpl;
@override @useResult
$Res call({
 Product product, int quantity
});


$ProductCopyWith<$Res> get product;

}
/// @nodoc
class __$CartItemProductCopyWithImpl<$Res>
    implements _$CartItemProductCopyWith<$Res> {
  __$CartItemProductCopyWithImpl(this._self, this._then);

  final _CartItemProduct _self;
  final $Res Function(_CartItemProduct) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? quantity = null,}) {
  return _then(_CartItemProduct(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class _CartItemService implements CartItem {
  const _CartItemService({required this.service, this.quantity = 1, final  String? $type}): $type = $type ?? 'service';
  factory _CartItemService.fromJson(Map<String, dynamic> json) => _$CartItemServiceFromJson(json);

 final  Service service;
@override@JsonKey() final  int quantity;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemServiceCopyWith<_CartItemService> get copyWith => __$CartItemServiceCopyWithImpl<_CartItemService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItemService&&(identical(other.service, service) || other.service == service)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,service,quantity);

@override
String toString() {
  return 'CartItem.service(service: $service, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$CartItemServiceCopyWith<$Res> implements $CartItemCopyWith<$Res> {
  factory _$CartItemServiceCopyWith(_CartItemService value, $Res Function(_CartItemService) _then) = __$CartItemServiceCopyWithImpl;
@override @useResult
$Res call({
 Service service, int quantity
});


$ServiceCopyWith<$Res> get service;

}
/// @nodoc
class __$CartItemServiceCopyWithImpl<$Res>
    implements _$CartItemServiceCopyWith<$Res> {
  __$CartItemServiceCopyWithImpl(this._self, this._then);

  final _CartItemService _self;
  final $Res Function(_CartItemService) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? service = null,Object? quantity = null,}) {
  return _then(_CartItemService(
service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as Service,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceCopyWith<$Res> get service {
  
  return $ServiceCopyWith<$Res>(_self.service, (value) {
    return _then(_self.copyWith(service: value));
  });
}
}

// dart format on
