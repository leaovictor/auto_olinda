import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/independent_service_repository.dart';
import '../domain/independent_service.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/utils/app_toast.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/service_booking.dart';

/// Screen for booking an independent service
class ServiceBookingScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const ServiceBookingScreen({super.key, required this.serviceId});

  @override
  ConsumerState<ServiceBookingScreen> createState() =>
      _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends ConsumerState<ServiceBookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  bool _isLoading = false;
  IndependentService? _service;
  Map<String, int> _availableSlots = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadService();
  }

  Future<void> _loadService() async {
    final service = await ref
        .read(independentServiceRepositoryProvider)
        .getService(widget.serviceId);
    if (mounted) {
      setState(() => _service = service);
      _loadAvailability();
    }
  }

  Future<void> _loadAvailability() async {
    if (_selectedDay == null || _service == null) return;

    final slots = await ref
        .read(independentServiceRepositoryProvider)
        .getAvailableSlots(_selectedDay!, widget.serviceId);

    if (mounted) {
      setState(() => _availableSlots = slots);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Agendar Serviço')),
        body: const Center(child: AppLoader()),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _service!.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.build,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _service!.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'R\$ ${_service!.price.toStringAsFixed(2)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_service!.durationMinutes} min',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Calendar
            Text(
              'Selecione a data',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedTime = null;
                  });
                  _loadAvailability();
                },
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time slots
            Text(
              'Horários disponíveis',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildTimeSlots(theme),
            const SizedBox(height: 32),

            // Book button
            PrimaryButton(
              text: 'Confirmar Agendamento',
              isLoading: _isLoading,
              onPressed: _selectedTime != null ? _confirmBooking : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots(ThemeData theme) {
    if (_availableSlots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nenhum horário disponível nesta data',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sortedTimes = _availableSlots.keys.toList()..sort();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortedTimes.map((time) {
        final slots = _availableSlots[time]!;
        final isSelected = _selectedTime == time;

        return InkWell(
          onTap: () => setState(() => _selectedTime = time),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  time,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$slots vaga${slots > 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary.withOpacity(0.8)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _confirmBooking() async {
    if (_selectedDay == null || _selectedTime == null || _service == null)
      return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final userProfile = await ref.read(currentUserProfileProvider.future);

      // Parse time
      final timeParts = _selectedTime!.split(':');
      final scheduledTime = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final booking = ServiceBooking(
        id: '',
        userId: user.uid,
        serviceId: widget.serviceId,
        scheduledTime: scheduledTime,
        totalPrice: _service!.price,
        status: ServiceBookingStatus.scheduled,
        userName: userProfile?.displayName,
      );

      await ref
          .read(independentServiceRepositoryProvider)
          .createBooking(booking);

      if (mounted) {
        AppToast.success(context, message: 'Agendamento confirmado!');
        context.go('/my-services');
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
