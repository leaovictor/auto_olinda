import '../../shared/enums/vehicle_category.dart';
import '../../features/profile/domain/vehicle.dart';

/// Extension methods for Vehicle to work with VehicleCategory
extension VehicleCategoryExtension on Vehicle {
  /// Get the VehicleCategory enum from the vehicle type string
  VehicleCategory get category {
    return VehicleCategory.fromString(type);
  }

  /// Check if this vehicle can accept a specific service type based on pricing
  bool canAcceptService(String serviceType) {
    // All vehicles can accept all services
    // This method is a placeholder for future business logic
    return true;
  }
}

extension VehicleCategoryAssets on VehicleCategory {
  String get assetPath {
    switch (this) {
      case VehicleCategory.hatch:
        return 'assets/images/vehicles/hatch.png';
      case VehicleCategory.sedan:
        return 'assets/images/vehicles/sedan.png';
      case VehicleCategory.suv:
        return 'assets/images/vehicles/suv.png';
      case VehicleCategory.pickup:
        return 'assets/images/vehicles/pickup.png';
      case VehicleCategory.moto:
        return 'assets/images/vehicles/moto.png';
    }
  }
}
