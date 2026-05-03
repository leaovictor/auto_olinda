// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardMetrics {

 String get tenantId; DateTime get date;// Revenue
 double get todayRevenue; double get weekRevenue; double get monthRevenue;// Appointments
 int get todayAppointments; int get pendingAppointments; int get completedToday; int get cancelledToday;// Customers
 int get newCustomersToday; int get totalCustomers; double get avgCustomerLTV;// Staff
 int get activeStaffCount; Map<String, StaffPerformance>? get staffPerformance;// staffId -> metrics
// Top services
 List<TopService> get topServices;// Subscription metrics
 int get activeSubscriptions; int get subscriptionMRR;// Monthly Recurring Revenue
// Comparison (vs yesterday/last week)
 double get revenueGrowthPercent; double get appointmentGrowthPercent;
/// Create a copy of DashboardMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardMetricsCopyWith<DashboardMetrics> get copyWith => _$DashboardMetricsCopyWithImpl<DashboardMetrics>(this as DashboardMetrics, _$identity);

  /// Serializes this DashboardMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardMetrics&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.date, date) || other.date == date)&&(identical(other.todayRevenue, todayRevenue) || other.todayRevenue == todayRevenue)&&(identical(other.weekRevenue, weekRevenue) || other.weekRevenue == weekRevenue)&&(identical(other.monthRevenue, monthRevenue) || other.monthRevenue == monthRevenue)&&(identical(other.todayAppointments, todayAppointments) || other.todayAppointments == todayAppointments)&&(identical(other.pendingAppointments, pendingAppointments) || other.pendingAppointments == pendingAppointments)&&(identical(other.completedToday, completedToday) || other.completedToday == completedToday)&&(identical(other.cancelledToday, cancelledToday) || other.cancelledToday == cancelledToday)&&(identical(other.newCustomersToday, newCustomersToday) || other.newCustomersToday == newCustomersToday)&&(identical(other.totalCustomers, totalCustomers) || other.totalCustomers == totalCustomers)&&(identical(other.avgCustomerLTV, avgCustomerLTV) || other.avgCustomerLTV == avgCustomerLTV)&&(identical(other.activeStaffCount, activeStaffCount) || other.activeStaffCount == activeStaffCount)&&const DeepCollectionEquality().equals(other.staffPerformance, staffPerformance)&&const DeepCollectionEquality().equals(other.topServices, topServices)&&(identical(other.activeSubscriptions, activeSubscriptions) || other.activeSubscriptions == activeSubscriptions)&&(identical(other.subscriptionMRR, subscriptionMRR) || other.subscriptionMRR == subscriptionMRR)&&(identical(other.revenueGrowthPercent, revenueGrowthPercent) || other.revenueGrowthPercent == revenueGrowthPercent)&&(identical(other.appointmentGrowthPercent, appointmentGrowthPercent) || other.appointmentGrowthPercent == appointmentGrowthPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tenantId,date,todayRevenue,weekRevenue,monthRevenue,todayAppointments,pendingAppointments,completedToday,cancelledToday,newCustomersToday,totalCustomers,avgCustomerLTV,activeStaffCount,const DeepCollectionEquality().hash(staffPerformance),const DeepCollectionEquality().hash(topServices),activeSubscriptions,subscriptionMRR,revenueGrowthPercent,appointmentGrowthPercent]);

@override
String toString() {
  return 'DashboardMetrics(tenantId: $tenantId, date: $date, todayRevenue: $todayRevenue, weekRevenue: $weekRevenue, monthRevenue: $monthRevenue, todayAppointments: $todayAppointments, pendingAppointments: $pendingAppointments, completedToday: $completedToday, cancelledToday: $cancelledToday, newCustomersToday: $newCustomersToday, totalCustomers: $totalCustomers, avgCustomerLTV: $avgCustomerLTV, activeStaffCount: $activeStaffCount, staffPerformance: $staffPerformance, topServices: $topServices, activeSubscriptions: $activeSubscriptions, subscriptionMRR: $subscriptionMRR, revenueGrowthPercent: $revenueGrowthPercent, appointmentGrowthPercent: $appointmentGrowthPercent)';
}


}

