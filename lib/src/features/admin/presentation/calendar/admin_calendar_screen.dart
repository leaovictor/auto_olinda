import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/admin_repository.dart'; // Import adminRepositoryProvider
import '../../domain/booking_with_details.dart'; // Import BookingWithDetails
import '../../../booking/domain/booking.dart'; // Import BookingStatus
import '../../../../common_widgets/molecules/app_refresh_indicator.dart';

import '../../../../common_widgets/atoms/app_loader.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário de Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/admin/calendar/config'),
          ),
        ],
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminBookingsWithDetailsProvider);
          // Wait a bit to show the loading indicator
          await Future.delayed(const Duration(seconds: 1));
        },
        child: bookingsAsync.when(
          data: (bookings) {
            final selectedBookings = bookings.where((b) {
              return isSameDay(b.booking.scheduledTime, _selectedDay);
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: TableCalendar<BookingWithDetails>(
                            firstDay: DateTime.utc(2024, 1, 1),
                            lastDay: DateTime.utc(2026, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
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
                            onPageChanged: (focusedDay) =>
                                _focusedDay = focusedDay,
                            eventLoader: (day) {
                              return bookings
                                  .where(
                                    (b) =>
                                        isSameDay(b.booking.scheduledTime, day),
                                  )
                                  .toList();
                            },
                            calendarStyle: CalendarStyle(
                              markerDecoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: theme.primaryColor.withAlpha(120),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.grey[50],
                          child: selectedBookings.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhum agendamento para este dia',
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: selectedBookings.length,
                                  itemBuilder: (context, index) {
                                    final appointment = selectedBookings[index];
                                    return _buildBookingCard(
                                      context,
                                      appointment,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    TableCalendar<BookingWithDetails>(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2026, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
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
                        return bookings
                            .where(
                              (b) => isSameDay(b.booking.scheduledTime, day),
                            )
                            .toList();
                      },
                      calendarStyle: CalendarStyle(
                        markerDecoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: theme.primaryColor.withAlpha(120),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: Container(
                        color: Colors.grey[50],
                        child: selectedBookings.isEmpty
                            ? const Center(
                                child: Text('Nenhum agendamento para este dia'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: selectedBookings.length,
                                itemBuilder: (context, index) {
                                  final appointment = selectedBookings[index];
                                  return _buildBookingCard(
                                    context,
                                    appointment,
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: AppLoader()),
          error: (err, stack) => Center(child: Text('Erro: $err')),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          // TODO: Show details
        },
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicle != null)
              Text(
                'Veículo: ${vehicle.brand} ${vehicle.model} (${vehicle.plate})',
              ),
            if (serviceNames.isNotEmpty) Text('Serviços: $serviceNames'),
            Text(
              'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
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
