// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// **************************************************************************
// FreezedGenerator
// **************************************************************************

import 'dart:core';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.freezed.dart';

@_$ServiceCopyWith<Service> get copyWith => throw UnsupportedError('copyWith');
class _$ServiceCopyWith<$Res> {
  factory _$ServiceCopyWith(Service value, $Res Function(Service) then) =
      ___$ServiceCopyWithImpl<$Res, Service>;
  $Res call({
    String id,
    String tenantId,
    String name,
    String? description,
    String? category,
    double price,
    double? discountedPrice,
    int durationMinutes,
    String? imageUrl,
    bool isActive,
    int sortOrder,
    List<String> tags,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class ___$ServiceCopyWithImpl<$Res, $Val extends Service>
    implements _$ServiceCopyWith<$Res> {
  ___$ServiceCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? price = null,
    Object? discountedPrice = freezed,
    Object? durationMinutes = null,
    Object? imageUrl = freezed,
    Object? isActive = null,
    Object? sortOrder = null,
    Object? tags = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      tenantId: null == tenantId ? _value.tenantId : tenantId as String,
      name: null == name ? _value.name : name as String,
      description: freezed == description ? _value.description : description as String?,
      category: freezed == category ? _value.category : category as String?,
      price: null == price ? _value.price : price as double,
      discountedPrice: freezed == discountedPrice ? _value.discountedPrice : discountedPrice as double?,
      durationMinutes: null == durationMinutes ? _value.durationMinutes : durationMinutes as int,
      imageUrl: freezed == imageUrl ? _value.imageUrl : imageUrl as String?,
      isActive: null == isActive ? _value.isActive : isActive as bool,
      sortOrder: null == sortOrder ? _value.sortOrder : sortOrder as int,
      tags: null == tags ? _value.tags : tags as List<String>,
      notes: freezed == notes ? _value.notes : notes as String?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ) as $Res);
  }
}

abstract class _$$ServiceCopyWith<$Res> implements _$ServiceCopyWith<$Res> {
  factory _$$ServiceCopyWith(_Service value, $Res Function(_Service) then) =
      __$$ServiceCopyWithImpl<$Res, _Service>;
  @override
  $Res call({
    String id,
    String tenantId,
    String name,
    String? description,
    String? category,
    double price,
    double? discountedPrice,
    int durationMinutes,
    String? imageUrl,
    bool isActive,
    int sortOrder,
    List<String> tags,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

class __$$ServiceCopyWithImpl<$Res, $Val extends _Service>
    extends ___$ServiceCopyWithImpl<$Res, $Val>
    implements _$$ServiceCopyWith<$Res> {
  __$$ServiceCopyWithImpl(_Service _value, $Res Function(_Service) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? price = null,
    Object? discountedPrice = freezed,
    Object? durationMinutes = null,
    Object? imageUrl = freezed,
    Object? isActive = null,
    Object? sortOrder = null,
    Object? tags = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Service(
      id: null == id ? _value.id : id as String,
      tenantId: null == tenantId ? _value.tenantId : tenantId as String,
      name: null == name ? _value.name : name as String,
      description: freezed == description ? _value.description : description as String?,
      category: freezed == category ? _value.category : category as String?,
      price: null == price ? _value.price : price as double,
      discountedPrice: freezed == discountedPrice ? _value.discountedPrice : discountedPrice as double?,
      durationMinutes: null == durationMinutes ? _value.durationMinutes : durationMinutes as int,
      imageUrl: freezed == imageUrl ? _value.imageUrl : imageUrl as String?,
      isActive: null == isActive ? _value.isActive : isActive as bool,
      sortOrder: null == sortOrder ? _value.sortOrder : sortOrder as int,
      tags: null == tags ? _value.tags : tags as List<String>,
      notes: freezed == notes ? _value.notes : notes as String?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ));
  }
}

@JsonSerializable()
class _Service implements Service {
  const _Service({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.category,
    required this.price,
    this.discountedPrice,
    @Default(30) this.durationMinutes,
    this.imageUrl,
    @Default(true) this.isActive,
    @Default(0) this.sortOrder,
    @Default([]) this.tags,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final double price;
  @override
  final double? discountedPrice;
  @override
  @Default(30)
  final int durationMinutes;
  @override
  final String? imageUrl;
  @override
  @Default(true)
  final bool isActive;
  @override
  @Default(0)
  final int sortOrder;
  @override
  @Default([])
  final List<String> tags;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Service(id: $id, tenantId: $tenantId, name: $name, description: $description, category: $category, price: $price, discountedPrice: $discountedPrice, durationMinutes: $durationMinutes, imageUrl: $imageUrl, isActive: $isActive, sortOrder: $sortOrder, tags: $tags, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Service &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) || other.tenantId == tenantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.discountedPrice, discountedPrice) ||
                other.discountedPrice == discountedPrice) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      name,
      description,
      category,
      price,
      discountedPrice,
      durationMinutes,
      imageUrl,
      isActive,
      sortOrder,
      const DeepCollectionEquality().hash(tags),
      notes,
      createdAt,
      updatedAt);

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
}
