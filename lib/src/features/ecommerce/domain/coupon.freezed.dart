// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Coupon {

 String get id; String get code; String get name; String? get description; CouponType get type; double get value; List<CouponApplicableTo> get applicableTo; DateTime? get validFrom; DateTime? get validUntil; int? get maxUses; int get usedCount; bool get isActive; String? get stripeCouponId; double? get minimumPurchase; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CouponCopyWith<Coupon> get copyWith => _$CouponCopyWithImpl<Coupon>(this as Coupon, _$identity);

  /// Serializes this Coupon to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Coupon&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&const DeepCollectionEquality().equals(other.applicableTo, applicableTo)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.usedCount, usedCount) || other.usedCount == usedCount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.stripeCouponId, stripeCouponId) || other.stripeCouponId == stripeCouponId)&&(identical(other.minimumPurchase, minimumPurchase) || other.minimumPurchase == minimumPurchase)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,description,type,value,const DeepCollectionEquality().hash(applicableTo),validFrom,validUntil,maxUses,usedCount,isActive,stripeCouponId,minimumPurchase,createdAt,updatedAt);

@override
String toString() {
  return 'Coupon(id: $id, code: $code, name: $name, description: $description, type: $type, value: $value, applicableTo: $applicableTo, validFrom: $validFrom, validUntil: $validUntil, maxUses: $maxUses, usedCount: $usedCount, isActive: $isActive, stripeCouponId: $stripeCouponId, minimumPurchase: $minimumPurchase, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CouponCopyWith<$Res>  {
  factory $CouponCopyWith(Coupon value, $Res Function(Coupon) _then) = _$CouponCopyWithImpl;
@useResult
$Res call({
 String id, String code, String name, String? description, CouponType type, double value, List<CouponApplicableTo> applicableTo, DateTime? validFrom, DateTime? validUntil, int? maxUses, int usedCount, bool isActive, String? stripeCouponId, double? minimumPurchase, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$CouponCopyWithImpl<$Res>
    implements $CouponCopyWith<$Res> {
  _$CouponCopyWithImpl(this._self, this._then);

  final Coupon _self;
  final $Res Function(Coupon) _then;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? description = freezed,Object? type = null,Object? value = null,Object? applicableTo = null,Object? validFrom = freezed,Object? validUntil = freezed,Object? maxUses = freezed,Object? usedCount = null,Object? isActive = null,Object? stripeCouponId = freezed,Object? minimumPurchase = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CouponType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,applicableTo: null == applicableTo ? _self.applicableTo : applicableTo // ignore: cast_nullable_to_non_nullable
as List<CouponApplicableTo>,validFrom: freezed == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,usedCount: null == usedCount ? _self.usedCount : usedCount // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,stripeCouponId: freezed == stripeCouponId ? _self.stripeCouponId : stripeCouponId // ignore: cast_nullable_to_non_nullable
as String?,minimumPurchase: freezed == minimumPurchase ? _self.minimumPurchase : minimumPurchase // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Coupon].
extension CouponPatterns on Coupon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Coupon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Coupon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Coupon value)  $default,){
final _that = this;
switch (_that) {
case _Coupon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Coupon value)?  $default,){
final _that = this;
switch (_that) {
case _Coupon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String name,  String? description,  CouponType type,  double value,  List<CouponApplicableTo> applicableTo,  DateTime? validFrom,  DateTime? validUntil,  int? maxUses,  int usedCount,  bool isActive,  String? stripeCouponId,  double? minimumPurchase,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Coupon() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.type,_that.value,_that.applicableTo,_that.validFrom,_that.validUntil,_that.maxUses,_that.usedCount,_that.isActive,_that.stripeCouponId,_that.minimumPurchase,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String name,  String? description,  CouponType type,  double value,  List<CouponApplicableTo> applicableTo,  DateTime? validFrom,  DateTime? validUntil,  int? maxUses,  int usedCount,  bool isActive,  String? stripeCouponId,  double? minimumPurchase,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Coupon():
return $default(_that.id,_that.code,_that.name,_that.description,_that.type,_that.value,_that.applicableTo,_that.validFrom,_that.validUntil,_that.maxUses,_that.usedCount,_that.isActive,_that.stripeCouponId,_that.minimumPurchase,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String name,  String? description,  CouponType type,  double value,  List<CouponApplicableTo> applicableTo,  DateTime? validFrom,  DateTime? validUntil,  int? maxUses,  int usedCount,  bool isActive,  String? stripeCouponId,  double? minimumPurchase,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Coupon() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.type,_that.value,_that.applicableTo,_that.validFrom,_that.validUntil,_that.maxUses,_that.usedCount,_that.isActive,_that.stripeCouponId,_that.minimumPurchase,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Coupon implements Coupon {
  const _Coupon({required this.id, required this.code, required this.name, this.description, required this.type, required this.value, required final  List<CouponApplicableTo> applicableTo, this.validFrom, this.validUntil, this.maxUses, this.usedCount = 0, this.isActive = true, this.stripeCouponId, this.minimumPurchase, required this.createdAt, required this.updatedAt}): _applicableTo = applicableTo;
  factory _Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);

@override final  String id;
@override final  String code;
@override final  String name;
@override final  String? description;
@override final  CouponType type;
@override final  double value;
 final  List<CouponApplicableTo> _applicableTo;
@override List<CouponApplicableTo> get applicableTo {
  if (_applicableTo is EqualUnmodifiableListView) return _applicableTo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_applicableTo);
}

@override final  DateTime? validFrom;
@override final  DateTime? validUntil;
@override final  int? maxUses;
@override@JsonKey() final  int usedCount;
@override@JsonKey() final  bool isActive;
@override final  String? stripeCouponId;
@override final  double? minimumPurchase;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CouponCopyWith<_Coupon> get copyWith => __$CouponCopyWithImpl<_Coupon>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CouponToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Coupon&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&const DeepCollectionEquality().equals(other._applicableTo, _applicableTo)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.usedCount, usedCount) || other.usedCount == usedCount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.stripeCouponId, stripeCouponId) || other.stripeCouponId == stripeCouponId)&&(identical(other.minimumPurchase, minimumPurchase) || other.minimumPurchase == minimumPurchase)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,description,type,value,const DeepCollectionEquality().hash(_applicableTo),validFrom,validUntil,maxUses,usedCount,isActive,stripeCouponId,minimumPurchase,createdAt,updatedAt);

