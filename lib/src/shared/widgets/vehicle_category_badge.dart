import 'package:flutter/material.dart';
import '../enums/vehicle_category.dart';

class VehicleCategoryBadge extends StatelessWidget {
  final VehicleCategory category;
  final bool showLabel;
  final double? fontSize;

  const VehicleCategoryBadge({
    super.key,
    required this.category,
    this.showLabel = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(VehicleCategory.getColorValue(category));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForCategory(category),
            size: (fontSize ?? 12) + 2,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: fontSize ?? 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForCategory(VehicleCategory category) {
    switch (category) {
      case VehicleCategory.hatch:
        return Icons.directions_car;
      case VehicleCategory.sedan:
        return Icons
            .airport_shuttle; // Just an example, ideally use custom icons
      case VehicleCategory.suv:
        return Icons.directions_bus; // Placeholder
      case VehicleCategory.pickup:
        return Icons.local_shipping;
      case VehicleCategory.moto:
        return Icons.two_wheeler;
    }
  }
}
