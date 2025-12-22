// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_appointments_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminAppointmentsState {

// UI State
 bool get isCalendarView; int get currentTabIndex;// Car Wash Filters
 String get carWashSearchQuery; String get carWashStatusFilter; SortOrder get carWashSortOrder;// Aesthetic Filters
 String get aestheticSearchQuery; String get aestheticStatusFilter; SortOrder get aestheticSortOrder;// Audio Alert Tracking
 int get lastPendingAestheticCount;// Calendar State
 DateTime? get selectedDay; DateTime? get focusedDay;
/// Create a copy of AdminAppointmentsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminAppointmentsStateCopyWith<AdminAppointmentsState> get copyWith => _$AdminAppointmentsStateCopyWithImpl<AdminAppointmentsState>(this as AdminAppointmentsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminAppointmentsState&&(identical(other.isCalendarView, isCalendarView) || other.isCalendarView == isCalendarView)&&(identical(other.currentTabIndex, currentTabIndex) || other.currentTabIndex == currentTabIndex)&&(identical(other.carWashSearchQuery, carWashSearchQuery) || other.carWashSearchQuery == carWashSearchQuery)&&(identical(other.carWashStatusFilter, carWashStatusFilter) || other.carWashStatusFilter == carWashStatusFilter)&&(identical(other.carWashSortOrder, carWashSortOrder) || other.carWashSortOrder == carWashSortOrder)&&(identical(other.aestheticSearchQuery, aestheticSearchQuery) || other.aestheticSearchQuery == aestheticSearchQuery)&&(identical(other.aestheticStatusFilter, aestheticStatusFilter) || other.aestheticStatusFilter == aestheticStatusFilter)&&(identical(other.aestheticSortOrder, aestheticSortOrder) || other.aestheticSortOrder == aestheticSortOrder)&&(identical(other.lastPendingAestheticCount, lastPendingAestheticCount) || other.lastPendingAestheticCount == lastPendingAestheticCount)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&(identical(other.focusedDay, focusedDay) || other.focusedDay == focusedDay));
}


@override
int get hashCode => Object.hash(runtimeType,isCalendarView,currentTabIndex,carWashSearchQuery,carWashStatusFilter,carWashSortOrder,aestheticSearchQuery,aestheticStatusFilter,aestheticSortOrder,lastPendingAestheticCount,selectedDay,focusedDay);

@override
String toString() {
  return 'AdminAppointmentsState(isCalendarView: $isCalendarView, currentTabIndex: $currentTabIndex, carWashSearchQuery: $carWashSearchQuery, carWashStatusFilter: $carWashStatusFilter, carWashSortOrder: $carWashSortOrder, aestheticSearchQuery: $aestheticSearchQuery, aestheticStatusFilter: $aestheticStatusFilter, aestheticSortOrder: $aestheticSortOrder, lastPendingAestheticCount: $lastPendingAestheticCount, selectedDay: $selectedDay, focusedDay: $focusedDay)';
}


}

