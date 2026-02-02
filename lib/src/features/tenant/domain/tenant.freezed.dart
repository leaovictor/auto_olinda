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

 String get id; String get name; String get slug; String get ownerId; String? get stripeCustomerId; TenantBranding get branding; TenantDomains get domains;@TimestampConverter() DateTime? get createdAt;
/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantCopyWith<Tenant> get copyWith => _$TenantCopyWithImpl<Tenant>(this as Tenant, _$identity);

  /// Serializes this Tenant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.branding, branding) || other.branding == branding)&&(identical(other.domains, domains) || other.domains == domains)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,ownerId,stripeCustomerId,branding,domains,createdAt);

@override
String toString() {
  return 'Tenant(id: $id, name: $name, slug: $slug, ownerId: $ownerId, stripeCustomerId: $stripeCustomerId, branding: $branding, domains: $domains, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TenantCopyWith<$Res>  {
  factory $TenantCopyWith(Tenant value, $Res Function(Tenant) _then) = _$TenantCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug, String ownerId, String? stripeCustomerId, TenantBranding branding, TenantDomains domains,@TimestampConverter() DateTime? createdAt
});


$TenantBrandingCopyWith<$Res> get branding;$TenantDomainsCopyWith<$Res> get domains;

}
/// @nodoc
class _$TenantCopyWithImpl<$Res>
    implements $TenantCopyWith<$Res> {
  _$TenantCopyWithImpl(this._self, this._then);

  final Tenant _self;
  final $Res Function(Tenant) _then;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? ownerId = null,Object? stripeCustomerId = freezed,Object? branding = null,Object? domains = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,branding: null == branding ? _self.branding : branding // ignore: cast_nullable_to_non_nullable
as TenantBranding,domains: null == domains ? _self.domains : domains // ignore: cast_nullable_to_non_nullable
as TenantDomains,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantBrandingCopyWith<$Res> get branding {
  
  return $TenantBrandingCopyWith<$Res>(_self.branding, (value) {
    return _then(_self.copyWith(branding: value));
  });
}/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantDomainsCopyWith<$Res> get domains {
  
  return $TenantDomainsCopyWith<$Res>(_self.domains, (value) {
    return _then(_self.copyWith(domains: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String ownerId,  String? stripeCustomerId,  TenantBranding branding,  TenantDomains domains, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.ownerId,_that.stripeCustomerId,_that.branding,_that.domains,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String ownerId,  String? stripeCustomerId,  TenantBranding branding,  TenantDomains domains, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Tenant():
return $default(_that.id,_that.name,_that.slug,_that.ownerId,_that.stripeCustomerId,_that.branding,_that.domains,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug,  String ownerId,  String? stripeCustomerId,  TenantBranding branding,  TenantDomains domains, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.ownerId,_that.stripeCustomerId,_that.branding,_that.domains,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tenant implements Tenant {
  const _Tenant({required this.id, required this.name, required this.slug, required this.ownerId, this.stripeCustomerId, required this.branding, required this.domains, @TimestampConverter() this.createdAt});
  factory _Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override final  String ownerId;
@override final  String? stripeCustomerId;
@override final  TenantBranding branding;
@override final  TenantDomains domains;
@override@TimestampConverter() final  DateTime? createdAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.branding, branding) || other.branding == branding)&&(identical(other.domains, domains) || other.domains == domains)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,ownerId,stripeCustomerId,branding,domains,createdAt);

@override
String toString() {
  return 'Tenant(id: $id, name: $name, slug: $slug, ownerId: $ownerId, stripeCustomerId: $stripeCustomerId, branding: $branding, domains: $domains, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TenantCopyWith<$Res> implements $TenantCopyWith<$Res> {
  factory _$TenantCopyWith(_Tenant value, $Res Function(_Tenant) _then) = __$TenantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug, String ownerId, String? stripeCustomerId, TenantBranding branding, TenantDomains domains,@TimestampConverter() DateTime? createdAt
});


@override $TenantBrandingCopyWith<$Res> get branding;@override $TenantDomainsCopyWith<$Res> get domains;

}
/// @nodoc
class __$TenantCopyWithImpl<$Res>
    implements _$TenantCopyWith<$Res> {
  __$TenantCopyWithImpl(this._self, this._then);

  final _Tenant _self;
  final $Res Function(_Tenant) _then;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? ownerId = null,Object? stripeCustomerId = freezed,Object? branding = null,Object? domains = null,Object? createdAt = freezed,}) {
  return _then(_Tenant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,branding: null == branding ? _self.branding : branding // ignore: cast_nullable_to_non_nullable
as TenantBranding,domains: null == domains ? _self.domains : domains // ignore: cast_nullable_to_non_nullable
as TenantDomains,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantBrandingCopyWith<$Res> get branding {
  
  return $TenantBrandingCopyWith<$Res>(_self.branding, (value) {
    return _then(_self.copyWith(branding: value));
  });
}/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantDomainsCopyWith<$Res> get domains {
  
  return $TenantDomainsCopyWith<$Res>(_self.domains, (value) {
    return _then(_self.copyWith(domains: value));
  });
}
}


/// @nodoc
mixin _$TenantBranding {

 String? get logoUrl; String get primaryColor;
/// Create a copy of TenantBranding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantBrandingCopyWith<TenantBranding> get copyWith => _$TenantBrandingCopyWithImpl<TenantBranding>(this as TenantBranding, _$identity);

  /// Serializes this TenantBranding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantBranding&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,logoUrl,primaryColor);

@override
String toString() {
  return 'TenantBranding(logoUrl: $logoUrl, primaryColor: $primaryColor)';
}


}

/// @nodoc
abstract mixin class $TenantBrandingCopyWith<$Res>  {
  factory $TenantBrandingCopyWith(TenantBranding value, $Res Function(TenantBranding) _then) = _$TenantBrandingCopyWithImpl;
@useResult
$Res call({
 String? logoUrl, String primaryColor
});




}
/// @nodoc
class _$TenantBrandingCopyWithImpl<$Res>
    implements $TenantBrandingCopyWith<$Res> {
  _$TenantBrandingCopyWithImpl(this._self, this._then);

  final TenantBranding _self;
  final $Res Function(TenantBranding) _then;

/// Create a copy of TenantBranding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logoUrl = freezed,Object? primaryColor = null,}) {
  return _then(_self.copyWith(
logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantBranding].
extension TenantBrandingPatterns on TenantBranding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantBranding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantBranding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantBranding value)  $default,){
final _that = this;
switch (_that) {
case _TenantBranding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantBranding value)?  $default,){
final _that = this;
switch (_that) {
case _TenantBranding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? logoUrl,  String primaryColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantBranding() when $default != null:
return $default(_that.logoUrl,_that.primaryColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? logoUrl,  String primaryColor)  $default,) {final _that = this;
switch (_that) {
case _TenantBranding():
return $default(_that.logoUrl,_that.primaryColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? logoUrl,  String primaryColor)?  $default,) {final _that = this;
switch (_that) {
case _TenantBranding() when $default != null:
return $default(_that.logoUrl,_that.primaryColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantBranding implements TenantBranding {
  const _TenantBranding({this.logoUrl, required this.primaryColor});
  factory _TenantBranding.fromJson(Map<String, dynamic> json) => _$TenantBrandingFromJson(json);

@override final  String? logoUrl;
@override final  String primaryColor;

/// Create a copy of TenantBranding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantBrandingCopyWith<_TenantBranding> get copyWith => __$TenantBrandingCopyWithImpl<_TenantBranding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantBrandingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantBranding&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,logoUrl,primaryColor);

@override
String toString() {
  return 'TenantBranding(logoUrl: $logoUrl, primaryColor: $primaryColor)';
}


}

/// @nodoc
abstract mixin class _$TenantBrandingCopyWith<$Res> implements $TenantBrandingCopyWith<$Res> {
  factory _$TenantBrandingCopyWith(_TenantBranding value, $Res Function(_TenantBranding) _then) = __$TenantBrandingCopyWithImpl;
@override @useResult
$Res call({
 String? logoUrl, String primaryColor
});




}
/// @nodoc
class __$TenantBrandingCopyWithImpl<$Res>
    implements _$TenantBrandingCopyWith<$Res> {
  __$TenantBrandingCopyWithImpl(this._self, this._then);

  final _TenantBranding _self;
  final $Res Function(_TenantBranding) _then;

/// Create a copy of TenantBranding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logoUrl = freezed,Object? primaryColor = null,}) {
  return _then(_TenantBranding(
logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TenantDomains {

 String get subdomain; String? get customDomain; bool get domainVerified;
/// Create a copy of TenantDomains
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantDomainsCopyWith<TenantDomains> get copyWith => _$TenantDomainsCopyWithImpl<TenantDomains>(this as TenantDomains, _$identity);

  /// Serializes this TenantDomains to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantDomains&&(identical(other.subdomain, subdomain) || other.subdomain == subdomain)&&(identical(other.customDomain, customDomain) || other.customDomain == customDomain)&&(identical(other.domainVerified, domainVerified) || other.domainVerified == domainVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subdomain,customDomain,domainVerified);

@override
String toString() {
  return 'TenantDomains(subdomain: $subdomain, customDomain: $customDomain, domainVerified: $domainVerified)';
}


}

/// @nodoc
abstract mixin class $TenantDomainsCopyWith<$Res>  {
  factory $TenantDomainsCopyWith(TenantDomains value, $Res Function(TenantDomains) _then) = _$TenantDomainsCopyWithImpl;
@useResult
$Res call({
 String subdomain, String? customDomain, bool domainVerified
});




}
/// @nodoc
class _$TenantDomainsCopyWithImpl<$Res>
    implements $TenantDomainsCopyWith<$Res> {
  _$TenantDomainsCopyWithImpl(this._self, this._then);

  final TenantDomains _self;
  final $Res Function(TenantDomains) _then;

/// Create a copy of TenantDomains
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subdomain = null,Object? customDomain = freezed,Object? domainVerified = null,}) {
  return _then(_self.copyWith(
subdomain: null == subdomain ? _self.subdomain : subdomain // ignore: cast_nullable_to_non_nullable
as String,customDomain: freezed == customDomain ? _self.customDomain : customDomain // ignore: cast_nullable_to_non_nullable
as String?,domainVerified: null == domainVerified ? _self.domainVerified : domainVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantDomains].
extension TenantDomainsPatterns on TenantDomains {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantDomains value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantDomains() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantDomains value)  $default,){
final _that = this;
switch (_that) {
case _TenantDomains():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantDomains value)?  $default,){
final _that = this;
switch (_that) {
case _TenantDomains() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String subdomain,  String? customDomain,  bool domainVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantDomains() when $default != null:
return $default(_that.subdomain,_that.customDomain,_that.domainVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String subdomain,  String? customDomain,  bool domainVerified)  $default,) {final _that = this;
switch (_that) {
case _TenantDomains():
return $default(_that.subdomain,_that.customDomain,_that.domainVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String subdomain,  String? customDomain,  bool domainVerified)?  $default,) {final _that = this;
switch (_that) {
case _TenantDomains() when $default != null:
return $default(_that.subdomain,_that.customDomain,_that.domainVerified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantDomains implements TenantDomains {
  const _TenantDomains({required this.subdomain, this.customDomain, this.domainVerified = false});
  factory _TenantDomains.fromJson(Map<String, dynamic> json) => _$TenantDomainsFromJson(json);

@override final  String subdomain;
@override final  String? customDomain;
@override@JsonKey() final  bool domainVerified;

/// Create a copy of TenantDomains
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantDomainsCopyWith<_TenantDomains> get copyWith => __$TenantDomainsCopyWithImpl<_TenantDomains>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantDomainsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantDomains&&(identical(other.subdomain, subdomain) || other.subdomain == subdomain)&&(identical(other.customDomain, customDomain) || other.customDomain == customDomain)&&(identical(other.domainVerified, domainVerified) || other.domainVerified == domainVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subdomain,customDomain,domainVerified);

@override
String toString() {
  return 'TenantDomains(subdomain: $subdomain, customDomain: $customDomain, domainVerified: $domainVerified)';
}


}

/// @nodoc
abstract mixin class _$TenantDomainsCopyWith<$Res> implements $TenantDomainsCopyWith<$Res> {
  factory _$TenantDomainsCopyWith(_TenantDomains value, $Res Function(_TenantDomains) _then) = __$TenantDomainsCopyWithImpl;
@override @useResult
$Res call({
 String subdomain, String? customDomain, bool domainVerified
});




}
/// @nodoc
class __$TenantDomainsCopyWithImpl<$Res>
    implements _$TenantDomainsCopyWith<$Res> {
  __$TenantDomainsCopyWithImpl(this._self, this._then);

  final _TenantDomains _self;
  final $Res Function(_TenantDomains) _then;

/// Create a copy of TenantDomains
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subdomain = null,Object? customDomain = freezed,Object? domainVerified = null,}) {
  return _then(_TenantDomains(
subdomain: null == subdomain ? _self.subdomain : subdomain // ignore: cast_nullable_to_non_nullable
as String,customDomain: freezed == customDomain ? _self.customDomain : customDomain // ignore: cast_nullable_to_non_nullable
as String?,domainVerified: null == domainVerified ? _self.domainVerified : domainVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
