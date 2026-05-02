import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../booking/data/vehicle_repository.dart';
import '../../../profile/domain/vehicle.dart';

class VehicleSelectionSheet extends ConsumerWidget {
  const VehicleSelectionSheet({super.key});

  static Future<Vehicle?> show(BuildContext context) {
    return showModalBottomSheet<Vehicle>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const VehicleSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vehiclesAsync = ref.watch(userVehiclesProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Selecione um Veículo',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          vehiclesAsync.when(
            data: (vehicles) {
              if (vehicles.isEmpty) {
                return const Center(
                  child: Text("Você não possui veículos cadastrados."),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return ListTile(
                    leading: Icon(
                      _getIconForType(vehicle.type),
                      color: theme.colorScheme.primary,
                    ),
                    title: Text('${vehicle.brand} ${vehicle.model}'),
                    subtitle: Text(vehicle.plate),
                    onTap: () => Navigator.pop(context, vehicle),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Erro ao carregar veículos: $err'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'sedan':
        return Icons.directions_car;
      case 'hatch':
        return Icons.directions_car_filled;
      case 'suv':
        return Icons.airport_shuttle;
      case 'pickup':
        return Icons.local_shipping;
      case 'moto':
        return Icons.two_wheeler;
      default:
        return Icons.directions_car;
    }
  }
}
