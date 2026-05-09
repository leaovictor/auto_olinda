// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_license.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreLicense {

 String get storeId; String get storeName; String get ownerName; String get ownerEmail; String get ownerPhone;/// 'anual' | 'royalties'
 String get modalidade;/// 'active' | 'expired' | 'suspended' | 'trial'
 String get status;@TimestampConverter() DateTime? get trialEndsAt;@TimestampConverter() DateTime? get licenseStartDate;@TimestampConverter() DateTime? get licenseExpiresAt;// Royalties
 double get royaltiesPercentage;@TimestampConverter() DateTime? get lastRoyaltiesPaymentAt;// Contract
@TimestampConverter() DateTime? get contractSignedAt; double get contractValue;// Metadata
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt; String get notes;
/// Create a copy of StoreLicense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreLicenseCopyWith<StoreLicense> get copyWith => _$StoreLicenseCopyWithImpl<StoreLicense>(this as StoreLicense, _$identity);

  /// Serializes this StoreLicense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreLicense&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.ownerEmail, ownerEmail) || other.ownerEmail == ownerEmail)&&(identical(other.ownerPhone, ownerPhone) || other.ownerPhone == ownerPhone)&&(identical(other.modalidade, modalidade) || other.modalidade == modalidade)&&(identical(other.status, status) || other.status == status)&&(identical(other.trialEndsAt, trialEndsAt) || other.trialEndsAt == trialEndsAt)&&(identical(other.licenseStartDate, licenseStartDate) || other.licenseStartDate == licenseStartDate)&&(identical(other.licenseExpiresAt, licenseExpiresAt) || other.licenseExpiresAt == licenseExpiresAt)&&(identical(other.royaltiesPercentage, royaltiesPercentage) || other.royaltiesPercentage == royaltiesPercentage)&&(identical(other.lastRoyaltiesPaymentAt, lastRoyaltiesPaymentAt) || other.lastRoyaltiesPaymentAt == lastRoyaltiesPaymentAt)&&(identical(other.contractSignedAt, contractSignedAt) || other.contractSignedAt == contractSignedAt)&&(identical(other.contractValue, contractValue) || other.contractValue == contractValue)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,storeId,storeName,ownerName,ownerEmail,ownerPhone,modalidade,status,trialEndsAt,licenseStartDate,licenseExpiresAt,royaltiesPercentage,lastRoyaltiesPaymentAt,contractSignedAt,contractValue,createdAt,updatedAt,notes);