@override
String toString() {
  return 'Coupon(id: $id, code: $code, name: $name, description: $description, type: $type, value: $value, applicableTo: $applicableTo, validFrom: $validFrom, validUntil: $validUntil, maxUses: $maxUses, usedCount: $usedCount, isActive: $isActive, stripeCouponId: $stripeCouponId, minimumPurchase: $minimumPurchase, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CouponCopyWith<$Res> implements $CouponCopyWith<$Res> {
  factory _$CouponCopyWith(_Coupon value, $Res Function(_Coupon) _then) = __$CouponCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String name, String? description, CouponType type, double value, List<CouponApplicableTo> applicableTo, DateTime? validFrom, DateTime? validUntil, int? maxUses, int usedCount, bool isActive, String? stripeCouponId, double? minimumPurchase, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$CouponCopyWithImpl<$Res>
    implements _$CouponCopyWith<$Res> {
  __$CouponCopyWithImpl(this._self, this._then);

  final _Coupon _self;
  final $Res Function(_Coupon) _then;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? description = freezed,Object? type = null,Object? value = null,Object? applicableTo = null,Object? validFrom = freezed,Object? validUntil = freezed,Object? maxUses = freezed,Object? usedCount = null,Object? isActive = null,Object? stripeCouponId = freezed,Object? minimumPurchase = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Coupon(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CouponType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,applicableTo: null == applicableTo ? _self._applicableTo : applicableTo // ignore: cast_nullable_to_non_nullable
as List<CouponApplicableTo>,validFrom: freezed == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,usedCount: null == usedCount ? _self.usedCount : usedCount // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,stripeCouponId: freezed == stripeCouponId ? _self.stripeCouponId : stripeCouponId // ignore: cast_nullable_to_non_nullable
as String?,minimumPurchase: freezed == minimumPurchase ? _self.minimumPurchase : minimumPurchase // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
