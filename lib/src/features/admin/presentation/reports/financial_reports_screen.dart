import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/admin_repository.dart';
import '../../data/stripe_reports_repository.dart';
import '../../data/pdf_report_service.dart';
import '../../domain/stripe_subscription.dart';
import '../../domain/stripe_transaction.dart';
import '../../../booking/domain/booking.dart';
import '../../../../common_widgets/atoms/app_loader.dart';
import '../../../../shared/utils/app_toast.dart';

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
  bool _isExporting = false;
  final _pdfService = PdfReportService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  Future<void> _exportPdf({
    required List<StripeSubscription> subscriptions,
    required List<StripeTransaction> transactions,
    required List<Booking> bookings,
  }) async {
    setState(() => _isExporting = true);
    try {
      final pdfBytes = await _pdfService.generateFinancialReport(
        subscriptions: subscriptions,
        transactions: transactions,
        bookings: bookings,
        period: _dateRange,
      );
      if (mounted) {
        await _pdfService.printReport(pdfBytes, context);
        AppToast.success(context, message: 'Relatório gerado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao gerar relatório: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(adminBookingsProvider);
    final subscriptionsAsync = ref.watch(stripeSubscriptionsProvider());
    final transactionsAsync = ref.watch(
      stripeTransactionsProvider(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
      ),
    );
    final theme = Theme.of(context);
    final range = _dateRange;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                        "Relatórios Financeiros",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Acompanhe a receita e desempenho do seu negócio.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Export Button
                FilledButton.icon(
                  onPressed: _isExporting
                      ? null
                      : () {
                          final bookings = bookingsAsync.valueOrNull ?? [];
                          final subs =
                              subscriptionsAsync.valueOrNull?.subscriptions ??
                              [];
                          final trans =
                              transactionsAsync.valueOrNull?.transactions ?? [];

                          final filteredBookings = bookings.where((b) {
                            return b.status == BookingStatus.finished &&
                                b.scheduledTime.isAfter(range.start) &&
                                b.scheduledTime.isBefore(
                                  range.end.add(const Duration(days: 1)),
                                );
                          }).toList();

                          _exportPdf(
                            subscriptions: subs,
                            transactions: trans,
                            bookings: filteredBookings,
                          );
                        },
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(_isExporting ? 'Gerando...' : 'Exportar PDF'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Period Filter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Período',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _selectCustomRange,
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: const Text('Personalizar'),
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
                            label: Text(_getPeriodLabel(period)),
                            selected: isSelected,
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: theme.colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Faturamento', icon: Icon(Icons.bar_chart)),
                      Tab(text: 'Assinaturas', icon: Icon(Icons.subscriptions)),
                      Tab(text: 'Transações', icon: Icon(Icons.receipt_long)),
                    ],
                  ),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Revenue Chart
                        _buildRevenueTab(bookingsAsync, range, theme),
                        // Tab 2: Subscriptions
                        _buildSubscriptionsTab(subscriptionsAsync, theme),
                        // Tab 3: Transactions
                        _buildTransactionsTab(transactionsAsync, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              Text(
                'Receita por Período',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  Widget _buildSubscriptionsTab(
    AsyncValue<StripeSubscriptionsResult> subscriptionsAsync,
    ThemeData theme,
  ) {
    return subscriptionsAsync.when(
      data: (result) {
        final subscriptions = result.subscriptions;

        if (subscriptions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.subscriptions_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text('Nenhuma assinatura encontrada'),
              ],
            ),
          );
        }

        final activeCount = subscriptions
            .where((s) => s.status == 'active')
            .length;
        final mrr = subscriptions
            .where((s) => s.status == 'active')
            .fold<double>(0, (sum, s) => sum + s.amount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary
              Row(
                children: [
                  Expanded(
                    child: _buildCountCard(
                      context,
                      'Assinaturas Ativas',
                      activeCount,
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'MRR',
                      mrr,
                      Colors.blue,
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCountCard(
                      context,
                      'Total',
                      subscriptions.length,
                      Colors.purple,
                      Icons.people,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Subscriptions Table
              Text(
                'Lista de Assinaturas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSubscriptionsTable(subscriptions, theme),
            ],
          ),
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar assinaturas:\n$err',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(stripeSubscriptionsProvider()),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(
    AsyncValue<StripeTransactionsResult> transactionsAsync,
    ThemeData theme,
  ) {
    return transactionsAsync.when(
      data: (result) {
        final transactions = result.transactions;

        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhuma transação encontrada neste período'),
              ],
            ),
          );
        }

        final totalPaid = transactions
            .where((t) => t.paid)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final paidCount = transactions.where((t) => t.paid).length;
        final refundedCount = transactions.where((t) => t.refunded).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Total Recebido',
                      totalPaid,
                      Colors.green,
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCountCard(
                      context,
                      'Transações Pagas',
                      paidCount,
                      Colors.blue,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCountCard(
                      context,
                      'Reembolsos',
                      refundedCount,
                      Colors.orange,
                      Icons.undo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Transactions Table
              Text(
                'Lista de Transações',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildTransactionsTable(transactions, theme),
            ],
          ),
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar transações:\n$err',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(
                stripeTransactionsProvider(
                  startDate: _dateRange.start,
                  endDate: _dateRange.end,
                ),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsTable(
    List<StripeSubscription> subscriptions,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('Cliente')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Valor'), numeric: true),
            DataColumn(label: Text('Intervalo')),
            DataColumn(label: Text('Próx. Cobrança')),
          ],
          rows: subscriptions.map((s) {
            final endDate = DateTime.fromMillisecondsSinceEpoch(
              s.currentPeriodEnd * 1000,
            );
            return DataRow(
              cells: [
                DataCell(Text(s.customerName ?? '-')),
                DataCell(Text(s.customerEmail ?? '-')),
                DataCell(_buildStatusChip(s.status)),
                DataCell(
                  Text(
                    NumberFormat.currency(
                      locale: 'pt_BR',
                      symbol: 'R\$',
                    ).format(s.amount),
                  ),
                ),
                DataCell(Text(_getIntervalLabel(s.interval))),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(endDate))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionsTable(
    List<StripeTransaction> transactions,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('Data')),
            DataColumn(label: Text('Cliente')),
            DataColumn(label: Text('Valor'), numeric: true),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Descrição')),
          ],
          rows: transactions.map((t) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              t.createdAt * 1000,
            );
            return DataRow(
              cells: [
                DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(date))),
                DataCell(Text(t.customerEmail ?? '-')),
                DataCell(
                  Text(
                    NumberFormat.currency(
                      locale: 'pt_BR',
                      symbol: 'R\$',
                    ).format(t.amount),
                  ),
                ),
                DataCell(_buildTransactionStatusChip(t)),
                DataCell(
                  Text(t.description ?? '-', overflow: TextOverflow.ellipsis),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'Ativo';
        break;
      case 'canceled':
        color = Colors.red;
        label = 'Cancelado';
        break;
      case 'past_due':
        color = Colors.orange;
        label = 'Vencido';
        break;
      case 'trialing':
        color = Colors.blue;
        label = 'Teste';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTransactionStatusChip(StripeTransaction t) {
    Color color;
    String label;

    if (t.refunded) {
      color = Colors.orange;
      label = 'Reembolsado';
    } else if (t.paid) {
      color = Colors.green;
      label = 'Pago';
    } else {
      color = Colors.grey;
      label = 'Pendente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getIntervalLabel(String interval) {
    switch (interval) {
      case 'month':
        return 'Mensal';
      case 'year':
        return 'Anual';
      case 'week':
        return 'Semanal';
      case 'day':
        return 'Diário';
      default:
        return interval;
    }
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
