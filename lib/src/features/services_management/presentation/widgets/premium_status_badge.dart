import 'package:flutter/material.dart';
import '../constants/history_colors.dart';

/// Premium status badge with soft color palette
/// Used across history screens for consistent status display
class PremiumStatusBadge extends StatelessWidget {
  final String label;
  final String statusKey;

  const PremiumStatusBadge({
    super.key,
    required this.label,
    required this.statusKey,
  });

  @override
  Widget build(BuildContext context) {
    final colors = HistoryStatusColors.getColorsForStatus(statusKey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.foreground,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Extension to easily get status badge from BookingStatus enum
extension BookingStatusBadge on String {
  /// Returns the display label for common booking status strings
  String get displayLabel {
    switch (toLowerCase()) {
      case 'scheduled':
        return 'Agendado';
      case 'confirmed':
        return 'Confirmado';
      case 'checkin':
        return 'Check-in';
      case 'washing':
        return 'Lavando';
      case 'vacuuming':
        return 'Aspirando';
      case 'drying':
        return 'Secando';
      case 'polishing':
        return 'Polindo';
      case 'finished':
        return 'Concluído';
      case 'cancelled':
        return 'Cancelado';
      case 'noshow':
        return 'Não Compareceu';
      case 'inprogress':
        return 'Em Andamento';
      case 'pendingapproval':
        return 'Aguardando';
      case 'rejected':
        return 'Recusado';
      default:
        return this;
    }
  }
}
