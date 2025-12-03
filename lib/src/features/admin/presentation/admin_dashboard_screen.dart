import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/admin_repository.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';

import '../domain/admin_event.dart';
import '../domain/booking_with_details.dart';
import 'widgets/add_event_dialog.dart';
import '../../../common_widgets/atoms/app_loader.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Painel Administrativo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: theme.colorScheme.onPrimary),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminBookingsWithDetailsProvider);
          ref.invalidate(adminEventsProvider);
          // Wait a bit to show the loading indicator
          await Future.delayed(const Duration(seconds: 1));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildKpiGrid(context, ref, isWide: isWide),
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildCalendarWidget(context)),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ações Rápidas',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildQuickActions(context),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildCalendarWidget(context),
                    const SizedBox(height: 24),
                    Text(
                      'Ações Rápidas',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem-vindo, Admin',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aqui está o resumo das atividades de hoje.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AddEventDialog(initialDate: _selectedDay ?? DateTime.now()),
    );
  }

  Widget _buildKpiGrid(
    BuildContext context,
    WidgetRef ref, {
    required bool isWide,
  }) {
    final subscribersAsync = ref.watch(subscribersProvider);
    final bookingsAsync = ref.watch(adminBookingsProvider);
    final vehiclesAsync = ref.watch(adminVehiclesProvider);

    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isWide ? 1.5 : 1.3,
      children: [
        // Bookings Today
        bookingsAsync.when(
          data: (bookings) {
            final today = DateTime.now();
            final count = bookings.where((b) {
              return b.scheduledTime.year == today.year &&
                  b.scheduledTime.month == today.month &&
                  b.scheduledTime.day == today.day;
            }).length;
            return _buildMetricCard(
              context,
              title: 'Agendamentos Hoje',
              value: count.toString(),
              icon: Icons.today,
              color: Colors.orange,
            );
          },
          loading: () => _buildLoadingCard(context, 'Agendamentos Hoje'),
          error: (_, __) => _buildErrorCard(context, 'Erro'),
        ),
        // Monthly Revenue
        bookingsAsync.when(
          data: (bookings) {
            final now = DateTime.now();
            final revenue = bookings
                .where(
                  (b) =>
                      b.status == BookingStatus.finished &&
                      b.scheduledTime.year == now.year &&
                      b.scheduledTime.month == now.month,
                )
                .fold(0.0, (sum, b) => sum + b.totalPrice);
            return _buildMetricCard(
              context,
              title: 'Receita Mensal',
              value: NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              ).format(revenue),
              icon: Icons.attach_money,
              color: Colors.green,
            );
          },
          loading: () => _buildLoadingCard(context, 'Receita Mensal'),
          error: (_, __) => _buildErrorCard(context, 'Erro'),
        ),
        // Vehicles
        vehiclesAsync.when(
          data: (vehicles) => _buildMetricCard(
            context,
            title: 'Veículos',
            value: vehicles.length.toString(),
            icon: Icons.directions_car,
            color: Colors.blue,
          ),
          loading: () => _buildLoadingCard(context, 'Veículos'),
          error: (_, __) => _buildErrorCard(context, 'Erro'),
        ),
        // Subscribers
        subscribersAsync.when(
          data: (subs) => _buildMetricCard(
            context,
            title: 'Assinantes',
            value: subs.length.toString(),
            icon: Icons.people,
            color: Colors.purple,
          ),
          loading: () => _buildLoadingCard(context, 'Assinantes'),
          error: (_, __) => _buildErrorCard(context, 'Erro'),
        ),
      ],
    );
  }

  Widget _buildCalendarWidget(BuildContext context) {
    final theme = Theme.of(context);
    final bookingsAsync = ref.watch(adminBookingsWithDetailsProvider);
    final eventsAsync = ref.watch(adminEventsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agenda',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddEventDialog(
                        initialDate: _selectedDay ?? DateTime.now(),
                      ),
                    );
                  },
                  tooltip: 'Adicionar Compromisso',
                ),
              ],
            ),
            const SizedBox(height: 16),
            bookingsAsync.when(
              data: (bookings) {
                return eventsAsync.when(
                  data: (events) {
                    return Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2025, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          calendarFormat: CalendarFormat.month,
                          eventLoader: (day) {
                            final dayBookings = bookings
                                .where(
                                  (b) =>
                                      isSameDay(b.booking.scheduledTime, day),
                                )
                                .toList();
                            final dayEvents = events
                                .where((e) => isSameDay(e.date, day))
                                .toList();
                            return [...dayBookings, ...dayEvents];
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(_selectedDay, selectedDay)) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarStyle: CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            markerDecoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildAgendaList(context, bookings, events),
                      ],
                    );
                  },
                  loading: () => const Center(child: AppLoader()),
                  error: (err, _) => Text('Erro ao carregar eventos: $err'),
                );
              },
              loading: () => const Center(child: AppLoader()),
              error: (err, _) => Text('Erro ao carregar agenda: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaList(
    BuildContext context,
    List<BookingWithDetails> allBookings,
    List<AdminEvent> allEvents,
  ) {
    final theme = Theme.of(context);

    final selectedBookings = allBookings.where((b) {
      return isSameDay(b.booking.scheduledTime, _selectedDay);
    }).toList();

    final selectedEvents = allEvents.where((e) {
      return isSameDay(e.date, _selectedDay);
    }).toList();

    final allItems = [
      ...selectedBookings.map(
        (b) => {'type': 'booking', 'data': b, 'time': b.booking.scheduledTime},
      ),
      ...selectedEvents.map(
        (e) => {'type': 'event', 'data': e, 'time': e.date},
      ),
    ];

    allItems.sort(
      (a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime),
    );

    if (allItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Nenhum agendamento ou compromisso para este dia.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = allItems[index];
        final type = item['type'] as String;

        if (type == 'booking') {
          final bookingWithDetails = item['data'] as BookingWithDetails;
          return _buildBookingItem(context, bookingWithDetails);
        } else {
          final event = item['data'] as AdminEvent;
          return _buildEventItem(context, event);
        }
      },
    );
  }

  Widget _buildBookingItem(BuildContext context, BookingWithDetails details) {
    final theme = Theme.of(context);
    final booking = details.booking;
    final user = details.user;
    final vehicle = details.vehicle;
    final services = details.services;

    final serviceNames = services.isNotEmpty
        ? services.map((s) => s.title).join(', ')
        : 'Serviço não identificado';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(booking.scheduledTime),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        title: Text(
          serviceNames,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              Text(
                user.displayName ?? 'Sem nome',
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (vehicle != null)
              Text(
                '${vehicle.model} - ${vehicle.plate}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                booking.status.name.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getStatusColor(booking.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {
          _showBookingDetailsDialog(context, details);
        },
      ),
    );
  }

  void _showBookingDetailsDialog(
    BuildContext context,
    BookingWithDetails details,
  ) {
    final theme = Theme.of(context);
    final booking = details.booking;
    final user = details.user;
    final vehicle = details.vehicle;
    final services = details.services;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalhes do Agendamento',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  'Status',
                  booking.status.name.toUpperCase(),
                  color: _getStatusColor(booking.status),
                ),
                _buildDetailRow(
                  context,
                  'Data',
                  DateFormat('dd/MM/yyyy').format(booking.scheduledTime),
                ),
                _buildDetailRow(
                  context,
                  'Horário',
                  DateFormat('HH:mm').format(booking.scheduledTime),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cliente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user != null) ...[
                  _buildDetailRow(
                    context,
                    'Nome',
                    user.displayName ?? 'Sem nome',
                  ),
                  _buildDetailRow(context, 'Email', user.email),
                  _buildDetailRow(context, 'Telefone', user.phoneNumber ?? '-'),
                ] else
                  const Text('Informações do cliente não disponíveis'),
                const SizedBox(height: 16),
                Text(
                  'Veículo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (vehicle != null) ...[
                  _buildDetailRow(context, 'Modelo', vehicle.model),
                  _buildDetailRow(context, 'Placa', vehicle.plate),
                  _buildDetailRow(
                    context,
                    'Tipo',
                    vehicle.type.toString().split('.').last,
                  ),
                ] else
                  const Text('Informações do veículo não disponíveis'),
                const SizedBox(height: 16),
                Text(
                  'Serviços',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (services.isNotEmpty)
                  ...services.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '• ${s.title} - R\$ ${s.price.toStringAsFixed(2)}',
                      ),
                    ),
                  )
                else
                  const Text('Nenhum serviço identificado'),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  'Total',
                  'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color ?? theme.colorScheme.onSurface,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, AdminEvent event) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(event.date),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
        title: Text(
          event.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: event.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: event.description != null
            ? Text(
                event.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            event.isDone ? Icons.check_circle : Icons.circle_outlined,
            color: event.isDone ? Colors.green : theme.colorScheme.tertiary,
          ),
          onPressed: () {
            ref
                .read(adminRepositoryProvider)
                .toggleEventStatus(event.id, !event.isDone);
          },
        ),
        onLongPress: () {
          // Confirm delete
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Excluir Compromisso'),
              content: const Text('Deseja excluir este compromisso?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(adminRepositoryProvider).deleteEvent(event.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Excluir'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkIn:
        return Colors.purple;
      case BookingStatus.washing:
        return Colors.blueAccent;
      case BookingStatus.vacuuming:
        return Colors.teal;
      case BookingStatus.drying:
        return Colors.lightBlue;
      case BookingStatus.polishing:
        return Colors.indigo;
      case BookingStatus.finished:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.noShow:
        return Colors.grey;
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acesso Rápido',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Gerenciar Agendamentos',
          subtitle: 'Ver todos os agendamentos',
          icon: Icons.calendar_today,
          color: Colors.orange,
          onTap: () => context.push('/admin/appointments'),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          title: 'Gerenciar Planos',
          subtitle: 'Criar e editar planos de assinatura',
          icon: Icons.card_membership,
          color: Colors.blue,
          onTap: () => context.push('/admin/plans'),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          title: 'Ver Assinantes',
          subtitle: 'Listar usuários com assinatura ativa',
          icon: Icons.group,
          color: Colors.green,
          onTap: () => context.push('/admin/subscribers'),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          title: 'Gerenciar Serviços',
          subtitle: 'Criar e editar serviços de lavagem',
          icon: Icons.local_car_wash,
          color: Colors.indigo,
          onTap: () => context.push('/admin/services'),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          title: 'Gerenciar Clientes',
          subtitle: 'Editar, suspender ou cancelar contas',
          icon: Icons.people_outline,
          color: Colors.purple,
          onTap: () => context.push('/admin/customers'),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          title: 'Relatórios Financeiros',
          subtitle: 'Receita, ticket médio e gráficos',
          icon: Icons.bar_chart,
          color: Colors.teal,
          onTap: () => context.push('/admin/reports'),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context, String title) {
    return _buildMetricCard(
      context,
      title: title,
      value: '...',
      icon: Icons.circle,
      color: Colors.grey,
    );
  }

  Widget _buildErrorCard(BuildContext context, String title) {
    return _buildMetricCard(
      context,
      title: title,
      value: '-',
      icon: Icons.error,
      color: Colors.red,
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
