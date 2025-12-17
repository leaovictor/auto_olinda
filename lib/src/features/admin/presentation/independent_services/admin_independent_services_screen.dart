import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/atoms/app_loader.dart';
import '../../../services/data/independent_service_repository.dart';
import '../../../services/domain/independent_service.dart';
import '../../../../shared/utils/app_toast.dart';

/// Admin screen to manage independent services (insufilm, etc)
class AdminIndependentServicesScreen extends ConsumerWidget {
  const AdminIndependentServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(allIndependentServicesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Serviços Independentes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Novo Serviço'),
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum serviço cadastrado.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione serviços como insufilm, polimento, etc.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _ServiceCard(
                service: service,
                onEdit: () => _showServiceDialog(context, ref, service),
                onToggleActive: () => _toggleActive(context, ref, service),
                onConfigureAvailability: () =>
                    _configureAvailability(context, service),
                onDelete: () => _deleteService(context, ref, service),
              );
            },
          );
        },
        loading: () => const Center(child: AppLoader()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  void _showServiceDialog(
    BuildContext context,
    WidgetRef ref,
    IndependentService? service,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ServiceFormDialog(service: service),
    );
  }

  void _toggleActive(
    BuildContext context,
    WidgetRef ref,
    IndependentService service,
  ) async {
    try {
      await ref
          .read(independentServiceRepositoryProvider)
          .toggleServiceActive(service.id, !service.isActive);
      if (context.mounted) {
        AppToast.success(
          context,
          message: service.isActive ? 'Serviço desativado' : 'Serviço ativado',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, message: 'Erro ao atualizar: $e');
      }
    }
  }

  void _configureAvailability(
    BuildContext context,
    IndependentService service,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceAvailabilityScreen(service: service),
      ),
    );
  }

  void _deleteService(
    BuildContext context,
    WidgetRef ref,
    IndependentService service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: Text('Deseja excluir "${service.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(independentServiceRepositoryProvider)
            .deleteService(service.id);
        if (context.mounted) {
          AppToast.success(context, message: 'Serviço excluído!');
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.error(context, message: 'Erro ao excluir: $e');
        }
      }
    }
  }
}

class _ServiceCard extends StatelessWidget {
  final IndependentService service;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onConfigureAvailability;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onToggleActive,
    required this.onConfigureAvailability,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: service.isActive
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(service.iconName),
                    color: service.isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: service.isActive
                                    ? null
                                    : theme.colorScheme.outline,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: service.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.isActive ? 'Ativo' : 'Inativo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: service.isActive
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'R\$ ${service.price.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 24),
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${service.durationMinutes} min',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'availability':
                        onConfigureAvailability();
                        break;
                      case 'toggle':
                        onToggleActive();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(
                      value: 'availability',
                      child: Text('Configurar Vagas'),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(service.isActive ? 'Desativar' : 'Ativar'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'window':
        return Icons.window;
      case 'auto_fix_high':
        return Icons.auto_fix_high;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'car_repair':
        return Icons.car_repair;
      case 'shield':
        return Icons.shield;
      default:
        return Icons.build;
    }
  }
}

class _ServiceFormDialog extends ConsumerStatefulWidget {
  final IndependentService? service;

  const _ServiceFormDialog({this.service});

  @override
  ConsumerState<_ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends ConsumerState<_ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  String _selectedIcon = 'build';
  bool _requiresVehicle = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.service?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.service?.price.toStringAsFixed(2) ?? '',
    );
    _durationController = TextEditingController(
      text: widget.service?.durationMinutes.toString() ?? '',
    );
    _selectedIcon = widget.service?.iconName ?? 'build';
    _requiresVehicle = widget.service?.requiresVehicle ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.service != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Serviço' : 'Novo Serviço'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ex: Aplicação de Insufilm',
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descreva o serviço...',
                  ),
                  maxLines: 3,
                  validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Preço (R\$)',
                          prefixText: 'R\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Obrigatório';
                          if (double.tryParse(v!) == null)
                            return 'Valor inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duração (min)',
                          suffixText: 'min',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Obrigatório';
                          if (int.tryParse(v!) == null) return 'Valor inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedIcon,
                  decoration: const InputDecoration(labelText: 'Ícone'),
                  items: const [
                    DropdownMenuItem(
                      value: 'build',
                      child: Text('🔧 Ferramenta'),
                    ),
                    DropdownMenuItem(
                      value: 'window',
                      child: Text('🪟 Janela (Insufilm)'),
                    ),
                    DropdownMenuItem(
                      value: 'auto_fix_high',
                      child: Text('✨ Polimento'),
                    ),
                    DropdownMenuItem(
                      value: 'cleaning_services',
                      child: Text('🧹 Limpeza'),
                    ),
                    DropdownMenuItem(
                      value: 'car_repair',
                      child: Text('🚗 Veículo'),
                    ),
                    DropdownMenuItem(
                      value: 'shield',
                      child: Text('🛡️ Proteção'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedIcon = v ?? 'build'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Requer veículo'),
                  subtitle: const Text(
                    'O cliente precisa selecionar um veículo',
                  ),
                  value: _requiresVehicle,
                  onChanged: (v) => setState(() => _requiresVehicle = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = IndependentService(
        id: widget.service?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        durationMinutes: int.parse(_durationController.text),
        iconName: _selectedIcon,
        requiresVehicle: _requiresVehicle,
        isActive: widget.service?.isActive ?? true,
      );

      final repo = ref.read(independentServiceRepositoryProvider);

      if (widget.service != null) {
        await repo.updateService(service);
      } else {
        await repo.createService(service);
      }

      if (mounted) {
        Navigator.pop(context);
        AppToast.success(
          context,
          message: widget.service != null
              ? 'Serviço atualizado!'
              : 'Serviço criado!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Stub for availability screen - will be implemented next
class ServiceAvailabilityScreen extends StatelessWidget {
  final IndependentService service;

  const ServiceAvailabilityScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vagas: ${service.title}')),
      body: const Center(child: Text('Configuração de vagas em breve')),
    );
  }
}
