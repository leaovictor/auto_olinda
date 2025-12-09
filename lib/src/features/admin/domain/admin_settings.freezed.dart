// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminSettings {

// Business Hours
 int get openingHour; int get openingMinute; int get closingHour; int get closingMinute;// Booking Settings
 int get bookingSlotDurationMinutes; int get maxBookingsPerSlot; bool get autoConfirmBookings;// Notification Preferences
 bool get pushNotificationsEnabled; bool get emailNotificationsEnabled;// Holidays (list of date strings in yyyy-MM-dd format)
 List<String> get holidays;// Payment Settings
 String get paymentProvider; bool get allowCardPayments; bool get allowPixPayments;
/// Create a copy of AdminSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminSettingsCopyWith<AdminSettings> get copyWith => _$AdminSettingsCopyWithImpl<AdminSettings>(this as AdminSettings, _$identity);

  /// Serializes this AdminSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminSettings&&(identical(other.openingHour, openingHour) || other.openingHour == openingHour)&&(identical(other.openingMinute, openingMinute) || other.openingMinute == openingMinute)&&(identical(other.closingHour, closingHour) || other.closingHour == closingHour)&&(identical(other.closingMinute, closingMinute) || other.closingMinute == closingMinute)&&(identical(other.bookingSlotDurationMinutes, bookingSlotDurationMinutes) || other.bookingSlotDurationMinutes == bookingSlotDurationMinutes)&&(identical(other.maxBookingsPerSlot, maxBookingsPerSlot) || other.maxBookingsPerSlot == maxBookingsPerSlot)&&(identical(other.autoConfirmBookings, autoConfirmBookings) || other.autoConfirmBookings == autoConfirmBookings)&&(identical(other.pushNotificationsEnabled, pushNotificationsEnabled) || other.pushNotificationsEnabled == pushNotificationsEnabled)&&(identical(other.emailNotificationsEnabled, emailNotificationsEnabled) || other.emailNotificationsEnabled == emailNotificationsEnabled)&&const DeepCollectionEquality().equals(other.holidays, holidays)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.allowCardPayments, allowCardPayments) || other.allowCardPayments == allowCardPayments)&&(identical(other.allowPixPayments, allowPixPayments) || other.allowPixPayments == allowPixPayments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,openingHour,openingMinute,closingHour,closingMinute,bookingSlotDurationMinutes,maxBookingsPerSlot,autoConfirmBookings,pushNotificationsEnabled,emailNotificationsEnabled,const DeepCollectionEquality().hash(holidays),paymentProvider,allowCardPayments,allowPixPayments);

@override
String toString() {
  return 'AdminSettings(openingHour: $openingHour, openingMinute: $openingMinute, closingHour: $closingHour, closingMinute: $closingMinute, bookingSlotDurationMinutes: $bookingSlotDurationMinutes, maxBookingsPerSlot: $maxBookingsPerSlot, autoConfirmBookings: $autoConfirmBookings, pushNotificationsEnabled: $pushNotificationsEnabled, emailNotificationsEnabled: $emailNotificationsEnabled, holidays: $holidays, paymentProvider: $paymentProvider, allowCardPayments: $allowCardPayments, allowPixPayments: $allowPixPayments)';
}


}

