import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoader({super.key, this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Lottie.asset(
        'assets/animations/Loading animation blue.json',
        fit: BoxFit.contain,
        // If the animation supports color delegation, we could use it here.
        // For now, we assume the JSON has the correct colors.
        // If dynamic coloring is needed, we'd use ValueDelegate.
      ),
    );
  }
}
