// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_booking_notification_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NewBookingNotificationData {

 String get bookingId; NewBookingType get type; DateTime get scheduledTime; double get totalPrice; DateTime get createdAt;// Client info
 String? get clientName; String? get clientPhone; String? get clientPhotoUrl; String? get clientId;// Subscription info
 bool get isPremiumSubscriber; String? get subscriptionPlanName;// Client history (for personalized attention)
 int get totalBookings; bool get isNewClient; bool get isReturningAfterLongTime; double get totalSpent;// Total spent by this client
// Vehicle info (for car wash or aesthetic that requires vehicle)
 String? get vehiclePlate; String? get vehicleModel; String? get vehicleBrand;// Service info
 String? get serviceName; List<String> get serviceNames;
/// Create a copy of NewBookingNotificationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewBookingNotificationDataCopyWith<NewBookingNotificationData> get copyWith => _$NewBookingNotificationDataCopyWithImpl<NewBookingNotificationData>(this as NewBookingNotificationData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewBookingNotificationData&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.type, type) || other.type == type)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.clientPhone, clientPhone) || other.clientPhone == clientPhone)&&(identical(other.clientPhotoUrl, clientPhotoUrl) || other.clientPhotoUrl == clientPhotoUrl)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.isPremiumSubscriber, isPremiumSubscriber) || other.isPremiumSubscriber == isPremiumSubscriber)&&(identical(other.subscriptionPlanName, subscriptionPlanName) || other.subscriptionPlanName == subscriptionPlanName)&&(identical(other.totalBookings, totalBookings) || other.totalBookings == totalBookings)&&(identical(other.isNewClient, isNewClient) || other.isNewClient == isNewClient)&&(identical(other.isReturningAfterLongTime, isReturningAfterLongTime) || other.isReturningAfterLongTime == isReturningAfterLongTime)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.vehiclePlate, vehiclePlate) || other.vehiclePlate == vehiclePlate)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.vehicleBrand, vehicleBrand) || other.vehicleBrand == vehicleBrand)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&const DeepCollectionEquality().equals(other.serviceNames, serviceNames));
}


@override
int get hashCode => Object.hashAll([runtimeType,bookingId,type,scheduledTime,totalPrice,createdAt,clientName,clientPhone,clientPhotoUrl,clientId,isPremiumSubscriber,subscriptionPlanName,totalBookings,isNewClient,isReturningAfterLongTime,totalSpent,vehiclePlate,vehicleModel,vehicleBrand,serviceName,const DeepCollectionEquality().hash(serviceNames)]);

@override
String toString() {
  return 'NewBookingNotificationData(bookingId: $bookingId, type: $type, scheduledTime: $scheduledTime, totalPrice: $totalPrice, createdAt: $createdAt, clientName: $clientName, clientPhone: $clientPhone, clientPhotoUrl: $clientPhotoUrl, clientId: $clientId, isPremiumSubscriber: $isPremiumSubscriber, subscriptionPlanName: $subscriptionPlanName, totalBookings: $totalBookings, isNewClient: $isNewClient, isReturningAfterLongTime: $isReturningAfterLongTime, totalSpent: $totalSpent, vehiclePlate: $vehiclePlate, vehicleModel: $vehicleModel, vehicleBrand: $vehicleBrand, serviceName: $serviceName, serviceNames: $serviceNames)';
}


}

