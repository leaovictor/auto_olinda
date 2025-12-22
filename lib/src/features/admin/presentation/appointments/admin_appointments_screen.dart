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

// Controller and State imports
import 'admin_appointments_controller.dart';
import 'admin_appointments_state.dart';

// Widget imports
import 'widgets/car_wash_booking_card.dart';
import 'widgets/aesthetic_booking_card.dart';
import 'widgets/appointment_card_skeleton.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Agendamentos'),
        actions: [
          IconButton(
            icon: Icon(
              controllerState.currentSortOrder == SortOrder.newestFirst
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
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
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.local_car_wash), text: 'Lavagem'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Estética'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCarWashTab(isMobile), _buildAestheticTab(isMobile)],
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
        // Search and filter bar (hide in calendar view)
        if (!controllerState.isCalendarView) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, placa...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
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
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por cliente, telefone...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
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
            markerDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(120),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: Container(
            color: Colors.grey[50],
            child: selectedBookings.isEmpty
                ? const Center(child: Text('Nenhum agendamento para este dia'))
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
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Detalhes'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.pop(context);
                    AppToast.info(
                      context,
                      message: 'Funcionalidade de editar em breve',
                    );
                  },
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar Exclusão'),
                        content: const Text(
                          'Tem certeza que deseja excluir este agendamento?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        AppToast.info(
                          context,
                          message: 'Funcionalidade de excluir em breve',
                        );
                      }
                    }
                  },
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client
                FutureBuilder<AppUser?>(
                  future: ref
                      .read(authRepositoryProvider)
                      .getUserProfile(appointment.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildDetailRow(
                        Icons.person,
                        'Cliente',
                        'Carregando...',
                      );
                    }
                    final user = snapshot.data;
                    return _buildDetailRow(
                      Icons.person,
                      'Cliente',
                      user?.displayName ?? 'Desconhecido',
                    );
                  },
                ),
                // Vehicle
                FutureBuilder<Vehicle?>(
                  future: ref
                      .read(bookingRepositoryProvider)
                      .getVehicle(appointment.vehicleId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildDetailRow(
                        Icons.directions_car,
                        'Veículo',
                        'Carregando...',
                      );
                    }
                    final vehicle = snapshot.data;
                    return _buildDetailRow(
                      Icons.directions_car,
                      'Veículo',
                      vehicle != null
                          ? '${vehicle.brand} ${vehicle.model} (${vehicle.plate})'
                          : 'Desconhecido',
                    );
                  },
                ),
                // Services
                FutureBuilder<List<ServicePackage?>>(
                  future: Future.wait(
                    appointment.serviceIds.map(
                      (id) =>
                          ref.read(bookingRepositoryProvider).getService(id),
                    ),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildDetailRow(
                        Icons.cleaning_services,
                        'Serviços',
                        'Carregando...',
                      );
                    }
                    final services =
                        snapshot.data?.whereType<ServicePackage>().toList() ??
                        [];
                    final serviceNames = services
                        .map((s) => s.title)
                        .join(', ');
                    return _buildDetailRow(
                      Icons.cleaning_services,
                      'Serviços',
                      serviceNames.isNotEmpty ? serviceNames : 'Nenhum',
                    );
                  },
                ),
                _buildDetailRow(
                  Icons.access_time,
                  'Horário',
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(appointment.scheduledTime),
                ),
                _buildDetailRow(
                  Icons.attach_money,
                  'Valor',
                  'R\$ ${appointment.totalPrice.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BookingStatus.values.map((status) {
                    final isSelected = appointment.status == status;
                    return ChoiceChip(
                      label: Text(getCarWashStatusLabel(status)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _updateCarWashStatus(ref, appointment.id, status);
                          Navigator.pop(context);
                        }
                      },
                      selectedColor: getCarWashStatusColor(
                        status,
                      ).withAlpha(50),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? getCarWashStatusColor(status)
                            : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      avatar: isSelected
                          ? Icon(
                              getCarWashStatusIcon(status),
                              size: 18,
                              color: getCarWashStatusColor(status),
                            )
                          : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _launchWhatsApp(ref, appointment.userId);
                      Navigator.pop(context);
                    },
                  ),
                ),
                _buildLogsSection(context, ref, appointment.logs),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
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
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Detalhes do Agendamento'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  Icons.person,
                  'Cliente',
                  booking.userName ?? 'Desconhecido',
                ),
                if (booking.userPhone != null)
                  _buildDetailRow(Icons.phone, 'Telefone', booking.userPhone!),
                _buildDetailRow(
                  Icons.auto_awesome,
                  'Serviço',
                  service?.title ?? 'Desconhecido',
                ),
                _buildDetailRow(
                  Icons.access_time,
                  'Horário',
                  DateFormat('dd/MM/yyyy HH:mm').format(booking.scheduledTime),
                ),
                _buildDetailRow(
                  Icons.attach_money,
                  'Valor',
                  'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                ),
                if (booking.notes != null && booking.notes!.isNotEmpty)
                  _buildDetailRow(Icons.note, 'Observações', booking.notes!),
                const SizedBox(height: 16),
                const Text(
                  'Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ServiceBookingStatus.values.map((status) {
                    final isSelected = booking.status == status;
                    return ChoiceChip(
                      label: Text(getAestheticStatusLabel(status)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _updateAestheticStatus(ref, booking.id, status);
                          Navigator.pop(context);
                        }
                      },
                      selectedColor: getAestheticStatusColor(
                        status,
                      ).withAlpha(50),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? getAestheticStatusColor(status)
                            : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      avatar: isSelected
                          ? Icon(
                              getAestheticStatusIcon(status),
                              size: 18,
                              color: getAestheticStatusColor(status),
                            )
                          : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Status do Pagamento:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PaymentStatus.values.map((status) {
                    final isSelected = booking.paymentStatus == status;
                    return ChoiceChip(
                      label: Text(getPaymentStatusLabel(status)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _updatePaymentStatus(
                            ref,
                            booking.id,
                            status,
                            booking.totalPrice,
                          );
                          Navigator.pop(context);
                        }
                      },
                      selectedColor: getPaymentStatusColor(
                        status,
                      ).withAlpha(50),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? getPaymentStatusColor(status)
                            : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      avatar: isSelected
                          ? Icon(
                              getPaymentStatusIcon(status),
                              size: 18,
                              color: getPaymentStatusColor(status),
                            )
                          : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (booking.userPhone != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _launchWhatsAppFromPhone(booking.userPhone);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                // Show rejection reason if booking was rejected
                if (booking.status == ServiceBookingStatus.rejected &&
                    booking.rejectionReason != null)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Motivo da recusa:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              Text(booking.rejectionReason!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Quick approve/reject buttons for pending bookings
                if (booking.status == ServiceBookingStatus.pendingApproval)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.pending_actions,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ação Necessária',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _approveBooking(ref, booking.id);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Aprovar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showRejectDialog(context, ref, booking.id);
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('Recusar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
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
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Recusar Agendamento'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por favor, informe o motivo da recusa. '
              'Esta informação será visível para o cliente.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Motivo da recusa',
                hintText: 'Ex: Horário indisponível, falta de materiais...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
              maxLines: 3,
              autofocus: true,
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
