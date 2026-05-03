// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'independent_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IndependentService {

 String get id; String get title; String get description; double get price; int get durationMinutes; String get iconName;// Material icon name
 bool get isActive; bool get requiresVehicle;// Some services might not need a vehicle
 String? get imageUrl; DateTime? get createdAt;
/// Create a copy of IndependentService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndependentServiceCopyWith<IndependentService> get copyWith => _$IndependentServiceCopyWithImpl<IndependentService>(this as IndependentService, _$identity);

  /// Serializes this IndependentService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndependentService&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.requiresVehicle, requiresVehicle) || other.requiresVehicle == requiresVehicle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,price,durationMinutes,iconName,isActive,requiresVehicle,imageUrl,createdAt);

@override
String toString() {
  return 'IndependentService(id: $id, title: $title, description: $description, price: $price, durationMinutes: $durationMinutes, iconName: $iconName, isActive: $isActive, requiresVehicle: $requiresVehicle, imageUrl: $imageUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $IndependentServiceCopyWith<$Res>  {
  factory $IndependentServiceCopyWith(IndependentService value, $Res Function(IndependentService) _then) = _$IndependentServiceCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, double price, int durationMinutes, String iconName, bool isActive, bool requiresVehicle, String? imageUrl, DateTime? createdAt
});




}
/// @nodoc
class _$IndependentServiceCopyWithImpl<$Res>
    implements $IndependentServiceCopyWith<$Res> {
  _$IndependentServiceCopyWithImpl(this._self, this._then);

  final IndependentService _self;
  final $Res Function(IndependentService) _then;

/// Create a copy of IndependentService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? price = null,Object? durationMinutes = null,Object? iconName = null,Object? isActive = null,Object? requiresVehicle = null,Object? imageUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,requiresVehicle: null == requiresVehicle ? _self.requiresVehicle : requiresVehicle // ignore: cast_nullable_to_non_nullable
as bool,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [IndependentService].
extension IndependentServicePatterns on IndependentService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IndependentService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IndependentService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IndependentService value)  $default,){
final _that = this;
switch (_that) {
case _IndependentService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IndependentService value)?  $default,){
final _that = this;
switch (_that) {
case _IndependentService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  double price,  int durationMinutes,  String iconName,  bool isActive,  bool requiresVehicle,  String? imageUrl,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IndependentService() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.price,_that.durationMinutes,_that.iconName,_that.isActive,_that.requiresVehicle,_that.imageUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  double price,  int durationMinutes,  String iconName,  bool isActive,  bool requiresVehicle,  String? imageUrl,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _IndependentService():
return $default(_that.id,_that.title,_that.description,_that.price,_that.durationMinutes,_that.iconName,_that.isActive,_that.requiresVehicle,_that.imageUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  double price,  int durationMinutes,  String iconName,  bool isActive,  bool requiresVehicle,  String? imageUrl,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _IndependentService() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.price,_that.durationMinutes,_that.iconName,_that.isActive,_that.requiresVehicle,_that.imageUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IndependentService implements IndependentService {
  const _IndependentService({required this.id, required this.title, required this.description, required this.price, required this.durationMinutes, this.iconName = 'build', this.isActive = true, this.requiresVehicle = false, this.imageUrl, this.createdAt});
  factory _IndependentService.fromJson(Map<String, dynamic> json) => _$IndependentServiceFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  double price;
@override final  int durationMinutes;
@override@JsonKey() final  String iconName;
// Material icon name
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool requiresVehicle;
// Some services might not need a vehicle
@override final  String? imageUrl;
@override final  DateTime? createdAt;

/// Create a copy of IndependentService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndependentServiceCopyWith<_IndependentService> get copyWith => __$IndependentServiceCopyWithImpl<_IndependentService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IndependentServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndependentService&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.requiresVehicle, requiresVehicle) || other.requiresVehicle == requiresVehicle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,price,durationMinutes,iconName,isActive,requiresVehicle,imageUrl,createdAt);

@override
String toString() {
  return 'IndependentService(id: $id, title: $title, description: $description, price: $price, durationMinutes: $durationMinutes, iconName: $iconName, isActive: $isActive, requiresVehicle: $requiresVehicle, imageUrl: $imageUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$IndependentServiceCopyWith<$Res> implements $IndependentServiceCopyWith<$Res> {
  factory _$IndependentServiceCopyWith(_IndependentService value, $Res Function(_IndependentService) _then) = __$IndependentServiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, double price, int durationMinutes, String iconName, bool isActive, bool requiresVehicle, String? imageUrl, DateTime? createdAt
});




}
/// @nodoc
class __$IndependentServiceCopyWithImpl<$Res>
    implements _$IndependentServiceCopyWith<$Res> {
  __$IndependentServiceCopyWithImpl(this._self, this._then);

  final _IndependentService _self;
  final $Res Function(_IndependentService) _then;

/// Create a copy of IndependentService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? price = null,Object? durationMinutes = null,Object? iconName = null,Object? isActive = null,Object? requiresVehicle = null,Object? imageUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_IndependentService(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,requiresVehicle: null == requiresVehicle ? _self.requiresVehicle : requiresVehicle // ignore: cast_nullable_to_non_nullable
as bool,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
