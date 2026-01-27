// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewTag {

 String get id; String get label;// Ex: "Serviço Rápido"
 String get emoji;// Ex: "⭐"
 bool get isActive;// Controle de ativação/desativação
 int get displayOrder;// Ordem de exibição
 DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of ReviewTag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewTagCopyWith<ReviewTag> get copyWith => _$ReviewTagCopyWithImpl<ReviewTag>(this as ReviewTag, _$identity);

  /// Serializes this ReviewTag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewTag&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,emoji,isActive,displayOrder,createdAt,updatedAt);

@override
String toString() {
  return 'ReviewTag(id: $id, label: $label, emoji: $emoji, isActive: $isActive, displayOrder: $displayOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReviewTagCopyWith<$Res>  {
  factory $ReviewTagCopyWith(ReviewTag value, $Res Function(ReviewTag) _then) = _$ReviewTagCopyWithImpl;
@useResult
$Res call({
 String id, String label, String emoji, bool isActive, int displayOrder, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ReviewTagCopyWithImpl<$Res>
    implements $ReviewTagCopyWith<$Res> {
  _$ReviewTagCopyWithImpl(this._self, this._then);

  final ReviewTag _self;
  final $Res Function(ReviewTag) _then;

/// Create a copy of ReviewTag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? emoji = null,Object? isActive = null,Object? displayOrder = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewTag].
extension ReviewTagPatterns on ReviewTag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewTag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewTag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewTag value)  $default,){
final _that = this;
switch (_that) {
case _ReviewTag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewTag value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewTag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String emoji,  bool isActive,  int displayOrder,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewTag() when $default != null:
return $default(_that.id,_that.label,_that.emoji,_that.isActive,_that.displayOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String emoji,  bool isActive,  int displayOrder,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReviewTag():
return $default(_that.id,_that.label,_that.emoji,_that.isActive,_that.displayOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String emoji,  bool isActive,  int displayOrder,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReviewTag() when $default != null:
return $default(_that.id,_that.label,_that.emoji,_that.isActive,_that.displayOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewTag implements ReviewTag {
  const _ReviewTag({required this.id, required this.label, required this.emoji, this.isActive = true, this.displayOrder = 0, required this.createdAt, this.updatedAt});
  factory _ReviewTag.fromJson(Map<String, dynamic> json) => _$ReviewTagFromJson(json);

@override final  String id;
@override final  String label;
// Ex: "Serviço Rápido"
@override final  String emoji;
// Ex: "⭐"
@override@JsonKey() final  bool isActive;
// Controle de ativação/desativação
@override@JsonKey() final  int displayOrder;
// Ordem de exibição
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ReviewTag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewTagCopyWith<_ReviewTag> get copyWith => __$ReviewTagCopyWithImpl<_ReviewTag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewTagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewTag&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,emoji,isActive,displayOrder,createdAt,updatedAt);

@override
String toString() {
  return 'ReviewTag(id: $id, label: $label, emoji: $emoji, isActive: $isActive, displayOrder: $displayOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewTagCopyWith<$Res> implements $ReviewTagCopyWith<$Res> {
  factory _$ReviewTagCopyWith(_ReviewTag value, $Res Function(_ReviewTag) _then) = __$ReviewTagCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String emoji, bool isActive, int displayOrder, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ReviewTagCopyWithImpl<$Res>
    implements _$ReviewTagCopyWith<$Res> {
  __$ReviewTagCopyWithImpl(this._self, this._then);

  final _ReviewTag _self;
  final $Res Function(_ReviewTag) _then;

/// Create a copy of ReviewTag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? emoji = null,Object? isActive = null,Object? displayOrder = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_ReviewTag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
