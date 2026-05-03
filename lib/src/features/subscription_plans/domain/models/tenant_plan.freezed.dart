// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TenantPlan {

 String get id; String get tenantId; String get name; String? get description; double get price; String? get currency;// 'brl', 'usd'
 int get washesIncluded;// Number of washes per period
 String get period;// 'weekly' | 'biweekly' | 'monthly' | 'yearly'
 bool get rollover;// Carry over unused washes?
 int get rolloverLimit;// Max rollover washes
 int get minContractMonths;// Minimum commitment
 bool get autoRenew; bool get isActive; int get sortOrder; List<String>? get includedServiceIds;// Which services count
 DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of TenantPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantPlanCopyWith<TenantPlan> get copyWith => _$TenantPlanCopyWithImpl<TenantPlan>(this as TenantPlan, _$identity);

  /// Serializes this TenantPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.washesIncluded, washesIncluded) || other.washesIncluded == washesIncluded)&&(identical(other.period, period) || other.period == period)&&(identical(other.rollover, rollover) || other.rollover == rollover)&&(identical(other.rolloverLimit, rolloverLimit) || other.rolloverLimit == rolloverLimit)&&(identical(other.minContractMonths, minContractMonths) || other.minContractMonths == minContractMonths)&&(identical(other.autoRenew, autoRenew) || other.autoRenew == autoRenew)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other.includedServiceIds, includedServiceIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,name,description,price,currency,washesIncluded,period,rollover,rolloverLimit,minContractMonths,autoRenew,isActive,sortOrder,const DeepCollectionEquality().hash(includedServiceIds),createdAt,updatedAt);

