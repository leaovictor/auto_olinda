import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/subscription_metrics_provider.dart';
import '../theme/admin_theme.dart';

/// Premium Line Chart showing subscriber growth over the last 6 months
/// Dark theme with gradient fill and interactive tooltips
class SubscriberGrowthChart extends StatelessWidget {
  final List<MonthlySubscriberGrowth> data;
  final int animationDelay;

  const SubscriberGrowthChart({
    super.key,
    required this.data,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final maxY = data
        .map((d) => d.subscriberCount)
        .reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = maxY == 0 ? 10.0 : maxY * 1.2;

    return Container(
          padding: const EdgeInsets.all(AdminTheme.paddingLG),
          decoration: AdminTheme.glassmorphicDecoration(
            opacity: 0.8,
            glowColor: AdminTheme.gradientInfo[0],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AdminTheme.gradientInfo,
                          ),
                          borderRadius: BorderRadius.circular(
                            AdminTheme.radiusSM,
                          ),
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AdminTheme.paddingMD),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crescimento de Assinantes',
                            style: AdminTheme.headingSmall,
                          ),
                          const SizedBox(height: 2),
                          Text('Últimos 6 meses', style: AdminTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                  // Current count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminTheme.paddingMD,
                      vertical: AdminTheme.paddingSM,
                    ),
                    decoration: BoxDecoration(
                      color: AdminTheme.gradientInfo[0].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                      border: Border.all(
                        color: AdminTheme.gradientInfo[0].withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${data.last.subscriberCount} ativos',
                      style: TextStyle(
                        color: AdminTheme.gradientInfo[0],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminTheme.paddingLG),

              // Chart
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: adjustedMaxY / 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AdminTheme.borderLight,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= data.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                data[index].monthLabel,
                                style: AdminTheme.labelSmall,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: adjustedMaxY / 4,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: AdminTheme.labelSmall,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: data.length - 1.0,
                    minY: 0,
                    maxY: adjustedMaxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => AdminTheme.bgCard,
                        tooltipBorder: BorderSide(
                          color: AdminTheme.borderMedium,
                        ),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index < 0 || index >= data.length) return null;

                            return LineTooltipItem(
                              '${data[index].monthLabel}\n${data[index].subscriberCount} assinantes',
                              AdminTheme.bodyMedium.copyWith(
                                color: AdminTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.asMap().entries.map((e) {
                          return FlSpot(
                            e.key.toDouble(),
                            e.value.subscriberCount.toDouble(),
                          );
                        }).toList(),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        gradient: LinearGradient(
                          colors: AdminTheme.gradientInfo,
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AdminTheme.gradientInfo[0],
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AdminTheme.gradientInfo[0].withOpacity(0.3),
                              AdminTheme.gradientInfo[1].withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingLG),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart_rounded, size: 48, color: AdminTheme.textMuted),
          const SizedBox(height: AdminTheme.paddingMD),
          Text('Sem dados de crescimento', style: AdminTheme.bodyMedium),
          const SizedBox(height: AdminTheme.paddingSM),
          Text(
            'Os dados aparecerão após o primeiro mês de uso',
            style: AdminTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
