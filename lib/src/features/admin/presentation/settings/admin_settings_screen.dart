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
import '../theme/admin_theme.dart';

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

  // WhatsApp support number
  String? _whatsappSupportNumber;

  // Weekly schedule state
  List<WeeklySchedule>? _weeklySchedule;
  bool _isLoadingSchedule = true;

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
      _whatsappSupportNumber = data['whatsappSupportNumber'] as String?;
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
        'whatsappSupportNumber': _whatsappSupportNumber,
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
    final settingsAsync = ref.watch(adminSettingsProvider);
    final blockedDatesAsync = ref.watch(blockedDatesProvider);

    settingsAsync.whenData(_loadSettingsFromData);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight:
            0, // Hide default AppBar but keep space management if needed, though we build our own header
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text("Configurações", style: AdminTheme.headingMedium),
                const SizedBox(height: 8),
                Text(
                  "Gerencie horários, agendamentos e preferências do sistema.",
                  style: AdminTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Weekly Schedule Section
                _buildSection("Horários de Funcionamento", Icons.schedule, [
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
                          if (index > 0)
                            Divider(height: 1, color: AdminTheme.borderLight),
                          _buildDayScheduleTile(daySchedule, index),
                        ],
                      );
                    }),
                ]),
                const SizedBox(height: 24),

                // Blocked Dates Section
                _buildSection("Datas Bloqueadas", Icons.block, [
                  blockedDatesAsync.when(
                    data: (dates) {
                      if (dates.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Nenhuma data bloqueada.',
                            style: AdminTheme.bodyMedium.copyWith(
                              color: AdminTheme.textMuted,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: dates.map((blockedDate) {
                          return ListTile(
                            title: Text(
                              DateFormat('dd/MM/yyyy').format(blockedDate.date),
                              style: AdminTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              blockedDate.reason ?? 'Sem motivo',
                              style: AdminTheme.bodyMedium,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: AdminTheme.gradientDanger[0],
                              ),
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
                      child: Text(
                        'Erro: $err',
                        style: TextStyle(color: AdminTheme.textPrimary),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: AdminTheme.borderLight),
                  ListTile(
                    leading: Icon(
                      Icons.add,
                      color: AdminTheme.gradientPrimary[0],
                    ),
                    title: Text(
                      'Adicionar Data Bloqueada',
                      style: AdminTheme.bodyLarge,
                    ),
                    onTap: () => _showBlockDateDialog(context),
                  ),
                ]),
                const SizedBox(height: 24),

                // Booking Settings Section
                _buildSection(
                  "Configurações de Agendamento",
                  Icons.calendar_month,
                  [
                    _buildSwitchTile(
                      "Confirmar automaticamente",
                      "Aceitar agendamentos sem aprovação manual",
                      _autoConfirmBookings,
                      (value) => setState(() => _autoConfirmBookings = value),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Notifications Section
                _buildSection("Notificações", Icons.notifications, [
                  _buildSwitchTile(
                    "Notificações Push",
                    "Receber alertas no celular",
                    _pushNotificationsEnabled,
                    (value) =>
                        setState(() => _pushNotificationsEnabled = value),
                  ),
                  Divider(height: 1, color: AdminTheme.borderLight),
                  _buildSwitchTile(
                    "Notificações por Email",
                    "Receber resumos diários por email",
                    _emailNotificationsEnabled,
                    (value) =>
                        setState(() => _emailNotificationsEnabled = value),
                  ),
                ]),
                const SizedBox(height: 24),

                // WhatsApp Support Section
                _buildSection("Suporte WhatsApp", Icons.support_agent, [
                  _buildWhatsAppSupportTile(),
                ]),
                const SizedBox(height: 24),

                // Quick Actions Section
                _buildSection("Ações Rápidas", Icons.bolt, [
                  _buildActionTile(
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
                  Divider(height: 1, color: AdminTheme.borderLight),
                  _buildActionTile(
                    _isExporting ? "Exportando..." : "Exportar Dados",
                    "Baixar relatório completo em CSV",
                    Icons.download,
                    _isExporting ? null : _exportDataToCsv,
                  ),
                  Divider(height: 1, color: AdminTheme.borderLight),
                  _buildActionTile(
                    _isSyncing ? "Sincronizando..." : "Sincronizar com Stripe",
                    "Atualizar produtos e preços",
                    Icons.sync,
                    _isSyncing ? null : _syncWithStripe,
                  ),
                ]),
                const SizedBox(height: 32),

                // Save Button
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AdminTheme.gradientPrimary,
                      ),
                      borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                      boxShadow: AdminTheme.glowShadow(
                        AdminTheme.gradientPrimary[0],
                      ),
                    ),
                    child: ElevatedButton.icon(
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
                          : const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        _isLoading ? "Salvando..." : "Salvar Configurações",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayScheduleTile(WeeklySchedule schedule, int index) {
    return ExpansionTile(
      iconColor: AdminTheme.gradientPrimary[0],
      collapsedIconColor: AdminTheme.textSecondary,
      title: Row(
        children: [
          Text(_getDayName(schedule.dayOfWeek), style: AdminTheme.bodyLarge),
          const Spacer(),
          if (schedule.isOpen)
            Text(
              '${schedule.startHour}:00 - ${schedule.endHour}:00',
              style: AdminTheme.bodyMedium.copyWith(
                color: AdminTheme.textSecondary,
              ),
            )
          else
            Text(
              'Fechado',
              style: AdminTheme.bodyMedium.copyWith(
                color: AdminTheme.gradientDanger[0],
              ),
            ),
        ],
      ),
      trailing: Switch(
        value: schedule.isOpen,
        activeColor: AdminTheme.gradientPrimary[0],
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
                    Text('Horário: ', style: AdminTheme.bodyMedium),
                    DropdownButton<int>(
                      value: schedule.startHour,
                      dropdownColor: AdminTheme.bgCard,
                      style: const TextStyle(color: AdminTheme.textPrimary),
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
                    Text(' às ', style: AdminTheme.bodyMedium),
                    DropdownButton<int>(
                      value: schedule.endHour,
                      dropdownColor: AdminTheme.bgCard,
                      style: const TextStyle(color: AdminTheme.textPrimary),
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
                    Text('Capacidade/Hora: ', style: AdminTheme.bodyMedium),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        color: AdminTheme.textSecondary,
                      ),
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
                    Text(
                      '${schedule.capacityPerHour}',
                      style: AdminTheme.bodyLarge,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: AdminTheme.textSecondary,
                      ),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AdminTheme.gradientPrimary[0],
              onPrimary: Colors.white,
              surface: AdminTheme.bgCard,
              onSurface: AdminTheme.textPrimary,
            ),
            dialogBackgroundColor: AdminTheme.bgCard,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null || !mounted) return;

    final reasonController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Bloquear Data', style: AdminTheme.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
              style: AdminTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: AdminTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Motivo (Opcional)',
                labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AdminTheme.borderLight),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AdminTheme.gradientPrimary[0]),
                ),
              ),
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
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AdminTheme.gradientDanger[0],
            ),
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

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminTheme.gradientPrimary[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AdminTheme.gradientPrimary[0]),
                ),
                const SizedBox(width: 12),
                Text(title, style: AdminTheme.headingSmall),
              ],
            ),
          ),
          Divider(height: 1, color: AdminTheme.borderLight),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(title, style: AdminTheme.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AdminTheme.bodyMedium.copyWith(color: AdminTheme.textSecondary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AdminTheme.gradientPrimary[0],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AdminTheme.textSecondary),
      title: Text(title, style: AdminTheme.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AdminTheme.bodyMedium.copyWith(color: AdminTheme.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AdminTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildWhatsAppSupportTile() {
    final hasNumber =
        _whatsappSupportNumber != null && _whatsappSupportNumber!.isNotEmpty;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasNumber
                ? [const Color(0xFF25D366), const Color(0xFF128C7E)]
                : [AdminTheme.textMuted, AdminTheme.textMuted],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.chat, color: Colors.white, size: 24),
      ),
      title: Text(
        hasNumber ? 'Número de Suporte' : 'Configurar WhatsApp',
        style: AdminTheme.bodyLarge,
      ),
      subtitle: Text(
        hasNumber
            ? _formatPhoneNumber(_whatsappSupportNumber!)
            : 'Adicione um número para suporte ao cliente',
        style: AdminTheme.bodyMedium.copyWith(
          color: hasNumber ? const Color(0xFF25D366) : AdminTheme.textSecondary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasNumber)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AdminTheme.gradientDanger[0],
              ),
              onPressed: () {
                setState(() => _whatsappSupportNumber = null);
                AppToast.success(
                  context,
                  message: 'Número removido. Salve para confirmar.',
                );
              },
              tooltip: 'Remover número',
            ),
          IconButton(
            icon: Icon(
              hasNumber ? Icons.edit : Icons.add,
              color: AdminTheme.gradientPrimary[0],
            ),
            onPressed: () => _showWhatsAppDialog(),
            tooltip: hasNumber ? 'Editar número' : 'Adicionar número',
          ),
        ],
      ),
    );
  }

  String _formatPhoneNumber(String phone) {
    // Format as +55 (XX) XXXXX-XXXX if Brazilian
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 13 && cleaned.startsWith('55')) {
      return '+55 (${cleaned.substring(2, 4)}) ${cleaned.substring(4, 9)}-${cleaned.substring(9)}';
    } else if (cleaned.length == 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }

  Future<void> _showWhatsAppDialog() async {
    final controller = TextEditingController(
      text: _whatsappSupportNumber?.replaceAll(RegExp(r'\D'), '') ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Row(
          children: [
            Icon(Icons.chat, color: Color(0xFF25D366)),
            SizedBox(width: 12),
            Text('WhatsApp de Suporte', style: AdminTheme.headingSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digite o número completo com DDD (apenas números):',
              style: AdminTheme.bodyMedium.copyWith(
                color: AdminTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                color: AdminTheme.textPrimary,
                fontSize: 18,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: '5581999999999',
                hintStyle: TextStyle(color: AdminTheme.textMuted),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF25D366)),
                filled: true,
                fillColor: AdminTheme.bgCardLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF25D366),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF25D366).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF25D366),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este número será usado pelos clientes para entrar em contato via WhatsApp.',
                      style: AdminTheme.bodySmall.copyWith(
                        color: const Color(0xFF25D366),
                      ),
                    ),
                  ),
                ],
              ),
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
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
            ),
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              final number = controller.text.replaceAll(RegExp(r'\D'), '');
              if (number.length >= 10) {
                Navigator.pop(context, number);
              } else {
                AppToast.error(
                  context,
                  message: 'Número inválido. Mínimo 10 dígitos.',
                );
              }
            },
            label: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _whatsappSupportNumber = result);
      AppToast.success(
        context,
        message: 'Número atualizado. Salve as configurações para confirmar.',
      );
    }
  }
}
