import 'package:flutter/material.dart';

/// Result of cancellation dialog analysis
class CancellationWarningResult {
  final String title;
  final String content;
  final Color contentColor;
  final bool isStrikeRisk;
  final bool isPenalty;

  const CancellationWarningResult({
    required this.title,
    required this.content,
    required this.contentColor,
    required this.isStrikeRisk,
    required this.isPenalty,
  });
}

/// Helper class to calculate cancellation warnings based on time remaining
///
/// Rules from backend (booking.ts):
/// - > 12h: Safe cancellation, credit refunded
/// - 4h - 12h: Late cancellation, credit consumed
/// - 2h - 4h: Critical cancellation, credit consumed + warning
/// - < 2h: Immediate cancellation, credit consumed + STRIKE (24h block)
class CancellationWarningHelper {
  /// Calculate the appropriate warning based on scheduled time
  static CancellationWarningResult getWarning(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    final hoursFloat = difference.inMinutes / 60.0;

    // Already past (shouldn't happen for active bookings usually)
    if (difference.isNegative) {
      return CancellationWarningResult(
        title: 'Agendamento Vencido',
        content: 'Este agendamento já passou do horário.',
        contentColor: Colors.grey[800]!,
        isStrikeRisk: false,
        isPenalty: true,
      );
    }

    // RULE 1: Safe (> 12h)
    if (hoursFloat >= 12) {
      return CancellationWarningResult(
        title: 'Cancelar Agendamento?',
        content:
            'Faltam mais de 12 horas. Cancelamento seguro.\n'
            'Seu crédito será devolvido integralmente.',
        contentColor: Colors.grey[800]!,
        isStrikeRisk: false,
        isPenalty: false,
      );
    }

    // RULE 2: Warning (< 12h but >= 4h)
    if (hoursFloat >= 4) {
      return CancellationWarningResult(
        title: 'Atenção: Cancelamento Tardio',
        content:
            'Faltam menos de 12 horas para o agendamento.\n\n'
            'Seu crédito de lavagem será CONSUMIDO mesmo com o cancelamento.\n\n'
            'Deseja continuar?',
        contentColor: Colors.orange[800]!,
        isStrikeRisk: false,
        isPenalty: true,
      );
    }

    // RULE 3: Critical (< 4h but >= 2h)
    if (hoursFloat >= 2) {
      return CancellationWarningResult(
        title: 'Cancelamento Crítico!',
        content:
            'Faltam menos de 4 horas!\n\n'
            'Seu crédito será consumido e uma reincidência poderá gerar '
            'BLOQUEIO temporário da sua conta.\n\n'
            'Deseja realmente cancelar?',
        contentColor: Colors.red[700]!,
        isStrikeRisk: false,
        isPenalty: true,
      );
    }

    // RULE 4: Immediate / Strike (< 2h)
    return CancellationWarningResult(
      title: 'RISCO DE STRIKE 🚫',
      content:
          'Faltam menos de 2 horas!\n\n'
          'Se você cancelar agora:\n'
          '1. Seu crédito será consumido.\n'
          '2. Sua conta receberá um STRIKE (bloqueio de 24h).\n\n'
          'Recomendamos manter o agendamento.',
      contentColor: Colors.red[900]!,
      isStrikeRisk: true,
      isPenalty: true,
    );
  }

  /// Show the cancellation dialog with appropriate warnings
  /// Returns true if user confirmed cancellation, false otherwise
  static Future<bool> showCancellationDialog({
    required BuildContext context,
    required DateTime scheduledTime,
  }) async {
    final warning = getWarning(scheduledTime);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          warning.title,
          style: TextStyle(
            color: warning.isStrikeRisk ? Colors.red : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          warning.content,
          style: TextStyle(color: warning.contentColor, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Manter Agendamento'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: warning.isStrikeRisk ? Colors.red[50] : null,
            ),
            child: Text(
              warning.isStrikeRisk
                  ? 'Aceitar Strike e Cancelar'
                  : 'Confirmar Cancelamento',
            ),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// Get the success/feedback message after cancellation
  static String getCancellationFeedback(DateTime scheduledTime) {
    final warning = getWarning(scheduledTime);
    if (warning.isStrikeRisk) {
      return 'Cancelado. Bloqueio de 24h aplicado.';
    } else if (warning.isPenalty) {
      return 'Agendamento cancelado. Crédito consumido.';
    }
    return 'Agendamento cancelado com sucesso.';
  }

  /// Check if cancellation button should show warning indicator
  /// Returns true if < 2h (strike risk)
  static bool shouldShowStrikeWarning(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    return difference.inMinutes < 120; // < 2 hours
  }
}
