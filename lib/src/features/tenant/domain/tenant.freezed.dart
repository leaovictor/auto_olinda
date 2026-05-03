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

 String get id; String get name;// Car wash business name
 String get ownerUid;// Firebase UID of owner
 String get status;// active | suspended | trial | cancelled
// Stripe Connect for payments
 String? get stripeAccountId; bool get stripeOnboarded; int get platformFeePercent;// Platform commission percentage
// Branding
 String? get logoUrl; String? get coverImageUrl; String get primaryColor; String? get secondaryColor;// Contact & Location
 String? get phone; String? get whatsapp; String? get email; String? get address; String? get city; String? get state; String? get zipCode; double? get latitude; double? get longitude;// Business Configuration
 BusinessConfig? get businessConfig;// Limits & Features
 int get maxStaffCount; int get maxActiveServices; bool get hasLoyaltyProgram; bool get sendAutomatedReminders; bool get notificationsEnabled;// Subscription/Trial
 String get subscriptionStatus;// trial | active | suspended | past_due
 DateTime? get trialEndsAt; int get trialDays; DateTime? get subscriptionEndsAt;// Staff references
 List<String> get staffIds;// Metadata
 DateTime? get createdAt; DateTime? get updatedAt; Map<String, dynamic>? get customFields;
/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantCopyWith<Tenant> get copyWith => _$TenantCopyWithImpl<Tenant>(this as Tenant, _$identity);

  /// Serializes this Tenant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.stripeOnboarded, stripeOnboarded) || other.stripeOnboarded == stripeOnboarded)&&(identical(other.platformFeePercent, platformFeePercent) || other.platformFeePercent == platformFeePercent)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.businessConfig, businessConfig) || other.businessConfig == businessConfig)&&(identical(other.maxStaffCount, maxStaffCount) || other.maxStaffCount == maxStaffCount)&&(identical(other.maxActiveServices, maxActiveServices) || other.maxActiveServices == maxActiveServices)&&(identical(other.hasLoyaltyProgram, hasLoyaltyProgram) || other.hasLoyaltyProgram == hasLoyaltyProgram)&&(identical(other.sendAutomatedReminders, sendAutomatedReminders) || other.sendAutomatedReminders == sendAutomatedReminders)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.trialEndsAt, trialEndsAt) || other.trialEndsAt == trialEndsAt)&&(identical(other.trialDays, trialDays) || other.trialDays == trialDays)&&(identical(other.subscriptionEndsAt, subscriptionEndsAt) || other.subscriptionEndsAt == subscriptionEndsAt)&&const DeepCollectionEquality().equals(other.staffIds, staffIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.customFields, customFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,ownerUid,status,stripeAccountId,stripeOnboarded,platformFeePercent,logoUrl,coverImageUrl,primaryColor,secondaryColor,phone,whatsapp,email,address,city,state,zipCode,latitude,longitude,businessConfig,maxStaffCount,maxActiveServices,hasLoyaltyProgram,sendAutomatedReminders,notificationsEnabled,subscriptionStatus,trialEndsAt,trialDays,subscriptionEndsAt,const DeepCollectionEquality().hash(staffIds),createdAt,updatedAt,const DeepCollectionEquality().hash(customFields)]);

@override
String toString() {
  return 'Tenant(id: $id, name: $name, ownerUid: $ownerUid, status: $status, stripeAccountId: $stripeAccountId, stripeOnboarded: $stripeOnboarded, platformFeePercent: $platformFeePercent, logoUrl: $logoUrl, coverImageUrl: $coverImageUrl, primaryColor: $primaryColor, secondaryColor: $secondaryColor, phone: $phone, whatsapp: $whatsapp, email: $email, address: $address, city: $city, state: $state, zipCode: $zipCode, latitude: $latitude, longitude: $longitude, businessConfig: $businessConfig, maxStaffCount: $maxStaffCount, maxActiveServices: $maxActiveServices, hasLoyaltyProgram: $hasLoyaltyProgram, sendAutomatedReminders: $sendAutomatedReminders, notificationsEnabled: $notificationsEnabled, subscriptionStatus: $subscriptionStatus, trialEndsAt: $trialEndsAt, trialDays: $trialDays, subscriptionEndsAt: $subscriptionEndsAt, staffIds: $staffIds, createdAt: $createdAt, updatedAt: $updatedAt, customFields: $customFields)';
}


}

