// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_matrix.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PricingMatrix _$PricingMatrixFromJson(Map<String, dynamic> json) =>
    _PricingMatrix(
      prices: (json['prices'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          (e as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
        ),
      ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PricingMatrixToJson(_PricingMatrix instance) =>
    <String, dynamic>{
      'prices': instance.prices,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
