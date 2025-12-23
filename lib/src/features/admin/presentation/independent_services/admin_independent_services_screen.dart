import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/atoms/app_loader.dart';
import '../../../services/data/independent_service_repository.dart';
import '../../../services/domain/independent_service.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

/// Admin screen to manage independent services (insufilm, etc)
class AdminIndependentServicesScreen extends ConsumerWidget {
  const AdminIndependentServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(allIndependentServicesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Serviços Independentes',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Novo Serviço'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.build_outlined,
                      size: 64,
                      color: AdminTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum serviço cadastrado.',
                      style: AdminTheme.bodyLarge.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicione serviços como insufilm, polimento, etc.',
                      style: AdminTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: kToolbarHeight + 40,
                bottom: 80,
              ),
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
          error: (err, stack) => Center(
            child: Text(
              'Erro: $err',
              style: const TextStyle(color: AdminTheme.textPrimary),
            ),
          ),
        ),
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
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Excluir Serviço', style: AdminTheme.headingSmall),
        content: Text(
          'Deseja excluir "${service.title}"?',
          style: AdminTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AdminTheme.textSecondary),
            ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
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
                        ? AdminTheme.gradientPrimary[0].withOpacity(0.2)
                        : AdminTheme.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(service.iconName),
                    color: service.isActive
                        ? AdminTheme.gradientPrimary[0]
                        : AdminTheme.textSecondary,
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
                              style: AdminTheme.headingSmall.copyWith(
                                color: service.isActive
                                    ? AdminTheme.textPrimary
                                    : AdminTheme.textSecondary,
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
                        style: AdminTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AdminTheme.borderLight),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 20,
                  color: const Color(0xFF32BCAD),
                ),
                const SizedBox(width: 4),
                Text(
                  'R\$ ${service.price.toStringAsFixed(2)}',
                  style: AdminTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF32BCAD),
                  ),
                ),
                const SizedBox(width: 24),
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: AdminTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${service.durationMinutes} min',
                  style: AdminTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: AdminTheme.bgCard,
                    iconTheme: const IconThemeData(
                      color: AdminTheme.textSecondary,
                    ),
                    popupMenuTheme: PopupMenuThemeData(
                      color: AdminTheme.bgCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AdminTheme.borderLight),
                      ),
                      textStyle: const TextStyle(color: AdminTheme.textPrimary),
                    ),
                  ),
                  child: PopupMenuButton<String>(
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
      backgroundColor: AdminTheme.bgCard,
      title: Text(
        isEditing ? 'Editar Serviço' : 'Novo Serviço',
        style: AdminTheme.headingSmall,
      ),
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
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ex: Aplicação de Insufilm',
                    labelStyle: TextStyle(color: AdminTheme.textSecondary),
                    hintStyle: TextStyle(color: AdminTheme.textMuted),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AdminTheme.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                    ),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descreva o serviço...',
                    labelStyle: TextStyle(color: AdminTheme.textSecondary),
                    hintStyle: TextStyle(color: AdminTheme.textMuted),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AdminTheme.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                    ),
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
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Preço (R\$)',
                          prefixText: 'R\$ ',
                          labelStyle: TextStyle(color: AdminTheme.textSecondary),
                          prefixStyle: TextStyle(color: AdminTheme.textPrimary),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AdminTheme.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6366F1)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Obrigatório';
                          if (double.tryParse(v!) == null) {
                            return 'Valor inválido';
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
                        decoration: const InputDecoration(
                          labelText: 'Duração (min)',
                          suffixText: 'min',
                          labelStyle: TextStyle(color: AdminTheme.textSecondary),
                          suffixStyle: TextStyle(color: AdminTheme.textPrimary),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AdminTheme.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6366F1)),
                          ),
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
                  initialValue: _selectedIcon,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  dropdownColor: AdminTheme.bgCard,
                  decoration: const InputDecoration(
                    labelText: 'Ícone',
                    labelStyle: TextStyle(color: AdminTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AdminTheme.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                    ),
                  ),
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
                  title: const Text(
                    'Requer veículo',
                    style: TextStyle(color: AdminTheme.textPrimary),
                  ),
                  subtitle: const Text(
                    'O cliente precisa selecionar um veículo',
                    style: TextStyle(color: AdminTheme.textSecondary),
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
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AdminTheme.textSecondary),
          ),
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

