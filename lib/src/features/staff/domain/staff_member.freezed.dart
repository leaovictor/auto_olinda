// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StaffMember {

 String get id; String get name; String get email; String? get photoUrl; String get role; String get status; String? get phoneNumber;// Performance metrics
 int get totalBookingsToday; int get totalBookingsMonth; double get revenueToday; double get revenueMonth; double get avgRating; int get totalRatings;// Shift info
 DateTime? get shiftStart; DateTime? get shiftEnd; bool get isOnShift;// Timestamps
 DateTime? get lastActiveAt; DateTime? get createdAt;
/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<StaffMember> get copyWith => _$StaffMemberCopyWithImpl<StaffMember>(this as StaffMember, _$identity);

  /// Serializes this StaffMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffMember&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.totalBookingsToday, totalBookingsToday) || other.totalBookingsToday == totalBookingsToday)&&(identical(other.totalBookingsMonth, totalBookingsMonth) || other.totalBookingsMonth == totalBookingsMonth)&&(identical(other.revenueToday, revenueToday) || other.revenueToday == revenueToday)&&(identical(other.revenueMonth, revenueMonth) || other.revenueMonth == revenueMonth)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.totalRatings, totalRatings) || other.totalRatings == totalRatings)&&(identical(other.shiftStart, shiftStart) || other.shiftStart == shiftStart)&&(identical(other.shiftEnd, shiftEnd) || other.shiftEnd == shiftEnd)&&(identical(other.isOnShift, isOnShift) || other.isOnShift == isOnShift)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,photoUrl,role,status,phoneNumber,totalBookingsToday,totalBookingsMonth,revenueToday,revenueMonth,avgRating,totalRatings,shiftStart,shiftEnd,isOnShift,lastActiveAt,createdAt);

