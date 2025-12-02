import 'package:flutter/material.dart';

enum StatusType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = StatusType.neutral,
  });

  Color _getBackgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (type) {
      case StatusType.success:
        return Colors.green.withValues(alpha: 0.1);
      case StatusType.warning:
        return Colors.orange.withValues(alpha: 0.1);
      case StatusType.error:
        return scheme.errorContainer;
      case StatusType.info:
        return scheme.primaryContainer;
      case StatusType.neutral:
        return scheme.surfaceContainerHighest;
    }
  }

  Color _getTextColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (type) {
      case StatusType.success:
        return Colors.green.shade700;
      case StatusType.warning:
        return Colors.orange.shade800;
      case StatusType.error:
        return scheme.onErrorContainer;
      case StatusType.info:
        return scheme.onPrimaryContainer;
      case StatusType.neutral:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getTextColor(context),
        ),
      ),
    );
  }
}
