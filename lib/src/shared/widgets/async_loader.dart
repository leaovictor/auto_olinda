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
  }) async {
    // Store the navigator before showing dialog
    final navigator = Navigator.of(context, rootNavigator: true);

    // Show the loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/limpando.json',
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

    try {
      // Wait for the future to complete
      final result = await future;
      // Pop the dialog using the stored navigator
      if (navigator.mounted) {
        navigator.pop();
      }
      return result;
    } catch (e) {
      // Always try to close the dialog on error
      if (navigator.mounted) {
        navigator.pop();
      }
      rethrow;
    }
  }
}
