import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

/// An animated banner that slides down from the top of the screen
/// when a booking status update notification arrives.
class NotificationBanner extends StatelessWidget {
  final String title;
  final String body;
  final String? bookingId;
  final VoidCallback onDismiss;
  final Color? backgroundColor;
  final IconData? icon;

  const NotificationBanner({
    super.key,
    required this.title,
    required this.body,
    this.bookingId,
    required this.onDismiss,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;

    return Material(
          elevation: 8,
          shadowColor: Colors.black26,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon ?? Icons.notifications_active,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            body,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withAlpha(204),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (bookingId != null)
                          IconButton(
                            icon: Icon(
                              Icons.visibility,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () {
                              onDismiss();
                              context.push('/booking/$bookingId');
                            },
                            tooltip: 'Ver detalhes',
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onPrimaryContainer
                                .withAlpha(153),
                          ),
                          onPressed: onDismiss,
                          tooltip: 'Fechar',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .slideY(begin: -1, end: 0, duration: 300.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 200.ms);
  }
}

/// Controller for showing notification banners
class NotificationBannerController {
  static OverlayEntry? _currentBanner;
  static bool _isShowing = false;

  /// Shows a notification banner at the top of the screen
  static void show(
    BuildContext context, {
    required String title,
    required String body,
    String? bookingId,
    Duration duration = const Duration(seconds: 5),
    Color? backgroundColor,
    IconData? icon,
  }) {
    // Don't show if there's already a banner
    if (_isShowing) {
      dismiss();
    }

    final overlay = Overlay.of(context);

    _currentBanner = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: NotificationBanner(
          title: title,
          body: body,
          bookingId: bookingId,
          onDismiss: dismiss,
          backgroundColor: backgroundColor,
          icon: icon,
        ),
      ),
    );

    _isShowing = true;
    overlay.insert(_currentBanner!);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (_isShowing) {
        dismiss();
      }
    });
  }

  /// Dismisses the current notification banner
  static void dismiss() {
    _currentBanner?.remove();
    _currentBanner = null;
    _isShowing = false;
  }
}

/// Helper to get icon based on booking status
IconData getNotificationIcon(String? status) {
  switch (status) {
    case 'checkIn':
      return Icons.login;
    case 'confirmed':
      return Icons.check_circle;
    case 'washing':
      return Icons.water_drop;
    case 'vacuuming':
      return Icons.cleaning_services;
    case 'drying':
      return Icons.air;
    case 'polishing':
      return Icons.auto_awesome;
    case 'finished':
      return Icons.celebration;
    case 'cancelled':
      return Icons.cancel;
    default:
      return Icons.notifications_active;
  }
}

/// Helper to get background color based on booking status
Color getNotificationColor(BuildContext context, String? status) {
  final theme = Theme.of(context);

  switch (status) {
    case 'finished':
      return Colors.green.shade100;
    case 'cancelled':
      return Colors.red.shade100;
    case 'washing':
    case 'vacuuming':
    case 'drying':
    case 'polishing':
      return Colors.blue.shade100;
    default:
      return theme.colorScheme.primaryContainer;
  }
}
