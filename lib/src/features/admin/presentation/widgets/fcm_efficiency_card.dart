import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/fcm_notification_log.dart';
import '../theme/admin_theme.dart';

/// Card showing FCM notification efficiency metrics
/// Displays total notifications, breakdown by type, and estimated time saved
class FcmEfficiencyCard extends StatelessWidget {
  final FcmEfficiencyMetrics metrics;
  final int animationDelay;

  const FcmEfficiencyCard({
    super.key,
    required this.metrics,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(AdminTheme.paddingLG),
          decoration: AdminTheme.glassmorphicDecoration(
            opacity: 0.8,
            glowColor: AdminTheme.gradientPink[0],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AdminTheme.gradientPink),
                      borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                      boxShadow: AdminTheme.glowShadow(
                        AdminTheme.gradientPink[0],
                        intensity: 0.3,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AdminTheme.paddingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eficiência de Notificações',
                          style: AdminTheme.headingSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Trabalho automatizado este mês',
                          style: AdminTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminTheme.paddingLG),

              // Main stat
              Row(
                children: [
                  Expanded(
                    child: _buildMainStat(
                      value: '${metrics.totalNotificationsThisMonth}',
                      label: 'Notificações Enviadas',
                      icon: Icons.send_rounded,
                    ),
                  ),
                  const SizedBox(width: AdminTheme.paddingMD),
                  Expanded(
                    child: _buildMainStat(
                      value: _formatTimeSaved(
                        metrics.estimatedTimeSavedMinutes,
                      ),
                      label: 'Tempo Economizado',
                      icon: Icons.timer_rounded,
                      isHighlighted: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminTheme.paddingLG),

              // Breakdown
              Text(
                'Detalhamento por Tipo',
                style: AdminTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AdminTheme.paddingMD),

              // Type breakdown chips
              Wrap(
                spacing: AdminTheme.paddingSM,
                runSpacing: AdminTheme.paddingSM,
                children: [
                  _buildTypeChip(
                    icon: Icons.local_car_wash_rounded,
                    label: 'Carro Pronto',
                    count: metrics.carrosProntosCount,
                    color: AdminTheme.gradientSuccess[0],
                  ),
                  _buildTypeChip(
                    icon: Icons.update_rounded,
                    label: 'Status',
                    count: metrics.statusUpdatesCount,
                    color: AdminTheme.gradientInfo[0],
                  ),
                  _buildTypeChip(
                    icon: Icons.alarm_rounded,
                    label: 'Lembretes',
                    count: metrics.remindersCount,
                    color: AdminTheme.gradientWarning[0],
                  ),
                  _buildTypeChip(
                    icon: Icons.campaign_rounded,
                    label: 'Promos',
                    count: metrics.promosCount,
                    color: AdminTheme.gradientPink[0],
                  ),
                ],
              ),

              const SizedBox(height: AdminTheme.paddingLG),

              // Value proposition
              Container(
                padding: const EdgeInsets.all(AdminTheme.paddingMD),
                decoration: BoxDecoration(
                  color: AdminTheme.gradientSuccess[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                  border: Border.all(
                    color: AdminTheme.gradientSuccess[0].withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: AdminTheme.gradientSuccess[0],
                      size: 20,
                    ),
                    const SizedBox(width: AdminTheme.paddingSM),
                    Expanded(
                      child: Text(
                        'O sistema enviou ${metrics.totalNotificationsThisMonth} mensagens automaticamente, poupando ${_formatTimeSaved(metrics.estimatedTimeSavedMinutes)} da sua equipe.',
                        style: AdminTheme.bodySmall.copyWith(
                          color: AdminTheme.gradientSuccess[0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildMainStat({
    required String value,
    required String label,
    required IconData icon,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AdminTheme.gradientSuccess[0].withOpacity(0.1)
            : AdminTheme.bgCardLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        border: Border.all(
          color: isHighlighted
              ? AdminTheme.gradientSuccess[0].withOpacity(0.3)
              : AdminTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isHighlighted
                ? AdminTheme.gradientSuccess[0]
                : AdminTheme.textMuted,
            size: 18,
          ),
          const SizedBox(height: AdminTheme.paddingSM),
          Text(
            value,
            style: AdminTheme.statValue.copyWith(
              fontSize: 22,
              color: isHighlighted
                  ? AdminTheme.gradientSuccess[0]
                  : AdminTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AdminTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminTheme.paddingMD,
        vertical: AdminTheme.paddingSM,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AdminTheme.paddingSM),
          Text(
            '$label: $count',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeSaved(double minutes) {
    if (minutes < 60) {
      return '${minutes.toInt()} min';
    } else {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)}h';
    }
  }
}

/// Compact version for dashboard overview
class FcmEfficiencyCardCompact extends StatelessWidget {
  final int totalNotifications;
  final double timeSavedMinutes;
  final int animationDelay;

  const FcmEfficiencyCardCompact({
    super.key,
    required this.totalNotifications,
    required this.timeSavedMinutes,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(AdminTheme.paddingMD),
          decoration: AdminTheme.premiumCardDecoration(type: CardType.neutral),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AdminTheme.gradientPink),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AdminTheme.paddingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalNotifications notificações',
                      style: AdminTheme.headingSmall,
                    ),
                    Text(
                      'economizou ${_formatTimeSaved(timeSavedMinutes)}',
                      style: AdminTheme.labelSmall.copyWith(
                        color: AdminTheme.gradientSuccess[0],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AdminTheme.textMuted,
                size: 16,
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms);
  }

  String _formatTimeSaved(double minutes) {
    if (minutes < 60) {
      return '${minutes.toInt()} min';
    } else {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)}h';
    }
  }
}