/// @nodoc
abstract mixin class $NewBookingNotificationDataCopyWith<$Res>  {
  factory $NewBookingNotificationDataCopyWith(NewBookingNotificationData value, $Res Function(NewBookingNotificationData) _then) = _$NewBookingNotificationDataCopyWithImpl;
@useResult
$Res call({
 String bookingId, NewBookingType type, DateTime scheduledTime, double totalPrice, DateTime createdAt, String? clientName, String? clientPhone, String? clientPhotoUrl, String? clientId, bool isPremiumSubscriber, String? subscriptionPlanName, int totalBookings, bool isNewClient, bool isReturningAfterLongTime, double totalSpent, String? vehiclePlate, String? vehicleModel, String? vehicleBrand, String? serviceName, List<String> serviceNames
});




}
/// @nodoc
class _$NewBookingNotificationDataCopyWithImpl<$Res>
    implements $NewBookingNotificationDataCopyWith<$Res> {
  _$NewBookingNotificationDataCopyWithImpl(this._self, this._then);

  final NewBookingNotificationData _self;
  final $Res Function(NewBookingNotificationData) _then;

/// Create a copy of NewBookingNotificationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? type = null,Object? scheduledTime = null,Object? totalPrice = null,Object? createdAt = null,Object? clientName = freezed,Object? clientPhone = freezed,Object? clientPhotoUrl = freezed,Object? clientId = freezed,Object? isPremiumSubscriber = null,Object? subscriptionPlanName = freezed,Object? totalBookings = null,Object? isNewClient = null,Object? isReturningAfterLongTime = null,Object? totalSpent = null,Object? vehiclePlate = freezed,Object? vehicleModel = freezed,Object? vehicleBrand = freezed,Object? serviceName = freezed,Object? serviceNames = null,}) {
  return _then(_self.copyWith(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NewBookingType,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,clientName: freezed == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String?,clientPhone: freezed == clientPhone ? _self.clientPhone : clientPhone // ignore: cast_nullable_to_non_nullable
as String?,clientPhotoUrl: freezed == clientPhotoUrl ? _self.clientPhotoUrl : clientPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,isPremiumSubscriber: null == isPremiumSubscriber ? _self.isPremiumSubscriber : isPremiumSubscriber // ignore: cast_nullable_to_non_nullable
as bool,subscriptionPlanName: freezed == subscriptionPlanName ? _self.subscriptionPlanName : subscriptionPlanName // ignore: cast_nullable_to_non_nullable
as String?,totalBookings: null == totalBookings ? _self.totalBookings : totalBookings // ignore: cast_nullable_to_non_nullable
as int,isNewClient: null == isNewClient ? _self.isNewClient : isNewClient // ignore: cast_nullable_to_non_nullable
as bool,isReturningAfterLongTime: null == isReturningAfterLongTime ? _self.isReturningAfterLongTime : isReturningAfterLongTime // ignore: cast_nullable_to_non_nullable
as bool,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,vehiclePlate: freezed == vehiclePlate ? _self.vehiclePlate : vehiclePlate // ignore: cast_nullable_to_non_nullable
as String?,vehicleModel: freezed == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String?,vehicleBrand: freezed == vehicleBrand ? _self.vehicleBrand : vehicleBrand // ignore: cast_nullable_to_non_nullable
as String?,serviceName: freezed == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String?,serviceNames: null == serviceNames ? _self.serviceNames : serviceNames // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [NewBookingNotificationData].
extension NewBookingNotificationDataPatterns on NewBookingNotificationData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewBookingNotificationData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewBookingNotificationData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewBookingNotificationData value)  $default,){
final _that = this;
switch (_that) {
case _NewBookingNotificationData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewBookingNotificationData value)?  $default,){
final _that = this;
switch (_that) {
case _NewBookingNotificationData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookingId,  NewBookingType type,  DateTime scheduledTime,  double totalPrice,  DateTime createdAt,  String? clientName,  String? clientPhone,  String? clientPhotoUrl,  String? clientId,  bool isPremiumSubscriber,  String? subscriptionPlanName,  int totalBookings,  bool isNewClient,  bool isReturningAfterLongTime,  double totalSpent,  String? vehiclePlate,  String? vehicleModel,  String? vehicleBrand,  String? serviceName,  List<String> serviceNames)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewBookingNotificationData() when $default != null:
return $default(_that.bookingId,_that.type,_that.scheduledTime,_that.totalPrice,_that.createdAt,_that.clientName,_that.clientPhone,_that.clientPhotoUrl,_that.clientId,_that.isPremiumSubscriber,_that.subscriptionPlanName,_that.totalBookings,_that.isNewClient,_that.isReturningAfterLongTime,_that.totalSpent,_that.vehiclePlate,_that.vehicleModel,_that.vehicleBrand,_that.serviceName,_that.serviceNames);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookingId,  NewBookingType type,  DateTime scheduledTime,  double totalPrice,  DateTime createdAt,  String? clientName,  String? clientPhone,  String? clientPhotoUrl,  String? clientId,  bool isPremiumSubscriber,  String? subscriptionPlanName,  int totalBookings,  bool isNewClient,  bool isReturningAfterLongTime,  double totalSpent,  String? vehiclePlate,  String? vehicleModel,  String? vehicleBrand,  String? serviceName,  List<String> serviceNames)  $default,) {final _that = this;
switch (_that) {
case _NewBookingNotificationData():
return $default(_that.bookingId,_that.type,_that.scheduledTime,_that.totalPrice,_that.createdAt,_that.clientName,_that.clientPhone,_that.clientPhotoUrl,_that.clientId,_that.isPremiumSubscriber,_that.subscriptionPlanName,_that.totalBookings,_that.isNewClient,_that.isReturningAfterLongTime,_that.totalSpent,_that.vehiclePlate,_that.vehicleModel,_that.vehicleBrand,_that.serviceName,_that.serviceNames);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookingId,  NewBookingType type,  DateTime scheduledTime,  double totalPrice,  DateTime createdAt,  String? clientName,  String? clientPhone,  String? clientPhotoUrl,  String? clientId,  bool isPremiumSubscriber,  String? subscriptionPlanName,  int totalBookings,  bool isNewClient,  bool isReturningAfterLongTime,  double totalSpent,  String? vehiclePlate,  String? vehicleModel,  String? vehicleBrand,  String? serviceName,  List<String> serviceNames)?  $default,) {final _that = this;
switch (_that) {
case _NewBookingNotificationData() when $default != null:
return $default(_that.bookingId,_that.type,_that.scheduledTime,_that.totalPrice,_that.createdAt,_that.clientName,_that.clientPhone,_that.clientPhotoUrl,_that.clientId,_that.isPremiumSubscriber,_that.subscriptionPlanName,_that.totalBookings,_that.isNewClient,_that.isReturningAfterLongTime,_that.totalSpent,_that.vehiclePlate,_that.vehicleModel,_that.vehicleBrand,_that.serviceName,_that.serviceNames);case _:
  return null;

}
}

}

