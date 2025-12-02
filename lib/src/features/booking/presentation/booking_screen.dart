import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/booking_repository.dart';
import 'booking_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../payment/data/payment_service.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../admin/data/calendar_repository.dart';
import '../../admin/domain/calendar_config.dart';
import '../../../common_widgets/atoms/secondary_button.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Novo Agendamento',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () {
            if (state.currentStep > 0) {
              controller.previousStep();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildProgressHeader(context, state.currentStep),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: IndexedStack(
                key: ValueKey(state.currentStep),
                index: state.currentStep,
                children: [
                  _ServiceSelectionStep(),
                  _VehicleSelectionStep(),
                  _DateTimeSelectionStep(),
                  _ReviewStep(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, int currentStep) {
    final theme = Theme.of(context);
    final steps = ['Serviços', 'Veículo', 'Horário', 'Revisão'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: index ~/ 2 < currentStep
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= currentStep;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            child: Center(
              child: isActive
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    )
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}

class _ServiceSelectionStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'O que vamos fazer hoje?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: servicesAsync.when(
            data: (services) => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final service = services[index];
                final isSelected = state.selectedServices.contains(service);
                return AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () => controller.toggleService(service),
                  child: Container(
                    decoration: BoxDecoration(
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_car_wash,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  service.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${service.durationMinutes} min',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'R\$ ${service.price.toStringAsFixed(0)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).slideX();
              },
            ),
            loading: () => ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: const ShimmerLoading.rectangular(height: 100),
              ),
            ),
            error: (err, stack) => Center(child: Text('Erro: $err')),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Estimado', style: theme.textTheme.titleMedium),
                  Text(
                    'R\$ ${state.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Continuar',
                onPressed: state.selectedServices.isNotEmpty
                    ? () => controller.nextStep()
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VehicleSelectionStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    final vehiclesAsync = ref.watch(userVehiclesProvider(user.uid));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Qual veículo vamos lavar?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: vehiclesAsync.when(
            data: (vehicles) {
              if (vehicles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum veículo cadastrado.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SecondaryButton(
                        text: 'Adicionar Veículo',
                        onPressed: () => context.push('/add-vehicle'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      ref
                          .read(bookingControllerProvider.notifier)
                          .selectVehicle(vehicle);
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${vehicle.brand} ${vehicle.model}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                vehicle.plate,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideX();
                },
              );
            },
            loading: () => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: const ShimmerLoading.rectangular(height: 80),
              ),
            ),
            error: (err, stack) => Center(child: Text('Erro: $err')),
          ),
        ),
      ],
    );
  }
}

class _DateTimeSelectionStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DateTimeSelectionStep> createState() =>
      _DateTimeSelectionStepState();
}

class _DateTimeSelectionStepState
    extends ConsumerState<_DateTimeSelectionStep> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final theme = Theme.of(context);

    final weeklyScheduleAsync = ref.watch(weeklyScheduleProvider);
    final blockedDatesAsync = ref.watch(blockedDatesProvider);

    return weeklyScheduleAsync.when(
      data: (schedule) => blockedDatesAsync.when(
        data: (blockedDates) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Quando fica melhor para você?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                enabledDayPredicate: (day) {
                  // 1. Check if past
                  if (day.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)),
                  )) {
                    return false;
                  }

                  // 2. Check if blocked
                  final isBlocked = blockedDates.any(
                    (blocked) => isSameDay(blocked.date, day),
                  );
                  if (isBlocked) return false;

                  // 3. Check if open in weekly schedule
                  // day.weekday: 1=Mon, 7=Sun
                  final daySchedule = schedule.firstWhere(
                    (s) => s.dayOfWeek == day.weekday,
                    orElse: () => WeeklySchedule(
                      dayOfWeek: day.weekday,
                      isOpen: false,
                      startHour: 0,
                      endHour: 0,
                      capacityPerHour: 0,
                    ),
                  );
                  return daySchedule.isOpen;
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  // Reset selected slot when day changes
                  // controller.selectTimeSlot(null); // You might need to add this method or handle it
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildTimeSlots(
                  context,
                  _selectedDay!,
                  schedule,
                  state.selectedTimeSlot,
                  controller,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: PrimaryButton(
                  text: 'Continuar',
                  onPressed: state.selectedTimeSlot != null
                      ? () => controller.nextStep()
                      : null,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erro: $err')),
    );
  }

  Widget _buildTimeSlots(
    BuildContext context,
    DateTime date,
    List<WeeklySchedule> schedule,
    DateTime? selectedSlot,
    BookingController controller,
  ) {
    final theme = Theme.of(context);
    final daySchedule = schedule.firstWhere(
      (s) => s.dayOfWeek == date.weekday,
      orElse: () => WeeklySchedule(
        dayOfWeek: date.weekday,
        isOpen: false,
        startHour: 0,
        endHour: 0,
        capacityPerHour: 0,
      ),
    );

    if (!daySchedule.isOpen) {
      return const Center(child: Text('Fechado neste dia'));
    }

    final slots = <DateTime>[];
    for (int hour = daySchedule.startHour; hour < daySchedule.endHour; hour++) {
      final slot = DateTime(date.year, date.month, date.day, hour);
      // Filter past hours if today
      if (slot.isAfter(DateTime.now())) {
        slots.add(slot);
      }
    }

    if (slots.isEmpty) {
      return const Center(child: Text('Sem horários disponíveis'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: slots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected =
            selectedSlot != null &&
            isSameDay(selectedSlot, slot) &&
            selectedSlot.hour == slot.hour;

        return AppCard(
          padding: EdgeInsets.zero,
          onTap: () => controller.selectTimeSlot(slot),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(
                Icons.access_time,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(
                DateFormat('HH:mm').format(slot),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
            ),
          ),
        ).animate().fadeIn(delay: (50 * index).ms).slideX();
      },
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            ShimmerLoading.rectangular(height: 300),
            SizedBox(height: 24),
            ShimmerLoading.rectangular(height: 60),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tudo certo?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppCard(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                ...state.selectedServices.map(
                  (service) =>
                      _buildSummaryRow(context, 'Serviço', service.title),
                ),
                Divider(height: 32, color: theme.colorScheme.outlineVariant),
                _buildSummaryRow(
                  context,
                  'Veículo',
                  '${state.selectedVehicle?.brand} ${state.selectedVehicle?.model}',
                ),
                _buildSummaryRow(
                  context,
                  'Placa',
                  state.selectedVehicle?.plate ?? '',
                ),
                Divider(height: 32, color: theme.colorScheme.outlineVariant),
                _buildSummaryRow(
                  context,
                  'Data',
                  state.selectedTimeSlot != null
                      ? DateFormat('dd/MM/yyyy').format(state.selectedTimeSlot!)
                      : '',
                ),
                _buildSummaryRow(
                  context,
                  'Horário',
                  state.selectedTimeSlot != null
                      ? DateFormat('HH:mm').format(state.selectedTimeSlot!)
                      : '',
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: theme.textTheme.titleLarge),
              Text(
                'R\$ ${state.totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Pagar e Agendar',
            icon: Icons.credit_card,
            onPressed: () async {
              // 1. Process Payment
              final paymentService = ref.read(paymentServiceProvider);
              final success = await paymentService.processPayment(
                state.totalPrice,
              );

              if (!success) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pagamento falhou. Tente novamente.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              // 2. Create Booking
              await controller.confirmBooking();
              if (context.mounted && state.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Pagamento confirmado! Agendamento realizado.',
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
                context.go('/dashboard');
              } else if (context.mounted && state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao agendar: ${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
