// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get uid; String get email; String? get displayName; String? get photoUrl;// Role: superAdmin | tenantOwner | admin (legacy) | staff | customer | client (legacy)
 String get role;// Which tenant this user belongs to. Null for superAdmin.
 String? get tenantId; String? get fcmToken; String? get phoneNumber; String? get cpf; bool get isWhatsApp; String get status;// active, suspended, cancelled
 String get subscriptionStatus;// none, active, inactive, cancelled
@TimestampConverter() DateTime? get subscriptionUpdatedAt; Address? get address;@TimestampConverter() DateTime? get lastAccessAt;@TimestampConverter() DateTime? get strikeUntil; String? get lastStrikeReason;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.isWhatsApp, isWhatsApp) || other.isWhatsApp == isWhatsApp)&&(identical(other.status, status) || other.status == status)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.subscriptionUpdatedAt, subscriptionUpdatedAt) || other.subscriptionUpdatedAt == subscriptionUpdatedAt)&&(identical(other.address, address) || other.address == address)&&(identical(other.lastAccessAt, lastAccessAt) || other.lastAccessAt == lastAccessAt)&&(identical(other.strikeUntil, strikeUntil) || other.strikeUntil == strikeUntil)&&(identical(other.lastStrikeReason, lastStrikeReason) || other.lastStrikeReason == lastStrikeReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,displayName,photoUrl,role,tenantId,fcmToken,phoneNumber,cpf,isWhatsApp,status,subscriptionStatus,subscriptionUpdatedAt,address,lastAccessAt,strikeUntil,lastStrikeReason);

@override
String toString() {
  return 'AppUser(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, role: $role, tenantId: $tenantId, fcmToken: $fcmToken, phoneNumber: $phoneNumber, cpf: $cpf, isWhatsApp: $isWhatsApp, status: $status, subscriptionStatus: $subscriptionStatus, subscriptionUpdatedAt: $subscriptionUpdatedAt, address: $address, lastAccessAt: $lastAccessAt, strikeUntil: $strikeUntil, lastStrikeReason: $lastStrikeReason)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String? displayName, String? photoUrl, String role, String? tenantId, String? fcmToken, String? phoneNumber, String? cpf, bool isWhatsApp, String status, String subscriptionStatus,@TimestampConverter() DateTime? subscriptionUpdatedAt, Address? address,@TimestampConverter() DateTime? lastAccessAt,@TimestampConverter() DateTime? strikeUntil, String? lastStrikeReason
});


