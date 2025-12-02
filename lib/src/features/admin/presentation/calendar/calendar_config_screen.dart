import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/calendar_config.dart';
import '../../data/calendar_repository.dart';
import '../../../../common_widgets/atoms/primary_button.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações salvas com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Calendário'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semanal'),
            Tab(text: 'Bloqueios'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWeeklyTab(), const _BlockedDatesTab()],
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
            itemCount: _schedule!.length,
            itemBuilder: (context, index) {
              final daySchedule = _schedule![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getDayName(daySchedule.dayOfWeek),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Switch(
                            value: daySchedule.isOpen,
                            onChanged: (val) {
                              setState(() {
                                _schedule![index] = daySchedule.copyWith(
                                  isOpen: val,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                      if (daySchedule.isOpen) ...[
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Horário'),
                                  Row(
                                    children: [
                                      DropdownButton<int>(
                                        value: daySchedule.startHour,
                                        items: List.generate(24, (i) => i)
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text('$e:00'),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _schedule![index] = daySchedule
                                                  .copyWith(startHour: val);
                                            });
                                          }
                                        },
                                      ),
                                      const Text(' às '),
                                      DropdownButton<int>(
                                        value: daySchedule.endHour,
                                        items: List.generate(24, (i) => i)
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text('$e:00'),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _schedule![index] = daySchedule
                                                  .copyWith(endHour: val);
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Capacidade/Hora'),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed:
                                            daySchedule.capacityPerHour > 1
                                            ? () {
                                                setState(() {
                                                  _schedule![index] =
                                                      daySchedule.copyWith(
                                                        capacityPerHour:
                                                            daySchedule
                                                                .capacityPerHour -
                                                            1,
                                                      );
                                                });
                                              }
                                            : null,
                                      ),
                                      Text(
                                        '${daySchedule.capacityPerHour}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            _schedule![index] = daySchedule
                                                .copyWith(
                                                  capacityPerHour:
                                                      daySchedule
                                                          .capacityPerHour +
                                                      1,
                                                );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBlockDateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: blockedDatesAsync.when(
        data: (dates) {
          if (dates.isEmpty) {
            return const Center(child: Text('Nenhuma data bloqueada.'));
          }
          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final blockedDate = dates[index];
              return ListTile(
                title: Text(DateFormat('dd/MM/yyyy').format(blockedDate.date)),
                subtitle: Text(blockedDate.reason ?? 'Sem motivo'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await ref
                        .read(calendarRepositoryProvider)
                        .unblockDate(blockedDate.date);
                    ref.invalidate(blockedDatesProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Future<void> _showBlockDateDialog(BuildContext context, WidgetRef ref) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null) return;

    if (context.mounted) {
      final reasonController = TextEditingController();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bloquear Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo (Opcional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
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
              child: const Text('Bloquear'),
            ),
          ],
        ),
      );
    }
  }
}
