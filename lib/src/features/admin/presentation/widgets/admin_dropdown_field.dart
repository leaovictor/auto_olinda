import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class AdminDropdownField<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? icon;

  const AdminDropdownField({
    super.key,
    this.label,
    this.hint,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      dropdownColor: AdminTheme.bgCard,
      style: const TextStyle(color: AdminTheme.textPrimary),
      iconEnabledColor: AdminTheme.textSecondary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(color: AdminTheme.textMuted),
        prefixIcon: icon != null
            ? Icon(icon, color: AdminTheme.textSecondary, size: 20)
            : null,
        filled: true,
        fillColor: AdminTheme.bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminTheme.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminTheme.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AdminTheme.gradientPrimary[0]),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AdminTheme.gradientDanger[0]),
        ),
      ),
    );
  }
}