/// @nodoc


class _NewBookingNotificationData implements NewBookingNotificationData {
  const _NewBookingNotificationData({required this.bookingId, required this.type, required this.scheduledTime, required this.totalPrice, required this.createdAt, this.clientName, this.clientPhone, this.clientPhotoUrl, this.clientId, this.isPremiumSubscriber = false, this.subscriptionPlanName, this.totalBookings = 0, this.isNewClient = false, this.isReturningAfterLongTime = false, this.totalSpent = 0.0, this.vehiclePlate, this.vehicleModel, this.vehicleBrand, this.serviceName, final  List<String> serviceNames = const []}): _serviceNames = serviceNames;
  

@override final  String bookingId;
@override final  NewBookingType type;
@override final  DateTime scheduledTime;
@override final  double totalPrice;
@override final  DateTime createdAt;
// Client info
@override final  String? clientName;
@override final  String? clientPhone;
@override final  String? clientPhotoUrl;
@override final  String? clientId;
// Subscription info
@override@JsonKey() final  bool isPremiumSubscriber;
@override final  String? subscriptionPlanName;
// Client history (for personalized attention)
@override@JsonKey() final  int totalBookings;
@override@JsonKey() final  bool isNewClient;
@override@JsonKey() final  bool isReturningAfterLongTime;
@override@JsonKey() final  double totalSpent;
// Total spent by this client
// Vehicle info (for car wash or aesthetic that requires vehicle)
@override final  String? vehiclePlate;
@override final  String? vehicleModel;
@override final  String? vehicleBrand;
// Service info
@override final  String? serviceName;
 final  List<String> _serviceNames;
@override@JsonKey() List<String> get serviceNames {
  if (_serviceNames is EqualUnmodifiableListView) return _serviceNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceNames);
}


/// Create a copy of NewBookingNotificationData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewBookingNotificationDataCopyWith<_NewBookingNotificationData> get copyWith => __$NewBookingNotificationDataCopyWithImpl<_NewBookingNotificationData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewBookingNotificationData&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.type, type) || other.type == type)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.clientPhone, clientPhone) || other.clientPhone == clientPhone)&&(identical(other.clientPhotoUrl, clientPhotoUrl) || other.clientPhotoUrl == clientPhotoUrl)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.isPremiumSubscriber, isPremiumSubscriber) || other.isPremiumSubscriber == isPremiumSubscriber)&&(identical(other.subscriptionPlanName, subscriptionPlanName) || other.subscriptionPlanName == subscriptionPlanName)&&(identical(other.totalBookings, totalBookings) || other.totalBookings == totalBookings)&&(identical(other.isNewClient, isNewClient) || other.isNewClient == isNewClient)&&(identical(other.isReturningAfterLongTime, isReturningAfterLongTime) || other.isReturningAfterLongTime == isReturningAfterLongTime)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.vehiclePlate, vehiclePlate) || other.vehiclePlate == vehiclePlate)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.vehicleBrand, vehicleBrand) || other.vehicleBrand == vehicleBrand)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&const DeepCollectionEquality().equals(other._serviceNames, _serviceNames));
}


