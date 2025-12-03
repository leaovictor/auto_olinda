import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

class AdminAppointmentsScreen extends ConsumerStatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  ConsumerState<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState
    extends ConsumerState<AdminAppointmentsScreen> {
  bool _isCalendarView = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(adminBookingsWithDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Agendamentos'),
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _isCalendarView = !_isCalendarView),
            tooltip: _isCalendarView ? 'Ver Lista' : 'Ver Calendário',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              if (!_isCalendarView)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              if (!_isCalendarView)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      _buildFilterChip('Todos', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pendentes', 'scheduled'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Confirmados', 'confirmed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Check-in', 'checkIn'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Lavando', 'washing'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Aspirando', 'vacuuming'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Secando', 'drying'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Polindo', 'polishing'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Finalizados', 'finished'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Não Compareceu', 'noShow'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminBookingsWithDetailsProvider);
          // Wait a bit to show the loading indicator
          await Future.delayed(const Duration(seconds: 1));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            return appointmentsAsync.when(
              data: (bookingsWithDetails) {
                if (_isCalendarView) {
                  return _buildCalendarView(bookingsWithDetails);
                }

                final filtered = bookingsWithDetails.where((a) {
                  final booking = a.booking;
                  final user = a.user;
                  final vehicle = a.vehicle;

                  final matchesSearch =
                      (user?.displayName?.toLowerCase() ?? '').contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      (vehicle?.plate.toLowerCase() ?? '').contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      booking.userId.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      booking.vehicleId.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                  final matchesStatus =
                      _statusFilter == 'all' ||
                      booking.status.name == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Nenhum agendamento encontrado.'),
                  );
                }

                return isWide
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final bookingWithDetails = filtered[index];
                          return _buildAppointmentCard(
                            context,
                            bookingWithDetails,
                            ref,
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final bookingWithDetails = filtered[index];
                          return _buildAppointmentCard(
                            context,
                            bookingWithDetails,
                            ref,
                          );
                        },
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<BookingWithDetails> appointments) {
    final selectedBookings = appointments.where((a) {
      return isSameDay(a.booking.scheduledTime, _selectedDay);
    }).toList();

    return Column(
      children: [
        TableCalendar<BookingWithDetails>(
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
                      final appointment = selectedBookings[index];
                      return _buildAppointmentCard(context, appointment, ref);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _statusFilter = value);
      },
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor.withAlpha(50),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    BookingWithDetails appointmentWithDetails,
    WidgetRef ref,
  ) {
    final appointment = appointmentWithDetails.booking;
    final user = appointmentWithDetails.user;
    final vehicle = appointmentWithDetails.vehicle;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Slidable(
        key: ValueKey(appointment.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) =>
                  _showDetailsDialog(context, appointment, ref),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit_note,
              label: 'Gerenciar',
            ),
            SlidableAction(
              onPressed: (context) => _launchWhatsApp(ref, appointment.userId),
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              icon: Icons.message,
              label: 'WhatsApp',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (appointment.status != BookingStatus.cancelled &&
                appointment.status != BookingStatus.finished)
              SlidableAction(
                onPressed: (context) =>
                    _updateStatus(ref, appointment.id, BookingStatus.cancelled),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.cancel,
                label: 'Cancelar',
              ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(appointment.status).withAlpha(25),
            child: Icon(
              _getStatusIcon(appointment.status),
              color: _getStatusColor(appointment.status),
            ),
          ),
          title: Text(
            DateFormat('dd/MM/yyyy - HH:mm').format(appointment.scheduledTime),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Cliente: ${user?.displayName ?? 'Cliente desconhecido'}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Veículo: ${vehicle != null ? '${vehicle.brand} ${vehicle.model} - ${vehicle.plate}' : 'Desconhecido'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                'Status: ${_getStatusLabel(appointment.status).toUpperCase()}',
                style: TextStyle(
                  color: _getStatusColor(appointment.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: Text(
            'R\$ ${appointment.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          onTap: () => _showDetailsDialog(context, appointment, ref),
        ),
      ),
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    Booking appointment,
    WidgetRef ref,
  ) {
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
                    // TODO: Implement Edit Booking
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidade de editar em breve'),
                      ),
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
                      // TODO: Implement Delete Booking
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade de excluir em breve'),
                          ),
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
                      label: Text(_getStatusLabel(status)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _updateStatus(ref, appointment.id, status);
                          Navigator.pop(context);
                        }
                      },
                      selectedColor: _getStatusColor(status).withAlpha(50),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? _getStatusColor(status)
                            : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      avatar: isSelected
                          ? Icon(
                              _getStatusIcon(status),
                              size: 18,
                              color: _getStatusColor(status),
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
          height: 180, // Constrain height to make it scrollable
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
                      _getStatusIcon(log.status),
                      size: 24,
                      color: _getStatusColor(log.status),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${_getStatusLabel(log.status)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat(
                              'dd/MM/yyyy \'às\' HH:mm',
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

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return 'Pendente';
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

  Future<void> _updateStatus(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status atualizado para ${_getStatusLabel(status)}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Telefone não cadastrado')),
          );
        }
        return;
      }

      // Clean phone number
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      final uri = Uri.parse(
        'https://wa.me/$cleanPhone?text=Olá, sobre seu agendamento na AquaClean...',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao buscar telefone: $e')));
      }
    }
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

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return Icons.access_time;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.checkIn:
        return Icons.login;
      case BookingStatus.washing:
        return Icons.water_drop;
      case BookingStatus.vacuuming:
        return Icons.cleaning_services;
      case BookingStatus.drying:
        return Icons.wb_sunny;
      case BookingStatus.polishing:
        return Icons.auto_awesome;
      case BookingStatus.finished:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.noShow:
        return Icons.person_off;
    }
  }
}
