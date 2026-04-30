// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tenant {

 String get id; String get name; String get ownerUid; String get status;// active | suspended | cancelled
 String get plan;// starter | pro | enterprise
 String? get logoUrl; String get primaryColor; String? get stripeConnectAccountId; bool get stripeConnectOnboarded; int get platformFeePercent; String? get phone; String? get address; String? get city; String? get state; Map<String, dynamic>? get settings;
/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantCopyWith<Tenant> get copyWith => _$TenantCopyWithImpl<Tenant>(this as Tenant, _$identity);

  /// Serializes this Tenant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.stripeConnectAccountId, stripeConnectAccountId) || other.stripeConnectAccountId == stripeConnectAccountId)&&(identical(other.stripeConnectOnboarded, stripeConnectOnboarded) || other.stripeConnectOnboarded == stripeConnectOnboarded)&&(identical(other.platformFeePercent, platformFeePercent) || other.platformFeePercent == platformFeePercent)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&const DeepCollectionEquality().equals(other.settings, settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerUid,status,plan,logoUrl,primaryColor,stripeConnectAccountId,stripeConnectOnboarded,platformFeePercent,phone,address,city,state,const DeepCollectionEquality().hash(settings));

@override
String toString() {
  return 'Tenant(id: $id, name: $name, ownerUid: $ownerUid, status: $status, plan: $plan, logoUrl: $logoUrl, primaryColor: $primaryColor, stripeConnectAccountId: $stripeConnectAccountId, stripeConnectOnboarded: $stripeConnectOnboarded, platformFeePercent: $platformFeePercent, phone: $phone, address: $address, city: $city, state: $state, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $TenantCopyWith<$Res>  {
  factory $TenantCopyWith(Tenant value, $Res Function(Tenant) _then) = _$TenantCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ownerUid, String status, String plan, String? logoUrl, String primaryColor, String? stripeConnectAccountId, bool stripeConnectOnboarded, int platformFeePercent, String? phone, String? address, String? city, String? state, Map<String, dynamic>? settings
});




}
/// @nodoc
class _$TenantCopyWithImpl<$Res>
    implements $TenantCopyWith<$Res> {
  _$TenantCopyWithImpl(this._self, this._then);

  final Tenant _self;
  final $Res Function(Tenant) _then;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerUid = null,Object? status = null,Object? plan = null,Object? logoUrl = freezed,Object? primaryColor = null,Object? stripeConnectAccountId = freezed,Object? stripeConnectOnboarded = null,Object? platformFeePercent = null,Object? phone = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? settings = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,stripeConnectAccountId: freezed == stripeConnectAccountId ? _self.stripeConnectAccountId : stripeConnectAccountId // ignore: cast_nullable_to_non_nullable
as String?,stripeConnectOnboarded: null == stripeConnectOnboarded ? _self.stripeConnectOnboarded : stripeConnectOnboarded // ignore: cast_nullable_to_non_nullable
as bool,platformFeePercent: null == platformFeePercent ? _self.platformFeePercent : platformFeePercent // ignore: cast_nullable_to_non_nullable
as int,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Tenant].
extension TenantPatterns on Tenant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tenant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tenant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tenant value)  $default,){
final _that = this;
switch (_that) {
case _Tenant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tenant value)?  $default,){
final _that = this;
switch (_that) {
case _Tenant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerUid,  String status,  String plan,  String? logoUrl,  String primaryColor,  String? stripeConnectAccountId,  bool stripeConnectOnboarded,  int platformFeePercent,  String? phone,  String? address,  String? city,  String? state,  Map<String, dynamic>? settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.ownerUid,_that.status,_that.plan,_that.logoUrl,_that.primaryColor,_that.stripeConnectAccountId,_that.stripeConnectOnboarded,_that.platformFeePercent,_that.phone,_that.address,_that.city,_that.state,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerUid,  String status,  String plan,  String? logoUrl,  String primaryColor,  String? stripeConnectAccountId,  bool stripeConnectOnboarded,  int platformFeePercent,  String? phone,  String? address,  String? city,  String? state,  Map<String, dynamic>? settings)  $default,) {final _that = this;
switch (_that) {
case _Tenant():
return $default(_that.id,_that.name,_that.ownerUid,_that.status,_that.plan,_that.logoUrl,_that.primaryColor,_that.stripeConnectAccountId,_that.stripeConnectOnboarded,_that.platformFeePercent,_that.phone,_that.address,_that.city,_that.state,_that.settings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerUid,  String status,  String plan,  String? logoUrl,  String primaryColor,  String? stripeConnectAccountId,  bool stripeConnectOnboarded,  int platformFeePercent,  String? phone,  String? address,  String? city,  String? state,  Map<String, dynamic>? settings)?  $default,) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.ownerUid,_that.status,_that.plan,_that.logoUrl,_that.primaryColor,_that.stripeConnectAccountId,_that.stripeConnectOnboarded,_that.platformFeePercent,_that.phone,_that.address,_that.city,_that.state,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tenant implements Tenant {
  const _Tenant({required this.id, required this.name, required this.ownerUid, this.status = 'active', this.plan = 'starter', this.logoUrl, this.primaryColor = '#1A73E8', this.stripeConnectAccountId, this.stripeConnectOnboarded = false, this.platformFeePercent = 5, this.phone, this.address, this.city, this.state, final  Map<String, dynamic>? settings}): _settings = settings;
  factory _Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);

@override final  String id;
@override final  String name;
@override final  String ownerUid;
@override@JsonKey() final  String status;
// active | suspended | cancelled
@override@JsonKey() final  String plan;
// starter | pro | enterprise
@override final  String? logoUrl;
@override@JsonKey() final  String primaryColor;
@override final  String? stripeConnectAccountId;
@override@JsonKey() final  bool stripeConnectOnboarded;
@override@JsonKey() final  int platformFeePercent;
@override final  String? phone;
@override final  String? address;
@override final  String? city;
@override final  String? state;
 final  Map<String, dynamic>? _settings;
@override Map<String, dynamic>? get settings {
  final value = _settings;
  if (value == null) return null;
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantCopyWith<_Tenant> get copyWith => __$TenantCopyWithImpl<_Tenant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.stripeConnectAccountId, stripeConnectAccountId) || other.stripeConnectAccountId == stripeConnectAccountId)&&(identical(other.stripeConnectOnboarded, stripeConnectOnboarded) || other.stripeConnectOnboarded == stripeConnectOnboarded)&&(identical(other.platformFeePercent, platformFeePercent) || other.platformFeePercent == platformFeePercent)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&const DeepCollectionEquality().equals(other._settings, _settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerUid,status,plan,logoUrl,primaryColor,stripeConnectAccountId,stripeConnectOnboarded,platformFeePercent,phone,address,city,state,const DeepCollectionEquality().hash(_settings));

