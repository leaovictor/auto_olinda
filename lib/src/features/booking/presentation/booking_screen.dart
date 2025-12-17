import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
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
import '../../../common_widgets/molecules/full_screen_loader.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../subscription/presentation/widgets/web_payment_sheet.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../shared/widgets/async_loader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../ecommerce/data/product_repository.dart';
import '../../ecommerce/domain/product.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProfileProvider);

    // Listen for booking errors
    ref.listen<BookingState>(bookingControllerProvider, (previous, next) {
      if (!next.isLoading &&
          next.error != null &&
          (previous?.error != next.error)) {
        AppToast.error(context, message: next.error!);
      }
    });

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
                      _ProductsSelectionStep(), // NEW: Products step
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
      loading: () =>
          const Scaffold(body: FullScreenLoader(message: 'Carregando...')),
      error: (err, stack) => Scaffold(body: Center(child: Text('Erro: $err'))),
    );
  }

  Widget _buildProgressHeader(BuildContext context, int currentStep) {
    final theme = Theme.of(context);
    final steps = ['Serviço', 'Veículo', 'Produtos', 'Horário', 'Revisão'];

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

/// Step for selecting additional products (wax, perfume, etc.)
class _ProductsSelectionStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final productsAsync = ref.watch(activeProductsProvider);
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(userSubscriptionProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Deseja adicionar algo?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              subscriptionAsync.when(
                data: (sub) {
                  final isPremium =
                      sub != null && sub.isActive && sub.status != 'canceled';
                  return Text(
                    isPremium
                        ? 'Produtos adicionais são cobrados separadamente'
                        : 'Adicione produtos ao seu agendamento',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        Expanded(
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum produto disponível',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isSelected = state.selectedProducts.any(
                    (p) => p.id == product.id,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => controller.toggleProduct(product),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Product image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                                image: product.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(product.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: product.imageUrl == null
                                  ? Icon(
                                      Icons.shopping_bag,
                                      color: theme.colorScheme.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Price and checkbox
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'R\$ ${product.price.toStringAsFixed(2)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) =>
                                      controller.toggleProduct(product),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideX();
                },
              );
            },
            loading: () => const Center(child: AppLoader()),
            error: (err, stack) => Center(child: Text('Erro: $err')),
          ),
        ),
        // Summary and action buttons
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              if (state.selectedProducts.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Produtos selecionados:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'R\$ ${state.productsTotalPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Pular',
                      onPressed: () => controller.nextStep(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: state.selectedProducts.isEmpty
                          ? 'Continuar sem produtos'
                          : 'Continuar (${state.selectedProducts.length})',
                      onPressed: () => controller.nextStep(),
                    ),
                  ),
                ],
              ),
            ],
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
  bool _isCheckingAvailability = false;

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
                  isLoading: _isCheckingAvailability,
                  onPressed:
                      state.selectedTimeSlot != null && !_isCheckingAvailability
                      ? () async {
                          // Check for duplicate booking before proceeding
                          final vehicle = state.selectedVehicle;
                          final timeSlot = state.selectedTimeSlot;

                          if (vehicle == null || timeSlot == null) return;

                          setState(() => _isCheckingAvailability = true);

                          try {
                            final hasExisting = await ref
                                .read(bookingRepositoryProvider)
                                .hasExistingBookingForVehicle(
                                  vehicleId: vehicle.id,
                                  scheduledTime: timeSlot,
                                );

                            if (!mounted) return;

                            if (hasExisting) {
                              AppToast.error(
                                context,
                                message:
                                    'Este veículo já possui um agendamento neste horário. Escolha outro horário.',
                              );
                            } else {
                              controller.nextStep();
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isCheckingAvailability = false);
                            }
                          }
                        }
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
        // Lead Time Rule: 2 Hours
        // We can just visually disable them or hide them.
        // Let's disable and show "Encerrado"
        final minTime = DateTime.now().add(const Duration(hours: 2));
        final isTooClose = slot.isBefore(minTime);

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

        final isDisabled = isFull || isTooClose;

        return InkWell(
          onTap: isDisabled ? null : () => controller.selectTimeSlot(slot),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDisabled
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isDisabled
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
                        : isDisabled
                        ? theme.colorScheme.onSurface.withOpacity(0.38)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSelected
                      ? 'Selecionado'
                      : (isTooClose
                            ? 'Encerrado'
                            : (isFull ? 'Esgotado' : '$availableSpots vagas')),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : isDisabled
                        ? theme.colorScheme.onSurface.withOpacity(0.38)
                        : Colors.green,
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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

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

    return Stack(
      children: [
        _buildContent(context, state, theme),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
            numberOfParticles: 30,
            gravity: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingState state,
    ThemeData theme,
  ) {
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
                  if (state.selectedProducts.isNotEmpty) ...[
                    Divider(
                      height: 32,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    ...state.selectedProducts.map(
                      (product) => _buildSummaryRow(
                        context,
                        'Produto',
                        '${product.name} (R\$ ${product.price.toStringAsFixed(2)})',
                      ),
                    ),
                  ],
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
                    await _confirmBooking(context, ref, controller, theme);
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

                    // Pre-payment validation: Lead Time
                    final minTime = DateTime.now().add(
                      const Duration(hours: 2),
                    );
                    if (state.selectedTimeSlot != null &&
                        state.selectedTimeSlot!.isBefore(minTime)) {
                      AppToast.error(
                        context,
                        message:
                            'Este horário não está mais disponível (antecedência mínima de 2h). Escolha outro.',
                      );
                      setState(() => _isProcessingPayment = false);
                      return;
                    }

                    try {
                      // 1. Initialize Payment
                      final paymentService = ref.read(paymentServiceProvider);

                      if (kIsWeb) {
                        // Web Flow: Use WebPaymentSheet for ALL web platforms
                        // This matches the subscription flow which works correctly
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
                            onSuccess: () async {
                              Navigator.pop(sheetContext); // Close sheet
                              await Future.delayed(
                                const Duration(milliseconds: 200),
                              );
                              if (context.mounted) {
                                _confirmBooking(
                                  context,
                                  ref,
                                  controller,
                                  theme,
                                );
                              }
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
    debugPrint(
      '🔵 BookingScreen: _confirmBooking called. Starting creation...',
    );
    try {
      // Wrap the confirmation future with AsyncLoader
      // controller.confirmBooking() returns bool
      final success = await AsyncLoader.show(
        context,
        future: controller.confirmBooking(),
        message: 'Agendando...',
      );

      debugPrint('🔵 BookingScreen: confirmBooking result: $success');

      if (!context.mounted) {
        debugPrint('🔴 BookingScreen: Context detached after confirmBooking.');
        return;
      }

      if (success) {
        debugPrint('🟢 BookingScreen: Booking created successfully!');
        _confettiController.play();
        AppToast.success(
          context,
          message: 'Agendamento realizado com sucesso!',
        );
        // Wait for confetti animation to complete (3 seconds duration)
        await Future.delayed(const Duration(seconds: 3));
        if (context.mounted) {
          context.go('/dashboard');
        }
      } else {
        // Error handling is managed by the listener in build()
        debugPrint('🔴 BookingScreen: confirmBooking returned false.');
        // Fallback: Show error from controller state if available
        final controllerState = ref.read(bookingControllerProvider);
        final errorMsg = controllerState.error;
        debugPrint('🔴 BookingScreen: Controller error state = $errorMsg');
        if (context.mounted && errorMsg != null) {
          AppToast.error(context, message: errorMsg);
        } else if (context.mounted) {
          AppToast.error(
            context,
            message:
                'Não foi possível finalizar o agendamento. Tente novamente.',
          );
        }
      }
    } catch (e, stack) {
      debugPrint('🔴 BookingScreen: Error in _confirmBooking: $e');
      debugPrint('Stack trace: $stack');
      if (context.mounted) {
        AppToast.error(
          context,
          message: 'Erro inesperado ao criar agendamento.',
        );
      }
    }
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
    final bookingState = ref.watch(bookingControllerProvider);

    return subscriptionAsync.when(
      data: (sub) {
        final isPremium =
            sub != null && sub.isActive && sub.status != 'canceled';

        if (isPremium) {
          final productsTotal = bookingState.productsTotalPrice;

          if (productsTotal > 0) {
            // Premium with products: show products price only
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${productsTotal.toStringAsFixed(2)}',
                  style:
                      (isLarge
                              ? theme.textTheme.headlineMedium
                              : theme.textTheme.headlineSmall)
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                ),
                Text(
                  'Serviço gratuito + Produtos',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }

          // Premium without products: fully free
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

        // Non-premium: full price
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