/// @nodoc
abstract mixin class $AdminAppointmentsStateCopyWith<$Res>  {
  factory $AdminAppointmentsStateCopyWith(AdminAppointmentsState value, $Res Function(AdminAppointmentsState) _then) = _$AdminAppointmentsStateCopyWithImpl;
@useResult
$Res call({
 bool isCalendarView, int currentTabIndex, String carWashSearchQuery, String carWashStatusFilter, SortOrder carWashSortOrder, String aestheticSearchQuery, String aestheticStatusFilter, SortOrder aestheticSortOrder, int lastPendingAestheticCount, DateTime? selectedDay, DateTime? focusedDay
});




}
/// @nodoc
class _$AdminAppointmentsStateCopyWithImpl<$Res>
    implements $AdminAppointmentsStateCopyWith<$Res> {
  _$AdminAppointmentsStateCopyWithImpl(this._self, this._then);

  final AdminAppointmentsState _self;
  final $Res Function(AdminAppointmentsState) _then;

/// Create a copy of AdminAppointmentsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isCalendarView = null,Object? currentTabIndex = null,Object? carWashSearchQuery = null,Object? carWashStatusFilter = null,Object? carWashSortOrder = null,Object? aestheticSearchQuery = null,Object? aestheticStatusFilter = null,Object? aestheticSortOrder = null,Object? lastPendingAestheticCount = null,Object? selectedDay = freezed,Object? focusedDay = freezed,}) {
  return _then(_self.copyWith(
isCalendarView: null == isCalendarView ? _self.isCalendarView : isCalendarView // ignore: cast_nullable_to_non_nullable
as bool,currentTabIndex: null == currentTabIndex ? _self.currentTabIndex : currentTabIndex // ignore: cast_nullable_to_non_nullable
as int,carWashSearchQuery: null == carWashSearchQuery ? _self.carWashSearchQuery : carWashSearchQuery // ignore: cast_nullable_to_non_nullable
as String,carWashStatusFilter: null == carWashStatusFilter ? _self.carWashStatusFilter : carWashStatusFilter // ignore: cast_nullable_to_non_nullable
as String,carWashSortOrder: null == carWashSortOrder ? _self.carWashSortOrder : carWashSortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,aestheticSearchQuery: null == aestheticSearchQuery ? _self.aestheticSearchQuery : aestheticSearchQuery // ignore: cast_nullable_to_non_nullable
as String,aestheticStatusFilter: null == aestheticStatusFilter ? _self.aestheticStatusFilter : aestheticStatusFilter // ignore: cast_nullable_to_non_nullable
as String,aestheticSortOrder: null == aestheticSortOrder ? _self.aestheticSortOrder : aestheticSortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,lastPendingAestheticCount: null == lastPendingAestheticCount ? _self.lastPendingAestheticCount : lastPendingAestheticCount // ignore: cast_nullable_to_non_nullable
as int,selectedDay: freezed == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,focusedDay: freezed == focusedDay ? _self.focusedDay : focusedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminAppointmentsState].
extension AdminAppointmentsStatePatterns on AdminAppointmentsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminAppointmentsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminAppointmentsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminAppointmentsState value)  $default,){
final _that = this;
switch (_that) {
case _AdminAppointmentsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminAppointmentsState value)?  $default,){
final _that = this;
switch (_that) {
case _AdminAppointmentsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isCalendarView,  int currentTabIndex,  String carWashSearchQuery,  String carWashStatusFilter,  SortOrder carWashSortOrder,  String aestheticSearchQuery,  String aestheticStatusFilter,  SortOrder aestheticSortOrder,  int lastPendingAestheticCount,  DateTime? selectedDay,  DateTime? focusedDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminAppointmentsState() when $default != null:
return $default(_that.isCalendarView,_that.currentTabIndex,_that.carWashSearchQuery,_that.carWashStatusFilter,_that.carWashSortOrder,_that.aestheticSearchQuery,_that.aestheticStatusFilter,_that.aestheticSortOrder,_that.lastPendingAestheticCount,_that.selectedDay,_that.focusedDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isCalendarView,  int currentTabIndex,  String carWashSearchQuery,  String carWashStatusFilter,  SortOrder carWashSortOrder,  String aestheticSearchQuery,  String aestheticStatusFilter,  SortOrder aestheticSortOrder,  int lastPendingAestheticCount,  DateTime? selectedDay,  DateTime? focusedDay)  $default,) {final _that = this;
switch (_that) {
case _AdminAppointmentsState():
return $default(_that.isCalendarView,_that.currentTabIndex,_that.carWashSearchQuery,_that.carWashStatusFilter,_that.carWashSortOrder,_that.aestheticSearchQuery,_that.aestheticStatusFilter,_that.aestheticSortOrder,_that.lastPendingAestheticCount,_that.selectedDay,_that.focusedDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isCalendarView,  int currentTabIndex,  String carWashSearchQuery,  String carWashStatusFilter,  SortOrder carWashSortOrder,  String aestheticSearchQuery,  String aestheticStatusFilter,  SortOrder aestheticSortOrder,  int lastPendingAestheticCount,  DateTime? selectedDay,  DateTime? focusedDay)?  $default,) {final _that = this;
switch (_that) {
case _AdminAppointmentsState() when $default != null:
return $default(_that.isCalendarView,_that.currentTabIndex,_that.carWashSearchQuery,_that.carWashStatusFilter,_that.carWashSortOrder,_that.aestheticSearchQuery,_that.aestheticStatusFilter,_that.aestheticSortOrder,_that.lastPendingAestheticCount,_that.selectedDay,_that.focusedDay);case _:
  return null;

}
}

}

/// @nodoc


class _AdminAppointmentsState extends AdminAppointmentsState {
  const _AdminAppointmentsState({this.isCalendarView = false, this.currentTabIndex = 0, this.carWashSearchQuery = '', this.carWashStatusFilter = 'all', this.carWashSortOrder = SortOrder.newestFirst, this.aestheticSearchQuery = '', this.aestheticStatusFilter = 'all', this.aestheticSortOrder = SortOrder.newestFirst, this.lastPendingAestheticCount = 0, this.selectedDay, this.focusedDay}): super._();
  

// UI State
@override@JsonKey() final  bool isCalendarView;
@override@JsonKey() final  int currentTabIndex;
// Car Wash Filters
@override@JsonKey() final  String carWashSearchQuery;
@override@JsonKey() final  String carWashStatusFilter;
@override@JsonKey() final  SortOrder carWashSortOrder;
// Aesthetic Filters
@override@JsonKey() final  String aestheticSearchQuery;
@override@JsonKey() final  String aestheticStatusFilter;
@override@JsonKey() final  SortOrder aestheticSortOrder;
// Audio Alert Tracking
@override@JsonKey() final  int lastPendingAestheticCount;
// Calendar State
@override final  DateTime? selectedDay;
@override final  DateTime? focusedDay;

/// Create a copy of AdminAppointmentsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminAppointmentsStateCopyWith<_AdminAppointmentsState> get copyWith => __$AdminAppointmentsStateCopyWithImpl<_AdminAppointmentsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminAppointmentsState&&(identical(other.isCalendarView, isCalendarView) || other.isCalendarView == isCalendarView)&&(identical(other.currentTabIndex, currentTabIndex) || other.currentTabIndex == currentTabIndex)&&(identical(other.carWashSearchQuery, carWashSearchQuery) || other.carWashSearchQuery == carWashSearchQuery)&&(identical(other.carWashStatusFilter, carWashStatusFilter) || other.carWashStatusFilter == carWashStatusFilter)&&(identical(other.carWashSortOrder, carWashSortOrder) || other.carWashSortOrder == carWashSortOrder)&&(identical(other.aestheticSearchQuery, aestheticSearchQuery) || other.aestheticSearchQuery == aestheticSearchQuery)&&(identical(other.aestheticStatusFilter, aestheticStatusFilter) || other.aestheticStatusFilter == aestheticStatusFilter)&&(identical(other.aestheticSortOrder, aestheticSortOrder) || other.aestheticSortOrder == aestheticSortOrder)&&(identical(other.lastPendingAestheticCount, lastPendingAestheticCount) || other.lastPendingAestheticCount == lastPendingAestheticCount)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&(identical(other.focusedDay, focusedDay) || other.focusedDay == focusedDay));
}


@override
int get hashCode => Object.hash(runtimeType,isCalendarView,currentTabIndex,carWashSearchQuery,carWashStatusFilter,carWashSortOrder,aestheticSearchQuery,aestheticStatusFilter,aestheticSortOrder,lastPendingAestheticCount,selectedDay,focusedDay);

@override
String toString() {
  return 'AdminAppointmentsState(isCalendarView: $isCalendarView, currentTabIndex: $currentTabIndex, carWashSearchQuery: $carWashSearchQuery, carWashStatusFilter: $carWashStatusFilter, carWashSortOrder: $carWashSortOrder, aestheticSearchQuery: $aestheticSearchQuery, aestheticStatusFilter: $aestheticStatusFilter, aestheticSortOrder: $aestheticSortOrder, lastPendingAestheticCount: $lastPendingAestheticCount, selectedDay: $selectedDay, focusedDay: $focusedDay)';
}


}

