// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingLog {

 String get message; DateTime get timestamp; String get actorId;// User ID who performed the action
 BookingStatus get status;
/// Create a copy of BookingLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingLogCopyWith<BookingLog> get copyWith => _$BookingLogCopyWithImpl<BookingLog>(this as BookingLog, _$identity);

  /// Serializes this BookingLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingLog&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,timestamp,actorId,status);

@override
String toString() {
  return 'BookingLog(message: $message, timestamp: $timestamp, actorId: $actorId, status: $status)';
}


}

/// @nodoc
abstract mixin class $BookingLogCopyWith<$Res>  {
  factory $BookingLogCopyWith(BookingLog value, $Res Function(BookingLog) _then) = _$BookingLogCopyWithImpl;
@useResult
$Res call({
 String message, DateTime timestamp, String actorId, BookingStatus status
});




}
/// @nodoc
class _$BookingLogCopyWithImpl<$Res>
    implements $BookingLogCopyWith<$Res> {
  _$BookingLogCopyWithImpl(this._self, this._then);

  final BookingLog _self;
  final $Res Function(BookingLog) _then;

/// Create a copy of BookingLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? timestamp = null,Object? actorId = null,Object? status = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingLog].
extension BookingLogPatterns on BookingLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingLog value)  $default,){
final _that = this;
switch (_that) {
case _BookingLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingLog value)?  $default,){
final _that = this;
switch (_that) {
case _BookingLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  DateTime timestamp,  String actorId,  BookingStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingLog() when $default != null:
return $default(_that.message,_that.timestamp,_that.actorId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  DateTime timestamp,  String actorId,  BookingStatus status)  $default,) {final _that = this;
switch (_that) {
case _BookingLog():
return $default(_that.message,_that.timestamp,_that.actorId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  DateTime timestamp,  String actorId,  BookingStatus status)?  $default,) {final _that = this;
switch (_that) {
case _BookingLog() when $default != null:
return $default(_that.message,_that.timestamp,_that.actorId,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingLog implements BookingLog {
  const _BookingLog({required this.message, required this.timestamp, required this.actorId, required this.status});
  factory _BookingLog.fromJson(Map<String, dynamic> json) => _$BookingLogFromJson(json);

@override final  String message;
@override final  DateTime timestamp;
@override final  String actorId;
// User ID who performed the action
@override final  BookingStatus status;

/// Create a copy of BookingLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingLogCopyWith<_BookingLog> get copyWith => __$BookingLogCopyWithImpl<_BookingLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingLog&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,timestamp,actorId,status);

@override
String toString() {
  return 'BookingLog(message: $message, timestamp: $timestamp, actorId: $actorId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BookingLogCopyWith<$Res> implements $BookingLogCopyWith<$Res> {
  factory _$BookingLogCopyWith(_BookingLog value, $Res Function(_BookingLog) _then) = __$BookingLogCopyWithImpl;
@override @useResult
$Res call({
 String message, DateTime timestamp, String actorId, BookingStatus status
});




}
/// @nodoc
class __$BookingLogCopyWithImpl<$Res>
    implements _$BookingLogCopyWith<$Res> {
  __$BookingLogCopyWithImpl(this._self, this._then);

  final _BookingLog _self;
  final $Res Function(_BookingLog) _then;

/// Create a copy of BookingLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? timestamp = null,Object? actorId = null,Object? status = null,}) {
  return _then(_BookingLog(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,
  ));
}


}


/// @nodoc
mixin _$Booking {

 String get id; String get userId; String get vehicleId; List<String> get serviceIds; double get totalPrice; DateTime get scheduledTime; BookingStatus get status; String? get staffNotes; List<String> get beforePhotos; List<String> get afterPhotos; bool get isRated; int? get rating; String? get ratingComment; List<BookingLog> get logs;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&const DeepCollectionEquality().equals(other.serviceIds, serviceIds)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.staffNotes, staffNotes) || other.staffNotes == staffNotes)&&const DeepCollectionEquality().equals(other.beforePhotos, beforePhotos)&&const DeepCollectionEquality().equals(other.afterPhotos, afterPhotos)&&(identical(other.isRated, isRated) || other.isRated == isRated)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingComment, ratingComment) || other.ratingComment == ratingComment)&&const DeepCollectionEquality().equals(other.logs, logs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,vehicleId,const DeepCollectionEquality().hash(serviceIds),totalPrice,scheduledTime,status,staffNotes,const DeepCollectionEquality().hash(beforePhotos),const DeepCollectionEquality().hash(afterPhotos),isRated,rating,ratingComment,const DeepCollectionEquality().hash(logs));

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, vehicleId: $vehicleId, serviceIds: $serviceIds, totalPrice: $totalPrice, scheduledTime: $scheduledTime, status: $status, staffNotes: $staffNotes, beforePhotos: $beforePhotos, afterPhotos: $afterPhotos, isRated: $isRated, rating: $rating, ratingComment: $ratingComment, logs: $logs)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String vehicleId, List<String> serviceIds, double totalPrice, DateTime scheduledTime, BookingStatus status, String? staffNotes, List<String> beforePhotos, List<String> afterPhotos, bool isRated, int? rating, String? ratingComment, List<BookingLog> logs
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? vehicleId = null,Object? serviceIds = null,Object? totalPrice = null,Object? scheduledTime = null,Object? status = null,Object? staffNotes = freezed,Object? beforePhotos = null,Object? afterPhotos = null,Object? isRated = null,Object? rating = freezed,Object? ratingComment = freezed,Object? logs = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,serviceIds: null == serviceIds ? _self.serviceIds : serviceIds // ignore: cast_nullable_to_non_nullable
as List<String>,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,staffNotes: freezed == staffNotes ? _self.staffNotes : staffNotes // ignore: cast_nullable_to_non_nullable
as String?,beforePhotos: null == beforePhotos ? _self.beforePhotos : beforePhotos // ignore: cast_nullable_to_non_nullable
as List<String>,afterPhotos: null == afterPhotos ? _self.afterPhotos : afterPhotos // ignore: cast_nullable_to_non_nullable
as List<String>,isRated: null == isRated ? _self.isRated : isRated // ignore: cast_nullable_to_non_nullable
as bool,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,ratingComment: freezed == ratingComment ? _self.ratingComment : ratingComment // ignore: cast_nullable_to_non_nullable
as String?,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<BookingLog>,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String vehicleId,  List<String> serviceIds,  double totalPrice,  DateTime scheduledTime,  BookingStatus status,  String? staffNotes,  List<String> beforePhotos,  List<String> afterPhotos,  bool isRated,  int? rating,  String? ratingComment,  List<BookingLog> logs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.vehicleId,_that.serviceIds,_that.totalPrice,_that.scheduledTime,_that.status,_that.staffNotes,_that.beforePhotos,_that.afterPhotos,_that.isRated,_that.rating,_that.ratingComment,_that.logs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String vehicleId,  List<String> serviceIds,  double totalPrice,  DateTime scheduledTime,  BookingStatus status,  String? staffNotes,  List<String> beforePhotos,  List<String> afterPhotos,  bool isRated,  int? rating,  String? ratingComment,  List<BookingLog> logs)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.userId,_that.vehicleId,_that.serviceIds,_that.totalPrice,_that.scheduledTime,_that.status,_that.staffNotes,_that.beforePhotos,_that.afterPhotos,_that.isRated,_that.rating,_that.ratingComment,_that.logs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String vehicleId,  List<String> serviceIds,  double totalPrice,  DateTime scheduledTime,  BookingStatus status,  String? staffNotes,  List<String> beforePhotos,  List<String> afterPhotos,  bool isRated,  int? rating,  String? ratingComment,  List<BookingLog> logs)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.vehicleId,_that.serviceIds,_that.totalPrice,_that.scheduledTime,_that.status,_that.staffNotes,_that.beforePhotos,_that.afterPhotos,_that.isRated,_that.rating,_that.ratingComment,_that.logs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({required this.id, required this.userId, required this.vehicleId, required final  List<String> serviceIds, required this.totalPrice, required this.scheduledTime, this.status = BookingStatus.scheduled, this.staffNotes, final  List<String> beforePhotos = const [], final  List<String> afterPhotos = const [], this.isRated = false, this.rating, this.ratingComment, final  List<BookingLog> logs = const []}): _serviceIds = serviceIds,_beforePhotos = beforePhotos,_afterPhotos = afterPhotos,_logs = logs;
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String vehicleId;
 final  List<String> _serviceIds;
