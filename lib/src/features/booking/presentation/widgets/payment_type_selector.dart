import 'package:flutter/material.dart';
import '../../../profile/domain/vehicle.dart';
import '../../domain/vehicle_subscription_status.dart';

class PaymentTypeSelector extends StatelessWidget {
  final Vehicle? selectedVehicle;
  final String? serviceType;
  final VehicleSubscriptionStatus subscriptionStatus;
  final double? cashPrice;

  const PaymentTypeSelector({
    super.key,
    this.selectedVehicle,
    this.serviceType,
    required this.subscriptionStatus,
    this.cashPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedVehicle == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subscriptionStatus.canUseSubscription)
          _buildSubscriptionOption(context)
        else
          _buildCashOnlyOption(context),
      ],
    );
  }

  Widget _buildSubscriptionOption(BuildContext context) {
    // We can cast here safely because we checked canUseSubscription
    // But to be cleaner, we could use map or when from freezed if we want
    // For now, let's just display assumes happy path

    // We need to access remaining washes safely if we want to show it
    // The status check in parent widget handles logic

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usar saldo da assinatura',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const Text(
                    'Sem custo adicional',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashOnlyOption(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.payments, color: Colors.orange),
                  const SizedBox(width: 12),
                  const Text(
                    'Pagamento avulso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              if (cashPrice != null)
                Text(
                  'R\$ ${cashPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Veículo não incluído na assinatura ou cota excedida.',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