/// @nodoc
abstract mixin class $TenantCopyWith<$Res>  {
  factory $TenantCopyWith(Tenant value, $Res Function(Tenant) _then) = _$TenantCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ownerUid, String status, String? stripeAccountId, bool stripeOnboarded, int platformFeePercent, String? logoUrl, String? coverImageUrl, String primaryColor, String? secondaryColor, String? phone, String? whatsapp, String? email, String? address, String? city, String? state, String? zipCode, double? latitude, double? longitude, BusinessConfig? businessConfig, int maxStaffCount, int maxActiveServices, bool hasLoyaltyProgram, bool sendAutomatedReminders, bool notificationsEnabled, String subscriptionStatus, DateTime? trialEndsAt, int trialDays, DateTime? subscriptionEndsAt, List<String> staffIds, DateTime? createdAt, DateTime? updatedAt, Map<String, dynamic>? customFields
});


$BusinessConfigCopyWith<$Res>? get businessConfig;

}
/// @nodoc
class _$TenantCopyWithImpl<$Res>
    implements $TenantCopyWith<$Res> {
  _$TenantCopyWithImpl(this._self, this._then);

  final Tenant _self;
  final $Res Function(Tenant) _then;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerUid = null,Object? status = null,Object? stripeAccountId = freezed,Object? stripeOnboarded = null,Object? platformFeePercent = null,Object? logoUrl = freezed,Object? coverImageUrl = freezed,Object? primaryColor = null,Object? secondaryColor = freezed,Object? phone = freezed,Object? whatsapp = freezed,Object? email = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? zipCode = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? businessConfig = freezed,Object? maxStaffCount = null,Object? maxActiveServices = null,Object? hasLoyaltyProgram = null,Object? sendAutomatedReminders = null,Object? notificationsEnabled = null,Object? subscriptionStatus = null,Object? trialEndsAt = freezed,Object? trialDays = null,Object? subscriptionEndsAt = freezed,Object? staffIds = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? customFields = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,stripeOnboarded: null == stripeOnboarded ? _self.stripeOnboarded : stripeOnboarded // ignore: cast_nullable_to_non_nullable
as bool,platformFeePercent: null == platformFeePercent ? _self.platformFeePercent : platformFeePercent // ignore: cast_nullable_to_non_nullable
as int,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,secondaryColor: freezed == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,businessConfig: freezed == businessConfig ? _self.businessConfig : businessConfig // ignore: cast_nullable_to_non_nullable
as BusinessConfig?,maxStaffCount: null == maxStaffCount ? _self.maxStaffCount : maxStaffCount // ignore: cast_nullable_to_non_nullable
as int,maxActiveServices: null == maxActiveServices ? _self.maxActiveServices : maxActiveServices // ignore: cast_nullable_to_non_nullable
as int,hasLoyaltyProgram: null == hasLoyaltyProgram ? _self.hasLoyaltyProgram : hasLoyaltyProgram // ignore: cast_nullable_to_non_nullable
as bool,sendAutomatedReminders: null == sendAutomatedReminders ? _self.sendAutomatedReminders : sendAutomatedReminders // ignore: cast_nullable_to_non_nullable
as bool,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,subscriptionStatus: null == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String,trialEndsAt: freezed == trialEndsAt ? _self.trialEndsAt : trialEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trialDays: null == trialDays ? _self.trialDays : trialDays // ignore: cast_nullable_to_non_nullable
as int,subscriptionEndsAt: freezed == subscriptionEndsAt ? _self.subscriptionEndsAt : subscriptionEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,staffIds: null == staffIds ? _self.staffIds : staffIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,customFields: freezed == customFields ? _self.customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BusinessConfigCopyWith<$Res>? get businessConfig {
    if (_self.businessConfig == null) {
    return null;
  }

  return $BusinessConfigCopyWith<$Res>(_self.businessConfig!, (value) {
    return _then(_self.copyWith(businessConfig: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerUid,  String status,  String? stripeAccountId,  bool stripeOnboarded,  int platformFeePercent,  String? logoUrl,  String? coverImageUrl,  String primaryColor,  String? secondaryColor,  String? phone,  String? whatsapp,  String? email,  String? address,  String? city,  String? state,  String? zipCode,  double? latitude,  double? longitude,  BusinessConfig? businessConfig,  int maxStaffCount,  int maxActiveServices,  bool hasLoyaltyProgram,  bool sendAutomatedReminders,  bool notificationsEnabled,  String subscriptionStatus,  DateTime? trialEndsAt,  int trialDays,  DateTime? subscriptionEndsAt,  List<String> staffIds,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic>? customFields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.ownerUid,_that.status,_that.stripeAccountId,_that.stripeOnboarded,_that.platformFeePercent,_that.logoUrl,_that.coverImageUrl,_that.primaryColor,_that.secondaryColor,_that.phone,_that.whatsapp,_that.email,_that.address,_that.city,_that.state,_that.zipCode,_that.latitude,_that.longitude,_that.businessConfig,_that.maxStaffCount,_that.maxActiveServices,_that.hasLoyaltyProgram,_that.sendAutomatedReminders,_that.notificationsEnabled,_that.subscriptionStatus,_that.trialEndsAt,_that.trialDays,_that.subscriptionEndsAt,_that.staffIds,_that.createdAt,_that.updatedAt,_that.customFields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerUid,  String status,  String? stripeAccountId,  bool stripeOnboarded,  int platformFeePercent,  String? logoUrl,  String? coverImageUrl,  String primaryColor,  String? secondaryColor,  String? phone,  String? whatsapp,  String? email,  String? address,  String? city,  String? state,  String? zipCode,  double? latitude,  double? longitude,  BusinessConfig? businessConfig,  int maxStaffCount,  int maxActiveServices,  bool hasLoyaltyProgram,  bool sendAutomatedReminders,  bool notificationsEnabled,  String subscriptionStatus,  DateTime? trialEndsAt,  int trialDays,  DateTime? subscriptionEndsAt,  List<String> staffIds,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic>? customFields)  $default,) {final _that = this;
switch (_that) {
case _Tenant():
return $default(_that.id,_that.name,_that.ownerUid,_that.status,_that.stripeAccountId,_that.stripeOnboarded,_that.platformFeePercent,_that.logoUrl,_that.coverImageUrl,_that.primaryColor,_that.secondaryColor,_that.phone,_that.whatsapp,_that.email,_that.address,_that.city,_that.state,_that.zipCode,_that.latitude,_that.longitude,_that.businessConfig,_that.maxStaffCount,_that.maxActiveServices,_that.hasLoyaltyProgram,_that.sendAutomatedReminders,_that.notificationsEnabled,_that.subscriptionStatus,_that.trialEndsAt,_that.trialDays,_that.subscriptionEndsAt,_that.staffIds,_that.createdAt,_that.updatedAt,_that.customFields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerUid,  String status,  String? stripeAccountId,  bool stripeOnboarded,  int platformFeePercent,  String? logoUrl,  String? coverImageUrl,  String primaryColor,  String? secondaryColor,  String? phone,  String? whatsapp,  String? email,  String? address,  String? city,  String? state,  String? zipCode,  double? latitude,  double? longitude,  BusinessConfig? businessConfig,  int maxStaffCount,  int maxActiveServices,  bool hasLoyaltyProgram,  bool sendAutomatedReminders,  bool notificationsEnabled,  String subscriptionStatus,  DateTime? trialEndsAt,  int trialDays,  DateTime? subscriptionEndsAt,  List<String> staffIds,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic>? customFields)?  $default,) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.ownerUid,_that.status,_that.stripeAccountId,_that.stripeOnboarded,_that.platformFeePercent,_that.logoUrl,_that.coverImageUrl,_that.primaryColor,_that.secondaryColor,_that.phone,_that.whatsapp,_that.email,_that.address,_that.city,_that.state,_that.zipCode,_that.latitude,_that.longitude,_that.businessConfig,_that.maxStaffCount,_that.maxActiveServices,_that.hasLoyaltyProgram,_that.sendAutomatedReminders,_that.notificationsEnabled,_that.subscriptionStatus,_that.trialEndsAt,_that.trialDays,_that.subscriptionEndsAt,_that.staffIds,_that.createdAt,_that.updatedAt,_that.customFields);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tenant implements Tenant {
  const _Tenant({required this.id, required this.name, required this.ownerUid, this.status = 'active', this.stripeAccountId, this.stripeOnboarded = false, this.platformFeePercent = 10, this.logoUrl, this.coverImageUrl, this.primaryColor = '#0066CC', this.secondaryColor, this.phone, this.whatsapp, this.email, this.address, this.city, this.state, this.zipCode, this.latitude, this.longitude, this.businessConfig, this.maxStaffCount = 5, this.maxActiveServices = 100, this.hasLoyaltyProgram = false, this.sendAutomatedReminders = false, this.notificationsEnabled = true, this.subscriptionStatus = 'trial', this.trialEndsAt, this.trialDays = 14, this.subscriptionEndsAt, final  List<String> staffIds = const [], this.createdAt, this.updatedAt, final  Map<String, dynamic>? customFields}): _staffIds = staffIds,_customFields = customFields;
  factory _Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);

@override final  String id;
@override final  String name;
// Car wash business name
@override final  String ownerUid;
// Firebase UID of owner
@override@JsonKey() final  String status;
// active | suspended | trial | cancelled
// Stripe Connect for payments
@override final  String? stripeAccountId;
@override@JsonKey() final  bool stripeOnboarded;
@override@JsonKey() final  int platformFeePercent;
// Platform commission percentage
// Branding
@override final  String? logoUrl;
@override final  String? coverImageUrl;
@override@JsonKey() final  String primaryColor;
@override final  String? secondaryColor;
// Contact & Location
@override final  String? phone;
@override final  String? whatsapp;
@override final  String? email;
@override final  String? address;
@override final  String? city;
@override final  String? state;
@override final  String? zipCode;
@override final  double? latitude;
@override final  double? longitude;
// Business Configuration
@override final  BusinessConfig? businessConfig;
// Limits & Features
@override@JsonKey() final  int maxStaffCount;
@override@JsonKey() final  int maxActiveServices;
@override@JsonKey() final  bool hasLoyaltyProgram;
@override@JsonKey() final  bool sendAutomatedReminders;
@override@JsonKey() final  bool notificationsEnabled;
// Subscription/Trial
@override@JsonKey() final  String subscriptionStatus;
// trial | active | suspended | past_due
@override final  DateTime? trialEndsAt;
@override@JsonKey() final  int trialDays;
@override final  DateTime? subscriptionEndsAt;
// Staff references
 final  List<String> _staffIds;
// Staff references
@override@JsonKey() List<String> get staffIds {
  if (_staffIds is EqualUnmodifiableListView) return _staffIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_staffIds);
}

// Metadata
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
 final  Map<String, dynamic>? _customFields;
@override Map<String, dynamic>? get customFields {
  final value = _customFields;
  if (value == null) return null;
  if (_customFields is EqualUnmodifiableMapView) return _customFields;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.stripeOnboarded, stripeOnboarded) || other.stripeOnboarded == stripeOnboarded)&&(identical(other.platformFeePercent, platformFeePercent) || other.platformFeePercent == platformFeePercent)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.businessConfig, businessConfig) || other.businessConfig == businessConfig)&&(identical(other.maxStaffCount, maxStaffCount) || other.maxStaffCount == maxStaffCount)&&(identical(other.maxActiveServices, maxActiveServices) || other.maxActiveServices == maxActiveServices)&&(identical(other.hasLoyaltyProgram, hasLoyaltyProgram) || other.hasLoyaltyProgram == hasLoyaltyProgram)&&(identical(other.sendAutomatedReminders, sendAutomatedReminders) || other.sendAutomatedReminders == sendAutomatedReminders)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.trialEndsAt, trialEndsAt) || other.trialEndsAt == trialEndsAt)&&(identical(other.trialDays, trialDays) || other.trialDays == trialDays)&&(identical(other.subscriptionEndsAt, subscriptionEndsAt) || other.subscriptionEndsAt == subscriptionEndsAt)&&const DeepCollectionEquality().equals(other._staffIds, _staffIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._customFields, _customFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,ownerUid,status,stripeAccountId,stripeOnboarded,platformFeePercent,logoUrl,coverImageUrl,primaryColor,secondaryColor,phone,whatsapp,email,address,city,state,zipCode,latitude,longitude,businessConfig,maxStaffCount,maxActiveServices,hasLoyaltyProgram,sendAutomatedReminders,notificationsEnabled,subscriptionStatus,trialEndsAt,trialDays,subscriptionEndsAt,const DeepCollectionEquality().hash(_staffIds),createdAt,updatedAt,const DeepCollectionEquality().hash(_customFields)]);

