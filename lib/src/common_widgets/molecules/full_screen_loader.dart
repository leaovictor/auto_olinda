import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

/// Full-screen loader overlay for Firebase/async operations
///
/// Uses the limpando.json Lottie animation with blur effect.
/// Use this when loading data from Firebase that blocks the entire screen.
class FullScreenLoader extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final bool showBlur;

  const FullScreenLoader({
    super.key,
    this.message,
    this.backgroundColor,
    this.showBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color:
          backgroundColor ?? theme.colorScheme.surface.withValues(alpha: 0.9),
      child: BackdropFilter(
        filter: showBlur
            ? ImageFilter.blur(sigmaX: 5, sigmaY: 5)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation
              SizedBox(
                width: 180,
                height: 180,
                child: Lottie.asset(
                  'assets/animations/limpando.json',
                  fit: BoxFit.contain,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading overlay that can be shown on top of existing content
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: FullScreenLoader(
              message: message,
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              showBlur: true,
            ).animate().fadeIn(duration: 200.ms),
          ),
      ],
    );
  }
}
