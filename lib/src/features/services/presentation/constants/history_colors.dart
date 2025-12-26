import 'package:flutter/material.dart';

/// Semantic color palette for history screen status badges
/// Uses a soft, accessible palette for premium look
class HistoryStatusColors {
  HistoryStatusColors._();

  // Concluído (Completed/Finished)
  static const completedBackground = Color(0xFFE8F5E9);
  static const completedForeground = Color(0xFF2E7D32);

  // Cancelado (Cancelled)
  static const cancelledBackground = Color(0xFFFFEBEE);
  static const cancelledForeground = Color(0xFFC62828);

  // Pendente/Agendado (Pending/Scheduled)
  static const pendingBackground = Color(0xFFE3F2FD);
  static const pendingForeground = Color(0xFF1976D2);

  // Em Andamento (In Progress)
  static const inProgressBackground = Color(0xFFFFF3E0);
  static const inProgressForeground = Color(0xFFEF6C00);

  // Confirmado (Confirmed)
  static const confirmedBackground = Color(0xFFE8EAF6);
  static const confirmedForeground = Color(0xFF3949AB);

  // Não Compareceu (No Show)
  static const noShowBackground = Color(0xFFECEFF1);
  static const noShowForeground = Color(0xFF546E7A);

  /// Returns background and foreground colors for a given status string
  static ({Color background, Color foreground}) getColorsForStatus(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'finished':
      case 'finalizado':
      case 'concluído':
        return (
          background: completedBackground,
          foreground: completedForeground,
        );
      case 'cancelled':
      case 'cancelado':
      case 'rejected':
      case 'recusado':
        return (
          background: cancelledBackground,
          foreground: cancelledForeground,
        );
      case 'scheduled':
      case 'agendado':
      case 'pending':
      case 'pendingapproval':
        return (background: pendingBackground, foreground: pendingForeground);
      case 'checkin':
      case 'washing':
      case 'vacuuming':
      case 'drying':
      case 'polishing':
      case 'inprogress':
      case 'in_progress':
        return (
          background: inProgressBackground,
          foreground: inProgressForeground,
        );
      case 'confirmed':
      case 'confirmado':
        return (
          background: confirmedBackground,
          foreground: confirmedForeground,
        );
      case 'noshow':
      case 'no_show':
        return (background: noShowBackground, foreground: noShowForeground);
      default:
        return (background: pendingBackground, foreground: pendingForeground);
    }
  }
}