@override
String toString() {
  return 'Tenant(id: $id, name: $name, ownerUid: $ownerUid, status: $status, stripeAccountId: $stripeAccountId, stripeOnboarded: $stripeOnboarded, platformFeePercent: $platformFeePercent, logoUrl: $logoUrl, coverImageUrl: $coverImageUrl, primaryColor: $primaryColor, secondaryColor: $secondaryColor, phone: $phone, whatsapp: $whatsapp, email: $email, address: $address, city: $city, state: $state, zipCode: $zipCode, latitude: $latitude, longitude: $longitude, businessConfig: $businessConfig, maxStaffCount: $maxStaffCount, maxActiveServices: $maxActiveServices, hasLoyaltyProgram: $hasLoyaltyProgram, sendAutomatedReminders: $sendAutomatedReminders, notificationsEnabled: $notificationsEnabled, subscriptionStatus: $subscriptionStatus, trialEndsAt: $trialEndsAt, trialDays: $trialDays, subscriptionEndsAt: $subscriptionEndsAt, staffIds: $staffIds, createdAt: $createdAt, updatedAt: $updatedAt, customFields: $customFields)';
}


}

/// @nodoc
abstract mixin class _$TenantCopyWith<$Res> implements $TenantCopyWith<$Res> {
  factory _$TenantCopyWith(_Tenant value, $Res Function(_Tenant) _then) = __$TenantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ownerUid, String status, String? stripeAccountId, bool stripeOnboarded, int platformFeePercent, String? logoUrl, String? coverImageUrl, String primaryColor, String? secondaryColor, String? phone, String? whatsapp, String? email, String? address, String? city, String? state, String? zipCode, double? latitude, double? longitude, BusinessConfig? businessConfig, int maxStaffCount, int maxActiveServices, bool hasLoyaltyProgram, bool sendAutomatedReminders, bool notificationsEnabled, String subscriptionStatus, DateTime? trialEndsAt, int trialDays, DateTime? subscriptionEndsAt, List<String> staffIds, DateTime? createdAt, DateTime? updatedAt, Map<String, dynamic>? customFields
});


