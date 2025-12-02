// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeeklySchedule {

 int get dayOfWeek;// 1 = Monday, 7 = Sunday
 bool get isOpen; int get startHour;// 0-23
 int get endHour;// 0-23
 int get capacityPerHour;
/// Create a copy of WeeklySchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyScheduleCopyWith<WeeklySchedule> get copyWith => _$WeeklyScheduleCopyWithImpl<WeeklySchedule>(this as WeeklySchedule, _$identity);

  /// Serializes this WeeklySchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklySchedule&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.startHour, startHour) || other.startHour == startHour)&&(identical(other.endHour, endHour) || other.endHour == endHour)&&(identical(other.capacityPerHour, capacityPerHour) || other.capacityPerHour == capacityPerHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,isOpen,startHour,endHour,capacityPerHour);

@override
String toString() {
  return 'WeeklySchedule(dayOfWeek: $dayOfWeek, isOpen: $isOpen, startHour: $startHour, endHour: $endHour, capacityPerHour: $capacityPerHour)';
}


}

/// @nodoc
abstract mixin class $WeeklyScheduleCopyWith<$Res>  {
  factory $WeeklyScheduleCopyWith(WeeklySchedule value, $Res Function(WeeklySchedule) _then) = _$WeeklyScheduleCopyWithImpl;
@useResult
$Res call({
 int dayOfWeek, bool isOpen, int startHour, int endHour, int capacityPerHour
});




}
/// @nodoc
class _$WeeklyScheduleCopyWithImpl<$Res>
    implements $WeeklyScheduleCopyWith<$Res> {
  _$WeeklyScheduleCopyWithImpl(this._self, this._then);

  final WeeklySchedule _self;
  final $Res Function(WeeklySchedule) _then;

/// Create a copy of WeeklySchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayOfWeek = null,Object? isOpen = null,Object? startHour = null,Object? endHour = null,Object? capacityPerHour = null,}) {
  return _then(_self.copyWith(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as int,endHour: null == endHour ? _self.endHour : endHour // ignore: cast_nullable_to_non_nullable
as int,capacityPerHour: null == capacityPerHour ? _self.capacityPerHour : capacityPerHour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklySchedule].
extension WeeklySchedulePatterns on WeeklySchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklySchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklySchedule value)  $default,){
final _that = this;
switch (_that) {
case _WeeklySchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklySchedule value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int dayOfWeek,  bool isOpen,  int startHour,  int endHour,  int capacityPerHour)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
return $default(_that.dayOfWeek,_that.isOpen,_that.startHour,_that.endHour,_that.capacityPerHour);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int dayOfWeek,  bool isOpen,  int startHour,  int endHour,  int capacityPerHour)  $default,) {final _that = this;
switch (_that) {
case _WeeklySchedule():
return $default(_that.dayOfWeek,_that.isOpen,_that.startHour,_that.endHour,_that.capacityPerHour);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int dayOfWeek,  bool isOpen,  int startHour,  int endHour,  int capacityPerHour)?  $default,) {final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
return $default(_that.dayOfWeek,_that.isOpen,_that.startHour,_that.endHour,_that.capacityPerHour);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklySchedule implements WeeklySchedule {
  const _WeeklySchedule({required this.dayOfWeek, required this.isOpen, required this.startHour, required this.endHour, required this.capacityPerHour});
  factory _WeeklySchedule.fromJson(Map<String, dynamic> json) => _$WeeklyScheduleFromJson(json);

@override final  int dayOfWeek;
// 1 = Monday, 7 = Sunday
@override final  bool isOpen;
@override final  int startHour;
// 0-23
@override final  int endHour;
// 0-23
@override final  int capacityPerHour;

/// Create a copy of WeeklySchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyScheduleCopyWith<_WeeklySchedule> get copyWith => __$WeeklyScheduleCopyWithImpl<_WeeklySchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklySchedule&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.startHour, startHour) || other.startHour == startHour)&&(identical(other.endHour, endHour) || other.endHour == endHour)&&(identical(other.capacityPerHour, capacityPerHour) || other.capacityPerHour == capacityPerHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,isOpen,startHour,endHour,capacityPerHour);

@override
String toString() {
  return 'WeeklySchedule(dayOfWeek: $dayOfWeek, isOpen: $isOpen, startHour: $startHour, endHour: $endHour, capacityPerHour: $capacityPerHour)';
}


}

/// @nodoc
abstract mixin class _$WeeklyScheduleCopyWith<$Res> implements $WeeklyScheduleCopyWith<$Res> {
  factory _$WeeklyScheduleCopyWith(_WeeklySchedule value, $Res Function(_WeeklySchedule) _then) = __$WeeklyScheduleCopyWithImpl;
@override @useResult
$Res call({
 int dayOfWeek, bool isOpen, int startHour, int endHour, int capacityPerHour
});




}
/// @nodoc
class __$WeeklyScheduleCopyWithImpl<$Res>
    implements _$WeeklyScheduleCopyWith<$Res> {
  __$WeeklyScheduleCopyWithImpl(this._self, this._then);

  final _WeeklySchedule _self;
  final $Res Function(_WeeklySchedule) _then;

/// Create a copy of WeeklySchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfWeek = null,Object? isOpen = null,Object? startHour = null,Object? endHour = null,Object? capacityPerHour = null,}) {
  return _then(_WeeklySchedule(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as int,endHour: null == endHour ? _self.endHour : endHour // ignore: cast_nullable_to_non_nullable
as int,capacityPerHour: null == capacityPerHour ? _self.capacityPerHour : capacityPerHour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BlockedDate {

 DateTime get date; String? get reason;
/// Create a copy of BlockedDate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockedDateCopyWith<BlockedDate> get copyWith => _$BlockedDateCopyWithImpl<BlockedDate>(this as BlockedDate, _$identity);

  /// Serializes this BlockedDate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockedDate&&(identical(other.date, date) || other.date == date)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,reason);

@override
String toString() {
  return 'BlockedDate(date: $date, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $BlockedDateCopyWith<$Res>  {
  factory $BlockedDateCopyWith(BlockedDate value, $Res Function(BlockedDate) _then) = _$BlockedDateCopyWithImpl;
@useResult
$Res call({
 DateTime date, String? reason
});




}
/// @nodoc
class _$BlockedDateCopyWithImpl<$Res>
    implements $BlockedDateCopyWith<$Res> {
  _$BlockedDateCopyWithImpl(this._self, this._then);

  final BlockedDate _self;
  final $Res Function(BlockedDate) _then;

/// Create a copy of BlockedDate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockedDate].
extension BlockedDatePatterns on BlockedDate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockedDate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockedDate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockedDate value)  $default,){
final _that = this;
switch (_that) {
case _BlockedDate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockedDate value)?  $default,){
final _that = this;
switch (_that) {
case _BlockedDate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockedDate() when $default != null:
return $default(_that.date,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _BlockedDate():
return $default(_that.date,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _BlockedDate() when $default != null:
return $default(_that.date,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BlockedDate implements BlockedDate {
  const _BlockedDate({required this.date, this.reason});
  factory _BlockedDate.fromJson(Map<String, dynamic> json) => _$BlockedDateFromJson(json);

@override final  DateTime date;
@override final  String? reason;

/// Create a copy of BlockedDate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockedDateCopyWith<_BlockedDate> get copyWith => __$BlockedDateCopyWithImpl<_BlockedDate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockedDateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockedDate&&(identical(other.date, date) || other.date == date)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,reason);

@override
String toString() {
  return 'BlockedDate(date: $date, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$BlockedDateCopyWith<$Res> implements $BlockedDateCopyWith<$Res> {
  factory _$BlockedDateCopyWith(_BlockedDate value, $Res Function(_BlockedDate) _then) = __$BlockedDateCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, String? reason
});




}
/// @nodoc
class __$BlockedDateCopyWithImpl<$Res>
    implements _$BlockedDateCopyWith<$Res> {
  __$BlockedDateCopyWithImpl(this._self, this._then);

  final _BlockedDate _self;
  final $Res Function(_BlockedDate) _then;

/// Create a copy of BlockedDate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? reason = freezed,}) {
  return _then(_BlockedDate(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