/// @nodoc
abstract mixin class $AdminSettingsCopyWith<$Res>  {
  factory $AdminSettingsCopyWith(AdminSettings value, $Res Function(AdminSettings) _then) = _$AdminSettingsCopyWithImpl;
@useResult
$Res call({
 int openingHour, int openingMinute, int closingHour, int closingMinute, int bookingSlotDurationMinutes, int maxBookingsPerSlot, bool autoConfirmBookings, bool pushNotificationsEnabled, bool emailNotificationsEnabled, List<String> holidays, String paymentProvider, bool allowCardPayments, bool allowPixPayments
});




}
/// @nodoc
class _$AdminSettingsCopyWithImpl<$Res>
    implements $AdminSettingsCopyWith<$Res> {
  _$AdminSettingsCopyWithImpl(this._self, this._then);

  final AdminSettings _self;
  final $Res Function(AdminSettings) _then;

/// Create a copy of AdminSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? openingHour = null,Object? openingMinute = null,Object? closingHour = null,Object? closingMinute = null,Object? bookingSlotDurationMinutes = null,Object? maxBookingsPerSlot = null,Object? autoConfirmBookings = null,Object? pushNotificationsEnabled = null,Object? emailNotificationsEnabled = null,Object? holidays = null,Object? paymentProvider = null,Object? allowCardPayments = null,Object? allowPixPayments = null,}) {
  return _then(_self.copyWith(
openingHour: null == openingHour ? _self.openingHour : openingHour // ignore: cast_nullable_to_non_nullable
as int,openingMinute: null == openingMinute ? _self.openingMinute : openingMinute // ignore: cast_nullable_to_non_nullable
as int,closingHour: null == closingHour ? _self.closingHour : closingHour // ignore: cast_nullable_to_non_nullable
as int,closingMinute: null == closingMinute ? _self.closingMinute : closingMinute // ignore: cast_nullable_to_non_nullable
as int,bookingSlotDurationMinutes: null == bookingSlotDurationMinutes ? _self.bookingSlotDurationMinutes : bookingSlotDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,maxBookingsPerSlot: null == maxBookingsPerSlot ? _self.maxBookingsPerSlot : maxBookingsPerSlot // ignore: cast_nullable_to_non_nullable
as int,autoConfirmBookings: null == autoConfirmBookings ? _self.autoConfirmBookings : autoConfirmBookings // ignore: cast_nullable_to_non_nullable
as bool,pushNotificationsEnabled: null == pushNotificationsEnabled ? _self.pushNotificationsEnabled : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailNotificationsEnabled: null == emailNotificationsEnabled ? _self.emailNotificationsEnabled : emailNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,holidays: null == holidays ? _self.holidays : holidays // ignore: cast_nullable_to_non_nullable
as List<String>,paymentProvider: null == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String,allowCardPayments: null == allowCardPayments ? _self.allowCardPayments : allowCardPayments // ignore: cast_nullable_to_non_nullable
as bool,allowPixPayments: null == allowPixPayments ? _self.allowPixPayments : allowPixPayments // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminSettings].
extension AdminSettingsPatterns on AdminSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminSettings value)  $default,){
final _that = this;
switch (_that) {
case _AdminSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AdminSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int openingHour,  int openingMinute,  int closingHour,  int closingMinute,  int bookingSlotDurationMinutes,  int maxBookingsPerSlot,  bool autoConfirmBookings,  bool pushNotificationsEnabled,  bool emailNotificationsEnabled,  List<String> holidays,  String paymentProvider,  bool allowCardPayments,  bool allowPixPayments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminSettings() when $default != null:
return $default(_that.openingHour,_that.openingMinute,_that.closingHour,_that.closingMinute,_that.bookingSlotDurationMinutes,_that.maxBookingsPerSlot,_that.autoConfirmBookings,_that.pushNotificationsEnabled,_that.emailNotificationsEnabled,_that.holidays,_that.paymentProvider,_that.allowCardPayments,_that.allowPixPayments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int openingHour,  int openingMinute,  int closingHour,  int closingMinute,  int bookingSlotDurationMinutes,  int maxBookingsPerSlot,  bool autoConfirmBookings,  bool pushNotificationsEnabled,  bool emailNotificationsEnabled,  List<String> holidays,  String paymentProvider,  bool allowCardPayments,  bool allowPixPayments)  $default,) {final _that = this;
switch (_that) {
case _AdminSettings():
return $default(_that.openingHour,_that.openingMinute,_that.closingHour,_that.closingMinute,_that.bookingSlotDurationMinutes,_that.maxBookingsPerSlot,_that.autoConfirmBookings,_that.pushNotificationsEnabled,_that.emailNotificationsEnabled,_that.holidays,_that.paymentProvider,_that.allowCardPayments,_that.allowPixPayments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int openingHour,  int openingMinute,  int closingHour,  int closingMinute,  int bookingSlotDurationMinutes,  int maxBookingsPerSlot,  bool autoConfirmBookings,  bool pushNotificationsEnabled,  bool emailNotificationsEnabled,  List<String> holidays,  String paymentProvider,  bool allowCardPayments,  bool allowPixPayments)?  $default,) {final _that = this;
switch (_that) {
case _AdminSettings() when $default != null:
return $default(_that.openingHour,_that.openingMinute,_that.closingHour,_that.closingMinute,_that.bookingSlotDurationMinutes,_that.maxBookingsPerSlot,_that.autoConfirmBookings,_that.pushNotificationsEnabled,_that.emailNotificationsEnabled,_that.holidays,_that.paymentProvider,_that.allowCardPayments,_that.allowPixPayments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminSettings implements AdminSettings {
  const _AdminSettings({this.openingHour = 8, this.openingMinute = 0, this.closingHour = 18, this.closingMinute = 0, this.bookingSlotDurationMinutes = 60, this.maxBookingsPerSlot = 3, this.autoConfirmBookings = false, this.pushNotificationsEnabled = true, this.emailNotificationsEnabled = true, final  List<String> holidays = const [], this.paymentProvider = 'stripe', this.allowCardPayments = true, this.allowPixPayments = true}): _holidays = holidays;
  factory _AdminSettings.fromJson(Map<String, dynamic> json) => _$AdminSettingsFromJson(json);

// Business Hours
@override@JsonKey() final  int openingHour;
@override@JsonKey() final  int openingMinute;
@override@JsonKey() final  int closingHour;
@override@JsonKey() final  int closingMinute;
// Booking Settings
@override@JsonKey() final  int bookingSlotDurationMinutes;
@override@JsonKey() final  int maxBookingsPerSlot;
@override@JsonKey() final  bool autoConfirmBookings;
// Notification Preferences
@override@JsonKey() final  bool pushNotificationsEnabled;
@override@JsonKey() final  bool emailNotificationsEnabled;
// Holidays (list of date strings in yyyy-MM-dd format)
 final  List<String> _holidays;
// Holidays (list of date strings in yyyy-MM-dd format)
@override@JsonKey() List<String> get holidays {
  if (_holidays is EqualUnmodifiableListView) return _holidays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holidays);
}

// Payment Settings
@override@JsonKey() final  String paymentProvider;
@override@JsonKey() final  bool allowCardPayments;
@override@JsonKey() final  bool allowPixPayments;

/// Create a copy of AdminSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminSettingsCopyWith<_AdminSettings> get copyWith => __$AdminSettingsCopyWithImpl<_AdminSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminSettings&&(identical(other.openingHour, openingHour) || other.openingHour == openingHour)&&(identical(other.openingMinute, openingMinute) || other.openingMinute == openingMinute)&&(identical(other.closingHour, closingHour) || other.closingHour == closingHour)&&(identical(other.closingMinute, closingMinute) || other.closingMinute == closingMinute)&&(identical(other.bookingSlotDurationMinutes, bookingSlotDurationMinutes) || other.bookingSlotDurationMinutes == bookingSlotDurationMinutes)&&(identical(other.maxBookingsPerSlot, maxBookingsPerSlot) || other.maxBookingsPerSlot == maxBookingsPerSlot)&&(identical(other.autoConfirmBookings, autoConfirmBookings) || other.autoConfirmBookings == autoConfirmBookings)&&(identical(other.pushNotificationsEnabled, pushNotificationsEnabled) || other.pushNotificationsEnabled == pushNotificationsEnabled)&&(identical(other.emailNotificationsEnabled, emailNotificationsEnabled) || other.emailNotificationsEnabled == emailNotificationsEnabled)&&const DeepCollectionEquality().equals(other._holidays, _holidays)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.allowCardPayments, allowCardPayments) || other.allowCardPayments == allowCardPayments)&&(identical(other.allowPixPayments, allowPixPayments) || other.allowPixPayments == allowPixPayments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,openingHour,openingMinute,closingHour,closingMinute,bookingSlotDurationMinutes,maxBookingsPerSlot,autoConfirmBookings,pushNotificationsEnabled,emailNotificationsEnabled,const DeepCollectionEquality().hash(_holidays),paymentProvider,allowCardPayments,allowPixPayments);

@override
String toString() {
  return 'AdminSettings(openingHour: $openingHour, openingMinute: $openingMinute, closingHour: $closingHour, closingMinute: $closingMinute, bookingSlotDurationMinutes: $bookingSlotDurationMinutes, maxBookingsPerSlot: $maxBookingsPerSlot, autoConfirmBookings: $autoConfirmBookings, pushNotificationsEnabled: $pushNotificationsEnabled, emailNotificationsEnabled: $emailNotificationsEnabled, holidays: $holidays, paymentProvider: $paymentProvider, allowCardPayments: $allowCardPayments, allowPixPayments: $allowPixPayments)';
}


}

/// @nodoc
abstract mixin class _$AdminSettingsCopyWith<$Res> implements $AdminSettingsCopyWith<$Res> {
  factory _$AdminSettingsCopyWith(_AdminSettings value, $Res Function(_AdminSettings) _then) = __$AdminSettingsCopyWithImpl;
@override @useResult
$Res call({
 int openingHour, int openingMinute, int closingHour, int closingMinute, int bookingSlotDurationMinutes, int maxBookingsPerSlot, bool autoConfirmBookings, bool pushNotificationsEnabled, bool emailNotificationsEnabled, List<String> holidays, String paymentProvider, bool allowCardPayments, bool allowPixPayments
});




}
/// @nodoc
class __$AdminSettingsCopyWithImpl<$Res>
    implements _$AdminSettingsCopyWith<$Res> {
  __$AdminSettingsCopyWithImpl(this._self, this._then);

  final _AdminSettings _self;
  final $Res Function(_AdminSettings) _then;

/// Create a copy of AdminSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? openingHour = null,Object? openingMinute = null,Object? closingHour = null,Object? closingMinute = null,Object? bookingSlotDurationMinutes = null,Object? maxBookingsPerSlot = null,Object? autoConfirmBookings = null,Object? pushNotificationsEnabled = null,Object? emailNotificationsEnabled = null,Object? holidays = null,Object? paymentProvider = null,Object? allowCardPayments = null,Object? allowPixPayments = null,}) {
  return _then(_AdminSettings(
openingHour: null == openingHour ? _self.openingHour : openingHour // ignore: cast_nullable_to_non_nullable
as int,openingMinute: null == openingMinute ? _self.openingMinute : openingMinute // ignore: cast_nullable_to_non_nullable
as int,closingHour: null == closingHour ? _self.closingHour : closingHour // ignore: cast_nullable_to_non_nullable
as int,closingMinute: null == closingMinute ? _self.closingMinute : closingMinute // ignore: cast_nullable_to_non_nullable
as int,bookingSlotDurationMinutes: null == bookingSlotDurationMinutes ? _self.bookingSlotDurationMinutes : bookingSlotDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,maxBookingsPerSlot: null == maxBookingsPerSlot ? _self.maxBookingsPerSlot : maxBookingsPerSlot // ignore: cast_nullable_to_non_nullable
as int,autoConfirmBookings: null == autoConfirmBookings ? _self.autoConfirmBookings : autoConfirmBookings // ignore: cast_nullable_to_non_nullable
as bool,pushNotificationsEnabled: null == pushNotificationsEnabled ? _self.pushNotificationsEnabled : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailNotificationsEnabled: null == emailNotificationsEnabled ? _self.emailNotificationsEnabled : emailNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,holidays: null == holidays ? _self._holidays : holidays // ignore: cast_nullable_to_non_nullable
as List<String>,paymentProvider: null == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String,allowCardPayments: null == allowCardPayments ? _self.allowCardPayments : allowCardPayments // ignore: cast_nullable_to_non_nullable
as bool,allowPixPayments: null == allowPixPayments ? _self.allowPixPayments : allowPixPayments // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
