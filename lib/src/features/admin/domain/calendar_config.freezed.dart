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
mixin _$TimeSlot {

 String get time;// "08:00"
 int get capacity; bool get isBlocked; List<String> get allowedCategories;
/// Create a copy of TimeSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeSlotCopyWith<TimeSlot> get copyWith => _$TimeSlotCopyWithImpl<TimeSlot>(this as TimeSlot, _$identity);

  /// Serializes this TimeSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeSlot&&(identical(other.time, time) || other.time == time)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&const DeepCollectionEquality().equals(other.allowedCategories, allowedCategories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,time,capacity,isBlocked,const DeepCollectionEquality().hash(allowedCategories));

@override
String toString() {
  return 'TimeSlot(time: $time, capacity: $capacity, isBlocked: $isBlocked, allowedCategories: $allowedCategories)';
}


}

/// @nodoc
abstract mixin class $TimeSlotCopyWith<$Res>  {
  factory $TimeSlotCopyWith(TimeSlot value, $Res Function(TimeSlot) _then) = _$TimeSlotCopyWithImpl;
@useResult
$Res call({
 String time, int capacity, bool isBlocked, List<String> allowedCategories
});




}
/// @nodoc
class _$TimeSlotCopyWithImpl<$Res>
    implements $TimeSlotCopyWith<$Res> {
  _$TimeSlotCopyWithImpl(this._self, this._then);

  final TimeSlot _self;
  final $Res Function(TimeSlot) _then;

/// Create a copy of TimeSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? capacity = null,Object? isBlocked = null,Object? allowedCategories = null,}) {
  return _then(_self.copyWith(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,allowedCategories: null == allowedCategories ? _self.allowedCategories : allowedCategories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeSlot].
extension TimeSlotPatterns on TimeSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeSlot value)  $default,){
final _that = this;
switch (_that) {
case _TimeSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeSlot value)?  $default,){
final _that = this;
switch (_that) {
case _TimeSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String time,  int capacity,  bool isBlocked,  List<String> allowedCategories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeSlot() when $default != null:
return $default(_that.time,_that.capacity,_that.isBlocked,_that.allowedCategories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String time,  int capacity,  bool isBlocked,  List<String> allowedCategories)  $default,) {final _that = this;
switch (_that) {
case _TimeSlot():
return $default(_that.time,_that.capacity,_that.isBlocked,_that.allowedCategories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String time,  int capacity,  bool isBlocked,  List<String> allowedCategories)?  $default,) {final _that = this;
switch (_that) {
case _TimeSlot() when $default != null:
return $default(_that.time,_that.capacity,_that.isBlocked,_that.allowedCategories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimeSlot implements TimeSlot {
  const _TimeSlot({required this.time, required this.capacity, this.isBlocked = false, final  List<String> allowedCategories = const []}): _allowedCategories = allowedCategories;
  factory _TimeSlot.fromJson(Map<String, dynamic> json) => _$TimeSlotFromJson(json);

@override final  String time;
// "08:00"
@override final  int capacity;
@override@JsonKey() final  bool isBlocked;
 final  List<String> _allowedCategories;
@override@JsonKey() List<String> get allowedCategories {
  if (_allowedCategories is EqualUnmodifiableListView) return _allowedCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedCategories);
}


/// Create a copy of TimeSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeSlotCopyWith<_TimeSlot> get copyWith => __$TimeSlotCopyWithImpl<_TimeSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeSlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeSlot&&(identical(other.time, time) || other.time == time)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&const DeepCollectionEquality().equals(other._allowedCategories, _allowedCategories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,time,capacity,isBlocked,const DeepCollectionEquality().hash(_allowedCategories));

@override
String toString() {
  return 'TimeSlot(time: $time, capacity: $capacity, isBlocked: $isBlocked, allowedCategories: $allowedCategories)';
}


}

/// @nodoc
abstract mixin class _$TimeSlotCopyWith<$Res> implements $TimeSlotCopyWith<$Res> {
  factory _$TimeSlotCopyWith(_TimeSlot value, $Res Function(_TimeSlot) _then) = __$TimeSlotCopyWithImpl;
@override @useResult
$Res call({
 String time, int capacity, bool isBlocked, List<String> allowedCategories
});




}
/// @nodoc
class __$TimeSlotCopyWithImpl<$Res>
    implements _$TimeSlotCopyWith<$Res> {
  __$TimeSlotCopyWithImpl(this._self, this._then);

  final _TimeSlot _self;
  final $Res Function(_TimeSlot) _then;

/// Create a copy of TimeSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? capacity = null,Object? isBlocked = null,Object? allowedCategories = null,}) {
  return _then(_TimeSlot(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,allowedCategories: null == allowedCategories ? _self._allowedCategories : allowedCategories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$WeeklySchedule {

 int get dayOfWeek;// 1 = Monday, 7 = Sunday
 bool get isOpen; int get startHour;// 0-23
 int get endHour;// 0-23
@Deprecated('Use slots instead') int get capacityPerHour; List<TimeSlot> get slots;
/// Create a copy of WeeklySchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyScheduleCopyWith<WeeklySchedule> get copyWith => _$WeeklyScheduleCopyWithImpl<WeeklySchedule>(this as WeeklySchedule, _$identity);

  /// Serializes this WeeklySchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklySchedule&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.startHour, startHour) || other.startHour == startHour)&&(identical(other.endHour, endHour) || other.endHour == endHour)&&(identical(other.capacityPerHour, capacityPerHour) || other.capacityPerHour == capacityPerHour)&&const DeepCollectionEquality().equals(other.slots, slots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,isOpen,startHour,endHour,capacityPerHour,const DeepCollectionEquality().hash(slots));

@override
String toString() {
  return 'WeeklySchedule(dayOfWeek: $dayOfWeek, isOpen: $isOpen, startHour: $startHour, endHour: $endHour, capacityPerHour: $capacityPerHour, slots: $slots)';
}


}

/// @nodoc
abstract mixin class $WeeklyScheduleCopyWith<$Res>  {
  factory $WeeklyScheduleCopyWith(WeeklySchedule value, $Res Function(WeeklySchedule) _then) = _$WeeklyScheduleCopyWithImpl;
@useResult
$Res call({
 int dayOfWeek, bool isOpen, int startHour, int endHour,@Deprecated('Use slots instead') int capacityPerHour, List<TimeSlot> slots
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
@pragma('vm:prefer-inline') @override $Res call({Object? dayOfWeek = null,Object? isOpen = null,Object? startHour = null,Object? endHour = null,Object? capacityPerHour = null,Object? slots = null,}) {
  return _then(_self.copyWith(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as int,endHour: null == endHour ? _self.endHour : endHour // ignore: cast_nullable_to_non_nullable
as int,capacityPerHour: null == capacityPerHour ? _self.capacityPerHour : capacityPerHour // ignore: cast_nullable_to_non_nullable
as int,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as List<TimeSlot>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int dayOfWeek,  bool isOpen,  int startHour,  int endHour, @Deprecated('Use slots instead')  int capacityPerHour,  List<TimeSlot> slots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
return $default(_that.dayOfWeek,_that.isOpen,_that.startHour,_that.endHour,_that.capacityPerHour,_that.slots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int dayOfWeek,  bool isOpen,  int startHour,  int endHour, @Deprecated('Use slots instead')  int capacityPerHour,  List<TimeSlot> slots)  $default,) {final _that = this;
switch (_that) {
case _WeeklySchedule():
return $default(_that.dayOfWeek,_that.isOpen,_that.startHour,_that.endHour,_that.capacityPerHour,_that.slots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int dayOfWeek,  bool isOpen,  int startHour,  int endHour, @Deprecated('Use slots instead')  int capacityPerHour,  List<TimeSlot> slots)?  $default,) {final _that = this;
switch (_that) {
case _WeeklySchedule() when $default != null:
return $default(_that.dayOfWeek,_that.isOpen,_that.startHour,_that.endHour,_that.capacityPerHour,_that.slots);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklySchedule implements WeeklySchedule {
  const _WeeklySchedule({required this.dayOfWeek, required this.isOpen, required this.startHour, required this.endHour, @Deprecated('Use slots instead') this.capacityPerHour = 0, final  List<TimeSlot> slots = const []}): _slots = slots;
  factory _WeeklySchedule.fromJson(Map<String, dynamic> json) => _$WeeklyScheduleFromJson(json);

@override final  int dayOfWeek;
// 1 = Monday, 7 = Sunday
@override final  bool isOpen;
@override final  int startHour;
// 0-23
@override final  int endHour;
// 0-23
@override@JsonKey()@Deprecated('Use slots instead') final  int capacityPerHour;
 final  List<TimeSlot> _slots;
@override@JsonKey() List<TimeSlot> get slots {
  if (_slots is EqualUnmodifiableListView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slots);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklySchedule&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.startHour, startHour) || other.startHour == startHour)&&(identical(other.endHour, endHour) || other.endHour == endHour)&&(identical(other.capacityPerHour, capacityPerHour) || other.capacityPerHour == capacityPerHour)&&const DeepCollectionEquality().equals(other._slots, _slots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,isOpen,startHour,endHour,capacityPerHour,const DeepCollectionEquality().hash(_slots));

@override
String toString() {
  return 'WeeklySchedule(dayOfWeek: $dayOfWeek, isOpen: $isOpen, startHour: $startHour, endHour: $endHour, capacityPerHour: $capacityPerHour, slots: $slots)';
}


}

/// @nodoc
abstract mixin class _$WeeklyScheduleCopyWith<$Res> implements $WeeklyScheduleCopyWith<$Res> {
  factory _$WeeklyScheduleCopyWith(_WeeklySchedule value, $Res Function(_WeeklySchedule) _then) = __$WeeklyScheduleCopyWithImpl;
@override @useResult
$Res call({
 int dayOfWeek, bool isOpen, int startHour, int endHour,@Deprecated('Use slots instead') int capacityPerHour, List<TimeSlot> slots
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
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfWeek = null,Object? isOpen = null,Object? startHour = null,Object? endHour = null,Object? capacityPerHour = null,Object? slots = null,}) {
  return _then(_WeeklySchedule(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as int,endHour: null == endHour ? _self.endHour : endHour // ignore: cast_nullable_to_non_nullable
as int,capacityPerHour: null == capacityPerHour ? _self.capacityPerHour : capacityPerHour // ignore: cast_nullable_to_non_nullable
as int,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as List<TimeSlot>,
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
