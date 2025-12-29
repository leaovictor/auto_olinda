// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActiveService {

 String get id; String get plate; String get vehicleModel; ServiceStatus get status;@TimestampConverter() DateTime get startedAt;@NullableTimestampConverter() DateTime? get finishedAt; String get staffId; String get serviceType; List<String> get photos; String get clientLink;
/// Create a copy of ActiveService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActiveServiceCopyWith<ActiveService> get copyWith => _$ActiveServiceCopyWithImpl<ActiveService>(this as ActiveService, _$identity);

  /// Serializes this ActiveService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActiveService&&(identical(other.id, id) || other.id == id)&&(identical(other.plate, plate) || other.plate == plate)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.clientLink, clientLink) || other.clientLink == clientLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,plate,vehicleModel,status,startedAt,finishedAt,staffId,serviceType,const DeepCollectionEquality().hash(photos),clientLink);

@override
String toString() {
  return 'ActiveService(id: $id, plate: $plate, vehicleModel: $vehicleModel, status: $status, startedAt: $startedAt, finishedAt: $finishedAt, staffId: $staffId, serviceType: $serviceType, photos: $photos, clientLink: $clientLink)';
}


}

/// @nodoc
abstract mixin class $ActiveServiceCopyWith<$Res>  {
  factory $ActiveServiceCopyWith(ActiveService value, $Res Function(ActiveService) _then) = _$ActiveServiceCopyWithImpl;
@useResult
$Res call({
 String id, String plate, String vehicleModel, ServiceStatus status,@TimestampConverter() DateTime startedAt,@NullableTimestampConverter() DateTime? finishedAt, String staffId, String serviceType, List<String> photos, String clientLink
});




}
/// @nodoc
class _$ActiveServiceCopyWithImpl<$Res>
    implements $ActiveServiceCopyWith<$Res> {
  _$ActiveServiceCopyWithImpl(this._self, this._then);

  final ActiveService _self;
  final $Res Function(ActiveService) _then;

/// Create a copy of ActiveService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? plate = null,Object? vehicleModel = null,Object? status = null,Object? startedAt = null,Object? finishedAt = freezed,Object? staffId = null,Object? serviceType = null,Object? photos = null,Object? clientLink = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,plate: null == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String,vehicleModel: null == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ServiceStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,clientLink: null == clientLink ? _self.clientLink : clientLink // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ActiveService].
extension ActiveServicePatterns on ActiveService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActiveService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActiveService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActiveService value)  $default,){
final _that = this;
switch (_that) {
case _ActiveService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActiveService value)?  $default,){
final _that = this;
switch (_that) {
case _ActiveService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String plate,  String vehicleModel,  ServiceStatus status, @TimestampConverter()  DateTime startedAt, @NullableTimestampConverter()  DateTime? finishedAt,  String staffId,  String serviceType,  List<String> photos,  String clientLink)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActiveService() when $default != null:
return $default(_that.id,_that.plate,_that.vehicleModel,_that.status,_that.startedAt,_that.finishedAt,_that.staffId,_that.serviceType,_that.photos,_that.clientLink);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String plate,  String vehicleModel,  ServiceStatus status, @TimestampConverter()  DateTime startedAt, @NullableTimestampConverter()  DateTime? finishedAt,  String staffId,  String serviceType,  List<String> photos,  String clientLink)  $default,) {final _that = this;
switch (_that) {
case _ActiveService():
return $default(_that.id,_that.plate,_that.vehicleModel,_that.status,_that.startedAt,_that.finishedAt,_that.staffId,_that.serviceType,_that.photos,_that.clientLink);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String plate,  String vehicleModel,  ServiceStatus status, @TimestampConverter()  DateTime startedAt, @NullableTimestampConverter()  DateTime? finishedAt,  String staffId,  String serviceType,  List<String> photos,  String clientLink)?  $default,) {final _that = this;
switch (_that) {
case _ActiveService() when $default != null:
return $default(_that.id,_that.plate,_that.vehicleModel,_that.status,_that.startedAt,_that.finishedAt,_that.staffId,_that.serviceType,_that.photos,_that.clientLink);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActiveService implements ActiveService {
   _ActiveService({required this.id, this.plate = '', this.vehicleModel = '', this.status = ServiceStatus.fila, @TimestampConverter() required this.startedAt, @NullableTimestampConverter() this.finishedAt, this.staffId = '', this.serviceType = '', final  List<String> photos = const [], this.clientLink = ''}): _photos = photos;
  factory _ActiveService.fromJson(Map<String, dynamic> json) => _$ActiveServiceFromJson(json);

@override final  String id;
@override@JsonKey() final  String plate;
@override@JsonKey() final  String vehicleModel;
@override@JsonKey() final  ServiceStatus status;
@override@TimestampConverter() final  DateTime startedAt;
@override@NullableTimestampConverter() final  DateTime? finishedAt;
@override@JsonKey() final  String staffId;
@override@JsonKey() final  String serviceType;
 final  List<String> _photos;
@override@JsonKey() List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override@JsonKey() final  String clientLink;

/// Create a copy of ActiveService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActiveServiceCopyWith<_ActiveService> get copyWith => __$ActiveServiceCopyWithImpl<_ActiveService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActiveServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActiveService&&(identical(other.id, id) || other.id == id)&&(identical(other.plate, plate) || other.plate == plate)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.clientLink, clientLink) || other.clientLink == clientLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,plate,vehicleModel,status,startedAt,finishedAt,staffId,serviceType,const DeepCollectionEquality().hash(_photos),clientLink);

@override
String toString() {
  return 'ActiveService(id: $id, plate: $plate, vehicleModel: $vehicleModel, status: $status, startedAt: $startedAt, finishedAt: $finishedAt, staffId: $staffId, serviceType: $serviceType, photos: $photos, clientLink: $clientLink)';
}


}

/// @nodoc
abstract mixin class _$ActiveServiceCopyWith<$Res> implements $ActiveServiceCopyWith<$Res> {
  factory _$ActiveServiceCopyWith(_ActiveService value, $Res Function(_ActiveService) _then) = __$ActiveServiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String plate, String vehicleModel, ServiceStatus status,@TimestampConverter() DateTime startedAt,@NullableTimestampConverter() DateTime? finishedAt, String staffId, String serviceType, List<String> photos, String clientLink
});




}
/// @nodoc
class __$ActiveServiceCopyWithImpl<$Res>
    implements _$ActiveServiceCopyWith<$Res> {
  __$ActiveServiceCopyWithImpl(this._self, this._then);

  final _ActiveService _self;
  final $Res Function(_ActiveService) _then;

/// Create a copy of ActiveService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? plate = null,Object? vehicleModel = null,Object? status = null,Object? startedAt = null,Object? finishedAt = freezed,Object? staffId = null,Object? serviceType = null,Object? photos = null,Object? clientLink = null,}) {
  return _then(_ActiveService(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,plate: null == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String,vehicleModel: null == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ServiceStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,clientLink: null == clientLink ? _self.clientLink : clientLink // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
