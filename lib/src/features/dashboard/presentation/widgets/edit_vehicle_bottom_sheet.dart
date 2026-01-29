import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blurred_overlay/blurred_overlay.dart';
import '../../../profile/domain/vehicle.dart';
import '../../../booking/data/vehicle_repository.dart';
import '../../../../shared/utils/app_toast.dart';
import '../../../../common_widgets/atoms/app_text_field.dart';

class EditVehicleBottomSheet extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const EditVehicleBottomSheet({super.key, required this.vehicle});

  static Future<void> show(BuildContext context, Vehicle vehicle) {
    return showBlurredModalBottomSheet(
      context: context,
      builder: (context) => EditVehicleBottomSheet(vehicle: vehicle),
    );
  }

  @override
  ConsumerState<EditVehicleBottomSheet> createState() =>
      _EditVehicleBottomSheetState();
}

class _EditVehicleBottomSheetState
    extends ConsumerState<EditVehicleBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _colorController;
  late String _selectedType;
  bool _isLoading = false;

  final _vehicleTypes = [
    ('sedan', 'Sedan', Icons.directions_car),
    ('hatch', 'Hatch', Icons.directions_car_filled),
    ('suv', 'SUV', Icons.airport_shuttle),
    ('pickup', 'Pickup', Icons.local_shipping),
    ('motorcycle', 'Moto', Icons.two_wheeler),
  ];

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.vehicle.brand);
    _modelController = TextEditingController(text: widget.vehicle.model);
    _plateController = TextEditingController(text: widget.vehicle.plate);
    _colorController = TextEditingController(text: widget.vehicle.color);
    _selectedType = widget.vehicle.type;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  bool get _isSubscriptionVehicle => widget.vehicle.isSubscriptionVehicle;

  Widget _buildSubscriptionWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este veículo está vinculado a uma assinatura. Categoria e placa não podem ser alteradas.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.edit, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editar Veículo',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.vehicle.plate,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Warning if vehicle has active subscription
                if (_isSubscriptionVehicle) ...[
                  _buildSubscriptionWarning(),
                  const SizedBox(height: 20),
                ],

                // Form fields
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Marca',
                        controller: _brandController,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Modelo',
                        controller: _modelController,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Placa',
                        controller: _plateController,
                        readOnly: _isSubscriptionVehicle,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Cor',
                        controller: _colorController,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Vehicle type selector
                Text(
                  'Tipo de Veículo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _vehicleTypes.map((type) {
                    final isSelected = _selectedType == type.$1;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.$3,
                            size: 18,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(type.$2),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: _isSubscriptionVehicle
                          ? null // Disabled if subscription vehicle
                          : (selected) {
                              if (selected) {
                                setState(() => _selectedType = type.$1);
                              }
                            },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _save,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Salvar Alterações'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedVehicle = Vehicle(
        id: widget.vehicle.id,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        plate: _plateController.text.trim().toUpperCase(),
        color: _colorController.text.trim(),
        type: _selectedType,
        photoUrl: widget.vehicle.photoUrl,
      );

      await ref.read(vehicleRepositoryProvider).updateVehicle(updatedVehicle);

      if (mounted) {
        Navigator.pop(context);
        AppToast.success(context, message: 'Veículo atualizado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
