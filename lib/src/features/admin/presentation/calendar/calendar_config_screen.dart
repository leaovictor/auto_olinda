import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/calendar_config.dart';
import '../../data/calendar_repository.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/admin_dropdown_field.dart';

class CalendarConfigScreen extends ConsumerStatefulWidget {
  const CalendarConfigScreen({super.key});

  @override
  ConsumerState<CalendarConfigScreen> createState() =>
      _CalendarConfigScreenState();
}

class _CalendarConfigScreenState extends ConsumerState<CalendarConfigScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WeeklySchedule>? _schedule;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final schedule = await ref
        .read(calendarRepositoryProvider)
        .getWeeklySchedule();
    if (mounted) {
      setState(() {
        _schedule = schedule;
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_schedule == null) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(calendarRepositoryProvider).saveWeeklySchedule(_schedule!);
      if (mounted) {
        AppToast.success(context, message: 'Configurações salvas com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao salvar: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Configurar Calendário',
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
              colors: [
                AdminTheme.bgDark.withValues(alpha: 0.9),
                Colors.transparent,
              ],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AdminTheme.gradientPrimary[0],
          unselectedLabelColor: AdminTheme.textSecondary,
          indicatorColor: AdminTheme.gradientPrimary[0],
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Semanal'),
            Tab(text: 'Bloqueios'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: TabBarView(
          controller: _tabController,
          children: [_buildWeeklyTab(), const _BlockedDatesTab()],
        ),
      ),
    );
  }

  Widget _buildWeeklyTab() {
    if (_schedule == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 60,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            itemCount: _schedule!.length,
            itemBuilder: (context, index) {
              final daySchedule = _schedule![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: AdminTheme.glassmorphicDecoration(
                  opacity: 0.6,
                  glowColor: daySchedule.isOpen
                      ? AdminTheme.gradientPrimary[0]
                      : null,
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: AdminTheme.borderLight),
                  child: ExpansionTile(
                    title: Text(
                      _getDayName(daySchedule.dayOfWeek),
                      style: AdminTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Switch(
                      value: daySchedule.isOpen,
                      activeThumbColor: AdminTheme.gradientPrimary[0],
                      onChanged: (val) {
                        setState(() {
                          _schedule![index] = daySchedule.copyWith(isOpen: val);
                        });
                      },
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (daySchedule.isOpen) ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Horário',
                                    style: AdminTheme.labelSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AdminDropdownField<int>(
                                          value: daySchedule.startHour,
                                          items: List.generate(24, (i) => i)
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(
                                                    '${e.toString().padLeft(2, '0')}:00',
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              _updateScheduleHours(
                                                index,
                                                val,
                                                daySchedule.endHour,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          'às',
                                          style: AdminTheme.bodySmall,
                                        ),
                                      ),
                                      Expanded(
                                        child: AdminDropdownField<int>(
                                          value: daySchedule.endHour,
                                          items: List.generate(24, (i) => i)
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(
                                                    '${e.toString().padLeft(2, '0')}:00',
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              _updateScheduleHours(
                                                index,
                                                daySchedule.startHour,
                                                val,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (index == 0)
                              Expanded(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.copy_all,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Aplicar a todos',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      onPressed: () =>
                                          _applyScheduleToAllDays(daySchedule),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Capacidade por Horário:',
                          style: AdminTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSlotsList(daySchedule, index),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            text: 'SALVAR CONFIGURAÇÕES',
            onPressed: _isLoading ? null : _saveSchedule,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  void _updateScheduleHours(int dayIndex, int start, int end) {
    if (start >= end) return;

    final currentSchedule = _schedule![dayIndex];
    final currentSlots = currentSchedule.slots;

    List<TimeSlot> newSlots = [];

    for (int i = 0; i < (end - start); i++) {
      final hour = start + i;
      final timeStr = '${hour.toString().padLeft(2, '0')}:00';

      final existingSlot = currentSlots.firstWhere(
        (s) => s.time == timeStr,
        orElse: () => TimeSlot(time: timeStr, capacity: 2, isBlocked: false),
      );
      newSlots.add(existingSlot);
    }

    setState(() {
      _schedule![dayIndex] = currentSchedule.copyWith(
        startHour: start,
        endHour: end,
        slots: newSlots,
      );
    });
  }

  void _applyScheduleToAllDays(WeeklySchedule source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text(
          'Aplicar a todos os dias?',
          style: AdminTheme.headingSmall,
        ),
        content: const Text(
          'Isso copiará os horários e capacidades desta configuração para todos os outros dias da semana (mantendo apenas o status Aberto/Fechado atual de cada dia).',
          style: AdminTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                for (int i = 0; i < _schedule!.length; i++) {
                  _schedule![i] = source.copyWith(
                    dayOfWeek: _schedule![i].dayOfWeek,
                    isOpen: source.isOpen,
                  );
                }
              });
              Navigator.pop(context);
              AppToast.success(context, message: 'Aplicado a todos os dias!');
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsList(WeeklySchedule schedule, int dayIndex) {
    if (schedule.slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Nenhum horário configurado.',
          style: AdminTheme.bodyMedium,
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: schedule.slots.map((slot) {
        final slotIndex = schedule.slots.indexOf(slot);
        final hasRestrictions = slot.allowedCategories.isNotEmpty;

        return Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: slot.isBlocked
                ? AdminTheme.bgCard.withValues(alpha: 0.5)
                : AdminTheme.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: slot.isBlocked
                  ? AdminTheme.borderLight
                  : (hasRestrictions
                        ? AdminTheme.gradientPrimary[0]
                        : AdminTheme.gradientPrimary[0].withValues(alpha: 0.5)),
              width: hasRestrictions ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    slot.time,
                    style: AdminTheme.bodyLarge.copyWith(
                      color: slot.isBlocked
                          ? AdminTheme.textMuted
                          : AdminTheme.textPrimary,
                      decoration: slot.isBlocked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Row(
                    children: [
                      // Restrictions Icon
                      InkWell(
                        onTap: () =>
                            _openRestrictionsDialog(dayIndex, slotIndex, slot),
                        child: Icon(
                          Icons.filter_list,
                          size: 18,
                          color: hasRestrictions
                              ? AdminTheme.gradientPrimary[0]
                              : AdminTheme.textSecondary.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Lock Icon
                      InkWell(
                        onTap: () {
                          final updatedSlot = slot.copyWith(
                            isBlocked: !slot.isBlocked,
                          );
                          final newSlots = List<TimeSlot>.from(schedule.slots);
                          newSlots[slotIndex] = updatedSlot;

                          setState(() {
                            _schedule![dayIndex] = schedule.copyWith(
                              slots: newSlots,
                            );
                          });
                        },
                        child: Icon(
                          slot.isBlocked ? Icons.lock : Icons.lock_open,
                          size: 18,
                          color: slot.isBlocked
                              ? AdminTheme.gradientDanger[0]
                              : AdminTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!slot.isBlocked)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: slot.capacity > 0
                          ? () {
                              final updatedSlot = slot.copyWith(
                                capacity: slot.capacity - 1,
                              );
                              final newSlots = List<TimeSlot>.from(
                                schedule.slots,
                              );
                              newSlots[slotIndex] = updatedSlot;
                              setState(() {
                                _schedule![dayIndex] = schedule.copyWith(
                                  slots: newSlots,
                                );
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AdminTheme.bgSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text('${slot.capacity}', style: AdminTheme.bodyLarge),
                    InkWell(
                      onTap: () {
                        final updatedSlot = slot.copyWith(
                          capacity: slot.capacity + 1,
                        );
                        final newSlots = List<TimeSlot>.from(schedule.slots);
                        newSlots[slotIndex] = updatedSlot;
                        setState(() {
                          _schedule![dayIndex] = schedule.copyWith(
                            slots: newSlots,
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AdminTheme.bgSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              if (hasRestrictions && !slot.isBlocked)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Restrito: ${slot.allowedCategories.length} cats',
                    style: AdminTheme.labelSmall.copyWith(
                      color: AdminTheme.gradientPrimary[0],
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _openRestrictionsDialog(
    int dayIndex,
    int slotIndex,
    TimeSlot slot,
  ) async {
    final Map<String, String> categories = {
      'general': 'Geral',
      'wash': 'Lavagem',
      'aesthetic': 'Estética',
      'maintenance': 'Manutenção',
    };

    final selectedCategories = List<String>.from(slot.allowedCategories);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AdminTheme.bgCard,
              title: Text(
                'Restrições: ${slot.time}',
                style: AdminTheme.headingSmall,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecione as categorias permitidas neste horário. Se nenhuma for selecionada, todas são permitidas.',
                    style: AdminTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: categories.entries.map((entry) {
                      final isSelected = selectedCategories.contains(entry.key);
                      return FilterChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          setStateDialog(() {
                            if (selected) {
                              selectedCategories.add(entry.key);
                            } else {
                              selectedCategories.remove(entry.key);
                            }
                          });
                        },
                        backgroundColor: AdminTheme.bgSurface,
                        selectedColor: AdminTheme.gradientPrimary[0]
                            .withOpacity(0.3),
                        checkmarkColor: AdminTheme.gradientPrimary[0],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AdminTheme.gradientPrimary[0]
                              : AdminTheme.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final updatedSlot = slot.copyWith(
                      allowedCategories: selectedCategories,
                    );
                    final schedule = _schedule![dayIndex];
                    final newSlots = List<TimeSlot>.from(schedule.slots);
                    newSlots[slotIndex] = updatedSlot;

                    setState(() {
                      _schedule![dayIndex] = schedule.copyWith(slots: newSlots);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }
}

class _BlockedDatesTab extends ConsumerWidget {
  const _BlockedDatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedDatesAsync = ref.watch(blockedDatesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit gradient from parent
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBlockDateDialog(context, ref),
        backgroundColor: AdminTheme.gradientPrimary[0],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: blockedDatesAsync.when(
        data: (dates) {
          if (dates.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma data bloqueada.',
                style: TextStyle(color: AdminTheme.textSecondary),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 60,
              left: 16,
              right: 16,
              bottom: 80,
            ),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final blockedDate = dates[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: AdminTheme.glassmorphicDecoration(
                  opacity: 0.6,
                  glowColor: Colors.red.withValues(alpha: 0.5),
                ),
                child: ListTile(
                  title: Text(
                    DateFormat('dd/MM/yyyy').format(blockedDate.date),
                    style: AdminTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    blockedDate.reason ?? 'Sem motivo',
                    style: AdminTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await ref
                          .read(calendarRepositoryProvider)
                          .unblockDate(blockedDate.date);
                      ref.invalidate(blockedDatesProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erro: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Future<void> _showBlockDateDialog(BuildContext context, WidgetRef ref) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1), // Gradient Primary 0
              onPrimary: Colors.white,
              surface: AdminTheme.bgCard,
              onSurface: AdminTheme.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AdminTheme.bgCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    if (context.mounted) {
      final reasonController = TextEditingController();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AdminTheme.bgCard,
          title: const Text('Bloquear Data', style: AdminTheme.headingSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                style: AdminTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              AdminTextField(
                controller: reasonController,
                label: 'Motivo (Opcional)',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AdminTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(calendarRepositoryProvider)
                    .blockDate(
                      BlockedDate(
                        date: selectedDate,
                        reason: reasonController.text,
                      ),
                    );
                ref.invalidate(blockedDatesProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(
                'Bloquear',
                style: TextStyle(color: AdminTheme.gradientDanger[0]),
              ),
            ),
          ],
        ),
      );
    }
  }
}
