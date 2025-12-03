import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../ecommerce/domain/coupon.dart';
import '../../../../ecommerce/data/coupon_repository.dart';

class CouponFormDialog extends ConsumerStatefulWidget {
  final Coupon? coupon;

  const CouponFormDialog({super.key, this.coupon});

  @override
  ConsumerState<CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends ConsumerState<CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  late TextEditingController _maxUsesController;
  late TextEditingController _minPurchaseController;

  CouponType _selectedType = CouponType.percentage;
  final List<CouponApplicableTo> _selectedApplicableTo = [];
  DateTime? _validFrom;
  DateTime? _validUntil;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.coupon?.code ?? '');
    _nameController = TextEditingController(text: widget.coupon?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.coupon?.description ?? '',
    );
    _valueController = TextEditingController(
      text: widget.coupon?.value.toString() ?? '',
    );
    _maxUsesController = TextEditingController(
      text: widget.coupon?.maxUses?.toString() ?? '',
    );
    _minPurchaseController = TextEditingController(
      text: widget.coupon?.minimumPurchase?.toString() ?? '',
    );

    _selectedType = widget.coupon?.type ?? CouponType.percentage;

    if (widget.coupon != null) {
      _selectedApplicableTo.addAll(widget.coupon!.applicableTo);
      _validFrom = widget.coupon!.validFrom;
      _validUntil = widget.coupon!.validUntil;
    } else {
      // Default to services
      _selectedApplicableTo.add(CouponApplicableTo.services);
      // Default valid from now
      _validFrom = DateTime.now();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _maxUsesController.dispose();
    _minPurchaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.coupon != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Cupom' : 'Novo Cupom'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código do Cupom *',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: VERAO2024',
                    helperText: 'Será convertido para maiúsculas',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (value.contains(' ')) {
                      return 'Não pode conter espaços';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Promoção *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Text(
                  'Configuração do Desconto',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CouponType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(),
                        ),
                        items: CouponType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _valueController,
                        decoration: InputDecoration(
                          labelText: 'Valor *',
                          border: const OutlineInputBorder(),
                          suffixText: _selectedType == CouponType.percentage
                              ? '%'
                              : null,
                          prefixText: _selectedType == CouponType.fixed
                              ? 'R\$ '
                              : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          final number = double.tryParse(value);
                          if (number == null) return 'Inválido';
                          if (_selectedType == CouponType.percentage &&
                              number > 100) {
                            return 'Máximo 100%';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Aplicável a',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: CouponApplicableTo.values.map((type) {
                    final isSelected = _selectedApplicableTo.contains(type);
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type.icon),
                          const SizedBox(width: 4),
                          Text(type.displayName),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedApplicableTo.add(type);
                          } else {
                            _selectedApplicableTo.remove(type);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                if (_selectedApplicableTo.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Selecione pelo menos um tipo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Regras e Limites',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minPurchaseController,
                        decoration: const InputDecoration(
                          labelText: 'Compra Mínima (R\$)',
                          border: OutlineInputBorder(),
                          helperText: 'Opcional',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxUsesController,
                        decoration: const InputDecoration(
                          labelText: 'Limite de Usos',
                          border: OutlineInputBorder(),
                          helperText: 'Opcional (Vazio = Ilimitado)',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Válido de',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _validFrom != null
                                ? DateFormat('dd/MM/yyyy').format(_validFrom!)
                                : 'Selecionar',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Válido até',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.event_busy),
                            helperText: 'Opcional',
                          ),
                          child: Text(
                            _validUntil != null
                                ? DateFormat('dd/MM/yyyy').format(_validUntil!)
                                : 'Sem validade',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveCoupon,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart
        ? (_validFrom ?? DateTime.now())
        : (_validUntil ?? DateTime.now().add(const Duration(days: 30)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _validFrom = picked;
        } else {
          _validUntil = picked;
        }
      });
    }
  }

  Future<void> _saveCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedApplicableTo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione onde o cupom pode ser aplicado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(couponRepositoryProvider);

      final coupon = Coupon(
        id: widget.coupon?.id ?? '',
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        value: double.parse(_valueController.text),
        applicableTo: List.from(_selectedApplicableTo),
        validFrom: _validFrom,
        validUntil: _validUntil,
        maxUses: _maxUsesController.text.isEmpty
            ? null
            : int.parse(_maxUsesController.text),
        minimumPurchase: _minPurchaseController.text.isEmpty
            ? null
            : double.parse(_minPurchaseController.text),
        usedCount: widget.coupon?.usedCount ?? 0,
        isActive: widget.coupon?.isActive ?? true,
        stripeCouponId: widget.coupon?.stripeCouponId,
        createdAt: widget.coupon?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.coupon == null) {
        await repository.createCoupon(coupon);
      } else {
        await repository.updateCoupon(coupon);
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.coupon == null
                ? 'Cupom criado com sucesso!'
                : 'Cupom atualizado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar cupom: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