@override $BusinessConfigCopyWith<$Res>? get businessConfig;

}
/// @nodoc
class __$TenantCopyWithImpl<$Res>
    implements _$TenantCopyWith<$Res> {
  __$TenantCopyWithImpl(this._self, this._then);

  final _Tenant _self;
  final $Res Function(_Tenant) _then;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerUid = null,Object? status = null,Object? stripeAccountId = freezed,Object? stripeOnboarded = null,Object? platformFeePercent = null,Object? logoUrl = freezed,Object? coverImageUrl = freezed,Object? primaryColor = null,Object? secondaryColor = freezed,Object? phone = freezed,Object? whatsapp = freezed,Object? email = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? zipCode = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? businessConfig = freezed,Object? maxStaffCount = null,Object? maxActiveServices = null,Object? hasLoyaltyProgram = null,Object? sendAutomatedReminders = null,Object? notificationsEnabled = null,Object? subscriptionStatus = null,Object? trialEndsAt = freezed,Object? trialDays = null,Object? subscriptionEndsAt = freezed,Object? staffIds = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? customFields = freezed,}) {
  return _then(_Tenant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,stripeOnboarded: null == stripeOnboarded ? _self.stripeOnboarded : stripeOnboarded // ignore: cast_nullable_to_non_nullable
as bool,platformFeePercent: null == platformFeePercent ? _self.platformFeePercent : platformFeePercent // ignore: cast_nullable_to_non_nullable
as int,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,secondaryColor: freezed == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,businessConfig: freezed == businessConfig ? _self.businessConfig : businessConfig // ignore: cast_nullable_to_non_nullable
as BusinessConfig?,maxStaffCount: null == maxStaffCount ? _self.maxStaffCount : maxStaffCount // ignore: cast_nullable_to_non_nullable
as int,maxActiveServices: null == maxActiveServices ? _self.maxActiveServices : maxActiveServices // ignore: cast_nullable_to_non_nullable
as int,hasLoyaltyProgram: null == hasLoyaltyProgram ? _self.hasLoyaltyProgram : hasLoyaltyProgram // ignore: cast_nullable_to_non_nullable
as bool,sendAutomatedReminders: null == sendAutomatedReminders ? _self.sendAutomatedReminders : sendAutomatedReminders // ignore: cast_nullable_to_non_nullable
as bool,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,subscriptionStatus: null == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String,trialEndsAt: freezed == trialEndsAt ? _self.trialEndsAt : trialEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trialDays: null == trialDays ? _self.trialDays : trialDays // ignore: cast_nullable_to_non_nullable
as int,subscriptionEndsAt: freezed == subscriptionEndsAt ? _self.subscriptionEndsAt : subscriptionEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,staffIds: null == staffIds ? _self._staffIds : staffIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,customFields: freezed == customFields ? _self._customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BusinessConfigCopyWith<$Res>? get businessConfig {
    if (_self.businessConfig == null) {
    return null;
  }

  return $BusinessConfigCopyWith<$Res>(_self.businessConfig!, (value) {
    return _then(_self.copyWith(businessConfig: value));
  });
}
}

// dart format on
