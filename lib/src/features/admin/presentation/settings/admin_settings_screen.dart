import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:web/web.dart' as web;
import '../../data/admin_repository.dart';
import '../../data/calendar_repository.dart';
import '../../domain/calendar_config.dart';
import '../../../../shared/utils/app_toast.dart';

/// Provider to stream admin settings from Firestore
final adminSettingsProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(adminRepositoryProvider).getSettings();
});

/// Admin settings screen for system configuration
class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  // Settings state
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _autoConfirmBookings = false;
  bool _isLoading = false;
  bool _hasLoadedFromFirestore = false;
  bool _isExporting = false;
  bool _isSyncing = false;

  // Weekly schedule state
  List<WeeklySchedule>? _weeklySchedule;
  bool _isLoadingSchedule = true;
  bool _isSavingSchedule = false;

  @override
  void initState() {
    super.initState();
    _loadWeeklySchedule();
  }

  Future<void> _loadWeeklySchedule() async {
    final schedule = await ref
        .read(calendarRepositoryProvider)
        .getWeeklySchedule();
    if (mounted) {
      setState(() {
        _weeklySchedule = schedule;
        _isLoadingSchedule = false;
      });
    }
  }

  void _loadSettingsFromData(Map<String, dynamic>? data) {
    if (data == null || _hasLoadedFromFirestore) return;

    setState(() {
      _hasLoadedFromFirestore = true;
      _autoConfirmBookings = data['autoConfirmBookings'] ?? false;
      _pushNotificationsEnabled = data['pushNotificationsEnabled'] ?? true;
      _emailNotificationsEnabled = data['emailNotificationsEnabled'] ?? true;
    });
  }

  Future<void> _saveAllSettings() async {
    setState(() => _isLoading = true);

    try {
      // Save general settings
      final settings = {
        'autoConfirmBookings': _autoConfirmBookings,
        'pushNotificationsEnabled': _pushNotificationsEnabled,
        'emailNotificationsEnabled': _emailNotificationsEnabled,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await ref.read(adminRepositoryProvider).saveSettings(settings);

      // Save weekly schedule
      if (_weeklySchedule != null) {
        await ref
            .read(calendarRepositoryProvider)
            .saveWeeklySchedule(_weeklySchedule!);
      }

      if (mounted) {
        AppToast.success(context, message: 'Configurações salvas com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao salvar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportDataToCsv() async {
    setState(() => _isExporting = true);

    try {
      final bookings = await ref.read(adminBookingsProvider.future);
      final buffer = StringBuffer();
      buffer.writeln('ID,Cliente,Data,Horário,Status,Valor,Veículo,Serviços');

      final dateFormat = DateFormat('dd/MM/yyyy');
      final timeFormat = DateFormat('HH:mm');

      for (final booking in bookings) {
        final date = dateFormat.format(booking.scheduledTime);
        final time = timeFormat.format(booking.scheduledTime);
        final services = booking.serviceIds.join('; ');
        buffer.writeln(
          '${booking.id},'
          '${booking.userId},'
          '$date,'
          '$time,'
          '${booking.status.name},'
          '${booking.totalPrice.toStringAsFixed(2)},'
          '${booking.vehicleId},'
          '"$services"',
        );
      }

      final csvContent = buffer.toString();
      final bytes = utf8.encode(csvContent);
      final dataUrl =
          'data:text/csv;charset=utf-8;base64,${base64Encode(bytes)}';
      final fileName =
          'agendamentos_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = dataUrl;
      anchor.download = fileName;
      anchor.click();

      if (mounted) {
        AppToast.success(context, message: 'Exportação concluída!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao exportar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _syncWithStripe() async {
    setState(() => _isSyncing = true);

    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final plans = await ref.read(adminPlansProvider.future);

      for (final plan in plans) {
        await functions.httpsCallable('syncPlanWithStripe').call({
          'planId': plan.id,
          'name': plan.name,
          'price': plan.price,
        });
      }

      ref.invalidate(adminPlansProvider);

      if (mounted) {
        AppToast.success(context, message: 'Sincronização concluída!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao sincronizar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  String _getDayName(int day) {
    const days = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    return days[day - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(adminSettingsProvider);
    final blockedDatesAsync = ref.watch(blockedDatesProvider);

    settingsAsync.whenData(_loadSettingsFromData);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Configurações",
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Gerencie horários, agendamentos e preferências do sistema.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Weekly Schedule Section
            _buildSection(theme, "Horários de Funcionamento", Icons.schedule, [
              if (_isLoadingSchedule)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_weeklySchedule != null)
                ...List.generate(7, (index) {
                  final daySchedule = _weeklySchedule![index];
                  return Column(
                    children: [
                      if (index > 0) const Divider(height: 1),
                      _buildDayScheduleTile(theme, daySchedule, index),
                    ],
                  );
                }),
            ]),
            const SizedBox(height: 24),

            // Blocked Dates Section
            _buildSection(theme, "Datas Bloqueadas", Icons.block, [
              blockedDatesAsync.when(
                data: (dates) {
                  if (dates.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhuma data bloqueada.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return Column(
                    children: dates.map((blockedDate) {
                      return ListTile(
                        title: Text(
                          DateFormat('dd/MM/yyyy').format(blockedDate.date),
                        ),
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
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erro: $err'),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.blue),
                title: const Text('Adicionar Data Bloqueada'),
                onTap: () => _showBlockDateDialog(context),
              ),
            ]),
            const SizedBox(height: 24),

            // Booking Settings Section
            _buildSection(
              theme,
              "Configurações de Agendamento",
              Icons.calendar_month,
              [
                _buildSwitchTile(
                  theme,
                  "Confirmar automaticamente",
                  "Aceitar agendamentos sem aprovação manual",
                  _autoConfirmBookings,
                  (value) => setState(() => _autoConfirmBookings = value),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSection(theme, "Notificações", Icons.notifications, [
              _buildSwitchTile(
                theme,
                "Notificações Push",
                "Receber alertas no celular",
                _pushNotificationsEnabled,
                (value) => setState(() => _pushNotificationsEnabled = value),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                theme,
                "Notificações por Email",
                "Receber resumos diários por email",
                _emailNotificationsEnabled,
                (value) => setState(() => _emailNotificationsEnabled = value),
              ),
            ]),
            const SizedBox(height: 24),

            // Quick Actions Section
            _buildSection(theme, "Ações Rápidas", Icons.bolt, [
              _buildActionTile(
                theme,
                "Limpar Cache",
                "Limpar dados em cache do aplicativo",
                Icons.cleaning_services,
                () {
                  ref.invalidate(adminBookingsProvider);
                  ref.invalidate(adminUsersProvider);
                  ref.invalidate(adminVehiclesProvider);
                  ref.invalidate(adminPlansProvider);
                  ref.invalidate(adminSettingsProvider);
                  ref.invalidate(weeklyScheduleProvider);
                  ref.invalidate(blockedDatesProvider);
                  AppToast.success(context, message: "Cache limpo!");
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                theme,
                _isExporting ? "Exportando..." : "Exportar Dados",
                "Baixar relatório completo em CSV",
                Icons.download,
                _isExporting ? null : _exportDataToCsv,
              ),
              const Divider(height: 1),
              _buildActionTile(
                theme,
                _isSyncing ? "Sincronizando..." : "Sincronizar com Stripe",
                "Atualizar produtos e preços",
                Icons.sync,
                _isSyncing ? null : _syncWithStripe,
              ),
            ]),
            const SizedBox(height: 32),

            // Save Button
            Center(
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _saveAllSettings,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? "Salvando..." : "Salvar Configurações",
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildDayScheduleTile(
    ThemeData theme,
    WeeklySchedule schedule,
    int index,
  ) {
    return ExpansionTile(
      title: Row(
        children: [
          Text(_getDayName(schedule.dayOfWeek)),
          const Spacer(),
          if (schedule.isOpen)
            Text(
              '${schedule.startHour}:00 - ${schedule.endHour}:00',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            )
          else
            Text(
              'Fechado',
              style: TextStyle(color: Colors.red[400], fontSize: 14),
            ),
        ],
      ),
      trailing: Switch(
        value: schedule.isOpen,
        onChanged: (val) {
          setState(() {
            _weeklySchedule![index] = schedule.copyWith(isOpen: val);
          });
        },
      ),
      children: [
        if (schedule.isOpen)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Horário: '),
                    DropdownButton<int>(
                      value: schedule.startHour,
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
                            _weeklySchedule![index] = schedule.copyWith(
                              startHour: val,
                            );
                          });
                        }
                      },
                    ),
                    const Text(' às '),
                    DropdownButton<int>(
                      value: schedule.endHour,
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
                            _weeklySchedule![index] = schedule.copyWith(
                              endHour: val,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Capacidade/Hora: '),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: schedule.capacityPerHour > 1
                          ? () {
                              setState(() {
                                _weeklySchedule![index] = schedule.copyWith(
                                  capacityPerHour: schedule.capacityPerHour - 1,
                                );
                              });
                            }
                          : null,
                    ),
                    Text('${schedule.capacityPerHour}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _weeklySchedule![index] = schedule.copyWith(
                            capacityPerHour: schedule.capacityPerHour + 1,
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
    );
  }

  Future<void> _showBlockDateDialog(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null || !mounted) return;

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
              decoration: const InputDecoration(labelText: 'Motivo (Opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
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

  Widget _buildSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildActionTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