@override List<String> get serviceIds {
  if (_serviceIds is EqualUnmodifiableListView) return _serviceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceIds);
}

@override final  double totalPrice;
@override final  DateTime scheduledTime;
@override@JsonKey() final  BookingStatus status;
@override final  String? staffNotes;
 final  List<String> _beforePhotos;
@override@JsonKey() List<String> get beforePhotos {
  if (_beforePhotos is EqualUnmodifiableListView) return _beforePhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beforePhotos);
}

 final  List<String> _afterPhotos;
@override@JsonKey() List<String> get afterPhotos {
  if (_afterPhotos is EqualUnmodifiableListView) return _afterPhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_afterPhotos);
}

@override@JsonKey() final  bool isRated;
@override final  int? rating;
@override final  String? ratingComment;
 final  List<BookingLog> _logs;
@override@JsonKey() List<BookingLog> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}


/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&const DeepCollectionEquality().equals(other._serviceIds, _serviceIds)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.staffNotes, staffNotes) || other.staffNotes == staffNotes)&&const DeepCollectionEquality().equals(other._beforePhotos, _beforePhotos)&&const DeepCollectionEquality().equals(other._afterPhotos, _afterPhotos)&&(identical(other.isRated, isRated) || other.isRated == isRated)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingComment, ratingComment) || other.ratingComment == ratingComment)&&const DeepCollectionEquality().equals(other._logs, _logs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,vehicleId,const DeepCollectionEquality().hash(_serviceIds),totalPrice,scheduledTime,status,staffNotes,const DeepCollectionEquality().hash(_beforePhotos),const DeepCollectionEquality().hash(_afterPhotos),isRated,rating,ratingComment,const DeepCollectionEquality().hash(_logs));

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, vehicleId: $vehicleId, serviceIds: $serviceIds, totalPrice: $totalPrice, scheduledTime: $scheduledTime, status: $status, staffNotes: $staffNotes, beforePhotos: $beforePhotos, afterPhotos: $afterPhotos, isRated: $isRated, rating: $rating, ratingComment: $ratingComment, logs: $logs)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String vehicleId, List<String> serviceIds, double totalPrice, DateTime scheduledTime, BookingStatus status, String? staffNotes, List<String> beforePhotos, List<String> afterPhotos, bool isRated, int? rating, String? ratingComment, List<BookingLog> logs
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? vehicleId = null,Object? serviceIds = null,Object? totalPrice = null,Object? scheduledTime = null,Object? status = null,Object? staffNotes = freezed,Object? beforePhotos = null,Object? afterPhotos = null,Object? isRated = null,Object? rating = freezed,Object? ratingComment = freezed,Object? logs = null,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,serviceIds: null == serviceIds ? _self._serviceIds : serviceIds // ignore: cast_nullable_to_non_nullable
as List<String>,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,staffNotes: freezed == staffNotes ? _self.staffNotes : staffNotes // ignore: cast_nullable_to_non_nullable
as String?,beforePhotos: null == beforePhotos ? _self._beforePhotos : beforePhotos // ignore: cast_nullable_to_non_nullable
as List<String>,afterPhotos: null == afterPhotos ? _self._afterPhotos : afterPhotos // ignore: cast_nullable_to_non_nullable
as List<String>,isRated: null == isRated ? _self.isRated : isRated // ignore: cast_nullable_to_non_nullable
as bool,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,ratingComment: freezed == ratingComment ? _self.ratingComment : ratingComment // ignore: cast_nullable_to_non_nullable
as String?,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<BookingLog>,
  ));
}


}

// dart format on
