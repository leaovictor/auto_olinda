import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/subscription_invoice.dart';
import '../../../../common_widgets/atoms/app_card.dart';

/// Widget that displays payment history (list of invoices)
class SubscriptionPaymentHistory extends StatelessWidget {
  final List<SubscriptionInvoice> invoices;
  final bool isLoading;

  const SubscriptionPaymentHistory({
    super.key,
    required this.invoices,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Histórico de Pagamento',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 8),

          // Loading state
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          // Empty state
          else if (invoices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 48,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum pagamento registrado',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Invoice list
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoices.length,
              separatorBuilder: (_, __) => Divider(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return _buildInvoiceRow(context, invoice);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(BuildContext context, SubscriptionInvoice invoice) {
    final theme = Theme.of(context);

    // Format date
    final date = DateTime.fromMillisecondsSinceEpoch(invoice.created * 1000);
    final dateFormatted = DateFormat("dd 'de' MMM, yyyy", 'pt_BR').format(date);

    // Format amount (from cents to BRL)
    final amount = invoice.amountPaid / 100;
    final amountFormatted = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(amount);

    // Status info
    final isPaid = invoice.status == 'paid';
    final statusColor = isPaid ? Colors.green : Colors.orange;
    final statusText = isPaid ? 'Pago' : 'Pendente';

    // Payment method info
    String paymentInfo = '';
    if (invoice.paymentMethodBrand != null &&
        invoice.paymentMethodLast4 != null) {
      final brandDisplay = _getBrandDisplayName(invoice.paymentMethodBrand!);
      paymentInfo = 'via $brandDisplay •••• ${invoice.paymentMethodLast4}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Date and payment method
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormatted,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (paymentInfo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      paymentInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              amountFormatted,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Download PDF button
          if (invoice.invoicePdf != null)
            IconButton(
              icon: Icon(
                Icons.download_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Baixar PDF',
              onPressed: () => _openInvoicePdf(invoice.invoicePdf!),
            ),
        ],
      ),
    );
  }

  String _getBrandDisplayName(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'Amex';
      case 'elo':
        return 'Elo';
      default:
        return brand.toUpperCase();
    }
  }

  Future<void> _openInvoicePdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
