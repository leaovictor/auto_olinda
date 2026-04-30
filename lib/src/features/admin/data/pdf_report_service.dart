import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/stripe_subscription.dart';
import '../domain/stripe_transaction.dart';
import '../domain/fcm_notification_log.dart';
import 'subscription_metrics_provider.dart';
import '../../booking/domain/booking.dart';

/// Service for generating PDF financial reports.
class PdfReportService {
  static const _primaryColor = PdfColor.fromInt(0xFF0F172A);
  static const _accentColor = PdfColor.fromInt(0xFF3B82F6);
  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  static final _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

  /// Generates a comprehensive financial report PDF.
  Future<Uint8List> generateFinancialReport({
    required List<StripeSubscription> subscriptions,
    required List<StripeTransaction> transactions,
    required List<Booking> bookings,
    required DateTimeRange period,
    SubscriptionMetrics? subscriptionMetrics,
    FcmEfficiencyMetrics? fcmMetrics,
    List<StripeSubscription>? previousPeriodSubscriptions,
    List<StripeTransaction>? previousPeriodTransactions,
  }) async {
    final pdf = pw.Document();

    // Load CleanFlow logo
    final ByteData logoBytes = await rootBundle.load(
      'assets/images/autoolinda_logo.jpg',
    );
    final Uint8List logoData = logoBytes.buffer.asUint8List();
    final logo = pw.MemoryImage(logoData);

    // Calculate metrics
    final totalSubscriptionRevenue = subscriptions.fold<double>(
      0,
      (sum, s) => sum + (s.status == 'active' ? s.amount : 0),
    );
    final activeSubscriptions = subscriptions
        .where((s) => s.status == 'active')
        .length;
    final totalTransactions = transactions.fold<double>(
      0,
      (sum, t) => sum + (t.paid ? t.amount : 0),
    );
    final totalBookingsRevenue = bookings.fold<double>(
      0,
      (sum, b) => sum + b.totalPrice,
    );

    // Calculate additional metrics
    // totalTransactions already includes ALL paid transactions (subscriptions + services)
    // This is the actual money received in the period
    final totalRevenue = totalTransactions;
    final arpu = activeSubscriptions > 0
        ? totalRevenue / activeSubscriptions
        : 0.0;
    final retentionRate = activeSubscriptions > 0 ? 100.0 : 0.0; // Simplified

    // Calculate previous period metrics for comparison
    double? previousRevenue;
    double? revenueGrowth;
    if (previousPeriodSubscriptions != null &&
        previousPeriodTransactions != null) {
      final prevSubRevenue = previousPeriodSubscriptions
          .where((s) => s.status == 'active')
          .fold<double>(0, (sum, s) => sum + s.amount);
      final prevTransRevenue = previousPeriodTransactions
          .where((t) => t.paid)
          .fold<double>(0, (sum, t) => sum + t.amount);
      previousRevenue = prevSubRevenue + prevTransRevenue;
      revenueGrowth = previousRevenue > 0
          ? ((totalRevenue - previousRevenue) / previousRevenue) * 100
          : 0.0;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(period, logo),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Enhanced Summary Section with Additional KPIs
          _buildEnhancedSummarySection(
            activeSubscriptions: activeSubscriptions,
            totalSubscriptionRevenue: totalSubscriptionRevenue,
            totalTransactions: totalTransactions,
            totalBookingsRevenue: totalBookingsRevenue,
            arpu: arpu,
            retentionRate: retentionRate,
            revenueGrowth: revenueGrowth,
          ),
          pw.SizedBox(height: 20),

          // Comparative Analysis Section (if previous period data available)
          if (previousRevenue != null && revenueGrowth != null) ...[
            _buildComparativeAnalysisSection(
              currentRevenue: totalRevenue,
              previousRevenue: previousRevenue,
              revenueGrowth: revenueGrowth,
              currentMRR: totalSubscriptionRevenue,
              previousMRR: previousPeriodSubscriptions!
                  .where((s) => s.status == 'active')
                  .fold<double>(0, (sum, s) => sum + s.amount),
              currentActiveClients: activeSubscriptions,
              previousActiveClients: previousPeriodSubscriptions
                  .where((s) => s.status == 'active')
                  .length,
            ),
            pw.SizedBox(height: 20),
          ],

          // Revenue Breakdown by Plan
          _buildRevenueBreakdownSection(subscriptions),
          pw.SizedBox(height: 20),

          // Cash Flow Summary
          _buildCashFlowSection(
            totalRevenue: totalRevenue,
            receivedAmount:
                transactions
                    .where((t) => t.paid)
                    .fold<double>(0, (sum, t) => sum + t.amount) +
                totalSubscriptionRevenue,
            pendingAmount: transactions
                .where((t) => !t.paid && !t.refunded)
                .fold<double>(0, (sum, t) => sum + t.amount),
            delinquentAmount: subscriptionMetrics?.delinquent != null
                ? subscriptions
                      .where((s) => s.status == 'past_due')
                      .fold<double>(0, (sum, s) => sum + s.amount)
                : 0.0,
          ),
          pw.SizedBox(height: 20),

          // Revenue Projections
          _buildProjectionsSection(
            currentMRR: totalSubscriptionRevenue,
            avgServiceRevenue: totalBookingsRevenue,
          ),
          pw.SizedBox(height: 30),

          // Subscription Metrics Section (NEW)
          if (subscriptionMetrics != null) ...[
            _buildSubscriptionMetricsSection(subscriptionMetrics),
            pw.SizedBox(height: 30),
          ],

          // FCM Efficiency Section (NEW)
          if (fcmMetrics != null) ...[
            _buildFcmEfficiencySection(fcmMetrics),
            pw.SizedBox(height: 30),
          ],

          // Subscriptions Section
          if (subscriptions.isNotEmpty) ...[
            _buildSectionTitle('Assinaturas Ativas'),
            _buildSubscriptionsTable(subscriptions),
            pw.SizedBox(height: 30),
          ],

          // Transactions Section
          if (transactions.isNotEmpty) ...[
            _buildSectionTitle('Transações'),
            _buildTransactionsTable(transactions),
            pw.SizedBox(height: 30),
          ],

          // Bookings Section with Enhanced Details
          if (bookings.isNotEmpty) ...[
            _buildSectionTitle('Agendamentos Finalizados'),
            _buildEnhancedBookingsTable(bookings),
            pw.SizedBox(height: 30),
          ],

          // Automated Insights Section
          _buildInsightsSection(
            subscriptions: subscriptions,
            totalRevenue: totalRevenue,
            activeSubscriptions: activeSubscriptions,
            totalBookingsRevenue: totalBookingsRevenue,
            metrics: subscriptionMetrics,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(DateTimeRange period, pw.MemoryImage logo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Relatório Financeiro',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Período: ${_dateFormat.format(period.start)} - ${_dateFormat.format(period.end)}',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300, width: 1),
              ),
              child: pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(logo, fit: pw.BoxFit.cover),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Gerado em: ${_dateFormat.format(DateTime.now())} às ${DateFormat('HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  pw.Widget _buildSummarySection({
    required int activeSubscriptions,
    required double totalSubscriptionRevenue,
    required double totalTransactions,
    required double totalBookingsRevenue,
  }) {
    final totalRevenue =
        totalSubscriptionRevenue + totalTransactions + totalBookingsRevenue;

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildMetricCard('Receita Total', _currency.format(totalRevenue)),
          _buildMetricCard(
            'Assinaturas Ativas',
            activeSubscriptions.toString(),
          ),
          _buildMetricCard('MRR', _currency.format(totalSubscriptionRevenue)),
          _buildMetricCard(
            'Serviços Avulsos',
            _currency.format(totalBookingsRevenue),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetricCard(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  pw.Widget _buildSubscriptionsTable(List<StripeSubscription> subscriptions) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
      },
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headers: ['Cliente', 'Email', 'Status', 'Valor', 'Período'],
      data: subscriptions.map((s) {
        final start = DateTime.fromMillisecondsSinceEpoch(
          s.currentPeriodStart * 1000,
        );
        final end = DateTime.fromMillisecondsSinceEpoch(
          s.currentPeriodEnd * 1000,
        );
        return [
          s.customerName ?? '-',
          s.customerEmail ?? '-',
          _getStatusLabel(s.status),
          _currency.format(s.amount),
          '${_dateFormat.format(start)} - ${_dateFormat.format(end)}',
        ];
      }).toList(),
    );
  }

  pw.Widget _buildTransactionsTable(List<StripeTransaction> transactions) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headers: ['Data', 'Cliente', 'Valor', 'Status', 'Descrição'],
      data: transactions.map((t) {
        final date = DateTime.fromMillisecondsSinceEpoch(t.createdAt * 1000);
        return [
          _dateFormat.format(date),
          t.customerEmail ?? '-',
          _currency.format(t.amount),
          t.paid ? 'Pago' : (t.refunded ? 'Reembolsado' : 'Pendente'),
          t.description ?? '-',
        ];
      }).toList(),
    );
  }

