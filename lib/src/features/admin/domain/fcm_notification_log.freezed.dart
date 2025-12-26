// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fcm_notification_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FcmNotificationLog {

 String get id; String get userId; String get notificationType;// 'carro_pronto', 'status_update', 'reminder', 'promo'
 String? get bookingId;@TimestampConverter() DateTime get sentAt; bool get delivered; String? get title; String? get body;
/// Create a copy of FcmNotificationLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FcmNotificationLogCopyWith<FcmNotificationLog> get copyWith => _$FcmNotificationLogCopyWithImpl<FcmNotificationLog>(this as FcmNotificationLog, _$identity);

  /// Serializes this FcmNotificationLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FcmNotificationLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,notificationType,bookingId,sentAt,delivered,title,body);

@override
String toString() {
  return 'FcmNotificationLog(id: $id, userId: $userId, notificationType: $notificationType, bookingId: $bookingId, sentAt: $sentAt, delivered: $delivered, title: $title, body: $body)';
}


}

/// @nodoc
abstract mixin class $FcmNotificationLogCopyWith<$Res>  {
  factory $FcmNotificationLogCopyWith(FcmNotificationLog value, $Res Function(FcmNotificationLog) _then) = _$FcmNotificationLogCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String notificationType, String? bookingId,@TimestampConverter() DateTime sentAt, bool delivered, String? title, String? body
});




}
/// @nodoc
class _$FcmNotificationLogCopyWithImpl<$Res>
    implements $FcmNotificationLogCopyWith<$Res> {
  _$FcmNotificationLogCopyWithImpl(this._self, this._then);

  final FcmNotificationLog _self;
  final $Res Function(FcmNotificationLog) _then;

/// Create a copy of FcmNotificationLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? notificationType = null,Object? bookingId = freezed,Object? sentAt = null,Object? delivered = null,Object? title = freezed,Object? body = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as bool,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FcmNotificationLog].
extension FcmNotificationLogPatterns on FcmNotificationLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FcmNotificationLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FcmNotificationLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FcmNotificationLog value)  $default,){
final _that = this;
switch (_that) {
case _FcmNotificationLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FcmNotificationLog value)?  $default,){
final _that = this;
switch (_that) {
case _FcmNotificationLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String notificationType,  String? bookingId, @TimestampConverter()  DateTime sentAt,  bool delivered,  String? title,  String? body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FcmNotificationLog() when $default != null:
return $default(_that.id,_that.userId,_that.notificationType,_that.bookingId,_that.sentAt,_that.delivered,_that.title,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String notificationType,  String? bookingId, @TimestampConverter()  DateTime sentAt,  bool delivered,  String? title,  String? body)  $default,) {final _that = this;
switch (_that) {
case _FcmNotificationLog():
return $default(_that.id,_that.userId,_that.notificationType,_that.bookingId,_that.sentAt,_that.delivered,_that.title,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String notificationType,  String? bookingId, @TimestampConverter()  DateTime sentAt,  bool delivered,  String? title,  String? body)?  $default,) {final _that = this;
switch (_that) {
case _FcmNotificationLog() when $default != null:
return $default(_that.id,_that.userId,_that.notificationType,_that.bookingId,_that.sentAt,_that.delivered,_that.title,_that.body);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FcmNotificationLog implements FcmNotificationLog {
  const _FcmNotificationLog({required this.id, required this.userId, required this.notificationType, this.bookingId, @TimestampConverter() required this.sentAt, this.delivered = true, this.title, this.body});
  factory _FcmNotificationLog.fromJson(Map<String, dynamic> json) => _$FcmNotificationLogFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String notificationType;
// 'carro_pronto', 'status_update', 'reminder', 'promo'
@override final  String? bookingId;
@override@TimestampConverter() final  DateTime sentAt;
@override@JsonKey() final  bool delivered;
@override final  String? title;
@override final  String? body;

/// Create a copy of FcmNotificationLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FcmNotificationLogCopyWith<_FcmNotificationLog> get copyWith => __$FcmNotificationLogCopyWithImpl<_FcmNotificationLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FcmNotificationLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FcmNotificationLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,notificationType,bookingId,sentAt,delivered,title,body);

@override
String toString() {
  return 'FcmNotificationLog(id: $id, userId: $userId, notificationType: $notificationType, bookingId: $bookingId, sentAt: $sentAt, delivered: $delivered, title: $title, body: $body)';
}


}

/// @nodoc
abstract mixin class _$FcmNotificationLogCopyWith<$Res> implements $FcmNotificationLogCopyWith<$Res> {
  factory _$FcmNotificationLogCopyWith(_FcmNotificationLog value, $Res Function(_FcmNotificationLog) _then) = __$FcmNotificationLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String notificationType, String? bookingId,@TimestampConverter() DateTime sentAt, bool delivered, String? title, String? body
});




}
/// @nodoc
class __$FcmNotificationLogCopyWithImpl<$Res>
    implements _$FcmNotificationLogCopyWith<$Res> {
  __$FcmNotificationLogCopyWithImpl(this._self, this._then);

  final _FcmNotificationLog _self;
  final $Res Function(_FcmNotificationLog) _then;

/// Create a copy of FcmNotificationLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? notificationType = null,Object? bookingId = freezed,Object? sentAt = null,Object? delivered = null,Object? title = freezed,Object? body = freezed,}) {
  return _then(_FcmNotificationLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as bool,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