@override
int get hashCode => Object.hashAll([runtimeType,bookingId,type,scheduledTime,totalPrice,createdAt,clientName,clientPhone,clientPhotoUrl,clientId,isPremiumSubscriber,subscriptionPlanName,totalBookings,isNewClient,isReturningAfterLongTime,totalSpent,vehiclePlate,vehicleModel,vehicleBrand,serviceName,const DeepCollectionEquality().hash(_serviceNames)]);

@override
String toString() {
  return 'NewBookingNotificationData(bookingId: $bookingId, type: $type, scheduledTime: $scheduledTime, totalPrice: $totalPrice, createdAt: $createdAt, clientName: $clientName, clientPhone: $clientPhone, clientPhotoUrl: $clientPhotoUrl, clientId: $clientId, isPremiumSubscriber: $isPremiumSubscriber, subscriptionPlanName: $subscriptionPlanName, totalBookings: $totalBookings, isNewClient: $isNewClient, isReturningAfterLongTime: $isReturningAfterLongTime, totalSpent: $totalSpent, vehiclePlate: $vehiclePlate, vehicleModel: $vehicleModel, vehicleBrand: $vehicleBrand, serviceName: $serviceName, serviceNames: $serviceNames)';
}


}

/// @nodoc
abstract mixin class _$NewBookingNotificationDataCopyWith<$Res> implements $NewBookingNotificationDataCopyWith<$Res> {
  factory _$NewBookingNotificationDataCopyWith(_NewBookingNotificationData value, $Res Function(_NewBookingNotificationData) _then) = __$NewBookingNotificationDataCopyWithImpl;
@override @useResult
$Res call({
 String bookingId, NewBookingType type, DateTime scheduledTime, double totalPrice, DateTime createdAt, String? clientName, String? clientPhone, String? clientPhotoUrl, String? clientId, bool isPremiumSubscriber, String? subscriptionPlanName, int totalBookings, bool isNewClient, bool isReturningAfterLongTime, double totalSpent, String? vehiclePlate, String? vehicleModel, String? vehicleBrand, String? serviceName, List<String> serviceNames
});




}
/// @nodoc
class __$NewBookingNotificationDataCopyWithImpl<$Res>
    implements _$NewBookingNotificationDataCopyWith<$Res> {
  __$NewBookingNotificationDataCopyWithImpl(this._self, this._then);

  final _NewBookingNotificationData _self;
  final $Res Function(_NewBookingNotificationData) _then;

/// Create a copy of NewBookingNotificationData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? type = null,Object? scheduledTime = null,Object? totalPrice = null,Object? createdAt = null,Object? clientName = freezed,Object? clientPhone = freezed,Object? clientPhotoUrl = freezed,Object? clientId = freezed,Object? isPremiumSubscriber = null,Object? subscriptionPlanName = freezed,Object? totalBookings = null,Object? isNewClient = null,Object? isReturningAfterLongTime = null,Object? totalSpent = null,Object? vehiclePlate = freezed,Object? vehicleModel = freezed,Object? vehicleBrand = freezed,Object? serviceName = freezed,Object? serviceNames = null,}) {
  return _then(_NewBookingNotificationData(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NewBookingType,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,clientName: freezed == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String?,clientPhone: freezed == clientPhone ? _self.clientPhone : clientPhone // ignore: cast_nullable_to_non_nullable
as String?,clientPhotoUrl: freezed == clientPhotoUrl ? _self.clientPhotoUrl : clientPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,isPremiumSubscriber: null == isPremiumSubscriber ? _self.isPremiumSubscriber : isPremiumSubscriber // ignore: cast_nullable_to_non_nullable
as bool,subscriptionPlanName: freezed == subscriptionPlanName ? _self.subscriptionPlanName : subscriptionPlanName // ignore: cast_nullable_to_non_nullable
as String?,totalBookings: null == totalBookings ? _self.totalBookings : totalBookings // ignore: cast_nullable_to_non_nullable
as int,isNewClient: null == isNewClient ? _self.isNewClient : isNewClient // ignore: cast_nullable_to_non_nullable
as bool,isReturningAfterLongTime: null == isReturningAfterLongTime ? _self.isReturningAfterLongTime : isReturningAfterLongTime // ignore: cast_nullable_to_non_nullable
as bool,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,vehiclePlate: freezed == vehiclePlate ? _self.vehiclePlate : vehiclePlate // ignore: cast_nullable_to_non_nullable
as String?,vehicleModel: freezed == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String?,vehicleBrand: freezed == vehicleBrand ? _self.vehicleBrand : vehicleBrand // ignore: cast_nullable_to_non_nullable
as String?,serviceName: freezed == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String?,serviceNames: null == serviceNames ? _self._serviceNames : serviceNames // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