@override
String toString() {
  return 'StoreLicense(storeId: $storeId, storeName: $storeName, ownerName: $ownerName, ownerEmail: $ownerEmail, ownerPhone: $ownerPhone, modalidade: $modalidade, status: $status, trialEndsAt: $trialEndsAt, licenseStartDate: $licenseStartDate, licenseExpiresAt: $licenseExpiresAt, royaltiesPercentage: $royaltiesPercentage, lastRoyaltiesPaymentAt: $lastRoyaltiesPaymentAt, contractSignedAt: $contractSignedAt, contractValue: $contractValue, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $StoreLicenseCopyWith<$Res>  {
  factory $StoreLicenseCopyWith(StoreLicense value, $Res Function(StoreLicense) _then) = _$StoreLicenseCopyWithImpl;
@useResult
$Res call({
 String storeId, String storeName, String ownerName, String ownerEmail, String ownerPhone, String modalidade, String status,@TimestampConverter() DateTime? trialEndsAt,@TimestampConverter() DateTime? licenseStartDate,@TimestampConverter() DateTime? licenseExpiresAt, double royaltiesPercentage,@TimestampConverter() DateTime? lastRoyaltiesPaymentAt,@TimestampConverter() DateTime? contractSignedAt, double contractValue,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, String notes
});




}
/// @nodoc
class _$StoreLicenseCopyWithImpl<$Res>
    implements $StoreLicenseCopyWith<$Res> {
  _$StoreLicenseCopyWithImpl(this._self, this._then);

  final StoreLicense _self;
  final $Res Function(StoreLicense) _then;

/// Create a copy of StoreLicense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? storeId = null,Object? storeName = null,Object? ownerName = null,Object? ownerEmail = null,Object? ownerPhone = null,Object? modalidade = null,Object? status = null,Object? trialEndsAt = freezed,Object? licenseStartDate = freezed,Object? licenseExpiresAt = freezed,Object? royaltiesPercentage = null,Object? lastRoyaltiesPaymentAt = freezed,Object? contractSignedAt = freezed,Object? contractValue = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? notes = null,}) {
  return _then(_self.copyWith(
storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,ownerEmail: null == ownerEmail ? _self.ownerEmail : ownerEmail // ignore: cast_nullable_to_non_nullable
as String,ownerPhone: null == ownerPhone ? _self.ownerPhone : ownerPhone // ignore: cast_nullable_to_non_nullable
as String,modalidade: null == modalidade ? _self.modalidade : modalidade // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,trialEndsAt: freezed == trialEndsAt ? _self.trialEndsAt : trialEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,licenseStartDate: freezed == licenseStartDate ? _self.licenseStartDate : licenseStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,licenseExpiresAt: freezed == licenseExpiresAt ? _self.licenseExpiresAt : licenseExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,royaltiesPercentage: null == royaltiesPercentage ? _self.royaltiesPercentage : royaltiesPercentage // ignore: cast_nullable_to_non_nullable
as double,lastRoyaltiesPaymentAt: freezed == lastRoyaltiesPaymentAt ? _self.lastRoyaltiesPaymentAt : lastRoyaltiesPaymentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contractSignedAt: freezed == contractSignedAt ? _self.contractSignedAt : contractSignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contractValue: null == contractValue ? _self.contractValue : contractValue // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreLicense].
extension StoreLicensePatterns on StoreLicense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreLicense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreLicense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreLicense value)  $default,){
final _that = this;
switch (_that) {
case _StoreLicense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreLicense value)?  $default,){
final _that = this;
switch (_that) {
case _StoreLicense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String storeId,  String storeName,  String ownerName,  String ownerEmail,  String ownerPhone,  String modalidade,  String status, @TimestampConverter()  DateTime? trialEndsAt, @TimestampConverter()  DateTime? licenseStartDate, @TimestampConverter()  DateTime? licenseExpiresAt,  double royaltiesPercentage, @TimestampConverter()  DateTime? lastRoyaltiesPaymentAt, @TimestampConverter()  DateTime? contractSignedAt,  double contractValue, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  String notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreLicense() when $default != null:
return $default(_that.storeId,_that.storeName,_that.ownerName,_that.ownerEmail,_that.ownerPhone,_that.modalidade,_that.status,_that.trialEndsAt,_that.licenseStartDate,_that.licenseExpiresAt,_that.royaltiesPercentage,_that.lastRoyaltiesPaymentAt,_that.contractSignedAt,_that.contractValue,_that.createdAt,_that.updatedAt,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String storeId,  String storeName,  String ownerName,  String ownerEmail,  String ownerPhone,  String modalidade,  String status, @TimestampConverter()  DateTime? trialEndsAt, @TimestampConverter()  DateTime? licenseStartDate, @TimestampConverter()  DateTime? licenseExpiresAt,  double royaltiesPercentage, @TimestampConverter()  DateTime? lastRoyaltiesPaymentAt, @TimestampConverter()  DateTime? contractSignedAt,  double contractValue, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  String notes)  $default,) {final _that = this;
switch (_that) {
case _StoreLicense():
return $default(_that.storeId,_that.storeName,_that.ownerName,_that.ownerEmail,_that.ownerPhone,_that.modalidade,_that.status,_that.trialEndsAt,_that.licenseStartDate,_that.licenseExpiresAt,_that.royaltiesPercentage,_that.lastRoyaltiesPaymentAt,_that.contractSignedAt,_that.contractValue,_that.createdAt,_that.updatedAt,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String storeId,  String storeName,  String ownerName,  String ownerEmail,  String ownerPhone,  String modalidade,  String status, @TimestampConverter()  DateTime? trialEndsAt, @TimestampConverter()  DateTime? licenseStartDate, @TimestampConverter()  DateTime? licenseExpiresAt,  double royaltiesPercentage, @TimestampConverter()  DateTime? lastRoyaltiesPaymentAt, @TimestampConverter()  DateTime? contractSignedAt,  double contractValue, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  String notes)?  $default,) {final _that = this;
switch (_that) {
case _StoreLicense() when $default != null:
return $default(_that.storeId,_that.storeName,_that.ownerName,_that.ownerEmail,_that.ownerPhone,_that.modalidade,_that.status,_that.trialEndsAt,_that.licenseStartDate,_that.licenseExpiresAt,_that.royaltiesPercentage,_that.lastRoyaltiesPaymentAt,_that.contractSignedAt,_that.contractValue,_that.createdAt,_that.updatedAt,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreLicense implements StoreLicense {
  const _StoreLicense({required this.storeId, required this.storeName, this.ownerName = '', this.ownerEmail = '', this.ownerPhone = '', this.modalidade = 'anual', this.status = 'trial', @TimestampConverter() this.trialEndsAt, @TimestampConverter() this.licenseStartDate, @TimestampConverter() this.licenseExpiresAt, this.royaltiesPercentage = 15.0, @TimestampConverter() this.lastRoyaltiesPaymentAt, @TimestampConverter() this.contractSignedAt, this.contractValue = 15000.0, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, this.notes = ''});
  factory _StoreLicense.fromJson(Map<String, dynamic> json) => _$StoreLicenseFromJson(json);

@override final  String storeId;
@override final  String storeName;
@override@JsonKey() final  String ownerName;
@override@JsonKey() final  String ownerEmail;
@override@JsonKey() final  String ownerPhone;
/// 'anual' | 'royalties'
@override@JsonKey() final  String modalidade;
/// 'active' | 'expired' | 'suspended' | 'trial'
@override@JsonKey() final  String status;
@override@TimestampConverter() final  DateTime? trialEndsAt;
@override@TimestampConverter() final  DateTime? licenseStartDate;
@override@TimestampConverter() final  DateTime? licenseExpiresAt;
// Royalties
@override@JsonKey() final  double royaltiesPercentage;
@override@TimestampConverter() final  DateTime? lastRoyaltiesPaymentAt;
// Contract
@override@TimestampConverter() final  DateTime? contractSignedAt;
@override@JsonKey() final  double contractValue;
// Metadata
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey() final  String notes;

/// Create a copy of StoreLicense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreLicenseCopyWith<_StoreLicense> get copyWith => __$StoreLicenseCopyWithImpl<_StoreLicense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreLicenseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreLicense&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.ownerEmail, ownerEmail) || other.ownerEmail == ownerEmail)&&(identical(other.ownerPhone, ownerPhone) || other.ownerPhone == ownerPhone)&&(identical(other.modalidade, modalidade) || other.modalidade == modalidade)&&(identical(other.status, status) || other.status == status)&&(identical(other.trialEndsAt, trialEndsAt) || other.trialEndsAt == trialEndsAt)&&(identical(other.licenseStartDate, licenseStartDate) || other.licenseStartDate == licenseStartDate)&&(identical(other.licenseExpiresAt, licenseExpiresAt) || other.licenseExpiresAt == licenseExpiresAt)&&(identical(other.royaltiesPercentage, royaltiesPercentage) || other.royaltiesPercentage == royaltiesPercentage)&&(identical(other.lastRoyaltiesPaymentAt, lastRoyaltiesPaymentAt) || other.lastRoyaltiesPaymentAt == lastRoyaltiesPaymentAt)&&(identical(other.contractSignedAt, contractSignedAt) || other.contractSignedAt == contractSignedAt)&&(identical(other.contractValue, contractValue) || other.contractValue == contractValue)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,storeId,storeName,ownerName,ownerEmail,ownerPhone,modalidade,status,trialEndsAt,licenseStartDate,licenseExpiresAt,royaltiesPercentage,lastRoyaltiesPaymentAt,contractSignedAt,contractValue,createdAt,updatedAt,notes);

@override
String toString() {
  return 'StoreLicense(storeId: $storeId, storeName: $storeName, ownerName: $ownerName, ownerEmail: $ownerEmail, ownerPhone: $ownerPhone, modalidade: $modalidade, status: $status, trialEndsAt: $trialEndsAt, licenseStartDate: $licenseStartDate, licenseExpiresAt: $licenseExpiresAt, royaltiesPercentage: $royaltiesPercentage, lastRoyaltiesPaymentAt: $lastRoyaltiesPaymentAt, contractSignedAt: $contractSignedAt, contractValue: $contractValue, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$StoreLicenseCopyWith<$Res> implements $StoreLicenseCopyWith<$Res> {
  factory _$StoreLicenseCopyWith(_StoreLicense value, $Res Function(_StoreLicense) _then) = __$StoreLicenseCopyWithImpl;
@override @useResult
$Res call({
 String storeId, String storeName, String ownerName, String ownerEmail, String ownerPhone, String modalidade, String status,@TimestampConverter() DateTime? trialEndsAt,@TimestampConverter() DateTime? licenseStartDate,@TimestampConverter() DateTime? licenseExpiresAt, double royaltiesPercentage,@TimestampConverter() DateTime? lastRoyaltiesPaymentAt,@TimestampConverter() DateTime? contractSignedAt, double contractValue,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, String notes
});




}
/// @nodoc
class __$StoreLicenseCopyWithImpl<$Res>
    implements _$StoreLicenseCopyWith<$Res> {
  __$StoreLicenseCopyWithImpl(this._self, this._then);

  final _StoreLicense _self;
  final $Res Function(_StoreLicense) _then;

/// Create a copy of StoreLicense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? storeId = null,Object? storeName = null,Object? ownerName = null,Object? ownerEmail = null,Object? ownerPhone = null,Object? modalidade = null,Object? status = null,Object? trialEndsAt = freezed,Object? licenseStartDate = freezed,Object? licenseExpiresAt = freezed,Object? royaltiesPercentage = null,Object? lastRoyaltiesPaymentAt = freezed,Object? contractSignedAt = freezed,Object? contractValue = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? notes = null,}) {
  return _then(_StoreLicense(
storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,ownerEmail: null == ownerEmail ? _self.ownerEmail : ownerEmail // ignore: cast_nullable_to_non_nullable
as String,ownerPhone: null == ownerPhone ? _self.ownerPhone : ownerPhone // ignore: cast_nullable_to_non_nullable
as String,modalidade: null == modalidade ? _self.modalidade : modalidade // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,trialEndsAt: freezed == trialEndsAt ? _self.trialEndsAt : trialEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,licenseStartDate: freezed == licenseStartDate ? _self.licenseStartDate : licenseStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,licenseExpiresAt: freezed == licenseExpiresAt ? _self.licenseExpiresAt : licenseExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,royaltiesPercentage: null == royaltiesPercentage ? _self.royaltiesPercentage : royaltiesPercentage // ignore: cast_nullable_to_non_nullable
as double,lastRoyaltiesPaymentAt: freezed == lastRoyaltiesPaymentAt ? _self.lastRoyaltiesPaymentAt : lastRoyaltiesPaymentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contractSignedAt: freezed == contractSignedAt ? _self.contractSignedAt : contractSignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contractValue: null == contractValue ? _self.contractValue : contractValue // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
