// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'independent_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IndependentService _$IndependentServiceFromJson(Map<String, dynamic> json) =>
    _IndependentService(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      iconName: json['iconName'] as String? ?? 'build',
      isActive: json['isActive'] as bool? ?? true,
      requiresVehicle: json['requiresVehicle'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$IndependentServiceToJson(_IndependentService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'durationMinutes': instance.durationMinutes,
      'iconName': instance.iconName,
      'isActive': instance.isActive,
      'requiresVehicle': instance.requiresVehicle,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