$AddressCopyWith<$Res>? get address;

}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? displayName = freezed,Object? photoUrl = freezed,Object? role = null,Object? tenantId = freezed,Object? fcmToken = freezed,Object? phoneNumber = freezed,Object? cpf = freezed,Object? isWhatsApp = null,Object? status = null,Object? subscriptionStatus = null,Object? subscriptionUpdatedAt = freezed,Object? address = freezed,Object? lastAccessAt = freezed,Object? strikeUntil = freezed,Object? lastStrikeReason = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,isWhatsApp: null == isWhatsApp ? _self.isWhatsApp : isWhatsApp // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,subscriptionStatus: null == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String,subscriptionUpdatedAt: freezed == subscriptionUpdatedAt ? _self.subscriptionUpdatedAt : subscriptionUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address?,lastAccessAt: freezed == lastAccessAt ? _self.lastAccessAt : lastAccessAt // ignore: cast_nullable_to_non_nullable
as DateTime?,strikeUntil: freezed == strikeUntil ? _self.strikeUntil : strikeUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStrikeReason: freezed == lastStrikeReason ? _self.lastStrikeReason : lastStrikeReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String? displayName,  String? photoUrl,  String role,  String? tenantId,  String? fcmToken,  String? phoneNumber,  String? cpf,  bool isWhatsApp,  String status,  String subscriptionStatus, @TimestampConverter()  DateTime? subscriptionUpdatedAt,  Address? address, @TimestampConverter()  DateTime? lastAccessAt, @TimestampConverter()  DateTime? strikeUntil,  String? lastStrikeReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.role,_that.tenantId,_that.fcmToken,_that.phoneNumber,_that.cpf,_that.isWhatsApp,_that.status,_that.subscriptionStatus,_that.subscriptionUpdatedAt,_that.address,_that.lastAccessAt,_that.strikeUntil,_that.lastStrikeReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String? displayName,  String? photoUrl,  String role,  String? tenantId,  String? fcmToken,  String? phoneNumber,  String? cpf,  bool isWhatsApp,  String status,  String subscriptionStatus, @TimestampConverter()  DateTime? subscriptionUpdatedAt,  Address? address, @TimestampConverter()  DateTime? lastAccessAt, @TimestampConverter()  DateTime? strikeUntil,  String? lastStrikeReason)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.role,_that.tenantId,_that.fcmToken,_that.phoneNumber,_that.cpf,_that.isWhatsApp,_that.status,_that.subscriptionStatus,_that.subscriptionUpdatedAt,_that.address,_that.lastAccessAt,_that.strikeUntil,_that.lastStrikeReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String? displayName,  String? photoUrl,  String role,  String? tenantId,  String? fcmToken,  String? phoneNumber,  String? cpf,  bool isWhatsApp,  String status,  String subscriptionStatus, @TimestampConverter()  DateTime? subscriptionUpdatedAt,  Address? address, @TimestampConverter()  DateTime? lastAccessAt, @TimestampConverter()  DateTime? strikeUntil,  String? lastStrikeReason)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.role,_that.tenantId,_that.fcmToken,_that.phoneNumber,_that.cpf,_that.isWhatsApp,_that.status,_that.subscriptionStatus,_that.subscriptionUpdatedAt,_that.address,_that.lastAccessAt,_that.strikeUntil,_that.lastStrikeReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
  const _AppUser({required this.uid, required this.email, this.displayName, this.photoUrl, this.role = 'customer', this.tenantId, this.fcmToken, this.phoneNumber, this.cpf, this.isWhatsApp = false, this.status = 'active', this.subscriptionStatus = 'none', @TimestampConverter() this.subscriptionUpdatedAt, this.address, @TimestampConverter() this.lastAccessAt, @TimestampConverter() this.strikeUntil, this.lastStrikeReason});
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String? displayName;
@override final  String? photoUrl;
// Role: superAdmin | tenantOwner | admin (legacy) | staff | customer | client (legacy)
@override@JsonKey() final  String role;
// Which tenant this user belongs to. Null for superAdmin.
@override final  String? tenantId;
@override final  String? fcmToken;
@override final  String? phoneNumber;
@override final  String? cpf;
@override@JsonKey() final  bool isWhatsApp;
@override@JsonKey() final  String status;
// active, suspended, cancelled
@override@JsonKey() final  String subscriptionStatus;
// none, active, inactive, cancelled
@override@TimestampConverter() final  DateTime? subscriptionUpdatedAt;
@override final  Address? address;
@override@TimestampConverter() final  DateTime? lastAccessAt;
@override@TimestampConverter() final  DateTime? strikeUntil;
@override final  String? lastStrikeReason;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.isWhatsApp, isWhatsApp) || other.isWhatsApp == isWhatsApp)&&(identical(other.status, status) || other.status == status)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.subscriptionUpdatedAt, subscriptionUpdatedAt) || other.subscriptionUpdatedAt == subscriptionUpdatedAt)&&(identical(other.address, address) || other.address == address)&&(identical(other.lastAccessAt, lastAccessAt) || other.lastAccessAt == lastAccessAt)&&(identical(other.strikeUntil, strikeUntil) || other.strikeUntil == strikeUntil)&&(identical(other.lastStrikeReason, lastStrikeReason) || other.lastStrikeReason == lastStrikeReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,displayName,photoUrl,role,tenantId,fcmToken,phoneNumber,cpf,isWhatsApp,status,subscriptionStatus,subscriptionUpdatedAt,address,lastAccessAt,strikeUntil,lastStrikeReason);

@override
String toString() {
  return 'AppUser(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, role: $role, tenantId: $tenantId, fcmToken: $fcmToken, phoneNumber: $phoneNumber, cpf: $cpf, isWhatsApp: $isWhatsApp, status: $status, subscriptionStatus: $subscriptionStatus, subscriptionUpdatedAt: $subscriptionUpdatedAt, address: $address, lastAccessAt: $lastAccessAt, strikeUntil: $strikeUntil, lastStrikeReason: $lastStrikeReason)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String? displayName, String? photoUrl, String role, String? tenantId, String? fcmToken, String? phoneNumber, String? cpf, bool isWhatsApp, String status, String subscriptionStatus,@TimestampConverter() DateTime? subscriptionUpdatedAt, Address? address,@TimestampConverter() DateTime? lastAccessAt,@TimestampConverter() DateTime? strikeUntil, String? lastStrikeReason
});


@override $AddressCopyWith<$Res>? get address;

}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = freezed,Object? photoUrl = freezed,Object? role = null,Object? tenantId = freezed,Object? fcmToken = freezed,Object? phoneNumber = freezed,Object? cpf = freezed,Object? isWhatsApp = null,Object? status = null,Object? subscriptionStatus = null,Object? subscriptionUpdatedAt = freezed,Object? address = freezed,Object? lastAccessAt = freezed,Object? strikeUntil = freezed,Object? lastStrikeReason = freezed,}) {
  return _then(_AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,isWhatsApp: null == isWhatsApp ? _self.isWhatsApp : isWhatsApp // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,subscriptionStatus: null == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String,subscriptionUpdatedAt: freezed == subscriptionUpdatedAt ? _self.subscriptionUpdatedAt : subscriptionUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address?,lastAccessAt: freezed == lastAccessAt ? _self.lastAccessAt : lastAccessAt // ignore: cast_nullable_to_non_nullable
as DateTime?,strikeUntil: freezed == strikeUntil ? _self.strikeUntil : strikeUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStrikeReason: freezed == lastStrikeReason ? _self.lastStrikeReason : lastStrikeReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}

// dart format on
