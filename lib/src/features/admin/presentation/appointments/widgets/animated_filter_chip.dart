import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? theme.primaryColor;
    final displayLabel = count != null && count! > 0
        ? '$label ($count)'
        : label;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: FilterChip(
        label: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: isSelected ? effectiveActiveColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
          child: Text(displayLabel),
        ),
        selected: isSelected,
        onSelected: onSelected,
        showCheckmark: false,
        backgroundColor: Colors.white,
        selectedColor: effectiveActiveColor.withAlpha(30),
        side: BorderSide(
          color: isSelected
              ? effectiveActiveColor.withAlpha(150)
              : Colors.grey.shade300,
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
                  decoration: BoxDecoration(
                    color: effectiveActiveColor,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