/// @nodoc
abstract mixin class _$AdminAppointmentsStateCopyWith<$Res> implements $AdminAppointmentsStateCopyWith<$Res> {
  factory _$AdminAppointmentsStateCopyWith(_AdminAppointmentsState value, $Res Function(_AdminAppointmentsState) _then) = __$AdminAppointmentsStateCopyWithImpl;
@override @useResult
$Res call({
 bool isCalendarView, int currentTabIndex, String carWashSearchQuery, String carWashStatusFilter, SortOrder carWashSortOrder, String aestheticSearchQuery, String aestheticStatusFilter, SortOrder aestheticSortOrder, int lastPendingAestheticCount, DateTime? selectedDay, DateTime? focusedDay
});




}
/// @nodoc
class __$AdminAppointmentsStateCopyWithImpl<$Res>
    implements _$AdminAppointmentsStateCopyWith<$Res> {
  __$AdminAppointmentsStateCopyWithImpl(this._self, this._then);

  final _AdminAppointmentsState _self;
  final $Res Function(_AdminAppointmentsState) _then;

/// Create a copy of AdminAppointmentsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isCalendarView = null,Object? currentTabIndex = null,Object? carWashSearchQuery = null,Object? carWashStatusFilter = null,Object? carWashSortOrder = null,Object? aestheticSearchQuery = null,Object? aestheticStatusFilter = null,Object? aestheticSortOrder = null,Object? lastPendingAestheticCount = null,Object? selectedDay = freezed,Object? focusedDay = freezed,}) {
  return _then(_AdminAppointmentsState(
isCalendarView: null == isCalendarView ? _self.isCalendarView : isCalendarView // ignore: cast_nullable_to_non_nullable
as bool,currentTabIndex: null == currentTabIndex ? _self.currentTabIndex : currentTabIndex // ignore: cast_nullable_to_non_nullable
as int,carWashSearchQuery: null == carWashSearchQuery ? _self.carWashSearchQuery : carWashSearchQuery // ignore: cast_nullable_to_non_nullable
as String,carWashStatusFilter: null == carWashStatusFilter ? _self.carWashStatusFilter : carWashStatusFilter // ignore: cast_nullable_to_non_nullable
as String,carWashSortOrder: null == carWashSortOrder ? _self.carWashSortOrder : carWashSortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,aestheticSearchQuery: null == aestheticSearchQuery ? _self.aestheticSearchQuery : aestheticSearchQuery // ignore: cast_nullable_to_non_nullable
as String,aestheticStatusFilter: null == aestheticStatusFilter ? _self.aestheticStatusFilter : aestheticStatusFilter // ignore: cast_nullable_to_non_nullable
as String,aestheticSortOrder: null == aestheticSortOrder ? _self.aestheticSortOrder : aestheticSortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,lastPendingAestheticCount: null == lastPendingAestheticCount ? _self.lastPendingAestheticCount : lastPendingAestheticCount // ignore: cast_nullable_to_non_nullable
as int,selectedDay: freezed == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,focusedDay: freezed == focusedDay ? _self.focusedDay : focusedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
