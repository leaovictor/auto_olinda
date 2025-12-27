import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/admin_theme.dart';

/// Premium Stat Card with glassmorphic design
/// Displays KPI metrics with gradient accents, glow effects, and animations
class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final double? percentageChange;
  final IconData? icon;
  final CardType type;
  final VoidCallback? onTap;
  final int animationDelay; // For staggered animations

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.percentageChange,
    this.icon,
    this.type = CardType.neutral,
    this.onTap,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = (percentageChange ?? 0) >= 0;
    final gradientColors = _getGradientColors();

    return ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
          child: BackdropFilter(
            filter: AdminTheme.standardBlur,
            child: Container(
              decoration: AdminTheme.premiumCardDecoration(type: type),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
                  child: Padding(
                    padding: const EdgeInsets.all(AdminTheme.paddingLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with icon and menu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Icon with gradient background
                            _buildIconContainer(gradientColors),
                            // Menu dots
                            Icon(
                              Icons.more_horiz,
                              color: AdminTheme.textMuted,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: AdminTheme.paddingMD),

                        // Title
                        Text(
                          title,
                          style: AdminTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AdminTheme.paddingSM),

                        // Value with gradient text effect
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AdminTheme.textPrimary,
                                AdminTheme.textPrimary.withOpacity(0.9),
                              ],
                            ).createShader(bounds),
                            child: Text(value, style: AdminTheme.statValue),
                          ),
                        ),

                        if (percentageChange != null) ...[
                          const SizedBox(height: AdminTheme.paddingMD),

                          // Percentage change indicator
                          Row(
                            children: [
                              _buildChangeIndicator(isPositive),
                              const SizedBox(width: AdminTheme.paddingSM),
                              Flexible(
                                child: Text(
                                  'vs mês ant.',
                                  style: AdminTheme.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildIconContainer(List<Color> gradientColors) {
    return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon ?? _getDefaultIcon(), color: Colors.white, size: 22),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 2.seconds,
        );
  }

  Widget _buildChangeIndicator(bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminTheme.paddingSM,
        vertical: AdminTheme.paddingXS,
      ),
      decoration: BoxDecoration(
        color: isPositive
            ? AdminTheme.gradientSuccess[0].withOpacity(0.15)
            : AdminTheme.gradientDanger[0].withOpacity(0.15),
        borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
        border: Border.all(
          color: isPositive
              ? AdminTheme.gradientSuccess[0].withOpacity(0.3)
              : AdminTheme.gradientDanger[0].withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 14,
            color: isPositive
                ? AdminTheme.gradientSuccess[0]
                : AdminTheme.gradientDanger[0],
          ),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${percentageChange!.toStringAsFixed(1)}%',
            style: TextStyle(
              color: isPositive
                  ? AdminTheme.gradientSuccess[0]
                  : AdminTheme.gradientDanger[0],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (type) {
      case CardType.revenue:
        return AdminTheme.gradientSuccess;
      case CardType.bookings:
        return AdminTheme.gradientInfo;
      case CardType.average:
        return AdminTheme.gradientPrimary;
      case CardType.rating:
        return AdminTheme.gradientWarning;
      case CardType.danger:
        return AdminTheme.gradientDanger;
      case CardType.neutral:
        return AdminTheme.gradientPrimary;
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case CardType.revenue:
        return Icons.attach_money_rounded;
      case CardType.bookings:
        return Icons.calendar_today_rounded;
      case CardType.average:
        return Icons.trending_up_rounded;
      case CardType.rating:
        return Icons.star_rounded;
      case CardType.danger:
        return Icons.warning_rounded;
      case CardType.neutral:
        return Icons.analytics_rounded;
    }
  }
}

/// Compact version of stat card for mobile
class DashboardStatCardCompact extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final CardType type;
  final int animationDelay;

  const DashboardStatCardCompact({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.type = CardType.neutral,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors();

    return ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
          child: BackdropFilter(
            filter: AdminTheme.standardBlur,
            child: Container(
              padding: const EdgeInsets.all(AdminTheme.paddingMD),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard.withOpacity(0.8),
                borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
                border: Border.all(color: AdminTheme.borderLight),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AdminTheme.paddingMD),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AdminTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: AdminTheme.headingSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.1, end: 0, duration: 300.ms);
  }

  List<Color> _getGradientColors() {
    switch (type) {
      case CardType.revenue:
        return AdminTheme.gradientSuccess;
      case CardType.bookings:
        return AdminTheme.gradientInfo;
      case CardType.average:
        return AdminTheme.gradientPrimary;
      case CardType.rating:
        return AdminTheme.gradientWarning;
      case CardType.danger:
        return AdminTheme.gradientDanger;
      case CardType.neutral:
        return AdminTheme.gradientPrimary;
    }
  }
}