@override
String toString() {
  return 'Tenant(id: $id, name: $name, ownerUid: $ownerUid, status: $status, plan: $plan, logoUrl: $logoUrl, primaryColor: $primaryColor, stripeConnectAccountId: $stripeConnectAccountId, stripeConnectOnboarded: $stripeConnectOnboarded, platformFeePercent: $platformFeePercent, phone: $phone, address: $address, city: $city, state: $state, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$TenantCopyWith<$Res> implements $TenantCopyWith<$Res> {
  factory _$TenantCopyWith(_Tenant value, $Res Function(_Tenant) _then) = __$TenantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ownerUid, String status, String plan, String? logoUrl, String primaryColor, String? stripeConnectAccountId, bool stripeConnectOnboarded, int platformFeePercent, String? phone, String? address, String? city, String? state, Map<String, dynamic>? settings
});




}
/// @nodoc
class __$TenantCopyWithImpl<$Res>
    implements _$TenantCopyWith<$Res> {
  __$TenantCopyWithImpl(this._self, this._then);

  final _Tenant _self;
  final $Res Function(_Tenant) _then;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerUid = null,Object? status = null,Object? plan = null,Object? logoUrl = freezed,Object? primaryColor = null,Object? stripeConnectAccountId = freezed,Object? stripeConnectOnboarded = null,Object? platformFeePercent = null,Object? phone = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? settings = freezed,}) {
  return _then(_Tenant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,stripeConnectAccountId: freezed == stripeConnectAccountId ? _self.stripeConnectAccountId : stripeConnectAccountId // ignore: cast_nullable_to_non_nullable
as String?,stripeConnectOnboarded: null == stripeConnectOnboarded ? _self.stripeConnectOnboarded : stripeConnectOnboarded // ignore: cast_nullable_to_non_nullable
as bool,platformFeePercent: null == platformFeePercent ? _self.platformFeePercent : platformFeePercent // ignore: cast_nullable_to_non_nullable
as int,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,settings: freezed == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
