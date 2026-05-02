import 'package:flutter/material.dart';
import '../../../../common_widgets/atoms/app_card.dart';
import '../../domain/subscription_details.dart';

class SubscriptionPaymentMethodCard extends StatelessWidget {
  final SubscriptionPaymentMethod? paymentMethod;
  final VoidCallback? onUpdatePressed;

  const SubscriptionPaymentMethodCard({
    required this.paymentMethod,
    this.onUpdatePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // If no payment method is available (e.g. legacy sub or error), show generic message or hide
    if (paymentMethod == null) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.credit_card_off, color: Colors.grey),
            const SizedBox(width: 16),
            const Expanded(child: Text('Nenhum método de pagamento salvo.')),
            if (onUpdatePressed != null)
              TextButton(
                onPressed: onUpdatePressed,
                child: const Text('Adicionar'),
              ),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    final brandIcon = _getBrandIcon(paymentMethod!.brand);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Método de Pagamento',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (onUpdatePressed != null)
                TextButton(
                  onPressed: onUpdatePressed,
                  child: const Text('Atualizar'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(brandIcon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•••• ${paymentMethod!.last4}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Expira em ${paymentMethod!.expMonth}/${paymentMethod!.expYear}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getBrandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons
            .credit_card; // In a real app, use brand assets or FontAwesome
      case 'mastercard':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}
