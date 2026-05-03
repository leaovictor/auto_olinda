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

 String get id; String get tenantId; String get userId;// Firebase UID
 String get name; String? get email; String? get phone; String get status;// active | inactive | on_leave
 String get role;// admin | manager | attendant
 List<String> get permissions; String? get imageUrl; StaffSchedule? get schedule; double get commissionRate; int get totalAppointments; double get totalRevenueGenerated; DateTime? get hiredAt; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<StaffMember> get copyWith => _$StaffMemberCopyWithImpl<StaffMember>(this as StaffMember, _$identity);

  /// Serializes this StaffMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffMember&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&(identical(other.totalRevenueGenerated, totalRevenueGenerated) || other.totalRevenueGenerated == totalRevenueGenerated)&&(identical(other.hiredAt, hiredAt) || other.hiredAt == hiredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,userId,name,email,phone,status,role,const DeepCollectionEquality().hash(permissions),imageUrl,schedule,commissionRate,totalAppointments,totalRevenueGenerated,hiredAt,createdAt,updatedAt);

@override
String toString() {
  return 'StaffMember(id: $id, tenantId: $tenantId, userId: $userId, name: $name, email: $email, phone: $phone, status: $status, role: $role, permissions: $permissions, imageUrl: $imageUrl, schedule: $schedule, commissionRate: $commissionRate, totalAppointments: $totalAppointments, totalRevenueGenerated: $totalRevenueGenerated, hiredAt: $hiredAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StaffMemberCopyWith<$Res>  {
  factory $StaffMemberCopyWith(StaffMember value, $Res Function(StaffMember) _then) = _$StaffMemberCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String userId, String name, String? email, String? phone, String status, String role, List<String> permissions, String? imageUrl, StaffSchedule? schedule, double commissionRate, int totalAppointments, double totalRevenueGenerated, DateTime? hiredAt, DateTime? createdAt, DateTime? updatedAt
});


