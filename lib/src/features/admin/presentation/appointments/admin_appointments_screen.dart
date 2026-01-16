import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../features/auth/domain/app_user.dart';
import '../../../../features/booking/domain/booking.dart';
import '../../../../features/booking/domain/service_package.dart';
import '../../../../features/profile/domain/vehicle.dart';
import '../../data/admin_repository.dart';
import '../../../../features/booking/data/booking_repository.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../domain/booking_with_details.dart';
import '../../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../../shared/utils/app_toast.dart';
import '../shell/admin_shell.dart';
import '../../../../features/services/data/independent_service_repository.dart';
import '../../../../features/services/domain/service_booking.dart';
import '../../../../features/services/domain/independent_service.dart';

import '../theme/admin_theme.dart';

// Controller and State imports
import 'admin_appointments_controller.dart';
import 'admin_appointments_state.dart';

// Widget imports
import 'widgets/car_wash_booking_card.dart';
import 'widgets/aesthetic_booking_card.dart';
import 'widgets/appointment_card_skeleton.dart';
import '../widgets/admin_text_field.dart';
import 'widgets/animated_filter_chip.dart';

/// Admin screen for managing all appointments (Car Wash + Aesthetic)
/// Refactored to use centralized Riverpod state management
class AdminAppointmentsScreen extends ConsumerStatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  ConsumerState<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState
    extends ConsumerState<AdminAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(adminAppointmentsControllerProvider.notifier)
            .setTabIndex(_tabController.index);
        setState(() {}); // Rebuild to update background/tab styles if needed
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;
    final controllerState = ref.watch(adminAppointmentsControllerProvider);
    final controller = ref.read(adminAppointmentsControllerProvider.notifier);

    return Container(
      decoration: const BoxDecoration(gradient: AdminTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Gerenciar Agendamentos',
            style: AdminTheme.headingMedium,
          ),
          actions: [
            IconButton(
              icon: Icon(
                controllerState.currentSortOrder == SortOrder.newestFirst
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: AdminTheme.textPrimary,
              ),
              onPressed: controller.toggleSortOrder,
              tooltip: controllerState.currentSortOrder == SortOrder.newestFirst
                  ? 'Mais recentes primeiro'
                  : 'Mais antigos primeiro',
            ),
            IconButton(
              icon: Icon(
                controllerState.isCalendarView
                    ? Icons.list
                    : Icons.calendar_month,
                color: AdminTheme.textPrimary,
              ),
              onPressed: controller.toggleCalendarView,
              tooltip: controllerState.isCalendarView
                  ? 'Ver Lista'
                  : 'Ver Calendário',
            ),
            if (isMobile)
              IconButton(
                onPressed: () {
                  final toggle = ref.read(adminDrawerToggleProvider);
                  toggle?.call();
                },
                icon: const Icon(Icons.menu, color: AdminTheme.textPrimary),
                tooltip: 'Menu',
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.borderLight),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AdminTheme.glowShadow(
                    AdminTheme.gradientPrimary[0],
                    intensity: 0.2,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AdminTheme.textSecondary,
                labelStyle: AdminTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_car_wash, size: 20),
                        SizedBox(width: 8),
                        Text('Lavagem'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 20),
                        SizedBox(width: 8),
                        Text('Estética'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildCarWashTab(isMobile), _buildAestheticTab(isMobile)],
        ),
      ),
    );
  }

  // ============ Car Wash Tab ============

  Widget _buildCarWashTab(bool isMobile) {
    final controllerState = ref.watch(adminAppointmentsControllerProvider);
    final controller = ref.read(adminAppointmentsControllerProvider.notifier);
    final statusCounts = ref.watch(carWashStatusCountsProvider);
    final bookingsAsync = ref.watch(adminBookingsWithDetailsProvider);
    final filteredBookings = ref.watch(filteredCarWashBookingsProvider);

    return Column(
      children: [
        const SizedBox(height: 16),
        // Search and filter bar (hide in calendar view)
        if (!controllerState.isCalendarView) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AdminTextField(
              hint: 'Buscar por cliente, placa...',
              icon: Icons.search,
              onChanged: controller.setCarWashSearchQuery,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                AnimatedFilterChip(
                  label: 'Todos',
                  count: statusCounts['all'],
                  isSelected: controllerState.carWashStatusFilter == 'all',
                  onSelected: (_) => controller.setCarWashStatusFilter('all'),
                ),
                const SizedBox(width: 8),
                AnimatedFilterChip(
                  label: 'Pendentes',
                  count: statusCounts['scheduled'],
                  isSelected:
                      controllerState.carWashStatusFilter == 'scheduled',
                  onSelected: (_) =>
                      controller.setCarWashStatusFilter('scheduled'),
                ),
                const SizedBox(width: 8),
                AnimatedFilterChip(
                  label: 'Confirmados',
                  count: statusCounts['confirmed'],
                  isSelected:
                      controllerState.carWashStatusFilter == 'confirmed',
                  onSelected: (_) =>
                      controller.setCarWashStatusFilter('confirmed'),
                ),
                const SizedBox(width: 8),
                AnimatedFilterChip(
                  label: 'Check-in',
                  count: statusCounts['checkIn'],
                  isSelected: controllerState.carWashStatusFilter == 'checkIn',
                  onSelected: (_) =>
                      controller.setCarWashStatusFilter('checkIn'),
                ),
                const SizedBox(width: 8),
                AnimatedFilterChip(
                  label: 'Lavando',
                  count: statusCounts['washing'],
                  isSelected: controllerState.carWashStatusFilter == 'washing',
                  onSelected: (_) =>
                      controller.setCarWashStatusFilter('washing'),
                ),
                const SizedBox(width: 8),
                AnimatedFilterChip(
                  label: 'Aspirando',
                  count: statusCounts['vacuuming'],
                  isSelected:
                      controllerState.carWashStatusFilter == 'vacuuming',
                  onSelected: (_) =>
                      controller.setCarWashStatusFilter('vacuuming'),
                ),
                const SizedBox(width: 8),
                AnimatedFilterChip(
                  label: 'Secando',
                  count: statusCounts['drying'],
                  isSelected: controllerState.carWashStatusFilter == 'drying',
                  onSelected: (_) =>
                      controller.setCarWashStatusFilter('drying'),
                ),
                const SizedBox(width: 8),
                AnimatedFilterChip(
                  label: 'Polindo',
                  count: statusCounts['polishing'],
                  isSelected:
                      controllerState.carWashStatusFilter == 'polishing',
                  onSelected: (_) =>
                      controller.setCarWashStatusFilter('polishing'),
                ),
                const SizedBox(width: 8),
                AnimatedFilterChip(
                  label: 'Finalizados',
                  count: statusCounts['finished'],
                  isSelected: controllerState.carWashStatusFilter == 'finished',
                  onSelected: (_) =>
                      controller.setCarWashStatusFilter('finished'),
                ),
                const SizedBox(width: 8),
                AnimatedFilterChip(
                  label: 'Não Compareceu',
                  count: statusCounts['noShow'],
                  isSelected: controllerState.carWashStatusFilter == 'noShow',
                  onSelected: (_) =>
                      controller.setCarWashStatusFilter('noShow'),
                ),
              ],
            ),
          ),
        ],
        // Main content
        Expanded(
          child: AppRefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminBookingsWithDetailsProvider);
              await Future.delayed(const Duration(seconds: 1));
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: bookingsAsync.when(
                data: (_) {
                  if (controllerState.isCalendarView) {
                    return _buildCalendarView(
                      filteredBookings,
                      controllerState,
                      controller,
                    );
                  }

                  if (filteredBookings.isEmpty) {
                    return const Center(
                      child: Text('Nenhum agendamento encontrado.'),
                    );
                  }

                  return ListView.builder(
                    key: const ValueKey('car-wash-list'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return CarWashBookingCard(
                        bookingWithDetails: booking,
                        onTap: () =>
                            _showCarWashDetailsDialog(context, booking, ref),
                        onManage: () =>
                            _showCarWashDetailsDialog(context, booking, ref),
                        onWhatsApp: () =>
                            _launchWhatsApp(ref, booking.booking.userId),
                        onCancel: () => _updateCarWashStatus(
                          ref,
                          booking.booking.id,
                          BookingStatus.cancelled,
                        ),
                      );
                    },
                  );
                },
                loading: () => const AppointmentSkeletonList(),
                error: (err, stack) => Center(child: Text('Erro: $err')),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ Aesthetic Tab ============

  Widget _buildAestheticTab(bool isMobile) {
    final controllerState = ref.watch(adminAppointmentsControllerProvider);
    final controller = ref.read(adminAppointmentsControllerProvider.notifier);
    final statusCounts = ref.watch(aestheticStatusCountsProvider);
    final bookingsAsync = ref.watch(allServiceBookingsProvider);
    final servicesAsync = ref.watch(allIndependentServicesProvider);
    final filteredBookings = ref.watch(filteredAestheticBookingsProvider);

    // Check and trigger audio alert for pending approvals
    final pendingCount = statusCounts['pendingApproval'] ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkPendingAlertSound(pendingCount);
    });

    // Build services map
    final servicesMap = <String, IndependentService>{};
    servicesAsync.whenData((services) {
      for (final service in services) {
        servicesMap[service.id] = service;
      }
    });

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AdminTextField(
            hint: 'Buscar por cliente, telefone...',
            icon: Icons.search,
            onChanged: controller.setAestheticSearchQuery,
          ),
        ),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              AnimatedFilterChip(
                label: 'Todos',
                count: statusCounts['all'],
                isSelected: controllerState.aestheticStatusFilter == 'all',
                onSelected: (_) => controller.setAestheticStatusFilter('all'),
              ),
              const SizedBox(width: 8),
              AnimatedFilterChip(
                label: '⏳ Aguardando',
                count: statusCounts['pendingApproval'],
                isSelected:
                    controllerState.aestheticStatusFilter == 'pendingApproval',
                onSelected: (_) =>
                    controller.setAestheticStatusFilter('pendingApproval'),
                activeColor: Colors.amber,
              ),
              const SizedBox(width: 8),
              AnimatedFilterChip(
                label: 'Agendados',
                count: statusCounts['scheduled'],
                isSelected:
                    controllerState.aestheticStatusFilter == 'scheduled',
                onSelected: (_) =>
                    controller.setAestheticStatusFilter('scheduled'),
              ),
              const SizedBox(width: 8),
              AnimatedFilterChip(
                label: 'Confirmados',
                count: statusCounts['confirmed'],
                isSelected:
                    controllerState.aestheticStatusFilter == 'confirmed',
                onSelected: (_) =>
                    controller.setAestheticStatusFilter('confirmed'),
              ),
              const SizedBox(width: 8),
              AnimatedFilterChip(
                label: 'Em Andamento',
                count: statusCounts['inProgress'],
                isSelected:
                    controllerState.aestheticStatusFilter == 'inProgress',
                onSelected: (_) =>
                    controller.setAestheticStatusFilter('inProgress'),
              ),
              const SizedBox(width: 8),
              AnimatedFilterChip(
                label: 'Finalizados',
                count: statusCounts['finished'],
                isSelected: controllerState.aestheticStatusFilter == 'finished',
                onSelected: (_) =>
                    controller.setAestheticStatusFilter('finished'),
              ),
              const SizedBox(width: 8),
              AnimatedFilterChip(
                label: 'Cancelados',
                count: statusCounts['cancelled'],
                isSelected:
                    controllerState.aestheticStatusFilter == 'cancelled',
                onSelected: (_) =>
                    controller.setAestheticStatusFilter('cancelled'),
              ),
              const SizedBox(width: 8),
              AnimatedFilterChip(
                label: 'Recusados',
                count: statusCounts['rejected'],
                isSelected: controllerState.aestheticStatusFilter == 'rejected',
                onSelected: (_) =>
                    controller.setAestheticStatusFilter('rejected'),
              ),
              const SizedBox(width: 8),
              AnimatedFilterChip(
                label: 'Não Compareceu',
                count: statusCounts['noShow'],
                isSelected: controllerState.aestheticStatusFilter == 'noShow',
                onSelected: (_) =>
                    controller.setAestheticStatusFilter('noShow'),
              ),
            ],
          ),
        ),
        // Pending approval alert banner
        if (pendingCount > 0)
          _buildPendingAlertBanner(pendingCount, controller),
        // Main content
        Expanded(
          child: AppRefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allServiceBookingsProvider);
              await Future.delayed(const Duration(seconds: 1));
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: bookingsAsync.when(
                data: (_) {
                  // Show calendar view if enabled
                  if (controllerState.isCalendarView) {
                    return _buildAestheticCalendarView(
                      filteredBookings,
                      controllerState,
                      controller,
                      servicesMap,
                    );
                  }

                  if (filteredBookings.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text('Nenhum agendamento de estética encontrado.'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    key: const ValueKey('aesthetic-list'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      final service = servicesMap[booking.serviceId];
                      return AestheticBookingCard(
                        booking: booking,
                        service: service,
                        onTap: () => _showAestheticDetailsDialog(
                          context,
                          booking,
                          service,
                          ref,
                        ),
                        onManage: () => _showAestheticDetailsDialog(
                          context,
                          booking,
                          service,
                          ref,
                        ),
                        onWhatsApp: () =>
                            _launchWhatsAppFromPhone(booking.userPhone),
                        onCancel: () => _updateAestheticStatus(
                          ref,
                          booking.id,
                          ServiceBookingStatus.cancelled,
                        ),
                      );
                    },
                  );
                },
                loading: () => const AppointmentSkeletonList(),
                error: (err, stack) => Center(child: Text('Erro: $err')),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingAlertBanner(
    int pendingCount,
    AdminAppointmentsController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade400, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.notification_important, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingCount agendamento(s) aguardando aprovação',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                Text(
                  'Clique em um agendamento para aprovar ou recusar',
                  style: TextStyle(fontSize: 12, color: Colors.amber.shade700),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                controller.setAestheticStatusFilter('pendingApproval'),
            child: const Text('Ver todos'),
          ),
        ],
      ),
    );
  }

  // ============ Calendar View ============

  Widget _buildCalendarView(
    List<BookingWithDetails> appointments,
    AdminAppointmentsState controllerState,
    AdminAppointmentsController controller,
  ) {
    final selectedBookings = appointments.where((a) {
      return isSameDay(a.booking.scheduledTime, controllerState.selectedDay);
    }).toList();

    return Column(
      children: [
        TableCalendar<BookingWithDetails>(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2026, 12, 31),
          focusedDay: controllerState.focusedDay ?? DateTime.now(),
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) =>
              isSameDay(controllerState.selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(controllerState.selectedDay, selectedDay)) {
              controller.setSelectedDay(selectedDay);
              controller.setFocusedDay(focusedDay);
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() => _calendarFormat = format);
            }
          },
          onPageChanged: (focusedDay) => controller.setFocusedDay(focusedDay),
          eventLoader: (day) {
            return appointments
                .where((b) => isSameDay(b.booking.scheduledTime, day))
                .toList();
          },
          calendarStyle: CalendarStyle(
            // Dark theme styling for calendar
            defaultTextStyle: const TextStyle(color: AdminTheme.textPrimary),
            weekendTextStyle: const TextStyle(color: AdminTheme.textSecondary),
            outsideTextStyle: const TextStyle(color: AdminTheme.textMuted),
            disabledTextStyle: TextStyle(
              color: AdminTheme.textMuted.withOpacity(0.5),
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            markerDecoration: BoxDecoration(
              gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AdminTheme.gradientPrimary[0].withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
              shape: BoxShape.circle,
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: AdminTheme.textSecondary),
            weekendStyle: TextStyle(color: AdminTheme.textMuted),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: AdminTheme.headingSmall,
            formatButtonTextStyle: const TextStyle(
              color: AdminTheme.textPrimary,
            ),
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: AdminTheme.borderLight),
              borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: AdminTheme.textPrimary,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: AdminTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AdminTheme.bgCard.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: selectedBookings.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum agendamento para este dia',
                      style: AdminTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedBookings.length,
                    itemBuilder: (context, index) {
                      final booking = selectedBookings[index];
                      return CarWashBookingCard(
                        bookingWithDetails: booking,
                        onTap: () =>
                            _showCarWashDetailsDialog(context, booking, ref),
                        onManage: () =>
                            _showCarWashDetailsDialog(context, booking, ref),
                        onWhatsApp: () =>
                            _launchWhatsApp(ref, booking.booking.userId),
                        onCancel: () => _updateCarWashStatus(
                          ref,
                          booking.booking.id,
                          BookingStatus.cancelled,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // ============ Aesthetic Calendar View ============

  Widget _buildAestheticCalendarView(
    List<ServiceBooking> appointments,
    AdminAppointmentsState controllerState,
    AdminAppointmentsController controller,
    Map<String, IndependentService> servicesMap,
  ) {
    final selectedBookings = appointments.where((a) {
      return isSameDay(a.scheduledTime, controllerState.selectedDay);
    }).toList();

    return Column(
      children: [
        TableCalendar<ServiceBooking>(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2026, 12, 31),
          focusedDay: controllerState.focusedDay ?? DateTime.now(),
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) =>
              isSameDay(controllerState.selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(controllerState.selectedDay, selectedDay)) {
              controller.setSelectedDay(selectedDay);
              controller.setFocusedDay(focusedDay);
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() => _calendarFormat = format);
            }
          },
          onPageChanged: (focusedDay) => controller.setFocusedDay(focusedDay),
          eventLoader: (day) {
            return appointments
                .where((b) => isSameDay(b.scheduledTime, day))
                .toList();
          },
          calendarStyle: CalendarStyle(
            // Dark theme styling for calendar
            defaultTextStyle: const TextStyle(color: AdminTheme.textPrimary),
            weekendTextStyle: const TextStyle(color: AdminTheme.textSecondary),
            outsideTextStyle: const TextStyle(color: AdminTheme.textMuted),
            markerDecoration: BoxDecoration(
              gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AdminTheme.gradientPrimary[0].withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
              shape: BoxShape.circle,
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: AdminTheme.textSecondary),
            weekendStyle: TextStyle(color: AdminTheme.textMuted),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: AdminTheme.headingSmall,
            formatButtonTextStyle: const TextStyle(
              color: AdminTheme.textPrimary,
            ),
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: AdminTheme.borderLight),
              borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: AdminTheme.textPrimary,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: AdminTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AdminTheme.bgCard.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: selectedBookings.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum agendamento para este dia',
                      style: AdminTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedBookings.length,
                    itemBuilder: (context, index) {
                      final booking = selectedBookings[index];
                      final service = servicesMap[booking.serviceId];
                      return AestheticBookingCard(
                        booking: booking,
                        service: service,
                        onTap: () => _showAestheticDetailsDialog(
                          context,
                          booking,
                          service,
                          ref,
                        ),
                        onManage: () => _showAestheticDetailsDialog(
                          context,
                          booking,
                          service,
                          ref,
                        ),
                        onWhatsApp: () =>
                            _launchWhatsAppFromPhone(booking.userPhone),
                        onCancel: () => _updateAestheticStatus(
                          ref,
                          booking.id,
                          ServiceBookingStatus.cancelled,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // ============ Dialog and Action Methods ============
  // (These remain largely the same as the original implementation)

  void _showCarWashDetailsDialog(
    BuildContext context,
    BookingWithDetails bookingWithDetails,
    WidgetRef ref,
  ) {
    final appointment = bookingWithDetails.booking;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusXXL),
          child: BackdropFilter(
            filter: AdminTheme.heavyBlur,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 750),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AdminTheme.radiusXXL),
                border: Border.all(color: AdminTheme.borderLight),
                boxShadow: AdminTheme.glowShadow(
                  AdminTheme.gradientPrimary[0],
                  intensity: 0.15,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Premium Header
                  _buildPremiumHeader(context, appointment),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AdminTheme.paddingLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Client Card
                          FutureBuilder<AppUser?>(
                            future: ref
                                .read(authRepositoryProvider)
                                .getUserProfile(appointment.userId),
                            builder: (context, snapshot) {
                              final user = snapshot.data;
                              final loading =
                                  snapshot.connectionState ==
                                  ConnectionState.waiting;
                              return _buildPremiumInfoCard(
                                icon: Icons.person_rounded,
                                iconColor: const Color(0xFF60A5FA),
                                label: 'Cliente',
                                value: loading
                                    ? 'Carregando...'
                                    : (user?.displayName ?? 'Desconhecido'),
                              );
                            },
                          ),
                          const SizedBox(height: AdminTheme.paddingMD),

                          // Vehicle Card
                          FutureBuilder<Vehicle?>(
                            future: ref
                                .read(bookingRepositoryProvider)
                                .getVehicle(appointment.vehicleId),
                            builder: (context, snapshot) {
                              final loading =
                                  snapshot.connectionState ==
                                  ConnectionState.waiting;
                              final vehicle = snapshot.data;
                              return _buildPremiumInfoCard(
                                icon: Icons.directions_car_rounded,
                                iconColor: const Color(0xFFA78BFA),
                                label: 'Veículo',
                                value: loading
                                    ? 'Carregando...'
                                    : (vehicle != null
                                          ? '${vehicle.brand} ${vehicle.model}'
                                          : 'Desconhecido'),
                                badge: vehicle?.plate.toUpperCase(),
                              );
                            },
                          ),
                          const SizedBox(height: AdminTheme.paddingMD),

                          // Services Card
                          FutureBuilder<List<ServicePackage?>>(
                            future: Future.wait(
                              appointment.serviceIds.map(
                                (id) => ref
                                    .read(bookingRepositoryProvider)
                                    .getService(id),
                              ),
                            ),
                            builder: (context, snapshot) {
                              final loading =
                                  snapshot.connectionState ==
                                  ConnectionState.waiting;
                              final services =
                                  snapshot.data
                                      ?.whereType<ServicePackage>()
                                      .toList() ??
                                  [];
                              final serviceNames = services
                                  .map((s) => s.title)
                                  .join(', ');
                              return _buildPremiumInfoCard(
                                icon: Icons.local_car_wash_rounded,
                                iconColor: const Color(0xFF10B981),
                                label: 'Serviços',
                                value: loading
                                    ? 'Carregando...'
                                    : (serviceNames.isNotEmpty
                                          ? serviceNames
                                          : 'Nenhum'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: AdminTheme.gradientSuccess,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AdminTheme.radiusMD,
                                    ),
                                    boxShadow: AdminTheme.glowShadow(
                                      AdminTheme.gradientSuccess[0],
                                      intensity: 0.3,
                                    ),
                                  ),
                                  child: Text(
                                    'R\$ ${appointment.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AdminTheme.paddingMD),

                          // DateTime Card
                          _buildPremiumInfoCard(
                            icon: Icons.schedule_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            label: 'Horário',
                            value: DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(appointment.scheduledTime),
                          ),
                          const SizedBox(height: AdminTheme.paddingLG),

                          // Status Section
                          _buildPremiumStatusSection(context, ref, appointment),
                          const SizedBox(height: AdminTheme.paddingLG),

                          // WhatsApp Button
                          _buildPremiumWhatsAppButton(ref, appointment.userId),

                          // Logs Section
                          _buildPremiumLogsSection(
                            context,
                            ref,
                            appointment.logs,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  _buildPremiumFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, Booking appointment) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminTheme.gradientPrimary[0].withOpacity(0.2),
            AdminTheme.gradientPrimary[1].withOpacity(0.1),
          ],
        ),
        border: Border(bottom: BorderSide(color: AdminTheme.borderLight)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
              borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
              boxShadow: AdminTheme.glowShadow(
                AdminTheme.gradientPrimary[0],
                intensity: 0.3,
              ),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AdminTheme.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detalhes do Agendamento', style: AdminTheme.headingSmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getCarWashStatusColor(
                      appointment.status,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                    border: Border.all(
                      color: getCarWashStatusColor(
                        appointment.status,
                      ).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getCarWashStatusIcon(appointment.status),
                        color: getCarWashStatusColor(appointment.status),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        getCarWashStatusLabel(appointment.status),
                        style: TextStyle(
                          color: getCarWashStatusColor(appointment.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderIconButton(
                icon: Icons.edit_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.pop(context);
                  AppToast.info(context, message: 'Funcionalidade em breve');
                },
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.delete_rounded,
                color: const Color(0xFFEF4444),
                onTap: () async {
                  final confirm = await _showPremiumConfirmDialog(
                    context,
                    'Excluir Agendamento',
                    'Tem certeza que deseja excluir?',
                  );
                  if (confirm == true && context.mounted) {
                    Navigator.pop(context);
                    AppToast.info(context, message: 'Funcionalidade em breve');
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildHeaderIconButton(
                icon: Icons.close_rounded,
                color: AdminTheme.textSecondary,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildPremiumInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? badge,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: AdminTheme.bgCardLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AdminTheme.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AdminTheme.labelSmall.copyWith(color: iconColor),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AdminTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                border: Border.all(color: iconColor.withOpacity(0.5)),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPremiumStatusSection(
    BuildContext context,
    WidgetRef ref,
    Booking appointment,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: AdminTheme.bgCardLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Alterar Status',
                style: AdminTheme.bodyLarge.copyWith(
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BookingStatus.values.map((status) {
              final isSelected = appointment.status == status;
              final color = getCarWashStatusColor(status);
              return GestureDetector(
                onTap: () {
                  _updateCarWashStatus(ref, appointment.id, status);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.25)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                    border: Border.all(
                      color: isSelected ? color : AdminTheme.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          getCarWashStatusIcon(status),
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        getCarWashStatusLabel(status),
                        style: TextStyle(
                          color: isSelected ? color : AdminTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumWhatsAppButton(WidgetRef ref, String userId) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
        ),
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        boxShadow: AdminTheme.glowShadow(
          const Color(0xFF25D366),
          intensity: 0.3,
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _launchWhatsApp(ref, userId),
        icon: const Icon(Icons.chat_rounded, size: 20),
        label: const Text('Enviar WhatsApp'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLogsSection(
    BuildContext context,
    WidgetRef ref,
    List<BookingLog> logs,
  ) {
    if (logs.isEmpty) return const SizedBox.shrink();

    final sortedLogs = List<BookingLog>.from(logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Container(
      margin: const EdgeInsets.only(top: AdminTheme.paddingLG),
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: AdminTheme.bgCardLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF06B6D4),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Histórico de Auditoria',
                style: AdminTheme.bodyLarge.copyWith(
                  color: const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedLogs
              .take(5)
              .map(
                (log) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: getCarWashStatusColor(
                            log.status,
                          ).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          getCarWashStatusIcon(log.status),
                          color: getCarWashStatusColor(log.status),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${getCarWashStatusLabel(log.status)}',
                              style: AdminTheme.bodyMedium.copyWith(
                                color: AdminTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat(
                                "dd/MM/yyyy 'às' HH:mm",
                              ).format(log.timestamp),
                              style: AdminTheme.bodySmall,
                            ),
                            FutureBuilder<AppUser?>(
                              future: ref
                                  .read(authRepositoryProvider)
                                  .getUserProfile(log.actorId),
                              builder: (context, snapshot) {
                                final actorName =
                                    snapshot.data?.displayName ??
                                    log.actorName ??
                                    'Sistema';
                                return Text(
                                  'Por: $actorName',
                                  style: AdminTheme.labelSmall.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildPremiumFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(top: BorderSide(color: AdminTheme.borderLight)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AdminTheme.textSecondary,
            side: BorderSide(color: AdminTheme.borderMedium),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
            ),
          ),
          child: const Text('Fechar'),
        ),
      ),
    );
  }

  Future<bool?> _showPremiumConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
          child: BackdropFilter(
            filter: AdminTheme.heavyBlur,
            child: Container(
              padding: const EdgeInsets.all(AdminTheme.paddingLG),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
                border: Border.all(color: AdminTheme.borderLight),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AdminTheme.headingSmall),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: AdminTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminTheme.textSecondary,
                            side: BorderSide(color: AdminTheme.borderMedium),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(
                              AdminTheme.radiusMD,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Confirmar'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAestheticDetailsDialog(
    BuildContext context,
    ServiceBooking booking,
    IndependentService? service,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusXXL),
          child: BackdropFilter(
            filter: AdminTheme.heavyBlur,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AdminTheme.radiusXXL),
                border: Border.all(color: AdminTheme.borderLight),
                boxShadow: AdminTheme.glowShadow(
                  AdminTheme.gradientPrimary[0],
                  intensity: 0.15,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Premium Header
                  _buildAestheticHeader(context, booking, service),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AdminTheme.paddingLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Client Card
                          _buildPremiumInfoCard(
                            icon: Icons.person_rounded,
                            iconColor: const Color(0xFF60A5FA),
                            label: 'Cliente',
                            value: booking.userName ?? 'Desconhecido',
                          ),
                          const SizedBox(height: AdminTheme.paddingMD),

                          // Phone Card
                          if (booking.userPhone != null)
                            _buildPremiumInfoCard(
                              icon: Icons.phone_rounded,
                              iconColor: const Color(0xFF10B981),
                              label: 'Telefone',
                              value: booking.userPhone!,
                            ),
                          if (booking.userPhone != null)
                            const SizedBox(height: AdminTheme.paddingMD),

                          // Service Card
                          _buildPremiumInfoCard(
                            icon: Icons.auto_awesome_rounded,
                            iconColor: const Color(0xFFA78BFA),
                            label: 'Serviço',
                            value: service?.title ?? 'Desconhecido',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AdminTheme.gradientSuccess,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AdminTheme.radiusMD,
                                ),
                                boxShadow: AdminTheme.glowShadow(
                                  AdminTheme.gradientSuccess[0],
                                  intensity: 0.3,
                                ),
                              ),
                              child: Text(
                                'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AdminTheme.paddingMD),

                          // DateTime Card
                          _buildPremiumInfoCard(
                            icon: Icons.schedule_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            label: 'Horário',
                            value: DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(booking.scheduledTime),
                          ),

                          // Notes Card
                          if (booking.notes != null &&
                              booking.notes!.isNotEmpty) ...[
                            const SizedBox(height: AdminTheme.paddingMD),
                            _buildPremiumInfoCard(
                              icon: Icons.note_rounded,
                              iconColor: const Color(0xFF64748B),
                              label: 'Observações',
                              value: booking.notes!,
                            ),
                          ],
                          const SizedBox(height: AdminTheme.paddingLG),

                          // Status Section
                          _buildAestheticStatusSection(context, ref, booking),
                          const SizedBox(height: AdminTheme.paddingLG),

                          // Payment Status Section
                          _buildAestheticPaymentSection(context, ref, booking),
                          const SizedBox(height: AdminTheme.paddingLG),

                          // WhatsApp Button
                          if (booking.userPhone != null)
                            _buildPremiumWhatsAppButtonForPhone(
                              booking.userPhone,
                            ),

                          // Rejection Reason
                          if (booking.status == ServiceBookingStatus.rejected &&
                              booking.rejectionReason != null)
                            _buildRejectionReasonCard(booking.rejectionReason!),

                          // Pending Approval Actions
                          if (booking.status ==
                              ServiceBookingStatus.pendingApproval)
                            _buildPendingApprovalCard(context, ref, booking.id),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  _buildPremiumFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAestheticHeader(
    BuildContext context,
    ServiceBooking booking,
    IndependentService? service,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminTheme.gradientPrimary[0].withOpacity(0.2),
            AdminTheme.gradientPrimary[1].withOpacity(0.1),
          ],
        ),
        border: Border(bottom: BorderSide(color: AdminTheme.borderLight)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
              borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
              boxShadow: AdminTheme.glowShadow(
                AdminTheme.gradientPrimary[0],
                intensity: 0.3,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AdminTheme.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalhes do Serviço',
                  style: AdminTheme.headingSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getAestheticStatusColor(
                      booking.status,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                    border: Border.all(
                      color: getAestheticStatusColor(
                        booking.status,
                      ).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getAestheticStatusIcon(booking.status),
                        color: getAestheticStatusColor(booking.status),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          getAestheticStatusLabel(booking.status),
                          style: TextStyle(
                            color: getAestheticStatusColor(booking.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderIconButton(
            icon: Icons.close_rounded,
            color: AdminTheme.textSecondary,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAestheticStatusSection(
    BuildContext context,
    WidgetRef ref,
    ServiceBooking booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: AdminTheme.bgCardLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Status do Serviço',
                style: AdminTheme.bodyLarge.copyWith(
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ServiceBookingStatus.values.map((status) {
              final isSelected = booking.status == status;
              final color = getAestheticStatusColor(status);
              return GestureDetector(
                onTap: () {
                  _updateAestheticStatus(ref, booking.id, status);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.25)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                    border: Border.all(
                      color: isSelected ? color : AdminTheme.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          getAestheticStatusIcon(status),
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        getAestheticStatusLabel(status),
                        style: TextStyle(
                          color: isSelected ? color : AdminTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAestheticPaymentSection(
    BuildContext context,
    WidgetRef ref,
    ServiceBooking booking,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: AdminTheme.bgCardLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Status do Pagamento',
                style: AdminTheme.bodyLarge.copyWith(
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentStatus.values.map((status) {
              final isSelected = booking.paymentStatus == status;
              final color = getPaymentStatusColor(status);
              return GestureDetector(
                onTap: () {
                  _updatePaymentStatus(
                    ref,
                    booking.id,
                    status,
                    booking.totalPrice,
                  );
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.25)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                    border: Border.all(
                      color: isSelected ? color : AdminTheme.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          getPaymentStatusIcon(status),
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        getPaymentStatusLabel(status),
                        style: TextStyle(
                          color: isSelected ? color : AdminTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumWhatsAppButtonForPhone(String? phone) {
    if (phone == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AdminTheme.paddingMD),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
        ),
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        boxShadow: AdminTheme.glowShadow(
          const Color(0xFF25D366),
          intensity: 0.3,
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _launchWhatsAppFromPhone(phone),
        icon: const Icon(Icons.chat_rounded, size: 20),
        label: const Text('Enviar WhatsApp'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
          ),
        ),
      ),
    );
  }

  Widget _buildRejectionReasonCard(String reason) {
    return Container(
      margin: const EdgeInsets.only(top: AdminTheme.paddingMD),
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.15),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.2),
              borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
            ),
            child: const Icon(
              Icons.info_rounded,
              color: Color(0xFFEF4444),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Motivo da Recusa',
                  style: AdminTheme.labelSmall.copyWith(
                    color: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 4),
                Text(reason, style: AdminTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalCard(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: AdminTheme.paddingMD),
      padding: const EdgeInsets.all(AdminTheme.paddingMD),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.15),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  color: Color(0xFFF59E0B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ação Necessária',
                style: AdminTheme.bodyLarge.copyWith(
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AdminTheme.gradientSuccess,
                    ),
                    borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                    boxShadow: AdminTheme.glowShadow(
                      AdminTheme.gradientSuccess[0],
                      intensity: 0.3,
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _approveBooking(ref, bookingId);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Aprovar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AdminTheme.radiusMD,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AdminTheme.gradientDanger),
                    borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                    boxShadow: AdminTheme.glowShadow(
                      AdminTheme.gradientDanger[0],
                      intensity: 0.3,
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showRejectDialog(context, ref, bookingId);
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Recusar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AdminTheme.radiusMD,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ Helper Widgets ============

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildLogsSection(
    BuildContext context,
    WidgetRef ref,
    List<BookingLog> logs,
  ) {
    if (logs.isEmpty) {
      return _buildDetailRow(
        Icons.history,
        'Auditoria',
        'Nenhum evento registrado.',
      );
    }

    final sortedLogs = List<BookingLog>.from(logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.history, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            const Text(
              'Histórico de Auditoria',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: sortedLogs.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      getCarWashStatusIcon(log.status),
                      size: 24,
                      color: getCarWashStatusColor(log.status),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${getCarWashStatusLabel(log.status)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat(
                              "dd/MM/yyyy 'às' HH:mm",
                            ).format(log.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<AppUser?>(
                            future: ref
                                .read(authRepositoryProvider)
                                .getUserProfile(log.actorId),
                            builder: (context, snapshot) {
                              final actorName =
                                  snapshot.data?.displayName ??
                                  log.actorId.substring(0, 6);
                              final actorText =
                                  snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? 'Carregando...'
                                  : 'Por: $actorName';
                              return Text(
                                actorText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade700,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============ Action Methods ============

  Future<void> _updateCarWashStatus(
    WidgetRef ref,
    String id,
    BookingStatus status,
  ) async {
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) return;

      await ref
          .read(adminRepositoryProvider)
          .updateBookingStatus(id, status, actorId: user.uid);
      if (mounted) {
        AppToast.success(
          context,
          message: 'Status atualizado para ${getCarWashStatusLabel(status)}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar: $e');
      }
    }
  }

  Future<void> _updateAestheticStatus(
    WidgetRef ref,
    String bookingId,
    ServiceBookingStatus status,
  ) async {
    try {
      await ref
          .read(independentServiceRepositoryProvider)
          .updateBookingStatus(bookingId, status);
      if (mounted) {
        AppToast.success(
          context,
          message: 'Status atualizado para ${getAestheticStatusLabel(status)}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar: $e');
      }
    }
  }

  Future<void> _approveBooking(WidgetRef ref, String bookingId) async {
    try {
      await ref
          .read(independentServiceRepositoryProvider)
          .approveBooking(bookingId);
      if (mounted) {
        AppToast.success(context, message: 'Agendamento aprovado!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao aprovar: $e');
      }
    }
  }

  void _showRejectDialog(BuildContext ctx, WidgetRef ref, String bookingId) {
    final reasonController = TextEditingController();

    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Recusar Agendamento', style: AdminTheme.headingSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por favor, informe o motivo da recusa. '
              'Esta informação será visível para o cliente.',
              style: AdminTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AdminTextField(
              controller: reasonController,
              label: 'Motivo da recusa',
              hint: 'Ex: Horário indisponível, falta de materiais...',
              icon: Icons.edit_note,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                AppToast.error(ctx, message: 'Informe o motivo da recusa');
                return;
              }
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(independentServiceRepositoryProvider)
                    .rejectBooking(bookingId, reason);
                if (mounted) {
                  AppToast.success(ctx, message: 'Agendamento recusado');
                }
              } catch (e) {
                if (mounted) {
                  AppToast.error(ctx, message: 'Erro ao recusar: $e');
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar Recusa'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePaymentStatus(
    WidgetRef ref,
    String bookingId,
    PaymentStatus status,
    double totalPrice,
  ) async {
    try {
      final paidAmount = status == PaymentStatus.paid
          ? totalPrice
          : status == PaymentStatus.pending
          ? 0.0
          : null;

      await ref
          .read(independentServiceRepositoryProvider)
          .updatePaymentStatus(bookingId, status, paidAmount: paidAmount);
      if (mounted) {
        AppToast.success(
          context,
          message: 'Pagamento atualizado para ${getPaymentStatusLabel(status)}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar pagamento: $e');
      }
    }
  }

  Future<void> _launchWhatsApp(WidgetRef ref, String userId) async {
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .getUserProfile(userId);
      final phoneNumber = user?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        if (mounted) {
          AppToast.warning(context, message: 'Telefone não cadastrado');
        }
        return;
      }

      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      final uri = Uri.parse(
        'https://wa.me/$cleanPhone?text=Olá, sobre seu agendamento na AquaClean...',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          AppToast.error(context, message: 'Não foi possível abrir o WhatsApp');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao buscar telefone: $e');
      }
    }
  }

  Future<void> _launchWhatsAppFromPhone(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (mounted) {
        AppToast.warning(context, message: 'Telefone não cadastrado');
      }
      return;
    }

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=Olá, sobre seu agendamento na AquaClean...',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        AppToast.error(context, message: 'Não foi possível abrir o WhatsApp');
      }
    }
  }
}
