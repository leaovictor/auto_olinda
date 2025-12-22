import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
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

import '../../../../common_widgets/atoms/app_loader.dart';

enum SortOrder { newestFirst, oldestFirst }

class AdminAppointmentsScreen extends ConsumerStatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  ConsumerState<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState
    extends ConsumerState<AdminAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  bool _isCalendarView = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _searchQuery = '';
  String _statusFilter = 'all';
  SortOrder _sortOrder = SortOrder.newestFirst;

  // Tab controller for switching between car wash and aesthetic bookings
  late TabController _tabController;

  // Aesthetic booking state
  String _aestheticSearchQuery = '';
  String _aestheticStatusFilter = 'all';

  // Audio player for pending booking alert
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _lastPendingCount = 0; // Track to avoid repeated sounds

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Play alert sound for new pending bookings
  void _playPendingAlertSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/agenda.mp3'));
    } catch (e) {
      debugPrint('Error playing alert sound: $e');
    }
  }

  // Helper to calculate counts per status
  Map<String, int> _calculateStatusCounts(List<BookingWithDetails> bookings) {
    final counts = <String, int>{'all': bookings.length};
    for (final status in BookingStatus.values) {
      counts[status.name] = bookings
          .where((b) => b.booking.status == status)
          .length;
    }
    return counts;
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == SortOrder.newestFirst
          ? SortOrder.oldestFirst
          : SortOrder.newestFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Agendamentos'),
        actions: [
          IconButton(
            icon: Icon(
              _sortOrder == SortOrder.newestFirst
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
            ),
            onPressed: _toggleSortOrder,
            tooltip: _sortOrder == SortOrder.newestFirst
                ? 'Mais recentes primeiro'
                : 'Mais antigos primeiro',
          ),
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _isCalendarView = !_isCalendarView),
            tooltip: _isCalendarView ? 'Ver Lista' : 'Ver Calendário',
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

  Widget _buildCarWashTab(bool isMobile) {
    final appointmentsAsync = ref.watch(adminBookingsWithDetailsProvider);

    // Pre-calculate status counts for badges
    final statusCounts = appointmentsAsync.maybeWhen(
      data: (bookings) => _calculateStatusCounts(bookings),
      orElse: () => <String, int>{},
    );

    return Column(
      children: [
        // Search and filter bar
        if (!_isCalendarView) ...[
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
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _buildFilterChip('Todos', 'all', statusCounts['all']),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pendentes',
                  'scheduled',
                  statusCounts['scheduled'],
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Confirmados',
                  'confirmed',
                  statusCounts['confirmed'],
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Check-in',
                  'checkIn',
                  statusCounts['checkIn'],
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Lavando', 'washing', statusCounts['washing']),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Aspirando',
                  'vacuuming',
                  statusCounts['vacuuming'],
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Secando', 'drying', statusCounts['drying']),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Polindo',
                  'polishing',
                  statusCounts['polishing'],
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Finalizados',
                  'finished',
                  statusCounts['finished'],
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Não Compareceu',
                  'noShow',
                  statusCounts['noShow'],
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
            child: LayoutBuilder(
              builder: (context, constraints) {
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

                    // Apply sorting
                    filtered.sort((a, b) {
                      final dateA = a.booking.scheduledTime;
                      final dateB = b.booking.scheduledTime;
                      return _sortOrder == SortOrder.newestFirst
                          ? dateB.compareTo(dateA)
                          : dateA.compareTo(dateB);
                    });

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('Nenhum agendamento encontrado.'),
                      );
                    }

                    return ListView.builder(
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
                  loading: () => const Center(child: AppLoader()),
                  error: (err, stack) => Center(child: Text('Erro: $err')),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Helper function to calculate status counts for aesthetic bookings
  Map<String, int> _calculateAestheticStatusCounts(
    List<ServiceBooking> bookings,
  ) {
    final counts = <String, int>{'all': bookings.length};
    for (final status in ServiceBookingStatus.values) {
      counts[status.name] = bookings.where((b) => b.status == status).length;
    }
    return counts;
  }

  Widget _buildAestheticTab(bool isMobile) {
    final bookingsAsync = ref.watch(allServiceBookingsProvider);
    final servicesAsync = ref.watch(allIndependentServicesProvider);

    // Pre-calculate status counts for badges
    final statusCounts = bookingsAsync.maybeWhen(
      data: (bookings) => _calculateAestheticStatusCounts(bookings),
      orElse: () => <String, int>{},
    );

    return Column(
      children: [
        // Search and filter bar for aesthetic bookings
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
            onChanged: (value) => setState(() => _aestheticSearchQuery = value),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              _buildAestheticFilterChip('Todos', 'all', statusCounts['all']),
              const SizedBox(width: 8),
              _buildAestheticFilterChip(
                '⏳ Aguardando',
                'pendingApproval',
                statusCounts['pendingApproval'],
              ),
              const SizedBox(width: 8),
              _buildAestheticFilterChip(
                'Agendados',
                'scheduled',
                statusCounts['scheduled'],
              ),
              const SizedBox(width: 8),
              _buildAestheticFilterChip(
                'Confirmados',
                'confirmed',
                statusCounts['confirmed'],
              ),
              const SizedBox(width: 8),
              _buildAestheticFilterChip(
                'Em Andamento',
                'inProgress',
                statusCounts['inProgress'],
              ),
              const SizedBox(width: 8),
              _buildAestheticFilterChip(
                'Finalizados',
                'finished',
                statusCounts['finished'],
              ),
              const SizedBox(width: 8),
              _buildAestheticFilterChip(
                'Cancelados',
                'cancelled',
                statusCounts['cancelled'],
              ),
              const SizedBox(width: 8),
              _buildAestheticFilterChip(
                'Recusados',
                'rejected',
                statusCounts['rejected'],
              ),
              const SizedBox(width: 8),
              _buildAestheticFilterChip(
                'Não Compareceu',
                'noShow',
                statusCounts['noShow'],
              ),
            ],
          ),
        ),
        // Pending approval alert banner with sound alert
        Builder(
          builder: (context) {
            final pendingCount = statusCounts['pendingApproval'] ?? 0;
            // Schedule sound if pending count increased
            if (pendingCount > _lastPendingCount && pendingCount > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _playPendingAlertSound();
                _lastPendingCount = pendingCount;
              });
            } else if (pendingCount != _lastPendingCount) {
              _lastPendingCount = pendingCount;
            }
            if (pendingCount == 0) return const SizedBox.shrink();
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
                  Icon(
                    Icons.notification_important,
                    color: Colors.amber.shade700,
                  ),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(
                      () => _aestheticStatusFilter = 'pendingApproval',
                    ),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
            );
          },
        ),
        // Main content
        Expanded(
          child: AppRefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allServiceBookingsProvider);
              await Future.delayed(const Duration(seconds: 1));
            },
            child: bookingsAsync.when(
              data: (bookings) {
                // Create a map of services for lookup
                final servicesMap = <String, IndependentService>{};
                servicesAsync.whenData((services) {
                  for (final service in services) {
                    servicesMap[service.id] = service;
                  }
                });

                // Filter bookings
                final filtered = bookings.where((booking) {
                  final matchesSearch =
                      (booking.userName?.toLowerCase() ?? '').contains(
                        _aestheticSearchQuery.toLowerCase(),
                      ) ||
                      (booking.userPhone?.toLowerCase() ?? '').contains(
                        _aestheticSearchQuery.toLowerCase(),
                      ) ||
                      booking.id.toLowerCase().contains(
                        _aestheticSearchQuery.toLowerCase(),
                      );
                  final matchesStatus =
                      _aestheticStatusFilter == 'all' ||
                      booking.status.name == _aestheticStatusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                // Apply sorting
                filtered.sort((a, b) {
                  final dateA = a.scheduledTime;
                  final dateB = b.scheduledTime;
                  return _sortOrder == SortOrder.newestFirst
                      ? dateB.compareTo(dateA)
                      : dateA.compareTo(dateB);
                });

                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Nenhum agendamento de estética encontrado.'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final booking = filtered[index];
                    final service = servicesMap[booking.serviceId];
                    return _buildAestheticBookingCard(
                      context,
                      booking,
                      service,
                      ref,
                    );
                  },
                );
              },
              loading: () => const Center(child: AppLoader()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAestheticFilterChip(String label, String value, int? count) {
    final isSelected = _aestheticStatusFilter == value;
    final displayLabel = count != null && count > 0 ? '$label ($count)' : label;
    return FilterChip(
      label: Text(displayLabel),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _aestheticStatusFilter = value);
      },
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor.withAlpha(50),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildAestheticBookingCard(
    BuildContext context,
    ServiceBooking booking,
    IndependentService? service,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Slidable(
        key: ValueKey(booking.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) =>
                  _showAestheticDetailsDialog(context, booking, service, ref),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit_note,
              label: 'Gerenciar',
            ),
            SlidableAction(
              onPressed: (context) =>
                  _launchWhatsAppFromPhone(booking.userPhone),
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
            if (booking.status != ServiceBookingStatus.cancelled &&
                booking.status != ServiceBookingStatus.finished)
              SlidableAction(
                onPressed: (context) => _updateAestheticStatus(
                  ref,
                  booking.id,
                  ServiceBookingStatus.cancelled,
                ),
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
            backgroundColor: _getAestheticStatusColor(
              booking.status,
            ).withAlpha(25),
            child: Icon(
              _getAestheticStatusIcon(booking.status),
              color: _getAestheticStatusColor(booking.status),
            ),
          ),
          title: Text(
            DateFormat('dd/MM/yyyy - HH:mm').format(booking.scheduledTime),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Cliente: ${booking.userName ?? 'Desconhecido'}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Serviço: ${service?.title ?? 'Desconhecido'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              if (booking.vehiclePlate != null || booking.vehicleModel != null)
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.vehiclePlate ?? ''} ${booking.vehicleModel != null ? '- ${booking.vehicleModel}' : ''}'
                          .trim(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              if (booking.userPhone != null)
                Text(
                  'Telefone: ${booking.userPhone}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              // Payment status indicator
              Row(
                children: [
                  Icon(
                    _getPaymentStatusIcon(booking.paymentStatus),
                    size: 14,
                    color: _getPaymentStatusColor(booking.paymentStatus),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pagamento: ${_getPaymentStatusLabel(booking.paymentStatus)}',
                    style: TextStyle(
                      color: _getPaymentStatusColor(booking.paymentStatus),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  if (booking.paymentStatus == PaymentStatus.partial)
                    Text(
                      ' (R\$ ${booking.paidAmount.toStringAsFixed(2)} pago)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                ],
              ),
              Text(
                'Status: ${_getAestheticStatusLabel(booking.status).toUpperCase()}',
                style: TextStyle(
                  color: _getAestheticStatusColor(booking.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onTap: () =>
              _showAestheticDetailsDialog(context, booking, service, ref),
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
                      label: Text(_getAestheticStatusLabel(status)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _updateAestheticStatus(ref, booking.id, status);
                          Navigator.pop(context);
                        }
                      },
                      selectedColor: _getAestheticStatusColor(
                        status,
                      ).withAlpha(50),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? _getAestheticStatusColor(status)
                            : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      avatar: isSelected
                          ? Icon(
                              _getAestheticStatusIcon(status),
                              size: 18,
                              color: _getAestheticStatusColor(status),
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
                      label: Text(_getPaymentStatusLabel(status)),
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
                      selectedColor: _getPaymentStatusColor(
                        status,
                      ).withAlpha(50),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? _getPaymentStatusColor(status)
                            : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      avatar: isSelected
                          ? Icon(
                              _getPaymentStatusIcon(status),
                              size: 18,
                              color: _getPaymentStatusColor(status),
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
          message: 'Status atualizado para ${_getAestheticStatusLabel(status)}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar: $e');
      }
    }
  }

  /// Approve a pending booking
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

  /// Show dialog to reject a booking with reason
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
      // When marked as paid, set paidAmount to totalPrice
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
          message:
              'Pagamento atualizado para ${_getPaymentStatusLabel(status)}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar pagamento: $e');
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

    // Clean phone number
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

  String _getAestheticStatusLabel(ServiceBookingStatus status) {
    switch (status) {
      case ServiceBookingStatus.pendingApproval:
        return 'Aguardando Aprovação';
      case ServiceBookingStatus.scheduled:
        return 'Agendado';
      case ServiceBookingStatus.confirmed:
        return 'Confirmado';
      case ServiceBookingStatus.inProgress:
        return 'Em Andamento';
      case ServiceBookingStatus.finished:
        return 'Finalizado';
      case ServiceBookingStatus.cancelled:
        return 'Cancelado';
      case ServiceBookingStatus.rejected:
        return 'Recusado';
      case ServiceBookingStatus.noShow:
        return 'Não Compareceu';
    }
  }

  Color _getAestheticStatusColor(ServiceBookingStatus status) {
    switch (status) {
      case ServiceBookingStatus.pendingApproval:
        return Colors.amber;
      case ServiceBookingStatus.scheduled:
        return Colors.orange;
      case ServiceBookingStatus.confirmed:
        return Colors.blue;
      case ServiceBookingStatus.inProgress:
        return Colors.purple;
      case ServiceBookingStatus.finished:
        return Colors.green;
      case ServiceBookingStatus.cancelled:
        return Colors.red;
      case ServiceBookingStatus.rejected:
        return Colors.red.shade900;
      case ServiceBookingStatus.noShow:
        return Colors.grey;
    }
  }

  IconData _getAestheticStatusIcon(ServiceBookingStatus status) {
    switch (status) {
      case ServiceBookingStatus.pendingApproval:
        return Icons.hourglass_empty;
      case ServiceBookingStatus.scheduled:
        return Icons.access_time;
      case ServiceBookingStatus.confirmed:
        return Icons.check_circle;
      case ServiceBookingStatus.inProgress:
        return Icons.build;
      case ServiceBookingStatus.finished:
        return Icons.done_all;
      case ServiceBookingStatus.cancelled:
        return Icons.cancel;
      case ServiceBookingStatus.rejected:
        return Icons.block;
      case ServiceBookingStatus.noShow:
        return Icons.person_off;
    }
  }

  String _getPaymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pendente';
      case PaymentStatus.paid:
        return 'Pago';
      case PaymentStatus.partial:
        return 'Parcial';
      case PaymentStatus.refunded:
        return 'Reembolsado';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.partial:
        return Colors.amber;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }

  IconData _getPaymentStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.pending;
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.partial:
        return Icons.pie_chart;
      case PaymentStatus.refunded:
        return Icons.replay;
    }
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

  Widget _buildFilterChip(String label, String value, int? count) {
    final isSelected = _statusFilter == value;
    final displayLabel = count != null && count > 0 ? '$label ($count)' : label;
    return FilterChip(
      label: Text(displayLabel),
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
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${appointment.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (appointment.isRated) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < (appointment.rating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    );
                  }),
                ),
              ],
            ],
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
                      // TODO: Implement Delete Booking
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
        AppToast.success(
          context,
          message: 'Status atualizado para ${_getStatusLabel(status)}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar: $e');
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

      // Clean phone number
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