@override
String toString() {
  return 'TenantPlan(id: $id, tenantId: $tenantId, name: $name, description: $description, price: $price, currency: $currency, washesIncluded: $washesIncluded, period: $period, rollover: $rollover, rolloverLimit: $rolloverLimit, minContractMonths: $minContractMonths, autoRenew: $autoRenew, isActive: $isActive, sortOrder: $sortOrder, includedServiceIds: $includedServiceIds, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TenantPlanCopyWith<$Res>  {
  factory $TenantPlanCopyWith(TenantPlan value, $Res Function(TenantPlan) _then) = _$TenantPlanCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String name, String? description, double price, String? currency, int washesIncluded, String period, bool rollover, int rolloverLimit, int minContractMonths, bool autoRenew, bool isActive, int sortOrder, List<String>? includedServiceIds, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$TenantPlanCopyWithImpl<$Res>
    implements $TenantPlanCopyWith<$Res> {
  _$TenantPlanCopyWithImpl(this._self, this._then);

  final TenantPlan _self;
  final $Res Function(TenantPlan) _then;

/// Create a copy of TenantPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? name = null,Object? description = freezed,Object? price = null,Object? currency = freezed,Object? washesIncluded = null,Object? period = null,Object? rollover = null,Object? rolloverLimit = null,Object? minContractMonths = null,Object? autoRenew = null,Object? isActive = null,Object? sortOrder = null,Object? includedServiceIds = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,washesIncluded: null == washesIncluded ? _self.washesIncluded : washesIncluded // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,rollover: null == rollover ? _self.rollover : rollover // ignore: cast_nullable_to_non_nullable
as bool,rolloverLimit: null == rolloverLimit ? _self.rolloverLimit : rolloverLimit // ignore: cast_nullable_to_non_nullable
as int,minContractMonths: null == minContractMonths ? _self.minContractMonths : minContractMonths // ignore: cast_nullable_to_non_nullable
as int,autoRenew: null == autoRenew ? _self.autoRenew : autoRenew // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,includedServiceIds: freezed == includedServiceIds ? _self.includedServiceIds : includedServiceIds // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantPlan].
extension TenantPlanPatterns on TenantPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantPlan value)  $default,){
final _that = this;
switch (_that) {
case _TenantPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantPlan value)?  $default,){
final _that = this;
switch (_that) {
case _TenantPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String name,  String? description,  double price,  String? currency,  int washesIncluded,  String period,  bool rollover,  int rolloverLimit,  int minContractMonths,  bool autoRenew,  bool isActive,  int sortOrder,  List<String>? includedServiceIds,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantPlan() when $default != null:
return $default(_that.id,_that.tenantId,_that.name,_that.description,_that.price,_that.currency,_that.washesIncluded,_that.period,_that.rollover,_that.rolloverLimit,_that.minContractMonths,_that.autoRenew,_that.isActive,_that.sortOrder,_that.includedServiceIds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String name,  String? description,  double price,  String? currency,  int washesIncluded,  String period,  bool rollover,  int rolloverLimit,  int minContractMonths,  bool autoRenew,  bool isActive,  int sortOrder,  List<String>? includedServiceIds,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TenantPlan():
return $default(_that.id,_that.tenantId,_that.name,_that.description,_that.price,_that.currency,_that.washesIncluded,_that.period,_that.rollover,_that.rolloverLimit,_that.minContractMonths,_that.autoRenew,_that.isActive,_that.sortOrder,_that.includedServiceIds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String name,  String? description,  double price,  String? currency,  int washesIncluded,  String period,  bool rollover,  int rolloverLimit,  int minContractMonths,  bool autoRenew,  bool isActive,  int sortOrder,  List<String>? includedServiceIds,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TenantPlan() when $default != null:
return $default(_that.id,_that.tenantId,_that.name,_that.description,_that.price,_that.currency,_that.washesIncluded,_that.period,_that.rollover,_that.rolloverLimit,_that.minContractMonths,_that.autoRenew,_that.isActive,_that.sortOrder,_that.includedServiceIds,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantPlan implements TenantPlan {
  const _TenantPlan({required this.id, required this.tenantId, required this.name, this.description, required this.price, this.currency, required this.washesIncluded, required this.period, this.rollover = false, this.rolloverLimit = 0, this.minContractMonths = 0, this.autoRenew = true, this.isActive = true, this.sortOrder = 0, final  List<String>? includedServiceIds, this.createdAt, this.updatedAt}): _includedServiceIds = includedServiceIds;
  factory _TenantPlan.fromJson(Map<String, dynamic> json) => _$TenantPlanFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String name;
@override final  String? description;
@override final  double price;
@override final  String? currency;
// 'brl', 'usd'
@override final  int washesIncluded;
// Number of washes per period
@override final  String period;
// 'weekly' | 'biweekly' | 'monthly' | 'yearly'
@override@JsonKey() final  bool rollover;
// Carry over unused washes?
@override@JsonKey() final  int rolloverLimit;
// Max rollover washes
@override@JsonKey() final  int minContractMonths;
// Minimum commitment
@override@JsonKey() final  bool autoRenew;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int sortOrder;
 final  List<String>? _includedServiceIds;
@override List<String>? get includedServiceIds {
  final value = _includedServiceIds;
  if (value == null) return null;
  if (_includedServiceIds is EqualUnmodifiableListView) return _includedServiceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Which services count
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of TenantPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantPlanCopyWith<_TenantPlan> get copyWith => __$TenantPlanCopyWithImpl<_TenantPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.washesIncluded, washesIncluded) || other.washesIncluded == washesIncluded)&&(identical(other.period, period) || other.period == period)&&(identical(other.rollover, rollover) || other.rollover == rollover)&&(identical(other.rolloverLimit, rolloverLimit) || other.rolloverLimit == rolloverLimit)&&(identical(other.minContractMonths, minContractMonths) || other.minContractMonths == minContractMonths)&&(identical(other.autoRenew, autoRenew) || other.autoRenew == autoRenew)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other._includedServiceIds, _includedServiceIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,name,description,price,currency,washesIncluded,period,rollover,rolloverLimit,minContractMonths,autoRenew,isActive,sortOrder,const DeepCollectionEquality().hash(_includedServiceIds),createdAt,updatedAt);

@override
String toString() {
  return 'TenantPlan(id: $id, tenantId: $tenantId, name: $name, description: $description, price: $price, currency: $currency, washesIncluded: $washesIncluded, period: $period, rollover: $rollover, rolloverLimit: $rolloverLimit, minContractMonths: $minContractMonths, autoRenew: $autoRenew, isActive: $isActive, sortOrder: $sortOrder, includedServiceIds: $includedServiceIds, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TenantPlanCopyWith<$Res> implements $TenantPlanCopyWith<$Res> {
  factory _$TenantPlanCopyWith(_TenantPlan value, $Res Function(_TenantPlan) _then) = __$TenantPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String name, String? description, double price, String? currency, int washesIncluded, String period, bool rollover, int rolloverLimit, int minContractMonths, bool autoRenew, bool isActive, int sortOrder, List<String>? includedServiceIds, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$TenantPlanCopyWithImpl<$Res>
    implements _$TenantPlanCopyWith<$Res> {
  __$TenantPlanCopyWithImpl(this._self, this._then);

  final _TenantPlan _self;
  final $Res Function(_TenantPlan) _then;

/// Create a copy of TenantPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? name = null,Object? description = freezed,Object? price = null,Object? currency = freezed,Object? washesIncluded = null,Object? period = null,Object? rollover = null,Object? rolloverLimit = null,Object? minContractMonths = null,Object? autoRenew = null,Object? isActive = null,Object? sortOrder = null,Object? includedServiceIds = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_TenantPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,washesIncluded: null == washesIncluded ? _self.washesIncluded : washesIncluded // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,rollover: null == rollover ? _self.rollover : rollover // ignore: cast_nullable_to_non_nullable
as bool,rolloverLimit: null == rolloverLimit ? _self.rolloverLimit : rolloverLimit // ignore: cast_nullable_to_non_nullable
as int,minContractMonths: null == minContractMonths ? _self.minContractMonths : minContractMonths // ignore: cast_nullable_to_non_nullable
as int,autoRenew: null == autoRenew ? _self.autoRenew : autoRenew // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,includedServiceIds: freezed == includedServiceIds ? _self._includedServiceIds : includedServiceIds // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
