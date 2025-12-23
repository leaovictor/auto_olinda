import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/admin_repository.dart';

import '../../../booking/domain/booking.dart';
import '../../../../common_widgets/atoms/app_loader.dart';

import '../theme/admin_theme.dart';

enum ReportPeriod { week, month, quarter, year, custom }

class FinancialReportsScreen extends ConsumerStatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  ConsumerState<FinancialReportsScreen> createState() =>
      _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends ConsumerState<FinancialReportsScreen>
    with SingleTickerProviderStateMixin {
  ReportPeriod _selectedPeriod = ReportPeriod.week;
  DateTimeRange? _customRange;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTimeRange get _dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedPeriod) {
      case ReportPeriod.week:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case ReportPeriod.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, now.day),
          end: today,
        );
      case ReportPeriod.quarter:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 3, now.day),
          end: today,
        );
      case ReportPeriod.year:
        return DateTimeRange(
          start: DateTime(now.year - 1, now.month, now.day),
          end: today,
        );
      case ReportPeriod.custom:
        return _customRange ??
            DateTimeRange(
              start: today.subtract(const Duration(days: 6)),
              end: today,
            );
    }
  }

  String _getPeriodLabel(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.week:
        return '7 dias';
      case ReportPeriod.month:
        return '30 dias';
      case ReportPeriod.quarter:
        return '3 meses';
      case ReportPeriod.year:
        return '1 ano';
      case ReportPeriod.custom:
        return 'Personalizado';
    }
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange ?? _dateRange,
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        _customRange = picked;
        _selectedPeriod = ReportPeriod.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(adminBookingsProvider);

    final theme = Theme.of(context);
    final range = _dateRange;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Relatórios Financeiros',
          style: AdminTheme.headingMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminTheme.textPrimary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AdminTheme.bgDark.withOpacity(0.9), Colors.transparent],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: kToolbarHeight + 40,
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Export Button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Acompanhe a receita e desempenho do seu negócio.",
                          style: AdminTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Period Filter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.date_range, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Período', style: AdminTheme.headingSmall),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _selectCustomRange,
                          icon: const Icon(
                            Icons.calendar_month,
                            size: 18,
                            color: AdminTheme.textPrimary,
                          ),
                          label: const Text(
                            'Personalizar',
                            style: TextStyle(color: AdminTheme.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ReportPeriod.values
                          .where((p) => p != ReportPeriod.custom)
                          .map((period) {
                            final isSelected = _selectedPeriod == period;
                            return ChoiceChip(
                              label: Text(
                                _getPeriodLabel(period),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AdminTheme.textSecondary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AdminTheme.gradientPrimary[0],
                              backgroundColor: AdminTheme.bgCardLight,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedPeriod = period);
                                }
                              },
                            );
                          })
                          .toList(),
                    ),
                    if (_selectedPeriod == ReportPeriod.custom &&
                        _customRange != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(_customRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_customRange!.end)}',
                        style: AdminTheme.bodySmall.copyWith(
                          color: AdminTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tabs
              Container(
                decoration: AdminTheme.glassmorphicDecoration(opacity: 0.3),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: AdminTheme.textPrimary,
                      unselectedLabelColor: AdminTheme.textSecondary,
                      indicatorColor: AdminTheme.gradientPrimary[0],
                      tabs: const [
                        Tab(text: 'Faturamento', icon: Icon(Icons.bar_chart)),
                      ],
                    ),
                    SizedBox(
                      height: 600,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Revenue Chart
                          _buildRevenueTab(bookingsAsync, range, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueTab(
    AsyncValue<List<Booking>> bookingsAsync,
    DateTimeRange range,
    ThemeData theme,
  ) {
    return bookingsAsync.when(
      data: (bookings) {
        final filteredBookings = bookings.where((b) {
          return b.status == BookingStatus.finished &&
              b.scheduledTime.isAfter(range.start) &&
              b.scheduledTime.isBefore(range.end.add(const Duration(days: 1)));
        }).toList();

        final totalRevenue = filteredBookings.fold(
          0.0,
          (sum, b) => sum + b.totalPrice,
        );
        final averageTicket = filteredBookings.isNotEmpty
            ? totalRevenue / filteredBookings.length
            : 0.0;

        final chartData = _generateChartData(filteredBookings, range);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Receita Total',
                      totalRevenue,
                      Colors.green,
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Ticket Médio',
                      averageTicket,
                      Colors.blue,
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCountCard(
                      context,
                      'Agendamentos',
                      filteredBookings.length,
                      Colors.purple,
                      Icons.event_available,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart
              Text('Receita por Período', style: AdminTheme.headingSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: chartData.isEmpty
                    ? const Center(child: Text('Nenhum dado para este período'))
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY:
                              chartData
                                  .map((e) => e['value'] as double)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => Colors.blueGrey,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      'R\$ ${rod.toY.toStringAsFixed(2)}',
                                      const TextStyle(color: Colors.white),
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
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < chartData.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        chartData[value.toInt()]['label']
                                            as String,
                                        style: const TextStyle(
                                          color: AdminTheme.textSecondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
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
                          barGroups: chartData.asMap().entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value['value'] as double,
                                  color: theme.primaryColor,
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(child: Text('Erro: $err')),
    );
  }

  List<Map<String, dynamic>> _generateChartData(
    List<Booking> bookings,
    DateTimeRange range,
  ) {
    if (bookings.isEmpty) return [];

    final days = range.end.difference(range.start).inDays + 1;

    if (days <= 14) {
      // Daily grouping
      return List.generate(days, (index) {
        final day = range.start.add(Duration(days: index));
        final dayRevenue = bookings
            .where(
              (b) =>
                  b.scheduledTime.year == day.year &&
                  b.scheduledTime.month == day.month &&
                  b.scheduledTime.day == day.day,
            )
            .fold(0.0, (sum, b) => sum + b.totalPrice);
        return {'label': DateFormat('dd/MM').format(day), 'value': dayRevenue};
      });
    } else if (days <= 90) {
      // Weekly grouping
      final weeks = (days / 7).ceil();
      return List.generate(weeks, (index) {
        final weekStart = range.start.add(Duration(days: index * 7));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final weekRevenue = bookings
            .where(
              (b) =>
                  b.scheduledTime.isAfter(
                    weekStart.subtract(const Duration(days: 1)),
                  ) &&
                  b.scheduledTime.isBefore(
                    weekEnd.add(const Duration(days: 1)),
                  ),
            )
            .fold(0.0, (sum, b) => sum + b.totalPrice);
        return {'label': 'S${index + 1}', 'value': weekRevenue};
      });
    } else {
      // Monthly grouping
      final months = <Map<String, dynamic>>[];
      var current = DateTime(range.start.year, range.start.month);
      while (current.isBefore(range.end.add(const Duration(days: 1)))) {
        final monthRevenue = bookings
            .where(
              (b) =>
                  b.scheduledTime.year == current.year &&
                  b.scheduledTime.month == current.month,
            )
            .fold(0.0, (sum, b) => sum + b.totalPrice);
        months.add({
          'label': DateFormat('MMM', 'pt_BR').format(current),
          'value': monthRevenue,
        });
        current = DateTime(current.year, current.month + 1);
      }
      return months;
    }
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard(
    BuildContext context,
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