  pw.Widget _buildBookingsTable(List<Booking> bookings) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
      },
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headers: ['Data', 'Serviços', 'Valor'],
      data: bookings.map((b) {
        return [
          _dateFormat.format(b.scheduledTime),
          '${b.serviceIds.length} serviço(s)',
          _currency.format(b.totalPrice),
        ];
      }).toList(),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'canceled':
        return 'Cancelado';
      case 'past_due':
        return 'Vencido';
      case 'trialing':
        return 'Em Avaliação';
      default:
        return status;
    }
  }

  /// Builds the subscription metrics section with MRR, Churn, Conversion
  pw.Widget _buildSubscriptionMetricsSection(SubscriptionMetrics metrics) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Métricas de Assinatura',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildMetricBox(
                'MRR',
                _currency.format(metrics.mrr),
                _accentColor,
              ),
              _buildMetricBox(
                'Churn Rate',
                '${metrics.churnRate.toStringAsFixed(1)}%',
                metrics.churnRate > 5 ? PdfColors.red : PdfColors.green,
              ),
              _buildMetricBox(
                'Conversão',
                '${metrics.conversionRate.toStringAsFixed(1)}%',
                metrics.conversionRate > 10
                    ? PdfColors.green
                    : PdfColors.orange,
              ),
              _buildMetricBox(
                'Inadimplentes',
                metrics.delinquent.toString(),
                metrics.delinquent > 0 ? PdfColors.red : PdfColors.green,
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildMetricBox(
                'Novos Assinantes',
                '+${metrics.newSubscribersThisMonth}',
                PdfColors.green,
              ),
              _buildMetricBox(
                'Cancelamentos',
                '-${metrics.canceledThisMonth}',
                PdfColors.red,
              ),
              _buildMetricBox(
                'Variação MRR',
                '${metrics.mrrChangePercent >= 0 ? '+' : ''}${metrics.mrrChangePercent.toStringAsFixed(1)}%',
                metrics.mrrChangePercent >= 0 ? PdfColors.green : PdfColors.red,
              ),
              _buildMetricBox(
                'Total Ativos',
                metrics.activeSubscribers.toString(),
                _accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the FCM notification efficiency section
  pw.Widget _buildFcmEfficiencySection(FcmEfficiencyMetrics metrics) {
    final hoursFormatted = (metrics.estimatedTimeSavedMinutes / 60)
        .toStringAsFixed(1);

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Eficiência de Notificações (FCM)',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  '${hoursFormatted}h economizadas',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildFcmMetricBox(
                'Total Enviadas',
                metrics.totalNotificationsThisMonth.toString(),
              ),
              _buildFcmMetricBox(
                'Carro Pronto',
                metrics.carrosProntosCount.toString(),
              ),
              _buildFcmMetricBox(
                'Status Updates',
                metrics.statusUpdatesCount.toString(),
              ),
              _buildFcmMetricBox(
                'Lembretes',
                metrics.remindersCount.toString(),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'O sistema enviou ${metrics.totalNotificationsThisMonth} notificações automaticamente, economizando aproximadamente $hoursFormatted horas de trabalho manual da sua equipe.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  /// Helper for subscription metrics box
  pw.Widget _buildMetricBox(String label, String value, PdfColor valueColor) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    );
  }

  /// Helper for FCM metrics box
  pw.Widget _buildFcmMetricBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: _accentColor,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    );
  }

  /// Enhanced summary section with additional KPIs
  pw.Widget _buildEnhancedSummarySection({
    required int activeSubscriptions,
    required double totalSubscriptionRevenue,
    required double totalTransactions,
    required double totalBookingsRevenue,
    required double arpu,
    required double retentionRate,
    double? revenueGrowth,
  }) {
    final totalRevenue =
        totalSubscriptionRevenue + totalTransactions + totalBookingsRevenue;

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // First Row - Main KPIs
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard('Receita Total', _currency.format(totalRevenue)),
              _buildMetricCard(
                'Assinaturas Ativas',
                activeSubscriptions.toString(),
              ),
              _buildMetricCard(
                'MRR',
                _currency.format(totalSubscriptionRevenue),
              ),
              _buildMetricCard(
                'Serviços Avulsos',
                _currency.format(totalBookingsRevenue),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 15),
          // Second Row - Additional KPIs
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard('ARPU', _currency.format(arpu)),
              _buildMetricCard(
                'Taxa de Retenção',
                '${retentionRate.toStringAsFixed(1)}%',
              ),
              if (revenueGrowth != null)
                _buildMetricCard(
                  'Crescimento MRR',
                  '${revenueGrowth >= 0 ? '+' : ''}${revenueGrowth.toStringAsFixed(1)}%',
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Comparative analysis section
  pw.Widget _buildComparativeAnalysisSection({
    required double currentRevenue,
    required double previousRevenue,
    required double revenueGrowth,
    required double currentMRR,
    required double previousMRR,
    required int currentActiveClients,
    required int previousActiveClients,
  }) {
    final mrrGrowth = previousMRR > 0
        ? ((currentMRR - previousMRR) / previousMRR) * 100
        : 0.0;
    final clientGrowth = previousActiveClients > 0
        ? ((currentActiveClients - previousActiveClients) /
                  previousActiveClients) *
              100
        : 0.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.blue50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Comparativo com Período Anterior',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableHeaderCell('Métrica'),
                  _buildTableHeaderCell('Atual'),
                  _buildTableHeaderCell('Anterior'),
                  _buildTableHeaderCell('Variação'),
                ],
              ),
              // Receita Total
              _buildComparisonRow(
                'Receita Total',
                _currency.format(currentRevenue),
                _currency.format(previousRevenue),
                revenueGrowth,
              ),
              // MRR
              _buildComparisonRow(
                'MRR',
                _currency.format(currentMRR),
                _currency.format(previousMRR),
                mrrGrowth,
              ),
              // Clientes Ativos
              _buildComparisonRow(
                'Clientes Ativos',
                currentActiveClients.toString(),
                previousActiveClients.toString(),
                clientGrowth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildComparisonRow(
    String metric,
    String current,
    String previous,
    double growth,
  ) {
    final growthStr = '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%';
    final growthColor = growth >= 0 ? PdfColors.green : PdfColors.red;
    final arrow = growth >= 0 ? '↑' : '↓';

    return pw.TableRow(
      children: [
        _buildTableCell(metric),
        _buildTableCell(current),
        _buildTableCell(previous),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                growthStr,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: growthColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(width: 2),
              pw.Text(
                arrow,
                style: pw.TextStyle(fontSize: 10, color: growthColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Revenue breakdown by subscription plan
  pw.Widget _buildRevenueBreakdownSection(
    List<StripeSubscription> subscriptions,
  ) {
    // Group subscriptions by plan
    final planRevenue = <String, double>{};
    final planCount = <String, int>{};

    for (final sub in subscriptions.where((s) => s.status == 'active')) {
      final planName = '${sub.interval} - ${_currency.format(sub.amount)}';
      planRevenue[planName] = (planRevenue[planName] ?? 0) + sub.amount;
      planCount[planName] = (planCount[planName] ?? 0) + 1;
    }

    final totalRevenue = planRevenue.values.fold<double>(
      0,
      (sum, v) => sum + v,
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Receita por Plano',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 15),
          if (planRevenue.isEmpty)
            pw.Text(
              'Nenhum plano ativo neste período',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableHeaderCell('Plano'),
                    _buildTableHeaderCell('Qtd. Clientes'),
                    _buildTableHeaderCell('Receita'),
                    _buildTableHeaderCell('% Total'),
                  ],
                ),
                // Data rows
                ...planRevenue.entries.map((entry) {
                  final planName = entry.key;
                  final revenue = entry.value;
                  final count = planCount[planName] ?? 0;
                  final percentage = totalRevenue > 0
                      ? (revenue / totalRevenue) * 100
                      : 0;

                  return pw.TableRow(
                    children: [
                      _buildTableCell(planName),
                      _buildTableCell(count.toString()),
                      _buildTableCell(_currency.format(revenue)),
                      _buildTableCell('${percentage.toStringAsFixed(1)}%'),
                    ],
                  );
                }),
                // Total row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildTableCell('Total'),
                    _buildTableCell(
                      subscriptions
                          .where((s) => s.status == 'active')
                          .length
                          .toString(),
                    ),
                    _buildTableCell(_currency.format(totalRevenue)),
                    _buildTableCell('100%'),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Cash flow summary section
  pw.Widget _buildCashFlowSection({
    required double totalRevenue,
    required double receivedAmount,
    required double pendingAmount,
    required double delinquentAmount,
  }) {
    final netReceipt = receivedAmount > 0
        ? (receivedAmount / totalRevenue) * 100
        : 100.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.green50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumo de Caixa',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildCashFlowMetric(
                '[OK] Recebido',
                _currency.format(receivedAmount),
                PdfColors.green,
              ),
              _buildCashFlowMetric(
                '[PEND] Pendente',
                _currency.format(pendingAmount),
                PdfColors.orange,
              ),
              _buildCashFlowMetric(
                '[ATRASO] Inadimplente',
                _currency.format(delinquentAmount),
                PdfColors.red,
              ),
              _buildCashFlowMetric(
                'Taxa Liquida',
                '${netReceipt.toStringAsFixed(1)}%',
                _accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCashFlowMetric(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Revenue projections section
  pw.Widget _buildProjectionsSection({
    required double currentMRR,
    required double avgServiceRevenue,
  }) {
    final guaranteedMRR = currentMRR;
    final estimatedServices = avgServiceRevenue * 1.2; // 20% growth estimate
    final projectedRevenue = guaranteedMRR + estimatedServices;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.purple200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.purple50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Projeção Próximo Mês',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildProjectionMetric(
                'MRR Garantido',
                _currency.format(guaranteedMRR),
              ),
              _buildProjectionMetric(
                'Estimativa Serviços',
                _currency.format(estimatedServices),
              ),
              _buildProjectionMetric(
                'Receita Projetada',
                _currency.format(projectedRevenue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectionMetric(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: _accentColor,
          ),
        ),
      ],
    );
  }

  /// Enhanced bookings table with more details
  pw.Widget _buildEnhancedBookingsTable(List<Booking> bookings) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headers: ['Data', 'Cliente', 'Serviços', 'Valor'],
      data: bookings.map((b) {
        return [
          _dateFormat.format(b.scheduledTime),
          b.userId.substring(0, 8), // Show first 8 chars of user ID
          '${b.serviceIds.length} serviço(s)',
          _currency.format(b.totalPrice),
        ];
      }).toList(),
    );
  }

  /// Automated insights section
  pw.Widget _buildInsightsSection({
    required List<StripeSubscription> subscriptions,
    required double totalRevenue,
    required int activeSubscriptions,
    required double totalBookingsRevenue,
    SubscriptionMetrics? metrics,
  }) {
    final insights = <String>[];

    // All subscriptions active
    if (activeSubscriptions > 0 &&
        subscriptions.where((s) => s.status != 'active').isEmpty) {
      insights.add('[OK] Todas as assinaturas estao ativas e em dia');
    }

    // No service revenue
    if (totalBookingsRevenue == 0) {
      insights.add(
        '[ATENCAO] Nenhum servico avulso realizado neste periodo - oportunidade de upsell',
      );
    }

    // MRR portion
    final mrrPercentage = totalRevenue > 0
        ? (subscriptions
                      .where((s) => s.status == 'active')
                      .fold<double>(0, (sum, s) => sum + s.amount) /
                  totalRevenue) *
              100
        : 0;
    insights.add(
      '[METRICAS] MRR representa ${mrrPercentage.toStringAsFixed(1)}% da receita total',
    );

    // Growth target
    final targetRevenue = 500.0;
    if (totalRevenue < targetRevenue) {
      final gap = targetRevenue - totalRevenue;
      final neededSubs =
          (gap /
                  (activeSubscriptions > 0
                      ? totalRevenue / activeSubscriptions
                      : 100))
              .ceil();
      insights.add(
        '[META] Para atingir R\$ ${_currency.format(targetRevenue)}/mes, voce precisa de +$neededSubs assinantes ou ${_currency.format(gap)} em servicos avulsos',
      );
    }

    // Churn warning
    if (metrics != null && metrics.churnRate > 5) {
      insights.add(
        '[ALERTA] Taxa de Churn elevada (${metrics.churnRate.toStringAsFixed(1)}%) - atencao a retencao',
      );
    }

    // Good retention
    if (metrics != null && metrics.churnRate == 0) {
      insights.add('[EXCELENTE] Churn Rate: 0%');
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow50,
        border: pw.Border.all(color: PdfColors.yellow200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Insights Automaticos',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 10),
          ...insights.map(
            (insight) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                  pw.Expanded(
                    child: pw.Text(
                      insight,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows print/save dialog for the generated PDF.
  Future<void> printReport(Uint8List pdfBytes, BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name:
          'relatorio_financeiro_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Shares the PDF directly on mobile or downloads on web.
  Future<void> shareReport(Uint8List pdfBytes) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          'relatorio_financeiro_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}
