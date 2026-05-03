import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/atoms/app_card.dart';
import '../../domain/subscription_details.dart';
import '../../domain/subscription_plan.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final SubscriptionDetails details;
  final bool isPromo;

  const SubscriptionStatusCard({
    required this.plan,
    required this.details,
    this.isPromo = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(details.status);
    final statusText = _getStatusText(
      details.status,
      details.cancelAtPeriodEnd,
    );

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plano Atual',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  isPromo ? 'CORTESIA' : statusText.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            plan.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${plan.price.toStringAsFixed(2)} / mês',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 24),
          _buildInfoRow(
            context,
            isPromo
                ? 'Válido até'
                : details.cancelAtPeriodEnd
                ? 'Cancelamento em'
                : 'Próxima Renovação',
            DateFormat('dd/MM/yyyy').format(
              DateTime.fromMillisecondsSinceEpoch(
                details.currentPeriodEnd * 1000,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (isPromo) return Colors.blue;
    if (details.cancelAtPeriodEnd) return Colors.orange;
    switch (status) {
      case 'active':
      case 'trialing':
        return Colors.green;
      case 'past_due':
        return Colors.red;
      case 'canceled':
      case 'unpaid':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, bool cancelAtPeriodEnd) {
    if (cancelAtPeriodEnd) return 'Cancelamento Pendente';
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'trialing':
        return 'Em Teste';
      case 'past_due':
        return 'Pagamento Pendente';
      case 'canceled':
      case 'unpaid':
        return 'Inativo';
      default:
        return status;
    }
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
