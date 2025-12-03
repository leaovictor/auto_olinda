import 'package:aquaclean_mobile/src/common_widgets/atoms/app_loader.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: AppLoader(size: 20, color: Colors.white),
            )
          : Icon(icon ?? Icons.arrow_forward, size: icon == null ? 0 : 20),
      label: Text(
        isLoading ? 'Aguarde...' : text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
