import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AsyncLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? statusMessage;

  const AsyncLoader({
    super.key,
    required this.isLoading,
    required this.child,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/Cleaning.json',
                    width: 200,
                    height: 200,
                  ),
                  if (statusMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      statusMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Static method to show a dialog with the loader
  static Future<T> show<T>(
    BuildContext context, {
    required Future<T> future,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/Cleaning.json',
                width: 200,
                height: 200,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return future.whenComplete(() {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
