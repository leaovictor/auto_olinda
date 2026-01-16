import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../profile/domain/vehicle.dart';

import '../../widgets/admin_text_field.dart';
import '../../widgets/admin_dropdown_field.dart';

class EditVehicleDialog extends ConsumerStatefulWidget {
  final Vehicle? vehicle;
  final Function(Vehicle) onSave;

  const EditVehicleDialog({super.key, this.vehicle, required this.onSave});

  @override
  ConsumerState<EditVehicleDialog> createState() => _EditVehicleDialogState();
}

class _EditVehicleDialogState extends ConsumerState<EditVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _colorController;
  String _selectedType = 'sedan';

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.vehicle?.brand);
    _modelController = TextEditingController(text: widget.vehicle?.model);
    _plateController = TextEditingController(text: widget.vehicle?.plate);
    _colorController = TextEditingController(text: widget.vehicle?.color);
    if (widget.vehicle != null) {
      _selectedType = widget.vehicle!.type;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.vehicle == null ? 'Adicionar Veículo' : 'Editar Veículo',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminTextField(
                label: 'Marca',
                controller: _brandController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AdminTextField(
                label: 'Modelo',
                controller: _modelController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AdminTextField(
                label: 'Placa',
                controller: _plateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AdminTextField(
                label: 'Cor',
                controller: _colorController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AdminDropdownField<String>(
                label: 'Tipo',
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'sedan', child: Text('Sedan')),
                  DropdownMenuItem(value: 'hatch', child: Text('Hatch')),
                  DropdownMenuItem(value: 'suv', child: Text('SUV')),
                  DropdownMenuItem(value: 'pickup', child: Text('Pickup')),
                  DropdownMenuItem(value: 'motorcycle', child: Text('Moto')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newVehicle = Vehicle(
        id:
            widget.vehicle?.id ??
            '', // ID will be handled by repository for new vehicles
        brand: _brandController.text,
        model: _modelController.text,
        plate: _plateController.text,
        color: _colorController.text,
        type: _selectedType,
        photoUrl: widget.vehicle?.photoUrl,
      );
      widget.onSave(newVehicle);
      Navigator.pop(context);
    }
  }
}
