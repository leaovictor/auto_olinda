/// Enum representing vehicle categories for pricing purposes
enum VehicleCategory {
  /// Hatchback vehicles - smallest category
  hatch('Hatch', 'hatch'),

  /// Sedan vehicles - medium category
  sedan('Sedan', 'sedan'),

  /// SUV vehicles - large category
  suv('SUV', 'suv'),

  /// Pickup trucks - largest category
  pickup('Pickup', 'pickup');

  const VehicleCategory(this.displayName, this.value);

  /// Display name for UI
  final String displayName;

  /// Value used for storage and comparison
  final String value;

  /// Convert from string value to enum
  static VehicleCategory fromString(String value) {
    return VehicleCategory.values.firstWhere(
      (cat) => cat.value == value.toLowerCase(),
      orElse: () => VehicleCategory.sedan,
    );
  }

  /// Get color for UI display based on category
  static int getColorValue(VehicleCategory category) {
    switch (category) {
      case VehicleCategory.hatch:
        return 0xFF2196F3; // Blue
      case VehicleCategory.sedan:
        return 0xFF9C27B0; // Purple
      case VehicleCategory.suv:
        return 0xFFFF9800; // Orange
      case VehicleCategory.pickup:
        return 0xFFF44336; // Red
    }
  }
}
