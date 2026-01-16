import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/admin_theme.dart';

class AdminTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? suffixText;
  final String? prefixText;
  final String? helperText;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final int? maxLength;

  const AdminTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.suffixText,
    this.prefixText,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(color: AdminTheme.textPrimary),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      textCapitalization: textCapitalization,
      cursorColor: AdminTheme.gradientPrimary[0],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(color: AdminTheme.textMuted),
        prefixIcon: icon != null
            ? Icon(icon, color: AdminTheme.textSecondary, size: 20)
            : null,
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: AdminTheme.textSecondary),
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        suffixStyle: const TextStyle(color: AdminTheme.textSecondary),
        helperText: helperText,
        helperStyle: const TextStyle(color: AdminTheme.textSecondary),
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AdminTheme.gradientDanger[0]),
        ),
      ),
    );
  }
}
