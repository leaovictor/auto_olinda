// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Customer {

 String get id; String get tenantId; String get name; String? get email; String? get phone; String? get whatsapp; String? get cpf; String? get cnpj; String get status;// active | inactive | blocked
 List<CustomerVehicle> get vehicles; DateTime? get firstVisitAt; DateTime? get lastVisitAt; int get visitCount; double get lifetimeValue; List<String> get activeSubscriptionIds; String? get notes; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerCopyWith<Customer> get copyWith => _$CustomerCopyWithImpl<Customer>(this as Customer, _$identity);

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Customer&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.cnpj, cnpj) || other.cnpj == cnpj)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.vehicles, vehicles)&&(identical(other.firstVisitAt, firstVisitAt) || other.firstVisitAt == firstVisitAt)&&(identical(other.lastVisitAt, lastVisitAt) || other.lastVisitAt == lastVisitAt)&&(identical(other.visitCount, visitCount) || other.visitCount == visitCount)&&(identical(other.lifetimeValue, lifetimeValue) || other.lifetimeValue == lifetimeValue)&&const DeepCollectionEquality().equals(other.activeSubscriptionIds, activeSubscriptionIds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,name,email,phone,whatsapp,cpf,cnpj,status,const DeepCollectionEquality().hash(vehicles),firstVisitAt,lastVisitAt,visitCount,lifetimeValue,const DeepCollectionEquality().hash(activeSubscriptionIds),notes,createdAt,updatedAt);

