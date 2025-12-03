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
        delegates: LottieDelegates(
          values: [
            if (color != null) ValueDelegate.color(const ['**'], value: color!),
          ],
        ),
      ),
    );
  }
}