$StaffScheduleCopyWith<$Res>? get schedule;

}
/// @nodoc
class _$StaffMemberCopyWithImpl<$Res>
    implements $StaffMemberCopyWith<$Res> {
  _$StaffMemberCopyWithImpl(this._self, this._then);

  final StaffMember _self;
  final $Res Function(StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? userId = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? status = null,Object? role = null,Object? permissions = null,Object? imageUrl = freezed,Object? schedule = freezed,Object? commissionRate = null,Object? totalAppointments = null,Object? totalRevenueGenerated = null,Object? hiredAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as StaffSchedule?,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,totalAppointments: null == totalAppointments ? _self.totalAppointments : totalAppointments // ignore: cast_nullable_to_non_nullable
as int,totalRevenueGenerated: null == totalRevenueGenerated ? _self.totalRevenueGenerated : totalRevenueGenerated // ignore: cast_nullable_to_non_nullable
as double,hiredAt: freezed == hiredAt ? _self.hiredAt : hiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffScheduleCopyWith<$Res>? get schedule {
    if (_self.schedule == null) {
    return null;
  }

  return $StaffScheduleCopyWith<$Res>(_self.schedule!, (value) {
    return _then(_self.copyWith(schedule: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String userId,  String name,  String? email,  String? phone,  String status,  String role,  List<String> permissions,  String? imageUrl,  StaffSchedule? schedule,  double commissionRate,  int totalAppointments,  double totalRevenueGenerated,  DateTime? hiredAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.id,_that.tenantId,_that.userId,_that.name,_that.email,_that.phone,_that.status,_that.role,_that.permissions,_that.imageUrl,_that.schedule,_that.commissionRate,_that.totalAppointments,_that.totalRevenueGenerated,_that.hiredAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String userId,  String name,  String? email,  String? phone,  String status,  String role,  List<String> permissions,  String? imageUrl,  StaffSchedule? schedule,  double commissionRate,  int totalAppointments,  double totalRevenueGenerated,  DateTime? hiredAt,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StaffMember():
return $default(_that.id,_that.tenantId,_that.userId,_that.name,_that.email,_that.phone,_that.status,_that.role,_that.permissions,_that.imageUrl,_that.schedule,_that.commissionRate,_that.totalAppointments,_that.totalRevenueGenerated,_that.hiredAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String userId,  String name,  String? email,  String? phone,  String status,  String role,  List<String> permissions,  String? imageUrl,  StaffSchedule? schedule,  double commissionRate,  int totalAppointments,  double totalRevenueGenerated,  DateTime? hiredAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.id,_that.tenantId,_that.userId,_that.name,_that.email,_that.phone,_that.status,_that.role,_that.permissions,_that.imageUrl,_that.schedule,_that.commissionRate,_that.totalAppointments,_that.totalRevenueGenerated,_that.hiredAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffMember implements StaffMember {
  const _StaffMember({required this.id, required this.tenantId, required this.userId, required this.name, this.email, this.phone, this.status = 'active', this.role = 'attendant', final  List<String> permissions = const [], this.imageUrl, this.schedule, this.commissionRate = 0.0, this.totalAppointments = 0, this.totalRevenueGenerated = 0, this.hiredAt, this.createdAt, this.updatedAt}): _permissions = permissions;
  factory _StaffMember.fromJson(Map<String, dynamic> json) => _$StaffMemberFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String userId;
// Firebase UID
@override final  String name;
@override final  String? email;
@override final  String? phone;
@override@JsonKey() final  String status;
// active | inactive | on_leave
@override@JsonKey() final  String role;
// admin | manager | attendant
 final  List<String> _permissions;
// admin | manager | attendant
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

@override final  String? imageUrl;
@override final  StaffSchedule? schedule;
@override@JsonKey() final  double commissionRate;
@override@JsonKey() final  int totalAppointments;
@override@JsonKey() final  double totalRevenueGenerated;
@override final  DateTime? hiredAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffMember&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&(identical(other.totalRevenueGenerated, totalRevenueGenerated) || other.totalRevenueGenerated == totalRevenueGenerated)&&(identical(other.hiredAt, hiredAt) || other.hiredAt == hiredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,userId,name,email,phone,status,role,const DeepCollectionEquality().hash(_permissions),imageUrl,schedule,commissionRate,totalAppointments,totalRevenueGenerated,hiredAt,createdAt,updatedAt);

@override
String toString() {
  return 'StaffMember(id: $id, tenantId: $tenantId, userId: $userId, name: $name, email: $email, phone: $phone, status: $status, role: $role, permissions: $permissions, imageUrl: $imageUrl, schedule: $schedule, commissionRate: $commissionRate, totalAppointments: $totalAppointments, totalRevenueGenerated: $totalRevenueGenerated, hiredAt: $hiredAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StaffMemberCopyWith<$Res> implements $StaffMemberCopyWith<$Res> {
  factory _$StaffMemberCopyWith(_StaffMember value, $Res Function(_StaffMember) _then) = __$StaffMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String userId, String name, String? email, String? phone, String status, String role, List<String> permissions, String? imageUrl, StaffSchedule? schedule, double commissionRate, int totalAppointments, double totalRevenueGenerated, DateTime? hiredAt, DateTime? createdAt, DateTime? updatedAt
});


@override $StaffScheduleCopyWith<$Res>? get schedule;

}
/// @nodoc
class __$StaffMemberCopyWithImpl<$Res>
    implements _$StaffMemberCopyWith<$Res> {
  __$StaffMemberCopyWithImpl(this._self, this._then);

  final _StaffMember _self;
  final $Res Function(_StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? userId = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? status = null,Object? role = null,Object? permissions = null,Object? imageUrl = freezed,Object? schedule = freezed,Object? commissionRate = null,Object? totalAppointments = null,Object? totalRevenueGenerated = null,Object? hiredAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_StaffMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as StaffSchedule?,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,totalAppointments: null == totalAppointments ? _self.totalAppointments : totalAppointments // ignore: cast_nullable_to_non_nullable
as int,totalRevenueGenerated: null == totalRevenueGenerated ? _self.totalRevenueGenerated : totalRevenueGenerated // ignore: cast_nullable_to_non_nullable
as double,hiredAt: freezed == hiredAt ? _self.hiredAt : hiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffScheduleCopyWith<$Res>? get schedule {
    if (_self.schedule == null) {
    return null;
  }

  return $StaffScheduleCopyWith<$Res>(_self.schedule!, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}


/// @nodoc
mixin _$StaffSchedule {

 List<String> get workingDays; String? get startTime;// "09:00"
 String? get endTime;// "18:00"
 bool get hasFixedSchedule; Map<String, dynamic>? get customSchedule;
/// Create a copy of StaffSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffScheduleCopyWith<StaffSchedule> get copyWith => _$StaffScheduleCopyWithImpl<StaffSchedule>(this as StaffSchedule, _$identity);

  /// Serializes this StaffSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffSchedule&&const DeepCollectionEquality().equals(other.workingDays, workingDays)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.hasFixedSchedule, hasFixedSchedule) || other.hasFixedSchedule == hasFixedSchedule)&&const DeepCollectionEquality().equals(other.customSchedule, customSchedule));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(workingDays),startTime,endTime,hasFixedSchedule,const DeepCollectionEquality().hash(customSchedule));

@override
String toString() {
  return 'StaffSchedule(workingDays: $workingDays, startTime: $startTime, endTime: $endTime, hasFixedSchedule: $hasFixedSchedule, customSchedule: $customSchedule)';
}


}

/// @nodoc
abstract mixin class $StaffScheduleCopyWith<$Res>  {
  factory $StaffScheduleCopyWith(StaffSchedule value, $Res Function(StaffSchedule) _then) = _$StaffScheduleCopyWithImpl;
@useResult
$Res call({
 List<String> workingDays, String? startTime, String? endTime, bool hasFixedSchedule, Map<String, dynamic>? customSchedule
});




}
/// @nodoc
class _$StaffScheduleCopyWithImpl<$Res>
    implements $StaffScheduleCopyWith<$Res> {
  _$StaffScheduleCopyWithImpl(this._self, this._then);

  final StaffSchedule _self;
  final $Res Function(StaffSchedule) _then;

/// Create a copy of StaffSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workingDays = null,Object? startTime = freezed,Object? endTime = freezed,Object? hasFixedSchedule = null,Object? customSchedule = freezed,}) {
  return _then(_self.copyWith(
workingDays: null == workingDays ? _self.workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as List<String>,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,hasFixedSchedule: null == hasFixedSchedule ? _self.hasFixedSchedule : hasFixedSchedule // ignore: cast_nullable_to_non_nullable
as bool,customSchedule: freezed == customSchedule ? _self.customSchedule : customSchedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffSchedule].
extension StaffSchedulePatterns on StaffSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffSchedule value)  $default,){
final _that = this;
switch (_that) {
case _StaffSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _StaffSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> workingDays,  String? startTime,  String? endTime,  bool hasFixedSchedule,  Map<String, dynamic>? customSchedule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffSchedule() when $default != null:
return $default(_that.workingDays,_that.startTime,_that.endTime,_that.hasFixedSchedule,_that.customSchedule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> workingDays,  String? startTime,  String? endTime,  bool hasFixedSchedule,  Map<String, dynamic>? customSchedule)  $default,) {final _that = this;
switch (_that) {
case _StaffSchedule():
return $default(_that.workingDays,_that.startTime,_that.endTime,_that.hasFixedSchedule,_that.customSchedule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> workingDays,  String? startTime,  String? endTime,  bool hasFixedSchedule,  Map<String, dynamic>? customSchedule)?  $default,) {final _that = this;
switch (_that) {
case _StaffSchedule() when $default != null:
return $default(_that.workingDays,_that.startTime,_that.endTime,_that.hasFixedSchedule,_that.customSchedule);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffSchedule implements StaffSchedule {
  const _StaffSchedule({final  List<String> workingDays = const ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'], this.startTime, this.endTime, this.hasFixedSchedule = false, final  Map<String, dynamic>? customSchedule}): _workingDays = workingDays,_customSchedule = customSchedule;
  factory _StaffSchedule.fromJson(Map<String, dynamic> json) => _$StaffScheduleFromJson(json);

 final  List<String> _workingDays;
@override@JsonKey() List<String> get workingDays {
  if (_workingDays is EqualUnmodifiableListView) return _workingDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workingDays);
}

@override final  String? startTime;
// "09:00"
@override final  String? endTime;
// "18:00"
@override@JsonKey() final  bool hasFixedSchedule;
 final  Map<String, dynamic>? _customSchedule;
@override Map<String, dynamic>? get customSchedule {
  final value = _customSchedule;
  if (value == null) return null;
  if (_customSchedule is EqualUnmodifiableMapView) return _customSchedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of StaffSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffScheduleCopyWith<_StaffSchedule> get copyWith => __$StaffScheduleCopyWithImpl<_StaffSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffSchedule&&const DeepCollectionEquality().equals(other._workingDays, _workingDays)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.hasFixedSchedule, hasFixedSchedule) || other.hasFixedSchedule == hasFixedSchedule)&&const DeepCollectionEquality().equals(other._customSchedule, _customSchedule));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_workingDays),startTime,endTime,hasFixedSchedule,const DeepCollectionEquality().hash(_customSchedule));

@override
String toString() {
  return 'StaffSchedule(workingDays: $workingDays, startTime: $startTime, endTime: $endTime, hasFixedSchedule: $hasFixedSchedule, customSchedule: $customSchedule)';
}


}

/// @nodoc
abstract mixin class _$StaffScheduleCopyWith<$Res> implements $StaffScheduleCopyWith<$Res> {
  factory _$StaffScheduleCopyWith(_StaffSchedule value, $Res Function(_StaffSchedule) _then) = __$StaffScheduleCopyWithImpl;
@override @useResult
$Res call({
 List<String> workingDays, String? startTime, String? endTime, bool hasFixedSchedule, Map<String, dynamic>? customSchedule
});




}
/// @nodoc
class __$StaffScheduleCopyWithImpl<$Res>
    implements _$StaffScheduleCopyWith<$Res> {
  __$StaffScheduleCopyWithImpl(this._self, this._then);

  final _StaffSchedule _self;
  final $Res Function(_StaffSchedule) _then;

/// Create a copy of StaffSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workingDays = null,Object? startTime = freezed,Object? endTime = freezed,Object? hasFixedSchedule = null,Object? customSchedule = freezed,}) {
  return _then(_StaffSchedule(
workingDays: null == workingDays ? _self._workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as List<String>,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,hasFixedSchedule: null == hasFixedSchedule ? _self.hasFixedSchedule : hasFixedSchedule // ignore: cast_nullable_to_non_nullable
as bool,customSchedule: freezed == customSchedule ? _self._customSchedule : customSchedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