@override
String toString() {
  return 'Customer(id: $id, tenantId: $tenantId, name: $name, email: $email, phone: $phone, whatsapp: $whatsapp, cpf: $cpf, cnpj: $cnpj, status: $status, vehicles: $vehicles, firstVisitAt: $firstVisitAt, lastVisitAt: $lastVisitAt, visitCount: $visitCount, lifetimeValue: $lifetimeValue, activeSubscriptionIds: $activeSubscriptionIds, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CustomerCopyWith<$Res>  {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) _then) = _$CustomerCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String name, String? email, String? phone, String? whatsapp, String? cpf, String? cnpj, String status, List<CustomerVehicle> vehicles, DateTime? firstVisitAt, DateTime? lastVisitAt, int visitCount, double lifetimeValue, List<String> activeSubscriptionIds, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CustomerCopyWithImpl<$Res>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._self, this._then);

  final Customer _self;
  final $Res Function(Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? whatsapp = freezed,Object? cpf = freezed,Object? cnpj = freezed,Object? status = null,Object? vehicles = null,Object? firstVisitAt = freezed,Object? lastVisitAt = freezed,Object? visitCount = null,Object? lifetimeValue = null,Object? activeSubscriptionIds = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,cnpj: freezed == cnpj ? _self.cnpj : cnpj // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,vehicles: null == vehicles ? _self.vehicles : vehicles // ignore: cast_nullable_to_non_nullable
as List<CustomerVehicle>,firstVisitAt: freezed == firstVisitAt ? _self.firstVisitAt : firstVisitAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastVisitAt: freezed == lastVisitAt ? _self.lastVisitAt : lastVisitAt // ignore: cast_nullable_to_non_nullable
as DateTime?,visitCount: null == visitCount ? _self.visitCount : visitCount // ignore: cast_nullable_to_non_nullable
as int,lifetimeValue: null == lifetimeValue ? _self.lifetimeValue : lifetimeValue // ignore: cast_nullable_to_non_nullable
as double,activeSubscriptionIds: null == activeSubscriptionIds ? _self.activeSubscriptionIds : activeSubscriptionIds // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Customer].
extension CustomerPatterns on Customer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Customer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Customer value)  $default,){
final _that = this;
switch (_that) {
case _Customer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Customer value)?  $default,){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String name,  String? email,  String? phone,  String? whatsapp,  String? cpf,  String? cnpj,  String status,  List<CustomerVehicle> vehicles,  DateTime? firstVisitAt,  DateTime? lastVisitAt,  int visitCount,  double lifetimeValue,  List<String> activeSubscriptionIds,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.tenantId,_that.name,_that.email,_that.phone,_that.whatsapp,_that.cpf,_that.cnpj,_that.status,_that.vehicles,_that.firstVisitAt,_that.lastVisitAt,_that.visitCount,_that.lifetimeValue,_that.activeSubscriptionIds,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String name,  String? email,  String? phone,  String? whatsapp,  String? cpf,  String? cnpj,  String status,  List<CustomerVehicle> vehicles,  DateTime? firstVisitAt,  DateTime? lastVisitAt,  int visitCount,  double lifetimeValue,  List<String> activeSubscriptionIds,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Customer():
return $default(_that.id,_that.tenantId,_that.name,_that.email,_that.phone,_that.whatsapp,_that.cpf,_that.cnpj,_that.status,_that.vehicles,_that.firstVisitAt,_that.lastVisitAt,_that.visitCount,_that.lifetimeValue,_that.activeSubscriptionIds,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String name,  String? email,  String? phone,  String? whatsapp,  String? cpf,  String? cnpj,  String status,  List<CustomerVehicle> vehicles,  DateTime? firstVisitAt,  DateTime? lastVisitAt,  int visitCount,  double lifetimeValue,  List<String> activeSubscriptionIds,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.tenantId,_that.name,_that.email,_that.phone,_that.whatsapp,_that.cpf,_that.cnpj,_that.status,_that.vehicles,_that.firstVisitAt,_that.lastVisitAt,_that.visitCount,_that.lifetimeValue,_that.activeSubscriptionIds,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Customer implements Customer {
  const _Customer({required this.id, required this.tenantId, required this.name, this.email, this.phone, this.whatsapp, this.cpf, this.cnpj, this.status = 'active', final  List<CustomerVehicle> vehicles = const [], this.firstVisitAt, this.lastVisitAt, this.visitCount = 0, this.lifetimeValue = 0.0, final  List<String> activeSubscriptionIds = const [], this.notes, this.createdAt, this.updatedAt}): _vehicles = vehicles,_activeSubscriptionIds = activeSubscriptionIds;
  factory _Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String name;
@override final  String? email;
@override final  String? phone;
@override final  String? whatsapp;
@override final  String? cpf;
@override final  String? cnpj;
@override@JsonKey() final  String status;
// active | inactive | blocked
 final  List<CustomerVehicle> _vehicles;
// active | inactive | blocked
@override@JsonKey() List<CustomerVehicle> get vehicles {
  if (_vehicles is EqualUnmodifiableListView) return _vehicles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vehicles);
}

@override final  DateTime? firstVisitAt;
@override final  DateTime? lastVisitAt;
@override@JsonKey() final  int visitCount;
@override@JsonKey() final  double lifetimeValue;
 final  List<String> _activeSubscriptionIds;
@override@JsonKey() List<String> get activeSubscriptionIds {
  if (_activeSubscriptionIds is EqualUnmodifiableListView) return _activeSubscriptionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeSubscriptionIds);
}

@override final  String? notes;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerCopyWith<_Customer> get copyWith => __$CustomerCopyWithImpl<_Customer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Customer&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.cnpj, cnpj) || other.cnpj == cnpj)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._vehicles, _vehicles)&&(identical(other.firstVisitAt, firstVisitAt) || other.firstVisitAt == firstVisitAt)&&(identical(other.lastVisitAt, lastVisitAt) || other.lastVisitAt == lastVisitAt)&&(identical(other.visitCount, visitCount) || other.visitCount == visitCount)&&(identical(other.lifetimeValue, lifetimeValue) || other.lifetimeValue == lifetimeValue)&&const DeepCollectionEquality().equals(other._activeSubscriptionIds, _activeSubscriptionIds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,name,email,phone,whatsapp,cpf,cnpj,status,const DeepCollectionEquality().hash(_vehicles),firstVisitAt,lastVisitAt,visitCount,lifetimeValue,const DeepCollectionEquality().hash(_activeSubscriptionIds),notes,createdAt,updatedAt);

