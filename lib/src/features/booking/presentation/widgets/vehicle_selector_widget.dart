import 'package:flutter/material.dart';
import '../../../../features/profile/domain/vehicle.dart';
import 'vehicle_card.dart';

class VehicleSelectorWidget extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final Function(Vehicle) onVehicleSelected;
  final VoidCallback? onAddVehicle;

  const VehicleSelectorWidget({
    super.key,
    required this.vehicles,
    required this.selectedVehicle,
    required this.onVehicleSelected,
    this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selecione o veículo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (onAddVehicle != null)
              TextButton.icon(
                onPressed: onAddVehicle,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (vehicles.isEmpty)
          _buildEmptyState(context)
        else
          ...vehicles.map(
            (vehicle) => VehicleCard(
              vehicle: vehicle,
              isSelected: vehicle.id == selectedVehicle?.id,
              onTap: () => onVehicleSelected(vehicle),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum veículo cadastrado',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (onAddVehicle != null)
              ElevatedButton(
                onPressed: onAddVehicle,
                child: const Text('Cadastrar meu primeiro carro'),
              ),
          ],
        ),
      ),
    );
  }
}