@override
String toString() {
  return 'StaffMember(id: $id, name: $name, email: $email, photoUrl: $photoUrl, role: $role, status: $status, phoneNumber: $phoneNumber, totalBookingsToday: $totalBookingsToday, totalBookingsMonth: $totalBookingsMonth, revenueToday: $revenueToday, revenueMonth: $revenueMonth, avgRating: $avgRating, totalRatings: $totalRatings, shiftStart: $shiftStart, shiftEnd: $shiftEnd, isOnShift: $isOnShift, lastActiveAt: $lastActiveAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $StaffMemberCopyWith<$Res>  {
  factory $StaffMemberCopyWith(StaffMember value, $Res Function(StaffMember) _then) = _$StaffMemberCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String? photoUrl, String role, String status, String? phoneNumber, int totalBookingsToday, int totalBookingsMonth, double revenueToday, double revenueMonth, double avgRating, int totalRatings, DateTime? shiftStart, DateTime? shiftEnd, bool isOnShift, DateTime? lastActiveAt, DateTime? createdAt
});




}
/// @nodoc
class _$StaffMemberCopyWithImpl<$Res>
    implements $StaffMemberCopyWith<$Res> {
  _$StaffMemberCopyWithImpl(this._self, this._then);

  final StaffMember _self;
  final $Res Function(StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? photoUrl = freezed,Object? role = null,Object? status = null,Object? phoneNumber = freezed,Object? totalBookingsToday = null,Object? totalBookingsMonth = null,Object? revenueToday = null,Object? revenueMonth = null,Object? avgRating = null,Object? totalRatings = null,Object? shiftStart = freezed,Object? shiftEnd = freezed,Object? isOnShift = null,Object? lastActiveAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,totalBookingsToday: null == totalBookingsToday ? _self.totalBookingsToday : totalBookingsToday // ignore: cast_nullable_to_non_nullable
as int,totalBookingsMonth: null == totalBookingsMonth ? _self.totalBookingsMonth : totalBookingsMonth // ignore: cast_nullable_to_non_nullable
as int,revenueToday: null == revenueToday ? _self.revenueToday : revenueToday // ignore: cast_nullable_to_non_nullable
as double,revenueMonth: null == revenueMonth ? _self.revenueMonth : revenueMonth // ignore: cast_nullable_to_non_nullable
as double,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as double,totalRatings: null == totalRatings ? _self.totalRatings : totalRatings // ignore: cast_nullable_to_non_nullable
as int,shiftStart: freezed == shiftStart ? _self.shiftStart : shiftStart // ignore: cast_nullable_to_non_nullable
as DateTime?,shiftEnd: freezed == shiftEnd ? _self.shiftEnd : shiftEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,isOnShift: null == isOnShift ? _self.isOnShift : isOnShift // ignore: cast_nullable_to_non_nullable
as bool,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffMember].
extension StaffMemberPatterns on StaffMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffMember value)  $default,){
final _that = this;
switch (_that) {
case _StaffMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffMember value)?  $default,){
final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? photoUrl,  String role,  String status,  String? phoneNumber,  int totalBookingsToday,  int totalBookingsMonth,  double revenueToday,  double revenueMonth,  double avgRating,  int totalRatings,  DateTime? shiftStart,  DateTime? shiftEnd,  bool isOnShift,  DateTime? lastActiveAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.photoUrl,_that.role,_that.status,_that.phoneNumber,_that.totalBookingsToday,_that.totalBookingsMonth,_that.revenueToday,_that.revenueMonth,_that.avgRating,_that.totalRatings,_that.shiftStart,_that.shiftEnd,_that.isOnShift,_that.lastActiveAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? photoUrl,  String role,  String status,  String? phoneNumber,  int totalBookingsToday,  int totalBookingsMonth,  double revenueToday,  double revenueMonth,  double avgRating,  int totalRatings,  DateTime? shiftStart,  DateTime? shiftEnd,  bool isOnShift,  DateTime? lastActiveAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _StaffMember():
return $default(_that.id,_that.name,_that.email,_that.photoUrl,_that.role,_that.status,_that.phoneNumber,_that.totalBookingsToday,_that.totalBookingsMonth,_that.revenueToday,_that.revenueMonth,_that.avgRating,_that.totalRatings,_that.shiftStart,_that.shiftEnd,_that.isOnShift,_that.lastActiveAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String? photoUrl,  String role,  String status,  String? phoneNumber,  int totalBookingsToday,  int totalBookingsMonth,  double revenueToday,  double revenueMonth,  double avgRating,  int totalRatings,  DateTime? shiftStart,  DateTime? shiftEnd,  bool isOnShift,  DateTime? lastActiveAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.photoUrl,_that.role,_that.status,_that.phoneNumber,_that.totalBookingsToday,_that.totalBookingsMonth,_that.revenueToday,_that.revenueMonth,_that.avgRating,_that.totalRatings,_that.shiftStart,_that.shiftEnd,_that.isOnShift,_that.lastActiveAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffMember implements StaffMember {
  const _StaffMember({required this.id, required this.name, required this.email, this.photoUrl, this.role = 'staff', this.status = 'active', this.phoneNumber, this.totalBookingsToday = 0, this.totalBookingsMonth = 0, this.revenueToday = 0.0, this.revenueMonth = 0.0, this.avgRating = 0.0, this.totalRatings = 0, this.shiftStart, this.shiftEnd, this.isOnShift = false, this.lastActiveAt, this.createdAt});
  factory _StaffMember.fromJson(Map<String, dynamic> json) => _$StaffMemberFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String? photoUrl;
@override@JsonKey() final  String role;
@override@JsonKey() final  String status;
@override final  String? phoneNumber;
// Performance metrics
@override@JsonKey() final  int totalBookingsToday;
@override@JsonKey() final  int totalBookingsMonth;
@override@JsonKey() final  double revenueToday;
@override@JsonKey() final  double revenueMonth;
@override@JsonKey() final  double avgRating;
@override@JsonKey() final  int totalRatings;
// Shift info
@override final  DateTime? shiftStart;
@override final  DateTime? shiftEnd;
@override@JsonKey() final  bool isOnShift;
// Timestamps
@override final  DateTime? lastActiveAt;
@override final  DateTime? createdAt;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffMemberCopyWith<_StaffMember> get copyWith => __$StaffMemberCopyWithImpl<_StaffMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffMember&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.totalBookingsToday, totalBookingsToday) || other.totalBookingsToday == totalBookingsToday)&&(identical(other.totalBookingsMonth, totalBookingsMonth) || other.totalBookingsMonth == totalBookingsMonth)&&(identical(other.revenueToday, revenueToday) || other.revenueToday == revenueToday)&&(identical(other.revenueMonth, revenueMonth) || other.revenueMonth == revenueMonth)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.totalRatings, totalRatings) || other.totalRatings == totalRatings)&&(identical(other.shiftStart, shiftStart) || other.shiftStart == shiftStart)&&(identical(other.shiftEnd, shiftEnd) || other.shiftEnd == shiftEnd)&&(identical(other.isOnShift, isOnShift) || other.isOnShift == isOnShift)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,photoUrl,role,status,phoneNumber,totalBookingsToday,totalBookingsMonth,revenueToday,revenueMonth,avgRating,totalRatings,shiftStart,shiftEnd,isOnShift,lastActiveAt,createdAt);