/// Full implementation of availability management screen with improved UX
class ServiceAvailabilityScreen extends ConsumerStatefulWidget {
  final IndependentService service;

  const ServiceAvailabilityScreen({super.key, required this.service});

  @override
  ConsumerState<ServiceAvailabilityScreen> createState() =>
      _ServiceAvailabilityScreenState();
}

class _ServiceAvailabilityScreenState
    extends ConsumerState<ServiceAvailabilityScreen> {
  final Map<int, List<TimeSlotConfig>> _weeklySchedule = {};
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _dayNames = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  final List<String> _dayShort = [
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
    'DOM',
  ];

  // Quick-add preset times
  final List<String> _presetTimes = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    try {
      final availability = await ref
          .read(independentServiceRepositoryProvider)
          .getServiceDefaultAvailability(widget.service.id);

      setState(() {
        _weeklySchedule.clear();
        for (final entry in availability.entries) {
          _weeklySchedule[entry.key] = entry.value
              .map(
                (slot) => TimeSlotConfig(
                  time: slot['time'] as String,
                  capacity: slot['capacity'] as int,
                ),
              )
              .toList();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSchedule() async {
    setState(() => _isSaving = true);

    try {
      final Map<int, List<Map<String, dynamic>>> availability = {};
      for (final entry in _weeklySchedule.entries) {
        availability[entry.key] = entry.value
            .map((slot) => {'time': slot.time, 'capacity': slot.capacity})
            .toList();
      }

      await ref
          .read(independentServiceRepositoryProvider)
          .saveServiceDefaultAvailability(widget.service.id, availability);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Disponibilidade salva! Agenda gerada para 60 dias.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      if (_weeklySchedule[dayIndex]?.isNotEmpty == true) {
        _weeklySchedule.remove(dayIndex);
      } else {
        // Add default slots for the day
        _weeklySchedule[dayIndex] = [
          TimeSlotConfig(time: '09:00', capacity: 2),
          TimeSlotConfig(time: '14:00', capacity: 2),
        ];
      }
    });
  }

  void _showEditDaySheet(int dayIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DayConfigSheet(
        dayName: _dayNames[dayIndex - 1],
        slots: _weeklySchedule[dayIndex] ?? [],
        presetTimes: _presetTimes,
        onSave: (slots) {
          setState(() {
            if (slots.isEmpty) {
              _weeklySchedule.remove(dayIndex);
            } else {
              _weeklySchedule[dayIndex] = slots;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Configurar Disponibilidade', style: AdminTheme.headingMedium),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveSchedule,
        backgroundColor: Colors.green,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          _isSaving ? 'Salvando...' : 'Salvar Agenda',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: kToolbarHeight + 40,
                  bottom: 16,
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with service info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AdminTheme.glassmorphicDecoration(
                      opacity: 0.6,
                      glowColor: Colors.purple,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AdminTheme.bgCardLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.purple.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.service.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.service.durationMinutes} min • R\$ ${widget.service.price.toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  Text(
                    'Selecione os dias e horários disponíveis',
                    style: AdminTheme.headingSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toque no dia para ativar/desativar, ou no ícone ⚙️ para configurar horários',
                    style: AdminTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Days grid
                  ...List.generate(7, (index) {
                    final dayIndex = index + 1;
                    final slots = _weeklySchedule[dayIndex] ?? [];
                    final isActive = slots.isNotEmpty;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AdminTheme.gradientSuccess[0].withOpacity(0.1)
                            : AdminTheme.bgCardLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? AdminTheme.gradientSuccess[0].withOpacity(0.3)
                              : AdminTheme.borderLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Day header with toggle
                          InkWell(
                            onTap: () => _toggleDay(dayIndex),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Day badge
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AdminTheme.gradientSuccess[0]
                                          : AdminTheme.bgCardLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _dayShort[index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _dayNames[index],
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          isActive
                                              ? '${slots.length} horário(s) • ${_getTotalSlots(slots)} vaga(s)'
                                              : 'Não disponível',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: isActive
                                                    ? Colors.green.shade700
                                                    : theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Toggle switch
                                  Switch(
                                    value: isActive,
                                    onChanged: (_) => _toggleDay(dayIndex),
                                    activeThumbColor: Colors.green,
                                  ),
                                  // Edit button
                                  if (isActive)
                                    IconButton(
                                      onPressed: () =>
                                          _showEditDaySheet(dayIndex),
                                      icon: const Icon(Icons.settings),
                                      tooltip: 'Configurar horários',
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Slots preview
                          if (isActive) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: slots.map((slot) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.green.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          slot.time,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            '${slot.capacity}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
    ),);
  }

  int _getTotalSlots(List<TimeSlotConfig> slots) {
    return slots.fold(0, (sum, slot) => sum + slot.capacity);
  }
}

/// Bottom sheet for configuring a specific day's time slots
class _DayConfigSheet extends StatefulWidget {
  final String dayName;
  final List<TimeSlotConfig> slots;
  final List<String> presetTimes;
  final Function(List<TimeSlotConfig>) onSave;

  const _DayConfigSheet({
    required this.dayName,
    required this.slots,
    required this.presetTimes,
    required this.onSave,
  });

  @override
  State<_DayConfigSheet> createState() => _DayConfigSheetState();
}

class _DayConfigSheetState extends State<_DayConfigSheet> {
  late List<TimeSlotConfig> _slots;

  @override
  void initState() {
    super.initState();
    _slots = List.from(widget.slots);
  }

  void _toggleTime(String time) {
    setState(() {
      final existingIndex = _slots.indexWhere((s) => s.time == time);
      if (existingIndex >= 0) {
        _slots.removeAt(existingIndex);
      } else {
        _slots.add(TimeSlotConfig(time: time, capacity: 1));
        _slots.sort((a, b) => a.time.compareTo(b.time));
      }
    });
  }

  void _updateCapacity(String time, int delta) {
    setState(() {
      final index = _slots.indexWhere((s) => s.time == time);
      if (index >= 0) {
        final newCapacity = (_slots[index].capacity + delta).clamp(1, 10);
        _slots[index] = TimeSlotConfig(time: time, capacity: newCapacity);
      }
    });
  }

  void _addCustomTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null) {
      final timeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      if (!_slots.any((s) => s.time == timeStr)) {
        setState(() {
          _slots.add(TimeSlotConfig(time: timeStr, capacity: 1));
          _slots.sort((a, b) => a.time.compareTo(b.time));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.dayName,
            style: AdminTheme.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Toque para ativar/desativar horários',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Preset times grid
          Text(
            'Horários disponíveis',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.presetTimes.map((time) {
              final slot = _slots.firstWhere(
                (s) => s.time == time,
                orElse: () => TimeSlotConfig(time: time, capacity: 0),
              );
              final isActive = slot.capacity > 0;

              return GestureDetector(
                onTap: () => _toggleTime(time),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? Colors.green
                          : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isActive
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _updateCapacity(time, -1),
                              child: Icon(
                                Icons.remove_circle,
                                size: 20,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                '${slot.capacity}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _updateCapacity(time, 1),
                              child: Icon(
                                Icons.add_circle,
                                size: 20,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Custom time button
          OutlinedButton.icon(
            onPressed: _addCustomTime,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar outro horário'),
          ),
          const SizedBox(height: 24),

          // Save button
          FilledButton(
            onPressed: () {
              widget.onSave(_slots);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Helper class for time slot configuration
class TimeSlotConfig {
  final String time;
  final int capacity;

  TimeSlotConfig({required this.time, required this.capacity});
}
