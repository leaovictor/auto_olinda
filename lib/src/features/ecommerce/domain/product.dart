import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// A product available for individual purchase (add-ons, extras)
/// These can be purchased by both subscribers and non-subscribers
@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String companyId,
    required String name,
    required String description,
    required double price,
    @Default(true) bool isActive,
    @Default(false) bool isFeatured,
    String? imageUrl,
    String? category, // e.g., 'cera', 'perfume', 'acessorio'
    String? stripePriceId,
    @TimestampOrNullConverter() DateTime? createdAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

class TimestampOrNullConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampOrNullConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) => object?.toIso8601String();
}
