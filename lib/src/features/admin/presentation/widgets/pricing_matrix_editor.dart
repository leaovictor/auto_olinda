import 'package:flutter/material.dart';
import '../../../../shared/enums/vehicle_category.dart';
import '../../../pricing/domain/pricing_matrix.dart';

class PricingMatrixEditor extends StatefulWidget {
  final PricingMatrix currentMatrix;
  final Function(PricingMatrix) onSave;

  const PricingMatrixEditor({
    super.key,
    required this.currentMatrix,
    required this.onSave,
  });

  @override
  State<PricingMatrixEditor> createState() => _PricingMatrixEditorState();
}

class _PricingMatrixEditorState extends State<PricingMatrixEditor> {
  late Map<String, Map<String, double>> _editablePrices;
  late List<String> _serviceTypes;

  @override
  void initState() {
    super.initState();
    _initEditablePrices();
  }

  void _initEditablePrices() {
    _editablePrices = {};
    final Set<String> foundServices = {};

    // Collect all existing services from all categories in the matrix
    if (widget.currentMatrix.prices.isNotEmpty) {
      for (var catValues in widget.currentMatrix.prices.values) {
        foundServices.addAll(catValues.keys);
      }
    }

    // Default initialization if list is empty (first run or completely empty DB)
    if (foundServices.isEmpty) {
      foundServices.addAll([
        'lavagem_simples',
        'lavagem_completa',
        'polimento',
        'cristalizacao',
        'higienizacao_interna',
      ]);
    }

    _serviceTypes = foundServices.toList()..sort();

    // Initialize the editable map structure
    for (var cat in VehicleCategory.values) {
      _editablePrices[cat.value] = {};
      final existingCatPrices = widget.currentMatrix.prices[cat.value] ?? {};

      for (var service in _serviceTypes) {
        _editablePrices[cat.value]![service] =
            existingCatPrices[service] ?? 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Serviços',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: () => _showServiceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Serviço'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(
                    label: Text(
                      'Tipo de Serviço',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...VehicleCategory.values.map(
                    (cat) => DataColumn(
                      label: Text(
                        cat.displayName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                rows: _serviceTypes.map((serviceType) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_formatServiceName(serviceType)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              color: Colors.blueGrey,
                              tooltip: 'Renomear',
                              onPressed: () =>
                                  _showServiceDialog(existingKey: serviceType),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Excluir',
                              onPressed: () => _confirmDelete(serviceType),
                            ),
                          ],
                        ),
                      ),
                      ...VehicleCategory.values.map((category) {
                        return DataCell(
                          _EditablePriceCell(
                            key: ValueKey('${category.value}_${serviceType}'),
                            initialPrice:
                                _editablePrices[category.value]?[serviceType] ??
                                0,
                            onChanged: (newPrice) =>
                                _updatePrice(category, serviceType, newPrice),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Alterações na Matriz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updatePrice(
    VehicleCategory category,
    String serviceType,
    double newPrice,
  ) {
    setState(() {
      if (_editablePrices[category.value] == null) {
        _editablePrices[category.value] = {};
      }
      _editablePrices[category.value]![serviceType] = newPrice;
    });
  }

  Future<void> _showServiceDialog({String? existingKey}) async {
    final isEditing = existingKey != null;
    final initialText = isEditing ? _formatServiceName(existingKey) : '';
    final controller = TextEditingController(text: initialText);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Renomear Serviço' : 'Novo Serviço'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome do Serviço',
            hintText: 'Ex: Lavagem Americana',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(isEditing ? 'Salvar' : 'Adicionar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final newKey = _toKey(result);
      if (existingKey == newKey) return;

      if (_serviceTypes.contains(newKey)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Já existe um serviço com este nome!'),
            ),
          );
        }
        return;
      }

      setState(() {
        if (isEditing) {
          // Rename: Move data to new key and remove old
          final index = _serviceTypes.indexOf(existingKey);
          if (index != -1) {
            _serviceTypes[index] = newKey;
            _serviceTypes.sort();

            // Move prices
            for (var cat in VehicleCategory.values) {
              final val = _editablePrices[cat.value]?[existingKey] ?? 0.0;
              _editablePrices[cat.value]![newKey] = val;
              _editablePrices[cat.value]!.remove(existingKey);
            }
          }
        } else {
          // Add new
          _serviceTypes.add(newKey);
          _serviceTypes.sort();
          for (var cat in VehicleCategory.values) {
            _editablePrices[cat.value]![newKey] = 0.0;
          }
        }
      });
    }
  }

  Future<void> _confirmDelete(String serviceKey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o serviço "${_formatServiceName(serviceKey)}"?\nIsso removerá os preços definidos para ele.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _serviceTypes.remove(serviceKey);
        for (var cat in VehicleCategory.values) {
          _editablePrices[cat.value]?.remove(serviceKey);
        }
      });
    }
  }

  String _toKey(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  void _saveChanges() {
    widget.onSave(
      widget.currentMatrix.copyWith(
        prices: _editablePrices,
        updatedAt: DateTime.now(),
      ),
    );
  }

  String _formatServiceName(String key) {
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

class _EditablePriceCell extends StatefulWidget {
  final double initialPrice;
  final ValueChanged<double> onChanged;

  const _EditablePriceCell({
    super.key,
    required this.initialPrice,
    required this.onChanged,
  });

  @override
  State<_EditablePriceCell> createState() => _EditablePriceCellState();
}

class _EditablePriceCellState extends State<_EditablePriceCell> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialPrice.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(_EditablePriceCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPrice != widget.initialPrice) {
      // Only update if not focused to avoid overwriting user input while typing?
      // Actually for simplicity in table, we might just keep local state until submitted or focus lost
      // But here we rely on init state.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          prefixText: 'R\$ ',
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          border: UnderlineInputBorder(),
        ),
        onChanged: (value) {
          final price = double.tryParse(value.replaceAll(',', '.'));
          if (price != null) {
            widget.onChanged(price);
          }
        },
      ),
    );
  }
}
