import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../shared/enums/vehicle_category.dart';

part 'pricing_matrix.freezed.dart';
part 'pricing_matrix.g.dart';

/// Represents the pricing matrix for all service types across vehicle categories
@freezed
abstract class PricingMatrix with _$PricingMatrix {
  const factory PricingMatrix({
    /// Prices mapped by vehicle category and service type
    /// Structure: { VehicleCategory: { serviceType: price } }
    required Map<String, Map<String, double>> prices,

    /// Last update timestamp
    required DateTime updatedAt,
  }) = _PricingMatrix;

  factory PricingMatrix.fromJson(Map<String, dynamic> json) =>
      _$PricingMatrixFromJson(json);
}

extension PricingMatrixExtensions on PricingMatrix {
  /// Get price for a specific vehicle category and service type
  double? getPriceForService(VehicleCategory category, String serviceType) {
    return prices[category.value]?[serviceType];
  }

  /// Get all prices for a specific vehicle category
  Map<String, double> getPricesForCategory(VehicleCategory category) {
    return prices[category.value] ?? {};
  }

  /// Get all available service types
  List<String> getAvailableServiceTypes() {
    if (prices.isEmpty) return [];
    return prices.values.first.keys.toList();
  }
}
