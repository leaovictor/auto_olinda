import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Premium Revenue Chart with gradient bars and dark theme
class DashboardRevenueChart extends StatelessWidget {
  final List<double> monthlyRevenue;
  final double maxRevenue;

  const DashboardRevenueChart({
    super.key,
    required this.monthlyRevenue,
    required this.maxRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxRevenue * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AdminTheme.bgCardLight,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'R\$ ${rod.toY.toStringAsFixed(0)}',
                const TextStyle(
                  color: AdminTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: AdminTheme.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Jan';
                    break;
                  case 2:
                    text = 'Mar';
                    break;
                  case 4:
                    text = 'Mai';
                    break;
                  case 6:
                    text = 'Jul';
                    break;
                  case 8:
                    text = 'Set';
                    break;
                  case 10:
                    text = 'Nov';
                    break;
                  default:
                    return Container();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(text, style: style),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxRevenue / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AdminTheme.borderLight,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: monthlyRevenue.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AdminTheme.gradientSuccess[1],
                    AdminTheme.gradientSuccess[0],
                  ],
                ),
                width: 14,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxRevenue * 1.2,
                  color: AdminTheme.bgCardLight.withOpacity(0.3),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Premium Pie Chart with gradient sections and dark theme
class DashboardStatusPieChart extends StatelessWidget {
  final int completed;
  final int pending;
  final int cancelled;
  final int total;

  const DashboardStatusPieChart({
    super.key,
    required this.completed,
    required this.pending,
    required this.cancelled,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 48,
              color: AdminTheme.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'Sem dados',
              style: AdminTheme.bodyMedium.copyWith(
                color: AdminTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      color: AdminTheme.gradientSuccess[0],
                      value: completed.toDouble(),
                      title: '',
                      radius: 28,
                    ),
                    PieChartSectionData(
                      color: AdminTheme.gradientWarning[0],
                      value: pending.toDouble(),
                      title: '',
                      radius: 28,
                    ),
                    PieChartSectionData(
                      color: AdminTheme.gradientDanger[0],
                      value: cancelled.toDouble(),
                      title: '',
                      radius: 28,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(total.toString(), style: AdminTheme.headingMedium),
                  Text('Total', style: AdminTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem(
              AdminTheme.gradientSuccess[0],
              'Finalizados',
              completed,
            ),
            _buildLegendItem(
              AdminTheme.gradientWarning[0],
              'Pendentes',
              pending,
            ),
            _buildLegendItem(
              AdminTheme.gradientDanger[0],
              'Cancelados',
              cancelled,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, int value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value.toString(),
              style: AdminTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AdminTheme.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }
}