@override
String toString() {
  return 'Customer(id: $id, tenantId: $tenantId, name: $name, email: $email, phone: $phone, whatsapp: $whatsapp, cpf: $cpf, cnpj: $cnpj, status: $status, vehicles: $vehicles, firstVisitAt: $firstVisitAt, lastVisitAt: $lastVisitAt, visitCount: $visitCount, lifetimeValue: $lifetimeValue, activeSubscriptionIds: $activeSubscriptionIds, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CustomerCopyWith<$Res> implements $CustomerCopyWith<$Res> {
  factory _$CustomerCopyWith(_Customer value, $Res Function(_Customer) _then) = __$CustomerCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String name, String? email, String? phone, String? whatsapp, String? cpf, String? cnpj, String status, List<CustomerVehicle> vehicles, DateTime? firstVisitAt, DateTime? lastVisitAt, int visitCount, double lifetimeValue, List<String> activeSubscriptionIds, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CustomerCopyWithImpl<$Res>
    implements _$CustomerCopyWith<$Res> {
  __$CustomerCopyWithImpl(this._self, this._then);

  final _Customer _self;
  final $Res Function(_Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? whatsapp = freezed,Object? cpf = freezed,Object? cnpj = freezed,Object? status = null,Object? vehicles = null,Object? firstVisitAt = freezed,Object? lastVisitAt = freezed,Object? visitCount = null,Object? lifetimeValue = null,Object? activeSubscriptionIds = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Customer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,cnpj: freezed == cnpj ? _self.cnpj : cnpj // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,vehicles: null == vehicles ? _self._vehicles : vehicles // ignore: cast_nullable_to_non_nullable
as List<CustomerVehicle>,firstVisitAt: freezed == firstVisitAt ? _self.firstVisitAt : firstVisitAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastVisitAt: freezed == lastVisitAt ? _self.lastVisitAt : lastVisitAt // ignore: cast_nullable_to_non_nullable
as DateTime?,visitCount: null == visitCount ? _self.visitCount : visitCount // ignore: cast_nullable_to_non_nullable
as int,lifetimeValue: null == lifetimeValue ? _self.lifetimeValue : lifetimeValue // ignore: cast_nullable_to_non_nullable
as double,activeSubscriptionIds: null == activeSubscriptionIds ? _self._activeSubscriptionIds : activeSubscriptionIds // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CustomerVehicle {

 String get id; String get customerId; String get brand; String get model; String get plate; String? get color; String? get vehicleType;// hatch | sedan | suv | moto | pickup
 String? get imageUrl; int get visitCount; DateTime? get addedAt;
/// Create a copy of CustomerVehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerVehicleCopyWith<CustomerVehicle> get copyWith => _$CustomerVehicleCopyWithImpl<CustomerVehicle>(this as CustomerVehicle, _$identity);

  /// Serializes this CustomerVehicle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerVehicle&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.plate, plate) || other.plate == plate)&&(identical(other.color, color) || other.color == color)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.visitCount, visitCount) || other.visitCount == visitCount)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,brand,model,plate,color,vehicleType,imageUrl,visitCount,addedAt);

@override
String toString() {
  return 'CustomerVehicle(id: $id, customerId: $customerId, brand: $brand, model: $model, plate: $plate, color: $color, vehicleType: $vehicleType, imageUrl: $imageUrl, visitCount: $visitCount, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class $CustomerVehicleCopyWith<$Res>  {
  factory $CustomerVehicleCopyWith(CustomerVehicle value, $Res Function(CustomerVehicle) _then) = _$CustomerVehicleCopyWithImpl;
@useResult
$Res call({
 String id, String customerId, String brand, String model, String plate, String? color, String? vehicleType, String? imageUrl, int visitCount, DateTime? addedAt
});




}
/// @nodoc
class _$CustomerVehicleCopyWithImpl<$Res>
    implements $CustomerVehicleCopyWith<$Res> {
  _$CustomerVehicleCopyWithImpl(this._self, this._then);

  final CustomerVehicle _self;
  final $Res Function(CustomerVehicle) _then;

/// Create a copy of CustomerVehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = null,Object? brand = null,Object? model = null,Object? plate = null,Object? color = freezed,Object? vehicleType = freezed,Object? imageUrl = freezed,Object? visitCount = null,Object? addedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,plate: null == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,visitCount: null == visitCount ? _self.visitCount : visitCount // ignore: cast_nullable_to_non_nullable
as int,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerVehicle].
extension CustomerVehiclePatterns on CustomerVehicle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerVehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerVehicle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerVehicle value)  $default,){
final _that = this;
switch (_that) {
case _CustomerVehicle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerVehicle value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerVehicle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerId,  String brand,  String model,  String plate,  String? color,  String? vehicleType,  String? imageUrl,  int visitCount,  DateTime? addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerVehicle() when $default != null:
return $default(_that.id,_that.customerId,_that.brand,_that.model,_that.plate,_that.color,_that.vehicleType,_that.imageUrl,_that.visitCount,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerId,  String brand,  String model,  String plate,  String? color,  String? vehicleType,  String? imageUrl,  int visitCount,  DateTime? addedAt)  $default,) {final _that = this;
switch (_that) {
case _CustomerVehicle():
return $default(_that.id,_that.customerId,_that.brand,_that.model,_that.plate,_that.color,_that.vehicleType,_that.imageUrl,_that.visitCount,_that.addedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerId,  String brand,  String model,  String plate,  String? color,  String? vehicleType,  String? imageUrl,  int visitCount,  DateTime? addedAt)?  $default,) {final _that = this;
switch (_that) {
case _CustomerVehicle() when $default != null:
return $default(_that.id,_that.customerId,_that.brand,_that.model,_that.plate,_that.color,_that.vehicleType,_that.imageUrl,_that.visitCount,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerVehicle implements CustomerVehicle {
  const _CustomerVehicle({required this.id, required this.customerId, required this.brand, required this.model, required this.plate, this.color, this.vehicleType, this.imageUrl, this.visitCount = 0, this.addedAt});
  factory _CustomerVehicle.fromJson(Map<String, dynamic> json) => _$CustomerVehicleFromJson(json);

@override final  String id;
@override final  String customerId;
@override final  String brand;
@override final  String model;
@override final  String plate;
@override final  String? color;
@override final  String? vehicleType;
// hatch | sedan | suv | moto | pickup
@override final  String? imageUrl;
@override@JsonKey() final  int visitCount;
@override final  DateTime? addedAt;

/// Create a copy of CustomerVehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerVehicleCopyWith<_CustomerVehicle> get copyWith => __$CustomerVehicleCopyWithImpl<_CustomerVehicle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerVehicleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerVehicle&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.plate, plate) || other.plate == plate)&&(identical(other.color, color) || other.color == color)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.visitCount, visitCount) || other.visitCount == visitCount)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,brand,model,plate,color,vehicleType,imageUrl,visitCount,addedAt);

@override
String toString() {
  return 'CustomerVehicle(id: $id, customerId: $customerId, brand: $brand, model: $model, plate: $plate, color: $color, vehicleType: $vehicleType, imageUrl: $imageUrl, visitCount: $visitCount, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$CustomerVehicleCopyWith<$Res> implements $CustomerVehicleCopyWith<$Res> {
  factory _$CustomerVehicleCopyWith(_CustomerVehicle value, $Res Function(_CustomerVehicle) _then) = __$CustomerVehicleCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerId, String brand, String model, String plate, String? color, String? vehicleType, String? imageUrl, int visitCount, DateTime? addedAt
});




}
/// @nodoc
class __$CustomerVehicleCopyWithImpl<$Res>
    implements _$CustomerVehicleCopyWith<$Res> {
  __$CustomerVehicleCopyWithImpl(this._self, this._then);

  final _CustomerVehicle _self;
  final $Res Function(_CustomerVehicle) _then;

/// Create a copy of CustomerVehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = null,Object? brand = null,Object? model = null,Object? plate = null,Object? color = freezed,Object? vehicleType = freezed,Object? imageUrl = freezed,Object? visitCount = null,Object? addedAt = freezed,}) {
  return _then(_CustomerVehicle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,plate: null == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,visitCount: null == visitCount ? _self.visitCount : visitCount // ignore: cast_nullable_to_non_nullable
as int,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
