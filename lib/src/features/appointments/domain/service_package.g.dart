// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServicePackage _$ServicePackageFromJson(Map<String, dynamic> json) =>
    _ServicePackage(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      stripePriceId: json['stripePriceId'] as String?,
      iconUrl: json['iconUrl'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      category: json['category'] as String? ?? 'general',
      steps:
          (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$ServicePackageToJson(_ServicePackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'durationMinutes': instance.durationMinutes,
      'stripePriceId': instance.stripePriceId,
      'iconUrl': instance.iconUrl,
      'isPopular': instance.isPopular,
      'category': instance.category,
      'steps': instance.steps,
    };
