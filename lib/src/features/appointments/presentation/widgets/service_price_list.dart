import 'package:flutter/material.dart';

class ServicePriceList extends StatelessWidget {
  final Map<String, double> prices;
  final String? selectedService;
  final Function(String) onServiceSelected;

  const ServicePriceList({
    super.key,
    required this.prices,
    required this.selectedService,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Sort keys or use defined order if needed
    final services = prices.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (services.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nenhum serviço disponível para esta categoria.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...services.map((service) {
            final price = prices[service]!;
            final isSelected = selectedService == service;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ServicePriceCard(
                serviceName: _formatServiceName(service),
                price: price,
                isSelected: isSelected,
                onTap: () => onServiceSelected(service),
              ),
            );
          }),
      ],
    );
  }

  String _formatServiceName(String key) {
    // Convert SCREAMING_SNAKE_CASE to Title Case
    // e.g., LAVAGEM_SIMPLES -> Lavagem Simples
    return key
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _ServicePriceCard extends StatelessWidget {
  final String serviceName;
  final double price;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServicePriceCard({
    required this.serviceName,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.05) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: primaryColor, width: 2)
              : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                serviceName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            Text(
              'R\$ ${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? primaryColor
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
