import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/admin_repository.dart'; // Import adminRepositoryProvider
import '../../domain/booking_with_details.dart'; // Import BookingWithDetails
import '../../../booking/domain/booking.dart'; // Import BookingStatus
import '../../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../domain/admin_event.dart'; // Import AdminEvent
import '../widgets/add_event_dialog.dart'; // Import AddEventDialog

import '../../../../common_widgets/molecules/full_screen_loader.dart';
import '../widgets/edit_event_dialog.dart';
import '../widgets/booking_details_dialog.dart';
import '../theme/admin_theme.dart';

class AdminCalendarScreen extends ConsumerStatefulWidget {
  const AdminCalendarScreen({super.key});

  @override
  ConsumerState<AdminCalendarScreen> createState() =>
      _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends ConsumerState<AdminCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(adminBookingsWithDetailsProvider);
    final eventsAsync = ref.watch(adminEventsProvider);
    final theme = Theme.of(context);

    // Merge loading/error states (simplified)
    if (bookingsAsync.isLoading || eventsAsync.isLoading) {
      return const Scaffold(
        body: FullScreenLoader(message: 'Carregando calendário...'),
      );
    }

    final bookings = bookingsAsync.valueOrNull ?? [];
    final events = eventsAsync.valueOrNull ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // title: const Text('Calendário', style: AdminTheme.headingMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminTheme.textPrimary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AdminTheme.bgDark.withOpacity(0.9), Colors.transparent],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/admin/calendar/config'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                AddEventDialog(initialDate: _selectedDay ?? DateTime.now()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: AppRefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminBookingsWithDetailsProvider);
            ref.invalidate(adminEventsProvider);
            await Future.delayed(const Duration(seconds: 1));
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              // Filter for selected day
              final selectedBookings = bookings.where((b) {
                return isSameDay(b.booking.scheduledTime, _selectedDay);
              }).toList();

              final selectedEvents = events.where((e) {
                return isSameDay(e.date, _selectedDay);
              }).toList();

