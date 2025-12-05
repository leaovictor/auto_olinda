import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Service for showing toast notifications throughout the app.
/// Replaces SnackBars for non-confirmation messages.
class AppToast {
  AppToast._();

  static void success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      autoCloseDuration: duration,
      alignment: Alignment.bottomCenter,
      primaryColor: Colors.green,
      borderRadius: BorderRadius.circular(12),
      boxShadow: lowModeShadow,
      showProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      autoCloseDuration: duration,
      alignment: Alignment.bottomCenter,
      primaryColor: Colors.red,
      borderRadius: BorderRadius.circular(12),
      boxShadow: lowModeShadow,
      showProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      autoCloseDuration: duration,
      alignment: Alignment.bottomCenter,
      primaryColor: Colors.orange,
      borderRadius: BorderRadius.circular(12),
      boxShadow: lowModeShadow,
      showProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      autoCloseDuration: duration,
      alignment: Alignment.bottomCenter,
      primaryColor: Colors.blue,
      borderRadius: BorderRadius.circular(12),
      boxShadow: lowModeShadow,
      showProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
    );
  }

  /// Dismiss all visible toasts
  static void dismissAll() {
    toastification.dismissAll();
  }
}