@override
String toString() {
  return 'StaffMember(id: $id, name: $name, email: $email, photoUrl: $photoUrl, role: $role, status: $status, phoneNumber: $phoneNumber, totalBookingsToday: $totalBookingsToday, totalBookingsMonth: $totalBookingsMonth, revenueToday: $revenueToday, revenueMonth: $revenueMonth, avgRating: $avgRating, totalRatings: $totalRatings, shiftStart: $shiftStart, shiftEnd: $shiftEnd, isOnShift: $isOnShift, lastActiveAt: $lastActiveAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StaffMemberCopyWith<$Res> implements $StaffMemberCopyWith<$Res> {
  factory _$StaffMemberCopyWith(_StaffMember value, $Res Function(_StaffMember) _then) = __$StaffMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String? photoUrl, String role, String status, String? phoneNumber, int totalBookingsToday, int totalBookingsMonth, double revenueToday, double revenueMonth, double avgRating, int totalRatings, DateTime? shiftStart, DateTime? shiftEnd, bool isOnShift, DateTime? lastActiveAt, DateTime? createdAt
});




}
/// @nodoc
class __$StaffMemberCopyWithImpl<$Res>
    implements _$StaffMemberCopyWith<$Res> {
  __$StaffMemberCopyWithImpl(this._self, this._then);

  final _StaffMember _self;
  final $Res Function(_StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? photoUrl = freezed,Object? role = null,Object? status = null,Object? phoneNumber = freezed,Object? totalBookingsToday = null,Object? totalBookingsMonth = null,Object? revenueToday = null,Object? revenueMonth = null,Object? avgRating = null,Object? totalRatings = null,Object? shiftStart = freezed,Object? shiftEnd = freezed,Object? isOnShift = null,Object? lastActiveAt = freezed,Object? createdAt = freezed,}) {
  return _then(_StaffMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,totalBookingsToday: null == totalBookingsToday ? _self.totalBookingsToday : totalBookingsToday // ignore: cast_nullable_to_non_nullable
as int,totalBookingsMonth: null == totalBookingsMonth ? _self.totalBookingsMonth : totalBookingsMonth // ignore: cast_nullable_to_non_nullable
as int,revenueToday: null == revenueToday ? _self.revenueToday : revenueToday // ignore: cast_nullable_to_non_nullable
as double,revenueMonth: null == revenueMonth ? _self.revenueMonth : revenueMonth // ignore: cast_nullable_to_non_nullable
as double,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as double,totalRatings: null == totalRatings ? _self.totalRatings : totalRatings // ignore: cast_nullable_to_non_nullable
as int,shiftStart: freezed == shiftStart ? _self.shiftStart : shiftStart // ignore: cast_nullable_to_non_nullable
as DateTime?,shiftEnd: freezed == shiftEnd ? _self.shiftEnd : shiftEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,isOnShift: null == isOnShift ? _self.isOnShift : isOnShift // ignore: cast_nullable_to_non_nullable
as bool,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$StaffShift {

 String get id; String get staffId; String get staffName; DateTime get startTime; DateTime get endTime; bool get isActive; String? get notes;
/// Create a copy of StaffShift
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffShiftCopyWith<StaffShift> get copyWith => _$StaffShiftCopyWithImpl<StaffShift>(this as StaffShift, _$identity);

  /// Serializes this StaffShift to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffShift&&(identical(other.id, id) || other.id == id)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,staffId,staffName,startTime,endTime,isActive,notes);

@override
String toString() {
  return 'StaffShift(id: $id, staffId: $staffId, staffName: $staffName, startTime: $startTime, endTime: $endTime, isActive: $isActive, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $StaffShiftCopyWith<$Res>  {
  factory $StaffShiftCopyWith(StaffShift value, $Res Function(StaffShift) _then) = _$StaffShiftCopyWithImpl;
@useResult
$Res call({
 String id, String staffId, String staffName, DateTime startTime, DateTime endTime, bool isActive, String? notes
});




}
/// @nodoc
class _$StaffShiftCopyWithImpl<$Res>
    implements $StaffShiftCopyWith<$Res> {
  _$StaffShiftCopyWithImpl(this._self, this._then);

  final StaffShift _self;
  final $Res Function(StaffShift) _then;

/// Create a copy of StaffShift
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? staffId = null,Object? staffName = null,Object? startTime = null,Object? endTime = null,Object? isActive = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffShift].
extension StaffShiftPatterns on StaffShift {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffShift value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffShift() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffShift value)  $default,){
final _that = this;
switch (_that) {
case _StaffShift():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffShift value)?  $default,){
final _that = this;
switch (_that) {
case _StaffShift() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String staffId,  String staffName,  DateTime startTime,  DateTime endTime,  bool isActive,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffShift() when $default != null:
return $default(_that.id,_that.staffId,_that.staffName,_that.startTime,_that.endTime,_that.isActive,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String staffId,  String staffName,  DateTime startTime,  DateTime endTime,  bool isActive,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _StaffShift():
return $default(_that.id,_that.staffId,_that.staffName,_that.startTime,_that.endTime,_that.isActive,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String staffId,  String staffName,  DateTime startTime,  DateTime endTime,  bool isActive,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _StaffShift() when $default != null:
return $default(_that.id,_that.staffId,_that.staffName,_that.startTime,_that.endTime,_that.isActive,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffShift implements StaffShift {
  const _StaffShift({required this.id, required this.staffId, required this.staffName, required this.startTime, required this.endTime, this.isActive = false, this.notes});
  factory _StaffShift.fromJson(Map<String, dynamic> json) => _$StaffShiftFromJson(json);

@override final  String id;
@override final  String staffId;
@override final  String staffName;
@override final  DateTime startTime;
@override final  DateTime endTime;
@override@JsonKey() final  bool isActive;
@override final  String? notes;

/// Create a copy of StaffShift
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffShiftCopyWith<_StaffShift> get copyWith => __$StaffShiftCopyWithImpl<_StaffShift>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffShiftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffShift&&(identical(other.id, id) || other.id == id)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,staffId,staffName,startTime,endTime,isActive,notes);

@override
String toString() {
  return 'StaffShift(id: $id, staffId: $staffId, staffName: $staffName, startTime: $startTime, endTime: $endTime, isActive: $isActive, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$StaffShiftCopyWith<$Res> implements $StaffShiftCopyWith<$Res> {
  factory _$StaffShiftCopyWith(_StaffShift value, $Res Function(_StaffShift) _then) = __$StaffShiftCopyWithImpl;
@override @useResult
$Res call({
 String id, String staffId, String staffName, DateTime startTime, DateTime endTime, bool isActive, String? notes
});




}
/// @nodoc
class __$StaffShiftCopyWithImpl<$Res>
    implements _$StaffShiftCopyWith<$Res> {
  __$StaffShiftCopyWithImpl(this._self, this._then);

  final _StaffShift _self;
  final $Res Function(_StaffShift) _then;

/// Create a copy of StaffShift
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? staffId = null,Object? staffName = null,Object? startTime = null,Object? endTime = null,Object? isActive = null,Object? notes = freezed,}) {
  return _then(_StaffShift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StaffPerformance {

 String get staffId; String get staffName; int get totalBookings; double get totalRevenue; double get avgRating; int get totalRatings;// Daily breakdown (last 7 days)
 List<DailyStats> get dailyStats;
/// Create a copy of StaffPerformance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffPerformanceCopyWith<StaffPerformance> get copyWith => _$StaffPerformanceCopyWithImpl<StaffPerformance>(this as StaffPerformance, _$identity);

  /// Serializes this StaffPerformance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffPerformance&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.totalBookings, totalBookings) || other.totalBookings == totalBookings)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.totalRatings, totalRatings) || other.totalRatings == totalRatings)&&const DeepCollectionEquality().equals(other.dailyStats, dailyStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,staffId,staffName,totalBookings,totalRevenue,avgRating,totalRatings,const DeepCollectionEquality().hash(dailyStats));

@override
String toString() {
  return 'StaffPerformance(staffId: $staffId, staffName: $staffName, totalBookings: $totalBookings, totalRevenue: $totalRevenue, avgRating: $avgRating, totalRatings: $totalRatings, dailyStats: $dailyStats)';
}


}

/// @nodoc
abstract mixin class $StaffPerformanceCopyWith<$Res>  {
  factory $StaffPerformanceCopyWith(StaffPerformance value, $Res Function(StaffPerformance) _then) = _$StaffPerformanceCopyWithImpl;
@useResult
$Res call({
 String staffId, String staffName, int totalBookings, double totalRevenue, double avgRating, int totalRatings, List<DailyStats> dailyStats
});




}
/// @nodoc
class _$StaffPerformanceCopyWithImpl<$Res>
    implements $StaffPerformanceCopyWith<$Res> {
  _$StaffPerformanceCopyWithImpl(this._self, this._then);

  final StaffPerformance _self;
  final $Res Function(StaffPerformance) _then;

/// Create a copy of StaffPerformance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? staffId = null,Object? staffName = null,Object? totalBookings = null,Object? totalRevenue = null,Object? avgRating = null,Object? totalRatings = null,Object? dailyStats = null,}) {
  return _then(_self.copyWith(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,totalBookings: null == totalBookings ? _self.totalBookings : totalBookings // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as double,totalRatings: null == totalRatings ? _self.totalRatings : totalRatings // ignore: cast_nullable_to_non_nullable
as int,dailyStats: null == dailyStats ? _self.dailyStats : dailyStats // ignore: cast_nullable_to_non_nullable
as List<DailyStats>,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffPerformance].
extension StaffPerformancePatterns on StaffPerformance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffPerformance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffPerformance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffPerformance value)  $default,){
final _that = this;
switch (_that) {
case _StaffPerformance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffPerformance value)?  $default,){
final _that = this;
switch (_that) {
case _StaffPerformance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String staffId,  String staffName,  int totalBookings,  double totalRevenue,  double avgRating,  int totalRatings,  List<DailyStats> dailyStats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffPerformance() when $default != null:
return $default(_that.staffId,_that.staffName,_that.totalBookings,_that.totalRevenue,_that.avgRating,_that.totalRatings,_that.dailyStats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String staffId,  String staffName,  int totalBookings,  double totalRevenue,  double avgRating,  int totalRatings,  List<DailyStats> dailyStats)  $default,) {final _that = this;
switch (_that) {
case _StaffPerformance():
return $default(_that.staffId,_that.staffName,_that.totalBookings,_that.totalRevenue,_that.avgRating,_that.totalRatings,_that.dailyStats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String staffId,  String staffName,  int totalBookings,  double totalRevenue,  double avgRating,  int totalRatings,  List<DailyStats> dailyStats)?  $default,) {final _that = this;
switch (_that) {
case _StaffPerformance() when $default != null:
return $default(_that.staffId,_that.staffName,_that.totalBookings,_that.totalRevenue,_that.avgRating,_that.totalRatings,_that.dailyStats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffPerformance implements StaffPerformance {
  const _StaffPerformance({required this.staffId, required this.staffName, required this.totalBookings, required this.totalRevenue, required this.avgRating, required this.totalRatings, final  List<DailyStats> dailyStats = const []}): _dailyStats = dailyStats;
  factory _StaffPerformance.fromJson(Map<String, dynamic> json) => _$StaffPerformanceFromJson(json);

@override final  String staffId;
@override final  String staffName;
@override final  int totalBookings;
@override final  double totalRevenue;
@override final  double avgRating;
@override final  int totalRatings;
// Daily breakdown (last 7 days)
 final  List<DailyStats> _dailyStats;
// Daily breakdown (last 7 days)
@override@JsonKey() List<DailyStats> get dailyStats {
  if (_dailyStats is EqualUnmodifiableListView) return _dailyStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dailyStats);
}


/// Create a copy of StaffPerformance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffPerformanceCopyWith<_StaffPerformance> get copyWith => __$StaffPerformanceCopyWithImpl<_StaffPerformance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffPerformanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffPerformance&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.totalBookings, totalBookings) || other.totalBookings == totalBookings)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating)&&(identical(other.totalRatings, totalRatings) || other.totalRatings == totalRatings)&&const DeepCollectionEquality().equals(other._dailyStats, _dailyStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,staffId,staffName,totalBookings,totalRevenue,avgRating,totalRatings,const DeepCollectionEquality().hash(_dailyStats));

@override
String toString() {
  return 'StaffPerformance(staffId: $staffId, staffName: $staffName, totalBookings: $totalBookings, totalRevenue: $totalRevenue, avgRating: $avgRating, totalRatings: $totalRatings, dailyStats: $dailyStats)';
}


}

/// @nodoc
abstract mixin class _$StaffPerformanceCopyWith<$Res> implements $StaffPerformanceCopyWith<$Res> {
  factory _$StaffPerformanceCopyWith(_StaffPerformance value, $Res Function(_StaffPerformance) _then) = __$StaffPerformanceCopyWithImpl;
@override @useResult
$Res call({
 String staffId, String staffName, int totalBookings, double totalRevenue, double avgRating, int totalRatings, List<DailyStats> dailyStats
});




}
/// @nodoc
class __$StaffPerformanceCopyWithImpl<$Res>
    implements _$StaffPerformanceCopyWith<$Res> {
  __$StaffPerformanceCopyWithImpl(this._self, this._then);

  final _StaffPerformance _self;
  final $Res Function(_StaffPerformance) _then;

/// Create a copy of StaffPerformance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? staffId = null,Object? staffName = null,Object? totalBookings = null,Object? totalRevenue = null,Object? avgRating = null,Object? totalRatings = null,Object? dailyStats = null,}) {
  return _then(_StaffPerformance(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,totalBookings: null == totalBookings ? _self.totalBookings : totalBookings // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as double,totalRatings: null == totalRatings ? _self.totalRatings : totalRatings // ignore: cast_nullable_to_non_nullable
as int,dailyStats: null == dailyStats ? _self._dailyStats : dailyStats // ignore: cast_nullable_to_non_nullable
as List<DailyStats>,
  ));
}


}


/// @nodoc
mixin _$DailyStats {

 DateTime get date; int get bookings; double get revenue;
/// Create a copy of DailyStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyStatsCopyWith<DailyStats> get copyWith => _$DailyStatsCopyWithImpl<DailyStats>(this as DailyStats, _$identity);

  /// Serializes this DailyStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyStats&&(identical(other.date, date) || other.date == date)&&(identical(other.bookings, bookings) || other.bookings == bookings)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,bookings,revenue);

@override
String toString() {
  return 'DailyStats(date: $date, bookings: $bookings, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class $DailyStatsCopyWith<$Res>  {
  factory $DailyStatsCopyWith(DailyStats value, $Res Function(DailyStats) _then) = _$DailyStatsCopyWithImpl;
@useResult
$Res call({
 DateTime date, int bookings, double revenue
});




}
/// @nodoc
class _$DailyStatsCopyWithImpl<$Res>
    implements $DailyStatsCopyWith<$Res> {
  _$DailyStatsCopyWithImpl(this._self, this._then);

  final DailyStats _self;
  final $Res Function(DailyStats) _then;

/// Create a copy of DailyStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? bookings = null,Object? revenue = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyStats].
extension DailyStatsPatterns on DailyStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyStats value)  $default,){
final _that = this;
switch (_that) {
case _DailyStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyStats value)?  $default,){
final _that = this;
switch (_that) {
case _DailyStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int bookings,  double revenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyStats() when $default != null:
return $default(_that.date,_that.bookings,_that.revenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int bookings,  double revenue)  $default,) {final _that = this;
switch (_that) {
case _DailyStats():
return $default(_that.date,_that.bookings,_that.revenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int bookings,  double revenue)?  $default,) {final _that = this;
switch (_that) {
case _DailyStats() when $default != null:
return $default(_that.date,_that.bookings,_that.revenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyStats implements DailyStats {
  const _DailyStats({required this.date, required this.bookings, required this.revenue});
  factory _DailyStats.fromJson(Map<String, dynamic> json) => _$DailyStatsFromJson(json);

@override final  DateTime date;
@override final  int bookings;
@override final  double revenue;

/// Create a copy of DailyStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyStatsCopyWith<_DailyStats> get copyWith => __$DailyStatsCopyWithImpl<_DailyStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyStats&&(identical(other.date, date) || other.date == date)&&(identical(other.bookings, bookings) || other.bookings == bookings)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,bookings,revenue);

@override
String toString() {
  return 'DailyStats(date: $date, bookings: $bookings, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class _$DailyStatsCopyWith<$Res> implements $DailyStatsCopyWith<$Res> {
  factory _$DailyStatsCopyWith(_DailyStats value, $Res Function(_DailyStats) _then) = __$DailyStatsCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int bookings, double revenue
});




}
/// @nodoc
class __$DailyStatsCopyWithImpl<$Res>
    implements _$DailyStatsCopyWith<$Res> {
  __$DailyStatsCopyWithImpl(this._self, this._then);

  final _DailyStats _self;
  final $Res Function(_DailyStats) _then;

/// Create a copy of DailyStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? bookings = null,Object? revenue = null,}) {
  return _then(_DailyStats(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