              // Combined list helper
              Widget buildDailyList() {
                if (selectedBookings.isEmpty && selectedEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: AdminTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nada agendado para este dia',
                          style: TextStyle(color: AdminTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(
                    top: kToolbarHeight + 16,
                    left: 16,
                    right: 16,
                    bottom: 80,
                  ),
                  children: [
                    if (selectedEvents.isNotEmpty) ...[
                      Text('Compromissos', style: AdminTheme.headingSmall),
                      const SizedBox(height: 8),
                      ...selectedEvents.map(
                        (event) => _buildEventCard(context, event),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (selectedBookings.isNotEmpty) ...[
                      Text('Agendamentos', style: AdminTheme.headingSmall),
                      const SizedBox(height: 8),
                      ...selectedBookings.map(
                        (booking) => _buildBookingCard(context, booking),
                      ),
                    ],
                  ],
                );
              }

              // Calendar Widget (reusable)
              Widget buildCalendar() {
                return Container(
                  margin: const EdgeInsets.only(
                    top: kToolbarHeight + 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  decoration: AdminTheme.glassmorphicDecoration(opacity: 0.3),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2026, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() => _calendarFormat = format);
                      }
                    },
                    onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    eventLoader: (day) {
                      final dayBookings = bookings
                          .where((b) => isSameDay(b.booking.scheduledTime, day))
                          .toList();
                      final dayEvents = events
                          .where((e) => isSameDay(e.date, day))
                          .toList();
                      return [...dayBookings, ...dayEvents];
                    },
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: const TextStyle(
                        color: AdminTheme.textPrimary,
                      ),
                      weekendTextStyle: const TextStyle(
                        color: AdminTheme.textSecondary,
                      ),
                      outsideTextStyle: const TextStyle(
                        color: AdminTheme.textMuted,
                      ),
                      markerDecoration: BoxDecoration(
                        color: AdminTheme.gradientPrimary[0],
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AdminTheme.gradientPrimary[1].withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(
                        color: AdminTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AdminTheme.gradientPrimary[0],
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      titleTextStyle: AdminTheme.headingSmall,
                      formatButtonTextStyle: TextStyle(
                        color: AdminTheme.textPrimary,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: AdminTheme.textPrimary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;

                        final hasBooking = events.any(
                          (e) => e is BookingWithDetails,
                        );
                        final hasEvent = events.any((e) => e is AdminEvent);

                        return Positioned(
                          bottom: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasBooking)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              if (hasEvent)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors
                                        .purple, // Different color for events
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(child: buildCalendar()),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.transparent,
                        child: buildDailyList(),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  buildCalendar(),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: buildDailyList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, AdminEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => EditEventDialog(event: event),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.withOpacity(0.1),
            child: const Icon(Icons.event_note, color: Colors.purple),
          ),
          title: Text(
            event.title,
            style: AdminTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('HH:mm').format(event.date),
                style: AdminTheme.bodySmall,
              ),
              if (event.description != null)
                Text(
                  event.description!,
                  style: AdminTheme.bodySmall.copyWith(
                    color: AdminTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: event.remindAt != null
              ? const Tooltip(
                  message: 'Lembrete agendado',
                  child: Icon(Icons.alarm, size: 20, color: Colors.grey),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    BookingWithDetails bookingWithDetails,
  ) {
    final booking = bookingWithDetails.booking;
    final vehicle = bookingWithDetails.vehicle;
    final services = bookingWithDetails.services;
    final serviceNames = services.map((s) => s.title).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AdminTheme.glassmorphicDecoration(
        opacity: 0.6,
        glowColor: _getStatusColor(booking.status),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) =>
                BookingDetailsDialog(bookingData: bookingWithDetails),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(
              booking.status,
            ).withValues(alpha: 0.1),
            child: Icon(
              _getStatusIcon(booking.status),
              color: _getStatusColor(booking.status),
            ),
          ),
          title: Text(
            DateFormat('HH:mm').format(booking.scheduledTime),
            style: AdminTheme.headingSmall,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vehicle != null)
                Text(
                  'Veículo: ${vehicle.brand} ${vehicle.model} (${vehicle.plate})',
                  style: AdminTheme.bodySmall,
                ),
              if (serviceNames.isNotEmpty)
                Text('Serviços: $serviceNames', style: AdminTheme.bodySmall),
              Text(
                'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                style: AdminTheme.bodyLarge.copyWith(
                  color: const Color(0xFF32BCAD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          trailing: Chip(
            label: Text(
              _getStatusLabel(booking.status),
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: _getStatusColor(booking.status),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
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
        return Colors.blue[700]!;
      case BookingStatus.vacuuming:
        return Colors.teal;
      case BookingStatus.drying:
        return Colors.cyan;
      case BookingStatus.polishing:
        return Colors.amber;
      case BookingStatus.finished:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.noShow:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.checkIn:
        return Icons.login;
      case BookingStatus.washing:
        return Icons.local_car_wash;
      case BookingStatus.vacuuming:
        return Icons.cleaning_services;
      case BookingStatus.drying:
        return Icons.air;
      case BookingStatus.polishing:
        return Icons.auto_awesome;
      case BookingStatus.finished:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.noShow:
        return Icons.person_off;
    }
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return 'Aguardando';
      case BookingStatus.confirmed:
        return 'Confirmado';
      case BookingStatus.checkIn:
        return 'Check-in';
      case BookingStatus.washing:
        return 'Lavando';
      case BookingStatus.vacuuming:
        return 'Aspirando';
      case BookingStatus.drying:
        return 'Secando';
      case BookingStatus.polishing:
        return 'Polindo';
      case BookingStatus.finished:
        return 'Finalizado';
      case BookingStatus.cancelled:
        return 'Cancelado';
      case BookingStatus.noShow:
        return 'Não Compareceu';
    }
  }
}
