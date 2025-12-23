import 'package:flutter/material.dart';
import '../../theme/admin_theme.dart';

/// An enhanced FilterChip with smooth animations and improved styling
class AnimatedFilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color? activeColor;

  const AnimatedFilterChip({
    super.key,
    required this.label,
    this.count,
    required this.isSelected,
    required this.onSelected,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AdminTheme.gradientPrimary[0];
    final displayLabel = count != null && count! > 0
        ? '$label ($count)'
        : label;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: FilterChip(
        label: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AdminTheme.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AdminTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
          child: Text(displayLabel),
        ),
        selected: isSelected,
        onSelected: onSelected,
        showCheckmark: false,
        backgroundColor: AdminTheme.bgCard.withOpacity(0.6),
        selectedColor: effectiveActiveColor.withOpacity(0.8),
        side: BorderSide(
          color: isSelected ? effectiveActiveColor : AdminTheme.borderLight,
          width: isSelected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        avatar: isSelected
            ? AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
