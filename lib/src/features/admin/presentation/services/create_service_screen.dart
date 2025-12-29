import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../booking/domain/service_package.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  final ServicePackage? serviceToEdit;

  const CreateServiceScreen({super.key, this.serviceToEdit});

  @override
  ConsumerState<CreateServiceScreen> createState() =>
      _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _stripePriceIdController;
  late bool _isPopular;
  late List<TextEditingController> _stepControllers;

  @override
  void initState() {
    super.initState();
    final service = widget.serviceToEdit;
    _titleController = TextEditingController(text: service?.title ?? '');
    _descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    _priceController = TextEditingController(
      text: service?.price.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    _durationController = TextEditingController(
      text: service?.durationMinutes.toString() ?? '',
    );
    _stripePriceIdController = TextEditingController(
      text: service?.stripePriceId ?? '',
    );
    _isPopular = service?.isPopular ?? false;
    _stepControllers =
        service?.steps
            .map((step) => TextEditingController(text: step))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _stripePriceIdController.dispose();
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    setState(() {
      final controller = _stepControllers.removeAt(index);
      controller.dispose();
    });
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price =
        double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
    final duration = int.tryParse(_durationController.text) ?? 0;
    final steps = _stepControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final service = ServicePackage(
      id: widget.serviceToEdit?.id ?? '', // Use existing ID if editing
      title: title,
      description: description,
      price: price,
      durationMinutes: duration,
      stripePriceId: _stripePriceIdController.text.trim().isEmpty
          ? null
          : _stripePriceIdController.text.trim(),
      isPopular: _isPopular,
      steps: steps,
    );

    try {
      if (widget.serviceToEdit != null) {
        await ref.read(bookingRepositoryProvider).updateService(service);
        if (mounted) {
          AppToast.success(context, message: 'Serviço atualizado com sucesso!');
        }
      } else {
        await ref.read(bookingRepositoryProvider).createService(service);
        if (mounted) {
          AppToast.success(context, message: 'Serviço criado com sucesso!');
        }
      }
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao salvar serviço: $e');
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    String? prefixText,
    String? suffixText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      suffixText: suffixText,
      helperText: helperText,
      helperStyle: TextStyle(color: AdminTheme.textSecondary.withOpacity(0.7)),
      prefixStyle: const TextStyle(color: AdminTheme.textPrimary),
      suffixStyle: const TextStyle(color: AdminTheme.textPrimary),
      hintStyle: TextStyle(color: AdminTheme.textSecondary.withOpacity(0.5)),
      labelStyle: const TextStyle(color: AdminTheme.textSecondary),
      filled: true,
      fillColor: AdminTheme.bgCardLight,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AdminTheme.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AdminTheme.gradientPrimary[0]),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.serviceToEdit != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Item' : 'Novo Item',
          style: AdminTheme.headingMedium,
        ),
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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 40,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AdminTheme.textPrimary),
                decoration: _buildInputDecoration(
                  labelText: 'Título do Item',
                  hintText: 'Ex: Lavagem Completa',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AdminTheme.textPrimary),
                decoration: _buildInputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex: Lavagem interna e externa...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      decoration: _buildInputDecoration(
                        labelText: 'Preço (Avulso)',
                        hintText: '0.00',
                        prefixText: 'R\$ ',
                        helperText: 'Preço para não assinantes',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira o preço';
                        }
                        if (double.tryParse(value.replaceAll(',', '.')) ==
                            null) {
                          return 'Preço inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      decoration: _buildInputDecoration(
                        labelText: 'Duração (min)',
                        hintText: '60',
                        suffixText: 'min',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira a duração';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Duração inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AdminTheme.bgCardLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AdminTheme.borderLight),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Serviço Popular',
                    style: TextStyle(color: AdminTheme.textPrimary),
                  ),
                  subtitle: const Text(
                    'Destacar este serviço na lista',
                    style: TextStyle(color: AdminTheme.textSecondary),
                  ),
                  value: _isPopular,
                  activeColor: AdminTheme.gradientPrimary[0],
                  inactiveTrackColor: Colors.grey.withOpacity(0.3),
                  onChanged: (value) {
                    setState(() {
                      _isPopular = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Passos da Lavagem',
                    style: AdminTheme.headingSmall,
                  ),
                  IconButton(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AdminTheme.textPrimary,
                  ),
                ],
              ),
              if (_stepControllers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Nenhum passo adicionado.',
                    style: AdminTheme.bodyMedium.copyWith(
                      color: AdminTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ..._stepControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AdminTheme.gradientPrimary,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          style: const TextStyle(color: AdminTheme.textPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Descrição do passo',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red[300],
                        onPressed: () => _removeStep(index),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stripePriceIdController,
                style: const TextStyle(color: AdminTheme.textPrimary),
                decoration: _buildInputDecoration(
                  labelText: 'Stripe Price ID',
                  hintText: 'price_...',
                  helperText: 'ID do preço no Stripe Dashboard (opcional)',
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AdminTheme.gradientPrimary,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _saveService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Salvar Serviço',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
