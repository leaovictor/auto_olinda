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

 String get uid; String get email; String? get displayName; String? get photoUrl; String get role; String? get fcmToken; String? get phoneNumber; String? get assignedCompanyId;// ID of the company this user is associated with (as admin/staff)
 bool get isWhatsApp; String get status;// active, suspended, cancelled
 Address? get address; String? get ndaAcceptedVersion;@TimestampConverter() DateTime? get ndaAcceptedAt;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.assignedCompanyId, assignedCompanyId) || other.assignedCompanyId == assignedCompanyId)&&(identical(other.isWhatsApp, isWhatsApp) || other.isWhatsApp == isWhatsApp)&&(identical(other.status, status) || other.status == status)&&(identical(other.address, address) || other.address == address)&&(identical(other.ndaAcceptedVersion, ndaAcceptedVersion) || other.ndaAcceptedVersion == ndaAcceptedVersion)&&(identical(other.ndaAcceptedAt, ndaAcceptedAt) || other.ndaAcceptedAt == ndaAcceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,displayName,photoUrl,role,fcmToken,phoneNumber,assignedCompanyId,isWhatsApp,status,address,ndaAcceptedVersion,ndaAcceptedAt);

@override
String toString() {
  return 'AppUser(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, role: $role, fcmToken: $fcmToken, phoneNumber: $phoneNumber, assignedCompanyId: $assignedCompanyId, isWhatsApp: $isWhatsApp, status: $status, address: $address, ndaAcceptedVersion: $ndaAcceptedVersion, ndaAcceptedAt: $ndaAcceptedAt)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String? displayName, String? photoUrl, String role, String? fcmToken, String? phoneNumber, String? assignedCompanyId, bool isWhatsApp, String status, Address? address, String? ndaAcceptedVersion,@TimestampConverter() DateTime? ndaAcceptedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? displayName = freezed,Object? photoUrl = freezed,Object? role = null,Object? fcmToken = freezed,Object? phoneNumber = freezed,Object? assignedCompanyId = freezed,Object? isWhatsApp = null,Object? status = null,Object? address = freezed,Object? ndaAcceptedVersion = freezed,Object? ndaAcceptedAt = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,assignedCompanyId: freezed == assignedCompanyId ? _self.assignedCompanyId : assignedCompanyId // ignore: cast_nullable_to_non_nullable
as String?,isWhatsApp: null == isWhatsApp ? _self.isWhatsApp : isWhatsApp // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address?,ndaAcceptedVersion: freezed == ndaAcceptedVersion ? _self.ndaAcceptedVersion : ndaAcceptedVersion // ignore: cast_nullable_to_non_nullable
as String?,ndaAcceptedAt: freezed == ndaAcceptedAt ? _self.ndaAcceptedAt : ndaAcceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String? displayName,  String? photoUrl,  String role,  String? fcmToken,  String? phoneNumber,  String? assignedCompanyId,  bool isWhatsApp,  String status,  Address? address,  String? ndaAcceptedVersion, @TimestampConverter()  DateTime? ndaAcceptedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.role,_that.fcmToken,_that.phoneNumber,_that.assignedCompanyId,_that.isWhatsApp,_that.status,_that.address,_that.ndaAcceptedVersion,_that.ndaAcceptedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String? displayName,  String? photoUrl,  String role,  String? fcmToken,  String? phoneNumber,  String? assignedCompanyId,  bool isWhatsApp,  String status,  Address? address,  String? ndaAcceptedVersion, @TimestampConverter()  DateTime? ndaAcceptedAt)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.role,_that.fcmToken,_that.phoneNumber,_that.assignedCompanyId,_that.isWhatsApp,_that.status,_that.address,_that.ndaAcceptedVersion,_that.ndaAcceptedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String? displayName,  String? photoUrl,  String role,  String? fcmToken,  String? phoneNumber,  String? assignedCompanyId,  bool isWhatsApp,  String status,  Address? address,  String? ndaAcceptedVersion, @TimestampConverter()  DateTime? ndaAcceptedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.role,_that.fcmToken,_that.phoneNumber,_that.assignedCompanyId,_that.isWhatsApp,_that.status,_that.address,_that.ndaAcceptedVersion,_that.ndaAcceptedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
  const _AppUser({required this.uid, required this.email, this.displayName, this.photoUrl, this.role = 'client', this.fcmToken, this.phoneNumber, this.assignedCompanyId, this.isWhatsApp = false, this.status = 'active', this.address, this.ndaAcceptedVersion, @TimestampConverter() this.ndaAcceptedAt});
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String? displayName;
@override final  String? photoUrl;
@override@JsonKey() final  String role;
@override final  String? fcmToken;
@override final  String? phoneNumber;
@override final  String? assignedCompanyId;
// ID of the company this user is associated with (as admin/staff)
@override@JsonKey() final  bool isWhatsApp;
@override@JsonKey() final  String status;
// active, suspended, cancelled
@override final  Address? address;
@override final  String? ndaAcceptedVersion;
@override@TimestampConverter() final  DateTime? ndaAcceptedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.assignedCompanyId, assignedCompanyId) || other.assignedCompanyId == assignedCompanyId)&&(identical(other.isWhatsApp, isWhatsApp) || other.isWhatsApp == isWhatsApp)&&(identical(other.status, status) || other.status == status)&&(identical(other.address, address) || other.address == address)&&(identical(other.ndaAcceptedVersion, ndaAcceptedVersion) || other.ndaAcceptedVersion == ndaAcceptedVersion)&&(identical(other.ndaAcceptedAt, ndaAcceptedAt) || other.ndaAcceptedAt == ndaAcceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,displayName,photoUrl,role,fcmToken,phoneNumber,assignedCompanyId,isWhatsApp,status,address,ndaAcceptedVersion,ndaAcceptedAt);

@override
String toString() {
  return 'AppUser(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, role: $role, fcmToken: $fcmToken, phoneNumber: $phoneNumber, assignedCompanyId: $assignedCompanyId, isWhatsApp: $isWhatsApp, status: $status, address: $address, ndaAcceptedVersion: $ndaAcceptedVersion, ndaAcceptedAt: $ndaAcceptedAt)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String? displayName, String? photoUrl, String role, String? fcmToken, String? phoneNumber, String? assignedCompanyId, bool isWhatsApp, String status, Address? address, String? ndaAcceptedVersion,@TimestampConverter() DateTime? ndaAcceptedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = freezed,Object? photoUrl = freezed,Object? role = null,Object? fcmToken = freezed,Object? phoneNumber = freezed,Object? assignedCompanyId = freezed,Object? isWhatsApp = null,Object? status = null,Object? address = freezed,Object? ndaAcceptedVersion = freezed,Object? ndaAcceptedAt = freezed,}) {
  return _then(_AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,assignedCompanyId: freezed == assignedCompanyId ? _self.assignedCompanyId : assignedCompanyId // ignore: cast_nullable_to_non_nullable
as String?,isWhatsApp: null == isWhatsApp ? _self.isWhatsApp : isWhatsApp // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address?,ndaAcceptedVersion: freezed == ndaAcceptedVersion ? _self.ndaAcceptedVersion : ndaAcceptedVersion // ignore: cast_nullable_to_non_nullable
as String?,ndaAcceptedAt: freezed == ndaAcceptedAt ? _self.ndaAcceptedAt : ndaAcceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
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
