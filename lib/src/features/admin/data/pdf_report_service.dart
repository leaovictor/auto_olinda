import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  }) async {
    final pdf = pw.Document();

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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(period),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Summary Section
          _buildSummarySection(
            activeSubscriptions: activeSubscriptions,
            totalSubscriptionRevenue: totalSubscriptionRevenue,
            totalTransactions: totalTransactions,
            totalBookingsRevenue: totalBookingsRevenue,
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

          // Bookings Section
          if (bookings.isNotEmpty) ...[
            _buildSectionTitle('Agendamentos Finalizados'),
            _buildBookingsTable(bookings),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(DateTimeRange period) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Relatório Financeiro',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            pw.Text(
              'Auto Olinda',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: _accentColor,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Período: ${_dateFormat.format(period.start)} - ${_dateFormat.format(period.end)}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
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
