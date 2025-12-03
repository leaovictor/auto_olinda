import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Represents a physical product available for purchase
@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    required ProductCategory category,
    @Default(true) bool isActive,
    @Default(0) int stock,
    String? stripeProductId,
    String? stripePriceId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

/// Categories for products
enum ProductCategory {
  @JsonValue('car_care')
  carCare, // Produtos de cuidado automotivo

  @JsonValue('accessories')
  accessories, // Acessórios

  @JsonValue('cleaning')
  cleaning, // Produtos de limpeza

  @JsonValue('other')
  other,
}

/// Extension for ProductCategory display names
extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.carCare:
        return 'Cuidado Automotivo';
      case ProductCategory.accessories:
        return 'Acessórios';
      case ProductCategory.cleaning:
        return 'Produtos de Limpeza';
      case ProductCategory.other:
        return 'Outros';
    }
  }

  String get icon {
    switch (this) {
      case ProductCategory.carCare:
        return '🚗';
      case ProductCategory.accessories:
        return '🔧';
      case ProductCategory.cleaning:
        return '🧼';
      case ProductCategory.other:
        return '📦';
    }
  }
}
