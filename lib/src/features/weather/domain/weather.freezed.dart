// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Weather {

 double get temperature; int get relativeHumidity; bool get isDay; double get precipitation; int get weatherCode;
/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherCopyWith<Weather> get copyWith => _$WeatherCopyWithImpl<Weather>(this as Weather, _$identity);

  /// Serializes this Weather to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Weather&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.relativeHumidity, relativeHumidity) || other.relativeHumidity == relativeHumidity)&&(identical(other.isDay, isDay) || other.isDay == isDay)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,relativeHumidity,isDay,precipitation,weatherCode);

@override
String toString() {
  return 'Weather(temperature: $temperature, relativeHumidity: $relativeHumidity, isDay: $isDay, precipitation: $precipitation, weatherCode: $weatherCode)';
}


}

/// @nodoc
abstract mixin class $WeatherCopyWith<$Res>  {
  factory $WeatherCopyWith(Weather value, $Res Function(Weather) _then) = _$WeatherCopyWithImpl;
@useResult
$Res call({
 double temperature, int relativeHumidity, bool isDay, double precipitation, int weatherCode
});




}
/// @nodoc
class _$WeatherCopyWithImpl<$Res>
    implements $WeatherCopyWith<$Res> {
  _$WeatherCopyWithImpl(this._self, this._then);

  final Weather _self;
  final $Res Function(Weather) _then;

/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? temperature = null,Object? relativeHumidity = null,Object? isDay = null,Object? precipitation = null,Object? weatherCode = null,}) {
  return _then(_self.copyWith(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,relativeHumidity: null == relativeHumidity ? _self.relativeHumidity : relativeHumidity // ignore: cast_nullable_to_non_nullable
as int,isDay: null == isDay ? _self.isDay : isDay // ignore: cast_nullable_to_non_nullable
as bool,precipitation: null == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Weather].
extension WeatherPatterns on Weather {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Weather value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Weather() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Weather value)  $default,){
final _that = this;
switch (_that) {
case _Weather():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Weather value)?  $default,){
final _that = this;
switch (_that) {
case _Weather() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double temperature,  int relativeHumidity,  bool isDay,  double precipitation,  int weatherCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Weather() when $default != null:
return $default(_that.temperature,_that.relativeHumidity,_that.isDay,_that.precipitation,_that.weatherCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double temperature,  int relativeHumidity,  bool isDay,  double precipitation,  int weatherCode)  $default,) {final _that = this;
switch (_that) {
case _Weather():
return $default(_that.temperature,_that.relativeHumidity,_that.isDay,_that.precipitation,_that.weatherCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double temperature,  int relativeHumidity,  bool isDay,  double precipitation,  int weatherCode)?  $default,) {final _that = this;
switch (_that) {
case _Weather() when $default != null:
return $default(_that.temperature,_that.relativeHumidity,_that.isDay,_that.precipitation,_that.weatherCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Weather implements Weather {
  const _Weather({required this.temperature, required this.relativeHumidity, required this.isDay, required this.precipitation, required this.weatherCode});
  factory _Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);

@override final  double temperature;
@override final  int relativeHumidity;
@override final  bool isDay;
@override final  double precipitation;
@override final  int weatherCode;

/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherCopyWith<_Weather> get copyWith => __$WeatherCopyWithImpl<_Weather>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Weather&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.relativeHumidity, relativeHumidity) || other.relativeHumidity == relativeHumidity)&&(identical(other.isDay, isDay) || other.isDay == isDay)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,relativeHumidity,isDay,precipitation,weatherCode);

@override
String toString() {
  return 'Weather(temperature: $temperature, relativeHumidity: $relativeHumidity, isDay: $isDay, precipitation: $precipitation, weatherCode: $weatherCode)';
}


}

/// @nodoc
abstract mixin class _$WeatherCopyWith<$Res> implements $WeatherCopyWith<$Res> {
  factory _$WeatherCopyWith(_Weather value, $Res Function(_Weather) _then) = __$WeatherCopyWithImpl;
@override @useResult
$Res call({
 double temperature, int relativeHumidity, bool isDay, double precipitation, int weatherCode
});




}
/// @nodoc
class __$WeatherCopyWithImpl<$Res>
    implements _$WeatherCopyWith<$Res> {
  __$WeatherCopyWithImpl(this._self, this._then);

  final _Weather _self;
  final $Res Function(_Weather) _then;

/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? temperature = null,Object? relativeHumidity = null,Object? isDay = null,Object? precipitation = null,Object? weatherCode = null,}) {
  return _then(_Weather(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,relativeHumidity: null == relativeHumidity ? _self.relativeHumidity : relativeHumidity // ignore: cast_nullable_to_non_nullable
as int,isDay: null == isDay ? _self.isDay : isDay // ignore: cast_nullable_to_non_nullable
as bool,precipitation: null == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
