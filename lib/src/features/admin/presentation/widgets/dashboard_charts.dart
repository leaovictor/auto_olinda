import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardRevenueChart extends StatelessWidget {
  final List<double> monthlyRevenue; // 12 months data
  final double maxRevenue;

  const DashboardRevenueChart({
    super.key,
    required this.monthlyRevenue,
    required this.maxRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxRevenue * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) =>
                theme.colorScheme.surfaceContainerHighest,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'R\$ ${rod.toY.toStringAsFixed(0)}',
                TextStyle(color: theme.colorScheme.onSurface),
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
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
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
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: monthlyRevenue.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: theme.colorScheme.primary,
                width: 12,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxRevenue * 1.2,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

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
    if (total == 0) return const Center(child: Text("No Data"));

    final theme = Theme.of(context);

    return Stack(
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                color: Colors.green,
                value: completed.toDouble(),
                title: '${((completed / total) * 100).toStringAsFixed(0)}%',
                radius: 25,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: Colors.orange,
                value: pending.toDouble(),
                title: '${((pending / total) * 100).toStringAsFixed(0)}%',
                radius: 25,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: Colors.red,
                value: cancelled.toDouble(),
                title: '${((cancelled / total) * 100).toStringAsFixed(0)}%',
                radius: 25,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Total",
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
              Text(
                total.toString(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
