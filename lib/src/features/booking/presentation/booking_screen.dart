import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../data/booking_repository.dart';
import '../domain/booking.dart';
import 'booking_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../payment/data/payment_service.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../admin/data/calendar_repository.dart';
import '../../admin/domain/calendar_config.dart';
import '../../../common_widgets/atoms/secondary_button.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../subscription/presentation/widgets/web_payment_sheet.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: AppRefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentUserProfileProvider);
                await Future.delayed(const Duration(seconds: 1));
              },
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 500,
                  child: Center(
                    child: Text(
                      'Usuário não encontrado. Arraste para atualizar.',
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (user.status == 'suspended') {
          return Scaffold(
            appBar: AppBar(title: const Text('Conta Suspensa')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.block, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Sua conta está suspensa.',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Entre em contato com o suporte para mais informações.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (user.status == 'cancelled') {
          return Scaffold(
            appBar: AppBar(title: const Text('Conta Cancelada')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cancel, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Sua conta foi cancelada.',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
                      const _ReviewStep(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: AppLoader())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Erro: $err'))),
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
                  PriceDisplay(price: state.totalPrice),
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
  CalendarFormat _calendarFormat = CalendarFormat.month;

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

    final bookingsAsync = ref.watch(bookingsForDateProvider(_selectedDay!));
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
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mês',
                  CalendarFormat.twoWeeks: '2 Semanas',
                  CalendarFormat.week: 'Semana',
                },
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
                    _calendarFormat = CalendarFormat.twoWeeks;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
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
                child: bookingsAsync.when(
                  data: (bookings) {
                    return _buildTimeSlots(
                      context,
                      _selectedDay!,
                      schedule,
                      state.selectedTimeSlot,
                      controller,
                      bookings,
                    );
                  },
                  loading: () => const Center(child: AppLoader()),
                  error: (err, stack) => Center(child: Text('Erro: $err')),
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
        loading: () => const Center(child: AppLoader()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(child: Text('Erro: $err')),
    );
  }

  Widget _buildTimeSlots(
    BuildContext context,
    DateTime date,
    List<WeeklySchedule> schedule,
    DateTime? selectedSlot,
    BookingController controller,
    List<Booking> existingBookings,
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8, // Taller to fit text
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected =
            selectedSlot != null &&
            isSameDay(selectedSlot, slot) &&
            selectedSlot.hour == slot.hour;

        // Calculate availability
        final bookedCount = existingBookings.where((b) {
          return b.status != BookingStatus.cancelled &&
              isSameDay(b.scheduledTime, slot) &&
              b.scheduledTime.hour == slot.hour;
        }).length;

        final capacity = daySchedule.capacityPerHour;
        final availableSpots = capacity - bookedCount;
        final isFull = availableSpots <= 0;

        return InkWell(
          onTap: isFull ? null : () => controller.selectTimeSlot(slot),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isFull
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isFull
                    ? Colors.transparent
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('HH:mm').format(slot),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : isFull
                        ? theme.colorScheme.onSurface.withOpacity(0.5)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : isFull
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isFull ? 'Esgotado' : '$availableSpots vagas',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isFull
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (30 * index).ms).scale();
      },
    );
  }
}

class _ReviewStep extends ConsumerStatefulWidget {
  const _ReviewStep();

  @override
  ConsumerState<_ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends ConsumerState<_ReviewStep> {
  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingControllerProvider);
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          100,
        ), // Extra bottom padding for nav bar
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
                        ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(state.selectedTimeSlot!)
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: theme.textTheme.titleLarge),
                PriceDisplay(price: state.totalPrice, isLarge: true),
              ],
            ),
            const SizedBox(height: 32),
            _buildActionButtons(context, ref, state, theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    BookingState state,
    ThemeData theme,
  ) {
    final subscriptionAsync = ref.watch(userSubscriptionProvider);
    final controller = ref.read(bookingControllerProvider.notifier);

    return subscriptionAsync.when(
      data: (sub) {
        final isPremium =
            sub != null && sub.isActive && sub.status != 'canceled';

        if (isPremium) {
          return PrimaryButton(
            text: 'Confirmar Agendamento',
            isLoading: _isProcessingPayment,
            onPressed: _isProcessingPayment
                ? null
                : () async {
                    setState(() => _isProcessingPayment = true);
                    try {
                      await controller.confirmBooking();
                      if (context.mounted &&
                          ref.read(bookingControllerProvider).error == null) {
                        AppToast.success(
                          context,
                          message: 'Agendamento realizado com sucesso!',
                        );
                        context.go('/dashboard');
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isProcessingPayment = false);
                      }
                    }
                  },
          );
        } else {
          return PrimaryButton(
            text: _isProcessingPayment ? 'Processando...' : 'Pagar e Agendar',
            icon: _isProcessingPayment ? null : Icons.payment,
            isLoading: _isProcessingPayment,
            onPressed: _isProcessingPayment
                ? null
                : () async {
                    setState(() => _isProcessingPayment = true);

                    try {
                      // 1. Initialize Payment
                      final paymentService = ref.read(paymentServiceProvider);

                      if (kIsWeb) {
                        // Detect if device is a Tablet (iPad/Android Tablet)
                        // Mobile phones (< 600px) and Desktops (> 1100px) will use Redirect
                        final width = MediaQuery.of(context).size.width;
                        final isTablet = width >= 600 && width < 1100;

                        if (isTablet) {
                          // Tablet Web Flow (iPad): Use embedded CardField modal
                          // User confirmed this works on iPad
                          final data = await paymentService.createPaymentIntent(
                            state.totalPrice,
                          );

                          if (data['publishableKey'] != null) {
                            Stripe.publishableKey = data['publishableKey'];
                          }

                          if (!context.mounted) return;

                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (sheetContext) => WebPaymentSheet(
                              clientSecret: data['paymentIntent'],
                              onSuccess: () {
                                Navigator.pop(sheetContext); // Close sheet
                                _confirmBooking(
                                  context,
                                  ref,
                                  controller,
                                  theme,
                                );
                              },
                              onError: (error) {
                                Navigator.pop(sheetContext); // Close sheet
                                AppToast.error(
                                  context,
                                  message: 'Erro no pagamento: $error',
                                );
                              },
                            ),
                          );
                        } else {
                          // Mobile Phone & Desktop Web Flow: Redirect/Popup to Stripe Checkout
                          // Solves CardField issues on Android mobile and is standard for Desktop
                          await _storePendingBookingData(ref, state);

                          final data = await paymentService
                              .createCheckoutSession(
                                amount: state.totalPrice,
                                successUrl:
                                    '${Uri.base.origin}/payment-success',
                                cancelUrl: '${Uri.base.origin}/booking',
                                vehicleId: state.selectedVehicle?.id,
                                serviceIds: state.selectedServices
                                    .map((s) => s.id)
                                    .toList(),
                                scheduledTime: state.selectedTimeSlot
                                    ?.toIso8601String(),
                              );

                          final checkoutUrl = data['url'] as String?;
                          if (checkoutUrl == null) {
                            throw Exception('URL de checkout não recebida');
                          }

                          // 1. Open Stripe Checkout in NEW TAB
                          if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
                            await launchUrl(
                              Uri.parse(checkoutUrl),
                              // webOnlyWindowName: '_blank' ensures new tab/window
                              webOnlyWindowName: '_blank',
                            );
                          } else {
                            throw 'Could not launch $checkoutUrl';
                          }

                          // 2. Show Waiting Dialog & Poll for Success
                          if (!context.mounted) return;

                          // Show non-dismissible dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) => PopScope(
                              canPop: false,
                              child: AlertDialog(
                                title: const Text('Processando Pagamento'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Por favor, complete o pagamento na nova aba.',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Aguardando confirmação...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          // 3. Poll for Booking Creation (timeout 3 minutes)
                          bool confirmed = false;
                          int attempts = 0;
                          final currentUser = ref
                              .read(authRepositoryProvider)
                              .currentUser;
                          final targetTime = state.selectedTimeSlot;

                          if (currentUser != null && targetTime != null) {
                            while (attempts < 60 &&
                                !confirmed &&
                                context.mounted) {
                              await Future.delayed(const Duration(seconds: 3));
                              attempts++;

                              // Check for SPECIFIC booking
                              final booking = await ref
                                  .read(bookingRepositoryProvider)
                                  .findBooking(
                                    userId: currentUser.uid,
                                    vehicleId: state.selectedVehicle!.id,
                                    scheduledTime: targetTime,
                                  );

                              if (booking != null) {
                                confirmed = true;
                              }
                            }
                          }

                          // 4. Handle Result
                          if (context.mounted) {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(); // Close Dialog

                            if (confirmed) {
                              // Success! Navigate to dashboard
                              context.go('/dashboard');
                              AppToast.success(
                                context,
                                message: 'Agendamento confirmado!',
                              );
                            } else {
                              // Timeout or error
                              AppToast.error(
                                context,
                                message:
                                    'Pagamento não confirmado. Verifique se o pagamento foi concluído.',
                              );
                              setState(() => _isProcessingPayment = false);
                            }
                          }
                        }
                      } else {
                        // Mobile App Flow
                        final initSuccess = await paymentService
                            .initPaymentSheet(state.totalPrice);

                        if (!initSuccess) {
                          if (context.mounted) {
                            AppToast.error(
                              context,
                              message:
                                  'Erro ao iniciar pagamento. Tente novamente.',
                            );
                          }
                          return;
                        }

                        // 2. Present Payment Sheet
                        final paymentSuccess = await paymentService
                            .presentPaymentSheet();

                        if (!paymentSuccess) {
                          if (context.mounted) {
                            AppToast.warning(
                              context,
                              message: 'Pagamento cancelado ou falhou.',
                            );
                          }
                          return;
                        }

                        // 3. Create Booking (Payment Confirmed)
                        if (context.mounted) {
                          _confirmBooking(context, ref, controller, theme);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppToast.error(
                          context,
                          message: 'Erro ao iniciar pagamento: $e',
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isProcessingPayment = false);
                      }
                    }
                  },
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
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

  Future<void> _confirmBooking(
    BuildContext context,
    WidgetRef ref,
    BookingController controller,
    ThemeData theme,
  ) async {
    await controller.confirmBooking();
    if (context.mounted && ref.read(bookingControllerProvider).error == null) {
      AppToast.success(
        context,
        message: 'Pagamento confirmado! Agendamento realizado.',
      );
      context.go('/dashboard');
    }
  }

  /// Store pending booking data to localStorage before Stripe redirect
  /// This data will be read by the payment-success page to create the booking
  Future<void> _storePendingBookingData(
    WidgetRef ref,
    BookingState state,
  ) async {
    debugPrint('🔵 _storePendingBookingData: Starting...');
    final prefs = await SharedPreferences.getInstance();
    final user = ref.read(authRepositoryProvider).currentUser;

    if (user == null) {
      debugPrint('❌ _storePendingBookingData: No user found!');
      return;
    }

    final pendingBooking = {
      'userId': user.uid,
      'vehicleId': state.selectedVehicle?.id,
      'serviceIds': state.selectedServices.map((s) => s.id).toList(),
      'scheduledTime': state.selectedTimeSlot?.toIso8601String(),
      'totalPrice': state.totalPrice,
      'timestamp': DateTime.now().toIso8601String(),
    };

    debugPrint('🔵 _storePendingBookingData: Data to save = $pendingBooking');
    await prefs.setString('pendingBooking', jsonEncode(pendingBooking));

    // Verify it was saved
    final saved = prefs.getString('pendingBooking');
    debugPrint('✅ _storePendingBookingData: Saved = $saved');
  }
}

class PriceDisplay extends ConsumerWidget {
  final double price;
  final bool isLarge;

  const PriceDisplay({super.key, required this.price, this.isLarge = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(userSubscriptionProvider);

    return subscriptionAsync.when(
      data: (sub) {
        final isPremium =
            sub != null && sub.isActive && sub.status != 'canceled';
        if (isPremium) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ 0,00',
                style:
                    (isLarge
                            ? theme.textTheme.headlineMedium
                            : theme.textTheme.headlineSmall)
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
              ),
              Text(
                'Gratuito (Premium)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }
        return Text(
          'R\$ ${price.toStringAsFixed(2)}',
          style:
              (isLarge
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.headlineSmall)
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
        );
      },
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => Text('R\$ ${price.toStringAsFixed(2)}'),
    );
  }
}