/// @nodoc
abstract mixin class $DashboardMetricsCopyWith<$Res>  {
  factory $DashboardMetricsCopyWith(DashboardMetrics value, $Res Function(DashboardMetrics) _then) = _$DashboardMetricsCopyWithImpl;
@useResult
$Res call({
 String tenantId, DateTime date, double todayRevenue, double weekRevenue, double monthRevenue, int todayAppointments, int pendingAppointments, int completedToday, int cancelledToday, int newCustomersToday, int totalCustomers, double avgCustomerLTV, int activeStaffCount, Map<String, StaffPerformance>? staffPerformance, List<TopService> topServices, int activeSubscriptions, int subscriptionMRR, double revenueGrowthPercent, double appointmentGrowthPercent
});




}
/// @nodoc
class _$DashboardMetricsCopyWithImpl<$Res>
    implements $DashboardMetricsCopyWith<$Res> {
  _$DashboardMetricsCopyWithImpl(this._self, this._then);

  final DashboardMetrics _self;
  final $Res Function(DashboardMetrics) _then;

/// Create a copy of DashboardMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tenantId = null,Object? date = null,Object? todayRevenue = null,Object? weekRevenue = null,Object? monthRevenue = null,Object? todayAppointments = null,Object? pendingAppointments = null,Object? completedToday = null,Object? cancelledToday = null,Object? newCustomersToday = null,Object? totalCustomers = null,Object? avgCustomerLTV = null,Object? activeStaffCount = null,Object? staffPerformance = freezed,Object? topServices = null,Object? activeSubscriptions = null,Object? subscriptionMRR = null,Object? revenueGrowthPercent = null,Object? appointmentGrowthPercent = null,}) {
  return _then(_self.copyWith(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,todayRevenue: null == todayRevenue ? _self.todayRevenue : todayRevenue // ignore: cast_nullable_to_non_nullable
as double,weekRevenue: null == weekRevenue ? _self.weekRevenue : weekRevenue // ignore: cast_nullable_to_non_nullable
as double,monthRevenue: null == monthRevenue ? _self.monthRevenue : monthRevenue // ignore: cast_nullable_to_non_nullable
as double,todayAppointments: null == todayAppointments ? _self.todayAppointments : todayAppointments // ignore: cast_nullable_to_non_nullable
as int,pendingAppointments: null == pendingAppointments ? _self.pendingAppointments : pendingAppointments // ignore: cast_nullable_to_non_nullable
as int,completedToday: null == completedToday ? _self.completedToday : completedToday // ignore: cast_nullable_to_non_nullable
as int,cancelledToday: null == cancelledToday ? _self.cancelledToday : cancelledToday // ignore: cast_nullable_to_non_nullable
as int,newCustomersToday: null == newCustomersToday ? _self.newCustomersToday : newCustomersToday // ignore: cast_nullable_to_non_nullable
as int,totalCustomers: null == totalCustomers ? _self.totalCustomers : totalCustomers // ignore: cast_nullable_to_non_nullable
as int,avgCustomerLTV: null == avgCustomerLTV ? _self.avgCustomerLTV : avgCustomerLTV // ignore: cast_nullable_to_non_nullable
as double,activeStaffCount: null == activeStaffCount ? _self.activeStaffCount : activeStaffCount // ignore: cast_nullable_to_non_nullable
as int,staffPerformance: freezed == staffPerformance ? _self.staffPerformance : staffPerformance // ignore: cast_nullable_to_non_nullable
as Map<String, StaffPerformance>?,topServices: null == topServices ? _self.topServices : topServices // ignore: cast_nullable_to_non_nullable
as List<TopService>,activeSubscriptions: null == activeSubscriptions ? _self.activeSubscriptions : activeSubscriptions // ignore: cast_nullable_to_non_nullable
as int,subscriptionMRR: null == subscriptionMRR ? _self.subscriptionMRR : subscriptionMRR // ignore: cast_nullable_to_non_nullable
as int,revenueGrowthPercent: null == revenueGrowthPercent ? _self.revenueGrowthPercent : revenueGrowthPercent // ignore: cast_nullable_to_non_nullable
as double,appointmentGrowthPercent: null == appointmentGrowthPercent ? _self.appointmentGrowthPercent : appointmentGrowthPercent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardMetrics].
extension DashboardMetricsPatterns on DashboardMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardMetrics value)  $default,){
final _that = this;
switch (_that) {
case _DashboardMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tenantId,  DateTime date,  double todayRevenue,  double weekRevenue,  double monthRevenue,  int todayAppointments,  int pendingAppointments,  int completedToday,  int cancelledToday,  int newCustomersToday,  int totalCustomers,  double avgCustomerLTV,  int activeStaffCount,  Map<String, StaffPerformance>? staffPerformance,  List<TopService> topServices,  int activeSubscriptions,  int subscriptionMRR,  double revenueGrowthPercent,  double appointmentGrowthPercent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardMetrics() when $default != null:
return $default(_that.tenantId,_that.date,_that.todayRevenue,_that.weekRevenue,_that.monthRevenue,_that.todayAppointments,_that.pendingAppointments,_that.completedToday,_that.cancelledToday,_that.newCustomersToday,_that.totalCustomers,_that.avgCustomerLTV,_that.activeStaffCount,_that.staffPerformance,_that.topServices,_that.activeSubscriptions,_that.subscriptionMRR,_that.revenueGrowthPercent,_that.appointmentGrowthPercent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tenantId,  DateTime date,  double todayRevenue,  double weekRevenue,  double monthRevenue,  int todayAppointments,  int pendingAppointments,  int completedToday,  int cancelledToday,  int newCustomersToday,  int totalCustomers,  double avgCustomerLTV,  int activeStaffCount,  Map<String, StaffPerformance>? staffPerformance,  List<TopService> topServices,  int activeSubscriptions,  int subscriptionMRR,  double revenueGrowthPercent,  double appointmentGrowthPercent)  $default,) {final _that = this;
switch (_that) {
case _DashboardMetrics():
return $default(_that.tenantId,_that.date,_that.todayRevenue,_that.weekRevenue,_that.monthRevenue,_that.todayAppointments,_that.pendingAppointments,_that.completedToday,_that.cancelledToday,_that.newCustomersToday,_that.totalCustomers,_that.avgCustomerLTV,_that.activeStaffCount,_that.staffPerformance,_that.topServices,_that.activeSubscriptions,_that.subscriptionMRR,_that.revenueGrowthPercent,_that.appointmentGrowthPercent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tenantId,  DateTime date,  double todayRevenue,  double weekRevenue,  double monthRevenue,  int todayAppointments,  int pendingAppointments,  int completedToday,  int cancelledToday,  int newCustomersToday,  int totalCustomers,  double avgCustomerLTV,  int activeStaffCount,  Map<String, StaffPerformance>? staffPerformance,  List<TopService> topServices,  int activeSubscriptions,  int subscriptionMRR,  double revenueGrowthPercent,  double appointmentGrowthPercent)?  $default,) {final _that = this;
switch (_that) {
case _DashboardMetrics() when $default != null:
return $default(_that.tenantId,_that.date,_that.todayRevenue,_that.weekRevenue,_that.monthRevenue,_that.todayAppointments,_that.pendingAppointments,_that.completedToday,_that.cancelledToday,_that.newCustomersToday,_that.totalCustomers,_that.avgCustomerLTV,_that.activeStaffCount,_that.staffPerformance,_that.topServices,_that.activeSubscriptions,_that.subscriptionMRR,_that.revenueGrowthPercent,_that.appointmentGrowthPercent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardMetrics implements DashboardMetrics {
  const _DashboardMetrics({required this.tenantId, required this.date, this.todayRevenue = 0.0, this.weekRevenue = 0.0, this.monthRevenue = 0.0, this.todayAppointments = 0, this.pendingAppointments = 0, this.completedToday = 0, this.cancelledToday = 0, this.newCustomersToday = 0, this.totalCustomers = 0, this.avgCustomerLTV = 0.0, this.activeStaffCount = 0, final  Map<String, StaffPerformance>? staffPerformance, final  List<TopService> topServices = const [], this.activeSubscriptions = 0, this.subscriptionMRR = 0, this.revenueGrowthPercent = 0.0, this.appointmentGrowthPercent = 0.0}): _staffPerformance = staffPerformance,_topServices = topServices;
  factory _DashboardMetrics.fromJson(Map<String, dynamic> json) => _$DashboardMetricsFromJson(json);

@override final  String tenantId;
@override final  DateTime date;
// Revenue
@override@JsonKey() final  double todayRevenue;
@override@JsonKey() final  double weekRevenue;
@override@JsonKey() final  double monthRevenue;
// Appointments
@override@JsonKey() final  int todayAppointments;
@override@JsonKey() final  int pendingAppointments;
@override@JsonKey() final  int completedToday;
@override@JsonKey() final  int cancelledToday;
// Customers
@override@JsonKey() final  int newCustomersToday;
@override@JsonKey() final  int totalCustomers;
@override@JsonKey() final  double avgCustomerLTV;
// Staff
@override@JsonKey() final  int activeStaffCount;
 final  Map<String, StaffPerformance>? _staffPerformance;
@override Map<String, StaffPerformance>? get staffPerformance {
  final value = _staffPerformance;
  if (value == null) return null;
  if (_staffPerformance is EqualUnmodifiableMapView) return _staffPerformance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// staffId -> metrics
// Top services
 final  List<TopService> _topServices;
// staffId -> metrics
// Top services
@override@JsonKey() List<TopService> get topServices {
  if (_topServices is EqualUnmodifiableListView) return _topServices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topServices);
}

// Subscription metrics
@override@JsonKey() final  int activeSubscriptions;
@override@JsonKey() final  int subscriptionMRR;
// Monthly Recurring Revenue
// Comparison (vs yesterday/last week)
@override@JsonKey() final  double revenueGrowthPercent;
@override@JsonKey() final  double appointmentGrowthPercent;

/// Create a copy of DashboardMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardMetricsCopyWith<_DashboardMetrics> get copyWith => __$DashboardMetricsCopyWithImpl<_DashboardMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardMetrics&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.date, date) || other.date == date)&&(identical(other.todayRevenue, todayRevenue) || other.todayRevenue == todayRevenue)&&(identical(other.weekRevenue, weekRevenue) || other.weekRevenue == weekRevenue)&&(identical(other.monthRevenue, monthRevenue) || other.monthRevenue == monthRevenue)&&(identical(other.todayAppointments, todayAppointments) || other.todayAppointments == todayAppointments)&&(identical(other.pendingAppointments, pendingAppointments) || other.pendingAppointments == pendingAppointments)&&(identical(other.completedToday, completedToday) || other.completedToday == completedToday)&&(identical(other.cancelledToday, cancelledToday) || other.cancelledToday == cancelledToday)&&(identical(other.newCustomersToday, newCustomersToday) || other.newCustomersToday == newCustomersToday)&&(identical(other.totalCustomers, totalCustomers) || other.totalCustomers == totalCustomers)&&(identical(other.avgCustomerLTV, avgCustomerLTV) || other.avgCustomerLTV == avgCustomerLTV)&&(identical(other.activeStaffCount, activeStaffCount) || other.activeStaffCount == activeStaffCount)&&const DeepCollectionEquality().equals(other._staffPerformance, _staffPerformance)&&const DeepCollectionEquality().equals(other._topServices, _topServices)&&(identical(other.activeSubscriptions, activeSubscriptions) || other.activeSubscriptions == activeSubscriptions)&&(identical(other.subscriptionMRR, subscriptionMRR) || other.subscriptionMRR == subscriptionMRR)&&(identical(other.revenueGrowthPercent, revenueGrowthPercent) || other.revenueGrowthPercent == revenueGrowthPercent)&&(identical(other.appointmentGrowthPercent, appointmentGrowthPercent) || other.appointmentGrowthPercent == appointmentGrowthPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tenantId,date,todayRevenue,weekRevenue,monthRevenue,todayAppointments,pendingAppointments,completedToday,cancelledToday,newCustomersToday,totalCustomers,avgCustomerLTV,activeStaffCount,const DeepCollectionEquality().hash(_staffPerformance),const DeepCollectionEquality().hash(_topServices),activeSubscriptions,subscriptionMRR,revenueGrowthPercent,appointmentGrowthPercent]);

@override
String toString() {
  return 'DashboardMetrics(tenantId: $tenantId, date: $date, todayRevenue: $todayRevenue, weekRevenue: $weekRevenue, monthRevenue: $monthRevenue, todayAppointments: $todayAppointments, pendingAppointments: $pendingAppointments, completedToday: $completedToday, cancelledToday: $cancelledToday, newCustomersToday: $newCustomersToday, totalCustomers: $totalCustomers, avgCustomerLTV: $avgCustomerLTV, activeStaffCount: $activeStaffCount, staffPerformance: $staffPerformance, topServices: $topServices, activeSubscriptions: $activeSubscriptions, subscriptionMRR: $subscriptionMRR, revenueGrowthPercent: $revenueGrowthPercent, appointmentGrowthPercent: $appointmentGrowthPercent)';
}


}

/// @nodoc
abstract mixin class _$DashboardMetricsCopyWith<$Res> implements $DashboardMetricsCopyWith<$Res> {
  factory _$DashboardMetricsCopyWith(_DashboardMetrics value, $Res Function(_DashboardMetrics) _then) = __$DashboardMetricsCopyWithImpl;
@override @useResult
$Res call({
 String tenantId, DateTime date, double todayRevenue, double weekRevenue, double monthRevenue, int todayAppointments, int pendingAppointments, int completedToday, int cancelledToday, int newCustomersToday, int totalCustomers, double avgCustomerLTV, int activeStaffCount, Map<String, StaffPerformance>? staffPerformance, List<TopService> topServices, int activeSubscriptions, int subscriptionMRR, double revenueGrowthPercent, double appointmentGrowthPercent
});




}
/// @nodoc
class __$DashboardMetricsCopyWithImpl<$Res>
    implements _$DashboardMetricsCopyWith<$Res> {
  __$DashboardMetricsCopyWithImpl(this._self, this._then);

  final _DashboardMetrics _self;
  final $Res Function(_DashboardMetrics) _then;

/// Create a copy of DashboardMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tenantId = null,Object? date = null,Object? todayRevenue = null,Object? weekRevenue = null,Object? monthRevenue = null,Object? todayAppointments = null,Object? pendingAppointments = null,Object? completedToday = null,Object? cancelledToday = null,Object? newCustomersToday = null,Object? totalCustomers = null,Object? avgCustomerLTV = null,Object? activeStaffCount = null,Object? staffPerformance = freezed,Object? topServices = null,Object? activeSubscriptions = null,Object? subscriptionMRR = null,Object? revenueGrowthPercent = null,Object? appointmentGrowthPercent = null,}) {
  return _then(_DashboardMetrics(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,todayRevenue: null == todayRevenue ? _self.todayRevenue : todayRevenue // ignore: cast_nullable_to_non_nullable
as double,weekRevenue: null == weekRevenue ? _self.weekRevenue : weekRevenue // ignore: cast_nullable_to_non_nullable
as double,monthRevenue: null == monthRevenue ? _self.monthRevenue : monthRevenue // ignore: cast_nullable_to_non_nullable
as double,todayAppointments: null == todayAppointments ? _self.todayAppointments : todayAppointments // ignore: cast_nullable_to_non_nullable
as int,pendingAppointments: null == pendingAppointments ? _self.pendingAppointments : pendingAppointments // ignore: cast_nullable_to_non_nullable
as int,completedToday: null == completedToday ? _self.completedToday : completedToday // ignore: cast_nullable_to_non_nullable
as int,cancelledToday: null == cancelledToday ? _self.cancelledToday : cancelledToday // ignore: cast_nullable_to_non_nullable
as int,newCustomersToday: null == newCustomersToday ? _self.newCustomersToday : newCustomersToday // ignore: cast_nullable_to_non_nullable
as int,totalCustomers: null == totalCustomers ? _self.totalCustomers : totalCustomers // ignore: cast_nullable_to_non_nullable
as int,avgCustomerLTV: null == avgCustomerLTV ? _self.avgCustomerLTV : avgCustomerLTV // ignore: cast_nullable_to_non_nullable
as double,activeStaffCount: null == activeStaffCount ? _self.activeStaffCount : activeStaffCount // ignore: cast_nullable_to_non_nullable
as int,staffPerformance: freezed == staffPerformance ? _self._staffPerformance : staffPerformance // ignore: cast_nullable_to_non_nullable
as Map<String, StaffPerformance>?,topServices: null == topServices ? _self._topServices : topServices // ignore: cast_nullable_to_non_nullable
as List<TopService>,activeSubscriptions: null == activeSubscriptions ? _self.activeSubscriptions : activeSubscriptions // ignore: cast_nullable_to_non_nullable
as int,subscriptionMRR: null == subscriptionMRR ? _self.subscriptionMRR : subscriptionMRR // ignore: cast_nullable_to_non_nullable
as int,revenueGrowthPercent: null == revenueGrowthPercent ? _self.revenueGrowthPercent : revenueGrowthPercent // ignore: cast_nullable_to_non_nullable
as double,appointmentGrowthPercent: null == appointmentGrowthPercent ? _self.appointmentGrowthPercent : appointmentGrowthPercent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$StaffPerformance {

 String get staffId; String get staffName; int get appointmentsToday; int get appointmentsWeek; int get completedAppointments; double get revenueGenerated; double get avgRating;
/// Create a copy of StaffPerformance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffPerformanceCopyWith<StaffPerformance> get copyWith => _$StaffPerformanceCopyWithImpl<StaffPerformance>(this as StaffPerformance, _$identity);

  /// Serializes this StaffPerformance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffPerformance&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.appointmentsToday, appointmentsToday) || other.appointmentsToday == appointmentsToday)&&(identical(other.appointmentsWeek, appointmentsWeek) || other.appointmentsWeek == appointmentsWeek)&&(identical(other.completedAppointments, completedAppointments) || other.completedAppointments == completedAppointments)&&(identical(other.revenueGenerated, revenueGenerated) || other.revenueGenerated == revenueGenerated)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,staffId,staffName,appointmentsToday,appointmentsWeek,completedAppointments,revenueGenerated,avgRating);

@override
String toString() {
  return 'StaffPerformance(staffId: $staffId, staffName: $staffName, appointmentsToday: $appointmentsToday, appointmentsWeek: $appointmentsWeek, completedAppointments: $completedAppointments, revenueGenerated: $revenueGenerated, avgRating: $avgRating)';
}


}

/// @nodoc
abstract mixin class $StaffPerformanceCopyWith<$Res>  {
  factory $StaffPerformanceCopyWith(StaffPerformance value, $Res Function(StaffPerformance) _then) = _$StaffPerformanceCopyWithImpl;
@useResult
$Res call({
 String staffId, String staffName, int appointmentsToday, int appointmentsWeek, int completedAppointments, double revenueGenerated, double avgRating
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
@pragma('vm:prefer-inline') @override $Res call({Object? staffId = null,Object? staffName = null,Object? appointmentsToday = null,Object? appointmentsWeek = null,Object? completedAppointments = null,Object? revenueGenerated = null,Object? avgRating = null,}) {
  return _then(_self.copyWith(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,appointmentsToday: null == appointmentsToday ? _self.appointmentsToday : appointmentsToday // ignore: cast_nullable_to_non_nullable
as int,appointmentsWeek: null == appointmentsWeek ? _self.appointmentsWeek : appointmentsWeek // ignore: cast_nullable_to_non_nullable
as int,completedAppointments: null == completedAppointments ? _self.completedAppointments : completedAppointments // ignore: cast_nullable_to_non_nullable
as int,revenueGenerated: null == revenueGenerated ? _self.revenueGenerated : revenueGenerated // ignore: cast_nullable_to_non_nullable
as double,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as double,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String staffId,  String staffName,  int appointmentsToday,  int appointmentsWeek,  int completedAppointments,  double revenueGenerated,  double avgRating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffPerformance() when $default != null:
return $default(_that.staffId,_that.staffName,_that.appointmentsToday,_that.appointmentsWeek,_that.completedAppointments,_that.revenueGenerated,_that.avgRating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String staffId,  String staffName,  int appointmentsToday,  int appointmentsWeek,  int completedAppointments,  double revenueGenerated,  double avgRating)  $default,) {final _that = this;
switch (_that) {
case _StaffPerformance():
return $default(_that.staffId,_that.staffName,_that.appointmentsToday,_that.appointmentsWeek,_that.completedAppointments,_that.revenueGenerated,_that.avgRating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String staffId,  String staffName,  int appointmentsToday,  int appointmentsWeek,  int completedAppointments,  double revenueGenerated,  double avgRating)?  $default,) {final _that = this;
switch (_that) {
case _StaffPerformance() when $default != null:
return $default(_that.staffId,_that.staffName,_that.appointmentsToday,_that.appointmentsWeek,_that.completedAppointments,_that.revenueGenerated,_that.avgRating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffPerformance implements StaffPerformance {
  const _StaffPerformance({required this.staffId, required this.staffName, this.appointmentsToday = 0, this.appointmentsWeek = 0, this.completedAppointments = 0, this.revenueGenerated = 0.0, this.avgRating = 0.0});
  factory _StaffPerformance.fromJson(Map<String, dynamic> json) => _$StaffPerformanceFromJson(json);

@override final  String staffId;
@override final  String staffName;
@override@JsonKey() final  int appointmentsToday;
@override@JsonKey() final  int appointmentsWeek;
@override@JsonKey() final  int completedAppointments;
@override@JsonKey() final  double revenueGenerated;
@override@JsonKey() final  double avgRating;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffPerformance&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.appointmentsToday, appointmentsToday) || other.appointmentsToday == appointmentsToday)&&(identical(other.appointmentsWeek, appointmentsWeek) || other.appointmentsWeek == appointmentsWeek)&&(identical(other.completedAppointments, completedAppointments) || other.completedAppointments == completedAppointments)&&(identical(other.revenueGenerated, revenueGenerated) || other.revenueGenerated == revenueGenerated)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,staffId,staffName,appointmentsToday,appointmentsWeek,completedAppointments,revenueGenerated,avgRating);

@override
String toString() {
  return 'StaffPerformance(staffId: $staffId, staffName: $staffName, appointmentsToday: $appointmentsToday, appointmentsWeek: $appointmentsWeek, completedAppointments: $completedAppointments, revenueGenerated: $revenueGenerated, avgRating: $avgRating)';
}


}

/// @nodoc
abstract mixin class _$StaffPerformanceCopyWith<$Res> implements $StaffPerformanceCopyWith<$Res> {
  factory _$StaffPerformanceCopyWith(_StaffPerformance value, $Res Function(_StaffPerformance) _then) = __$StaffPerformanceCopyWithImpl;
@override @useResult
$Res call({
 String staffId, String staffName, int appointmentsToday, int appointmentsWeek, int completedAppointments, double revenueGenerated, double avgRating
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
@override @pragma('vm:prefer-inline') $Res call({Object? staffId = null,Object? staffName = null,Object? appointmentsToday = null,Object? appointmentsWeek = null,Object? completedAppointments = null,Object? revenueGenerated = null,Object? avgRating = null,}) {
  return _then(_StaffPerformance(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,appointmentsToday: null == appointmentsToday ? _self.appointmentsToday : appointmentsToday // ignore: cast_nullable_to_non_nullable
as int,appointmentsWeek: null == appointmentsWeek ? _self.appointmentsWeek : appointmentsWeek // ignore: cast_nullable_to_non_nullable
as int,completedAppointments: null == completedAppointments ? _self.completedAppointments : completedAppointments // ignore: cast_nullable_to_non_nullable
as int,revenueGenerated: null == revenueGenerated ? _self.revenueGenerated : revenueGenerated // ignore: cast_nullable_to_non_nullable
as double,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TopService {

 String get serviceId; String get serviceName; int get count; double get revenue;
/// Create a copy of TopService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopServiceCopyWith<TopService> get copyWith => _$TopServiceCopyWithImpl<TopService>(this as TopService, _$identity);

  /// Serializes this TopService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopService&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.count, count) || other.count == count)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serviceId,serviceName,count,revenue);

@override
String toString() {
  return 'TopService(serviceId: $serviceId, serviceName: $serviceName, count: $count, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class $TopServiceCopyWith<$Res>  {
  factory $TopServiceCopyWith(TopService value, $Res Function(TopService) _then) = _$TopServiceCopyWithImpl;
@useResult
$Res call({
 String serviceId, String serviceName, int count, double revenue
});




}
/// @nodoc
class _$TopServiceCopyWithImpl<$Res>
    implements $TopServiceCopyWith<$Res> {
  _$TopServiceCopyWithImpl(this._self, this._then);

  final TopService _self;
  final $Res Function(TopService) _then;

/// Create a copy of TopService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serviceId = null,Object? serviceName = null,Object? count = null,Object? revenue = null,}) {
  return _then(_self.copyWith(
serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TopService].
extension TopServicePatterns on TopService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopService value)  $default,){
final _that = this;
switch (_that) {
case _TopService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopService value)?  $default,){
final _that = this;
switch (_that) {
case _TopService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serviceId,  String serviceName,  int count,  double revenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopService() when $default != null:
return $default(_that.serviceId,_that.serviceName,_that.count,_that.revenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serviceId,  String serviceName,  int count,  double revenue)  $default,) {final _that = this;
switch (_that) {
case _TopService():
return $default(_that.serviceId,_that.serviceName,_that.count,_that.revenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serviceId,  String serviceName,  int count,  double revenue)?  $default,) {final _that = this;
switch (_that) {
case _TopService() when $default != null:
return $default(_that.serviceId,_that.serviceName,_that.count,_that.revenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopService implements TopService {
  const _TopService({required this.serviceId, required this.serviceName, this.count = 0, this.revenue = 0.0});
  factory _TopService.fromJson(Map<String, dynamic> json) => _$TopServiceFromJson(json);

@override final  String serviceId;
@override final  String serviceName;
@override@JsonKey() final  int count;
@override@JsonKey() final  double revenue;

/// Create a copy of TopService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopServiceCopyWith<_TopService> get copyWith => __$TopServiceCopyWithImpl<_TopService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopService&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.count, count) || other.count == count)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serviceId,serviceName,count,revenue);

@override
String toString() {
  return 'TopService(serviceId: $serviceId, serviceName: $serviceName, count: $count, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class _$TopServiceCopyWith<$Res> implements $TopServiceCopyWith<$Res> {
  factory _$TopServiceCopyWith(_TopService value, $Res Function(_TopService) _then) = __$TopServiceCopyWithImpl;
@override @useResult
$Res call({
 String serviceId, String serviceName, int count, double revenue
});




}
/// @nodoc
class __$TopServiceCopyWithImpl<$Res>
    implements _$TopServiceCopyWith<$Res> {
  __$TopServiceCopyWithImpl(this._self, this._then);

  final _TopService _self;
  final $Res Function(_TopService) _then;

/// Create a copy of TopService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serviceId = null,Object? serviceName = null,Object? count = null,Object? revenue = null,}) {
  return _then(_TopService(
serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
