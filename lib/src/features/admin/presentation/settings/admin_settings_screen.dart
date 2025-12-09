import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_repository.dart';
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
  TimeOfDay _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 18, minute: 0);
  int _bookingSlotDuration = 60; // minutes
  int _maxBookingsPerSlot = 3;
  bool _isLoading = false;
  bool _hasLoadedFromFirestore = false;

  @override
  void initState() {
    super.initState();
  }

  void _loadSettingsFromData(Map<String, dynamic>? data) {
    if (data == null || _hasLoadedFromFirestore) return;

    setState(() {
      _hasLoadedFromFirestore = true;
      _openingTime = TimeOfDay(
        hour: data['openingHour'] ?? 8,
        minute: data['openingMinute'] ?? 0,
      );
      _closingTime = TimeOfDay(
        hour: data['closingHour'] ?? 18,
        minute: data['closingMinute'] ?? 0,
      );
      _bookingSlotDuration = data['bookingSlotDurationMinutes'] ?? 60;
      _maxBookingsPerSlot = data['maxBookingsPerSlot'] ?? 3;
      _autoConfirmBookings = data['autoConfirmBookings'] ?? false;
      _pushNotificationsEnabled = data['pushNotificationsEnabled'] ?? true;
      _emailNotificationsEnabled = data['emailNotificationsEnabled'] ?? true;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final settings = {
        'openingHour': _openingTime.hour,
        'openingMinute': _openingTime.minute,
        'closingHour': _closingTime.hour,
        'closingMinute': _closingTime.minute,
        'bookingSlotDurationMinutes': _bookingSlotDuration,
        'maxBookingsPerSlot': _maxBookingsPerSlot,
        'autoConfirmBookings': _autoConfirmBookings,
        'pushNotificationsEnabled': _pushNotificationsEnabled,
        'emailNotificationsEnabled': _emailNotificationsEnabled,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await ref.read(adminRepositoryProvider).saveSettings(settings);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(adminSettingsProvider);

    // Load initial data from Firestore
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
              "Gerencie as configurações do sistema e preferências.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Business Hours Section
            _buildSection(
              theme,
              "Horário de Funcionamento",
              Icons.access_time,
              [
                _buildTimePickerTile(
                  theme,
                  "Abertura",
                  _openingTime,
                  (time) => setState(() => _openingTime = time),
                ),
                const Divider(height: 1),
                _buildTimePickerTile(
                  theme,
                  "Fechamento",
                  _closingTime,
                  (time) => setState(() => _closingTime = time),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Booking Settings Section
            _buildSection(
              theme,
              "Configurações de Agendamento",
              Icons.calendar_month,
              [
                _buildDropdownTile(
                  theme,
                  "Duração do Slot",
                  "$_bookingSlotDuration minutos",
                  Icons.timer,
                  [30, 45, 60, 90, 120],
                  _bookingSlotDuration,
                  (value) => setState(() => _bookingSlotDuration = value),
                ),
                const Divider(height: 1),
                _buildDropdownTile(
                  theme,
                  "Máx. Agendamentos por Slot",
                  "$_maxBookingsPerSlot",
                  Icons.groups,
                  [1, 2, 3, 4, 5],
                  _maxBookingsPerSlot,
                  (value) => setState(() => _maxBookingsPerSlot = value),
                ),
                const Divider(height: 1),
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
                  AppToast.info(context, message: "Cache limpo com sucesso!");
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                theme,
                "Exportar Dados",
                "Baixar relatório completo em CSV",
                Icons.download,
                () {
                  AppToast.info(context, message: "Exportação iniciada...");
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                theme,
                "Sincronizar com Stripe",
                "Atualizar produtos e preços",
                Icons.sync,
                () {
                  AppToast.info(context, message: "Sincronização iniciada...");
                },
              ),
            ]),
            const SizedBox(height: 32),

            // Save Button
            Center(
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _saveSettings,
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

  Widget _buildTimePickerTile(
    ThemeData theme,
    String title,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(title),
      trailing: TextButton(
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (picked != null) {
            onChanged(picked);
          }
        },
        child: Text(
          time.format(context),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile<T>(
    ThemeData theme,
    String title,
    String displayValue,
    IconData icon,
    List<T> options,
    T currentValue,
    ValueChanged<T> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: DropdownButton<T>(
        value: currentValue,
        underline: const SizedBox(),
        items: options.map((option) {
          return DropdownMenuItem<T>(
            value: option,
            child: Text(option is int ? "$option" : option.toString()),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }

  Widget _buildActionTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
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
