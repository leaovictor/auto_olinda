// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewTag _$ReviewTagFromJson(Map<String, dynamic> json) => _ReviewTag(
  id: json['id'] as String,
  label: json['label'] as String,
  emoji: json['emoji'] as String,
  isActive: json['isActive'] as bool? ?? true,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReviewTagToJson(_ReviewTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'emoji': instance.emoji,
      'isActive': instance.isActive,
      'displayOrder': instance.displayOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
