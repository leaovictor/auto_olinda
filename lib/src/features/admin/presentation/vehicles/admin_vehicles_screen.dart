import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_repository.dart';
import '../../../profile/domain/vehicle.dart';

import '../../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../theme/admin_theme.dart';

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
    final vehiclesAsync = ref.watch(adminVehiclesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Veículos Cadastrados', style: AdminTheme.headingMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminTheme.textPrimary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AdminTheme.bgDark.withOpacity(0.9), Colors.transparent],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: AppRefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminVehiclesProvider);
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: kToolbarHeight + 40,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  "Visualize todos os veículos registrados pelos clientes.",
                  style: AdminTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

              // Search and Filter Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Buscar Veículo',
                        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                        hintText: 'Modelo, placa ou cor',
                        hintStyle: const TextStyle(color: AdminTheme.textSecondary),
                        prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary),
                        filled: true,
                        fillColor: AdminTheme.bgCardLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AdminTheme.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AdminTheme.borderLight),
                        ),
                      ),
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
                      dropdownColor: AdminTheme.bgCard,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Ordenar por',
                        labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                        filled: true,
                        fillColor: AdminTheme.bgCardLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AdminTheme.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AdminTheme.borderLight),
                        ),
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
                        "Total de Veículos",
                        vehicles.length.toString(),
                        Icons.directions_car,
                        Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
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
                decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
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
                          child: Text("Nenhum veículo encontrado.", style: TextStyle(color: AdminTheme.textSecondary)),
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
                                style: AdminTheme.headingSmall,
                              ),
                              const Spacer(),
                              Text(
                                "${filtered.length} veículos",
                                style: AdminTheme.bodyMedium,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        const Divider(color: AdminTheme.borderLight),
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "VEÍCULO",
                                  style: TextStyle(
                                    color: AdminTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "PLACA",
                                  style: TextStyle(
                                    color: AdminTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "COR",
                                  style: TextStyle(
                                    color: AdminTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "TIPO",
                                  style: TextStyle(
                                    color: AdminTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: AdminTheme.borderLight),
                        // Table Rows
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(color: AdminTheme.borderLight, height: 1),
                          itemBuilder: (context, index) {
                            final vehicle = filtered[index];
                            return _buildVehicleRow(vehicle);
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
    ));
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
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
                  style: AdminTheme.headingSmall,
                ),
                Text(
                  title,
                  style: AdminTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleRow(Vehicle vehicle) {
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
                    color: AdminTheme.bgCardLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    vehicle.type.toLowerCase() == 'motorcycle'
                        ? Icons.two_wheeler
                        : Icons.directions_car,
                    color: AdminTheme.gradientPrimary[0],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  vehicle.model,
                  style: AdminTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              vehicle.plate.toUpperCase(),
              style: AdminTheme.bodyMedium.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                color: AdminTheme.textSecondary,
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
                  style: AdminTheme.bodyMedium,
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
