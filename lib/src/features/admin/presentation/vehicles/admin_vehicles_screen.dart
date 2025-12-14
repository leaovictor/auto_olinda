import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_repository.dart';
import '../../../profile/domain/vehicle.dart';
import '../../../../common_widgets/atoms/app_text_field.dart';
import '../../../../common_widgets/molecules/app_refresh_indicator.dart';

/// Admin screen to view and manage all registered vehicles
class AdminVehiclesScreen extends ConsumerStatefulWidget {
  const AdminVehiclesScreen({super.key});

  @override
  ConsumerState<AdminVehiclesScreen> createState() =>
      _AdminVehiclesScreenState();
}

class _AdminVehiclesScreenState extends ConsumerState<AdminVehiclesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'model'; // model, plate, lastWash

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehiclesAsync = ref.watch(adminVehiclesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminVehiclesProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Veículos Cadastrados",
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Visualize todos os veículos registrados pelos clientes.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Search and Filter Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      label: 'Buscar Veículo',
                      hint: 'Modelo, placa ou cor',
                      controller: _searchController,
                      prefixIcon: const Icon(Icons.search),
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _sortBy,
                      decoration: const InputDecoration(
                        labelText: 'Ordenar por',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'model', child: Text('Modelo')),
                        DropdownMenuItem(value: 'plate', child: Text('Placa')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortBy = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Row
              vehiclesAsync.when(
                data: (vehicles) {
                  return Row(
                    children: [
                      _buildStatCard(
                        theme,
                        "Total de Veículos",
                        vehicles.length.toString(),
                        Icons.directions_car,
                        Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        theme,
                        "Carros",
                        vehicles
                            .where((v) => v.type.toLowerCase() == 'car')
                            .length
                            .toString(),
                        Icons.directions_car_filled,
                        Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        theme,
                        "Motos",
                        vehicles
                            .where((v) => v.type.toLowerCase() == 'motorcycle')
                            .length
                            .toString(),
                        Icons.two_wheeler,
                        Colors.orange,
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 24),

              // Vehicles Grid
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: vehiclesAsync.when(
                  data: (vehicles) {
                    // Filter
                    var filtered = vehicles.where((v) {
                      final model = v.model.toLowerCase();
                      final plate = v.plate.toLowerCase();
                      final color = v.color.toLowerCase();
                      return model.contains(_searchQuery) ||
                          plate.contains(_searchQuery) ||
                          color.contains(_searchQuery);
                    }).toList();

                    // Sort
                    if (_sortBy == 'model') {
                      filtered.sort((a, b) => a.model.compareTo(b.model));
                    } else if (_sortBy == 'plate') {
                      filtered.sort((a, b) => a.plate.compareTo(b.plate));
                    }

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text("Nenhum veículo encontrado."),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Lista de Veículos",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "${filtered.length} veículos",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "VEÍCULO",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "PLACA",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "COR",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "TIPO",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        // Table Rows
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final vehicle = filtered[index];
                            return _buildVehicleRow(theme, vehicle);
                          },
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("Erro: $e")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleRow(ThemeData theme, Vehicle vehicle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    vehicle.type.toLowerCase() == 'motorcycle'
                        ? Icons.two_wheeler
                        : Icons.directions_car,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  vehicle.model,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              vehicle.plate.toUpperCase(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getColorFromName(
                      vehicle.color.isNotEmpty ? vehicle.color : 'grey',
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  vehicle.color.isNotEmpty ? vehicle.color : '-',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vehicle.type.toLowerCase() == 'motorcycle'
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vehicle.type.toLowerCase() == 'motorcycle' ? 'Moto' : 'Carro',
                style: TextStyle(
                  color: vehicle.type.toLowerCase() == 'motorcycle'
                      ? Colors.orange
                      : Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'preto':
      case 'black':
        return Colors.black;
      case 'branco':
      case 'white':
        return Colors.white;
      case 'prata':
      case 'silver':
        return Colors.grey[400]!;
      case 'vermelho':
      case 'red':
        return Colors.red;
      case 'azul':
      case 'blue':
        return Colors.blue;
      case 'verde':
      case 'green':
        return Colors.green;
      case 'amarelo':
      case 'yellow':
        return Colors.yellow;
      case 'laranja':
      case 'orange':
        return Colors.orange;
      case 'cinza':
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
