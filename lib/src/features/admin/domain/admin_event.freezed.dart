// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminEvent {

 String get id; String get title; String? get description; DateTime get date; DateTime? get remindAt; AdminEventType get type; bool get isDone; String? get companyId;
/// Create a copy of AdminEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminEventCopyWith<AdminEvent> get copyWith => _$AdminEventCopyWithImpl<AdminEvent>(this as AdminEvent, _$identity);

  /// Serializes this AdminEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.date, date) || other.date == date)&&(identical(other.remindAt, remindAt) || other.remindAt == remindAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.companyId, companyId) || other.companyId == companyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,date,remindAt,type,isDone,companyId);

@override
String toString() {
  return 'AdminEvent(id: $id, title: $title, description: $description, date: $date, remindAt: $remindAt, type: $type, isDone: $isDone, companyId: $companyId)';
}


}

/// @nodoc
abstract mixin class $AdminEventCopyWith<$Res>  {
  factory $AdminEventCopyWith(AdminEvent value, $Res Function(AdminEvent) _then) = _$AdminEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, DateTime date, DateTime? remindAt, AdminEventType type, bool isDone, String? companyId
});




}
/// @nodoc
class _$AdminEventCopyWithImpl<$Res>
    implements $AdminEventCopyWith<$Res> {
  _$AdminEventCopyWithImpl(this._self, this._then);

  final AdminEvent _self;
  final $Res Function(AdminEvent) _then;

/// Create a copy of AdminEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? date = null,Object? remindAt = freezed,Object? type = null,Object? isDone = null,Object? companyId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AdminEventType,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminEvent].
extension AdminEventPatterns on AdminEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminEvent value)  $default,){
final _that = this;
switch (_that) {
case _AdminEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminEvent value)?  $default,){
final _that = this;
switch (_that) {
case _AdminEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  DateTime date,  DateTime? remindAt,  AdminEventType type,  bool isDone,  String? companyId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.date,_that.remindAt,_that.type,_that.isDone,_that.companyId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  DateTime date,  DateTime? remindAt,  AdminEventType type,  bool isDone,  String? companyId)  $default,) {final _that = this;
switch (_that) {
case _AdminEvent():
return $default(_that.id,_that.title,_that.description,_that.date,_that.remindAt,_that.type,_that.isDone,_that.companyId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  DateTime date,  DateTime? remindAt,  AdminEventType type,  bool isDone,  String? companyId)?  $default,) {final _that = this;
switch (_that) {
case _AdminEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.date,_that.remindAt,_that.type,_that.isDone,_that.companyId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminEvent implements AdminEvent {
  const _AdminEvent({required this.id, required this.title, this.description, required this.date, this.remindAt, this.type = AdminEventType.task, this.isDone = false, this.companyId});
  factory _AdminEvent.fromJson(Map<String, dynamic> json) => _$AdminEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  DateTime date;
@override final  DateTime? remindAt;
@override@JsonKey() final  AdminEventType type;
@override@JsonKey() final  bool isDone;
@override final  String? companyId;

/// Create a copy of AdminEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminEventCopyWith<_AdminEvent> get copyWith => __$AdminEventCopyWithImpl<_AdminEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.date, date) || other.date == date)&&(identical(other.remindAt, remindAt) || other.remindAt == remindAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.companyId, companyId) || other.companyId == companyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,date,remindAt,type,isDone,companyId);

@override
String toString() {
  return 'AdminEvent(id: $id, title: $title, description: $description, date: $date, remindAt: $remindAt, type: $type, isDone: $isDone, companyId: $companyId)';
}


}

/// @nodoc
abstract mixin class _$AdminEventCopyWith<$Res> implements $AdminEventCopyWith<$Res> {
  factory _$AdminEventCopyWith(_AdminEvent value, $Res Function(_AdminEvent) _then) = __$AdminEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, DateTime date, DateTime? remindAt, AdminEventType type, bool isDone, String? companyId
});




}
/// @nodoc
class __$AdminEventCopyWithImpl<$Res>
    implements _$AdminEventCopyWith<$Res> {
  __$AdminEventCopyWithImpl(this._self, this._then);

  final _AdminEvent _self;
  final $Res Function(_AdminEvent) _then;

/// Create a copy of AdminEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? date = null,Object? remindAt = freezed,Object? type = null,Object? isDone = null,Object? companyId = freezed,}) {
  return _then(_AdminEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AdminEventType,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
