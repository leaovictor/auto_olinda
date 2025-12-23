import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon.freezed.dart';
part 'coupon.g.dart';

/// Represents a discount coupon
@freezed
abstract class Coupon with _$Coupon {
  const factory Coupon({
    required String id,
    required String code,
    required String name,
    String? description,
    required CouponType type,
    required double value,
    required List<CouponApplicableTo> applicableTo,
    @TimestampConverter() DateTime? validFrom,
    @TimestampConverter() DateTime? validUntil,
    int? maxUses,
    @Default(0) int usedCount,
    @Default(true) bool isActive,

    double? minimumPurchase,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Coupon;

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    // Handle Firestore Timestamp
    if (timestamp != null && timestamp.runtimeType.toString() == 'Timestamp') {
      return (timestamp as dynamic).toDate();
    }
    // Handle int (millisecondsSinceEpoch)
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now(); // Fallback
  }

  @override
  dynamic toJson(DateTime date) => date.toIso8601String();
}

/// Type of discount
enum CouponType {
  @JsonValue('percentage')
  percentage, // Porcentagem (ex: 20%)

  @JsonValue('fixed')
  fixed, // Valor fixo (ex: R$ 10)
}

/// What the coupon can be applied to
enum CouponApplicableTo {
  @JsonValue('products')
  products, // Produtos físicos

  @JsonValue('services')
  services, // Serviços pontuais

  @JsonValue('subscriptions')
  subscriptions, // Assinaturas
}

/// Extension for CouponType display
extension CouponTypeExtension on CouponType {
  String get displayName {
    switch (this) {
      case CouponType.percentage:
        return 'Porcentagem';
      case CouponType.fixed:
        return 'Valor Fixo';
    }
  }

  String formatValue(double value) {
    switch (this) {
      case CouponType.percentage:
        return '${value.toStringAsFixed(0)}%';
      case CouponType.fixed:
        return 'R\$ ${value.toStringAsFixed(2)}';
    }
  }
}

/// Extension for CouponApplicableTo display
extension CouponApplicableToExtension on CouponApplicableTo {
  String get displayName {
    switch (this) {
      case CouponApplicableTo.products:
        return 'Produtos';
      case CouponApplicableTo.services:
        return 'Serviços';
      case CouponApplicableTo.subscriptions:
        return 'Assinaturas';
    }
  }

  String get icon {
    switch (this) {
      case CouponApplicableTo.products:
        return '📦';
      case CouponApplicableTo.services:
        return '🔧';
      case CouponApplicableTo.subscriptions:
        return '⭐';
    }
  }
}

/// Extension for Coupon helpers
extension CouponExtension on Coupon {
  /// Check if coupon is currently valid
  bool get isValid {
    if (!isActive) return false;

    final now = DateTime.now();

    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (maxUses != null && usedCount >= maxUses!) return false;

    return true;
  }

  /// Check if coupon can be applied to a specific type
  bool canApplyTo(CouponApplicableTo type) {
    return applicableTo.contains(type);
  }

  /// Calculate discount amount
  double calculateDiscount(double amount) {
    if (!isValid) return 0;
    if (minimumPurchase != null && amount < minimumPurchase!) return 0;

    switch (type) {
      case CouponType.percentage:
        return amount * (value / 100);
      case CouponType.fixed:
        return value > amount ? amount : value;
    }
  }

  /// Get formatted discount
  String get formattedDiscount {
    return type.formatValue(value);
  }
}
