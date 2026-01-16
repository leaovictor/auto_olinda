import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/domain/app_user.dart';
import '../../../../profile/domain/vehicle.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_text_field.dart';
import '../../../../booking/data/vehicle_repository.dart';
import '../../../data/admin_repository.dart';
import 'edit_vehicle_dialog.dart';
import '../../../../../shared/utils/app_toast.dart';

import '../../../../auth/domain/address.dart';

class EditCustomerDialog extends ConsumerStatefulWidget {
  final AppUser user;

  const EditCustomerDialog({super.key, required this.user});

  @override
  ConsumerState<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends ConsumerState<EditCustomerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // User Data Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late bool _isWhatsApp;

  // Address Controllers
  late TextEditingController _cepController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _complementController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize User Data
    _nameController = TextEditingController(text: widget.user.displayName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _isWhatsApp = widget.user.isWhatsApp;

    // Initialize Address Data
    final address = widget.user.address;
    _cepController = TextEditingController(text: address?.cep);
    _streetController = TextEditingController(text: address?.street);
    _numberController = TextEditingController(text: address?.number);
    _complementController = TextEditingController(text: address?.complement);
    _neighborhoodController = TextEditingController(
      text: address?.neighborhood,
    );
    _cityController = TextEditingController(text: address?.city);
    _stateController = TextEditingController(text: address?.state);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();

    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AdminTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Editar Cliente', style: AdminTheme.headingMedium),
              const SizedBox(height: 24),
              TabBar(
                controller: _tabController,
                labelColor: AdminTheme.gradientPrimary[0],
                unselectedLabelColor: AdminTheme.textSecondary,
                indicatorColor: AdminTheme.gradientPrimary[0],
                tabs: const [
                  Tab(text: 'Dados'),
                  Tab(text: 'Endereço'),
                  Tab(text: 'Veículos'),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDataTab(),
                    _buildAddressTab(),
                    _buildVehiclesTab(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AdminTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.gradientPrimary[0],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AdminTextField(
            label: 'Nome',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AdminTextField(
            label: 'Telefone',
            controller: _phoneController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('É WhatsApp?', style: AdminTheme.bodyMedium),
            value: _isWhatsApp,
            activeTrackColor: AdminTheme.gradientPrimary[0],
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() => _isWhatsApp = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AdminTextField(label: 'CEP', controller: _cepController),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: AdminTextField(
                  label: 'Estado',
                  controller: _stateController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AdminTextField(
                  label: 'Cidade',
                  controller: _cityController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AdminTextField(
                  label: 'Bairro',
                  controller: _neighborhoodController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdminTextField(label: 'Rua', controller: _streetController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: AdminTextField(
                  label: 'Número',
                  controller: _numberController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AdminTextField(
                  label: 'Complemento',
                  controller: _complementController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesTab() {
    final vehiclesAsync = ref
        .watch(vehicleRepositoryProvider)
        .getUserVehicles(widget.user.uid);

    return StreamBuilder<List<Vehicle>>(
      stream: vehiclesAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final vehicles = snapshot.data ?? [];

        return Column(
          children: [
            Expanded(
              child: vehicles.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum veículo cadastrado',
                        style: TextStyle(color: AdminTheme.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: vehicles.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: AdminTheme.borderLight),
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return ListTile(
                          leading: Icon(
                            _getVehicleIcon(vehicle.type),
                            color: AdminTheme.gradientPrimary[0],
                          ),
                          title: Text(
                            '${vehicle.brand} ${vehicle.model}',
                            style: AdminTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            '${vehicle.plate} - ${vehicle.color}',
                            style: AdminTheme.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showVehicleDialog(vehicle),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteVehicle(vehicle.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showVehicleDialog(null),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.bgCardLight,
                foregroundColor: AdminTheme.textPrimary,
                side: BorderSide(color: AdminTheme.borderLight),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Veículo'),
            ),
          ],
        );
      },
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'pickup':
        return Icons.local_shipping;
      case 'suv':
        return Icons.directions_car;
      default:
        return Icons.directions_car;
    }
  }

  void _showVehicleDialog(Vehicle? vehicle) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditVehicleDialog(
        vehicle: vehicle,
        onSave: (newVehicle) async {
          try {
            if (vehicle == null) {
              await ref
                  .read(vehicleRepositoryProvider)
                  .createVehicle(newVehicle, widget.user.uid);
            } else {
              await ref
                  .read(vehicleRepositoryProvider)
                  .updateVehicle(newVehicle.copyWith(id: vehicle.id));
            }
            if (mounted) {
              AppToast.success(context, message: 'Veículo salvo com sucesso');
            }
          } catch (e) {
            if (mounted) {
              AppToast.error(context, message: 'Erro ao salvar veículo: $e');
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteVehicle(String vehicleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Veículo'),
        content: const Text('Tem certeza que deseja excluir este veículo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(vehicleRepositoryProvider).deleteVehicle(vehicleId);
        if (mounted) {
          AppToast.success(context, message: 'Veículo excluído com sucesso');
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(context, message: 'Erro ao excluir veículo: $e');
        }
      }
    }
  }

  Future<void> _saveUser() async {
    // Manual validation for required fields
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      if (mounted) {
        AppToast.error(
          context,
          message: 'Por favor, preencha Nome e Telefone na aba Dados.',
        );
      }
      return;
    }

    if (_formKey.currentState?.validate() ?? true) {
      try {
        Address? newAddress;
        if (_cepController.text.isNotEmpty ||
            _streetController.text.isNotEmpty ||
            _cityController.text.isNotEmpty) {
          newAddress = Address(
            cep: _cepController.text,
            street: _streetController.text,
            number: _numberController.text,
            complement: _complementController.text,
            neighborhood: _neighborhoodController.text,
            city: _cityController.text,
            state: _stateController.text,
          );
        }

        final updatedUser = widget.user.copyWith(
          displayName: _nameController.text,
          phoneNumber: _phoneController.text,
          isWhatsApp: _isWhatsApp,
          address: newAddress,
        );

        await ref.read(adminRepositoryProvider).updateUser(updatedUser);

        if (mounted) {
          Navigator.pop(context);
          AppToast.success(context, message: 'Cliente atualizado com sucesso');
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(context, message: 'Erro ao atualizar cliente: $e');
        }
      }
    }
  }
}
