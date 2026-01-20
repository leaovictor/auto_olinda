import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../features/booking/domain/booking.dart';
import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../dashboard/presentation/shell/client_shell.dart';
import '../../../common_widgets/molecules/full_screen_loader.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../shared/utils/cancellation_warning_helper.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  Set<BookingStatus>? _selectedStatuses; // null = "All"
  bool _sortNewestFirst = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;
    final bookingsAsync = user != null
        ? ref.watch(userBookingsProvider(user.uid))
        : const AsyncValue.data(<Booking>[]);

    final subscriptionAsync = ref.watch(userSubscriptionProvider);
    final isPremium = subscriptionAsync.valueOrNull?.isActive ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          'Meus Agendamentos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              final toggle = ref.read(drawerToggleProvider);
              toggle?.call();
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPremium
                  ? [
                      const Color(0xFFB8860B),
                      const Color(0xFFFFD700),
                    ] // Dark Goldenrod to Gold
                  : [const Color(0xFF2563EB), const Color(0xFF0891B2)], // Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter and Sort Controls
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Todos',
                        isSelected: _selectedStatuses == null,
                        onTap: () => setState(() => _selectedStatuses = null),
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Agendado',
                        isSelected:
                            _selectedStatuses?.contains(
                              BookingStatus.scheduled,
                            ) ??
                            false,
                        onTap: () => setState(
                          () => _selectedStatuses = {BookingStatus.scheduled},
                        ),
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Confirmado',
                        isSelected:
                            _selectedStatuses?.contains(
                              BookingStatus.confirmed,
                            ) ??
                            false,
                        onTap: () => setState(
                          () => _selectedStatuses = {BookingStatus.confirmed},
                        ),
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Em Andamento',
                        isSelected:
                            _selectedStatuses != null &&
                            (_selectedStatuses!.contains(
                                  BookingStatus.checkIn,
                                ) ||
                                _selectedStatuses!.contains(
                                  BookingStatus.washing,
                                ) ||
                                _selectedStatuses!.contains(
                                  BookingStatus.vacuuming,
                                ) ||
                                _selectedStatuses!.contains(
                                  BookingStatus.drying,
                                ) ||
                                _selectedStatuses!.contains(
                                  BookingStatus.polishing,
                                )),
                        onTap: () => setState(
                          () => _selectedStatuses = {
                            BookingStatus.checkIn,
                            BookingStatus.washing,
                            BookingStatus.vacuuming,
                            BookingStatus.drying,
                            BookingStatus.polishing,
                          },
                        ),
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Finalizado',
                        isSelected:
                            _selectedStatuses?.contains(
                              BookingStatus.finished,
                            ) ??
                            false,
                        onTap: () => setState(
                          () => _selectedStatuses = {BookingStatus.finished},
                        ),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Cancelado',
                        isSelected:
                            _selectedStatuses?.contains(
                              BookingStatus.cancelled,
                            ) ??
                            false,
                        onTap: () => setState(
                          () => _selectedStatuses = {BookingStatus.cancelled},
                        ),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Sort Dropdown
                Row(
                  children: [
                    const Icon(Icons.sort, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<bool>(
                        value: _sortNewestFirst,
                        isExpanded: true,
                        underline: Container(),
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Mais recentes'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Mais antigos'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortNewestFirst = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Bookings List
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  ref.invalidate(userBookingsProvider(user.uid));
                } else {
                  // If user is null, try to refresh auth state
                  ref.invalidate(authStateChangesProvider);
                }
                ref.invalidate(userSubscriptionProvider);
                // Wait a bit to show the loading indicator
                await Future.delayed(const Duration(seconds: 1));
              },
              child: bookingsAsync.when(
                data: (bookings) {
                  // Apply filters
                  var filteredBookings = bookings;
                  if (_selectedStatuses != null) {
                    filteredBookings = bookings
                        .where((b) => _selectedStatuses!.contains(b.status))
                        .toList();
                  }

                  // Apply sorting
                  filteredBookings.sort((a, b) {
                    final comparison = a.scheduledTime.compareTo(
                      b.scheduledTime,
                    );
                    return _sortNewestFirst ? -comparison : comparison;
                  });

                  return _buildBookingList(context, filteredBookings);
                },
                loading: () => const FullScreenLoader(
                  message: 'Carregando agendamentos...',
                ),
                error: (err, stack) => Center(child: Text('Erro: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _selectedStatuses == null
                  ? 'Nenhum agendamento encontrado'
                  : 'Nenhum agendamento com este status',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              context.push('/booking/${booking.id}');
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat(
                          "d 'de' MMM, HH:mm",
                          'pt_BR',
                        ).format(booking.scheduledTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _buildStatusChip(context, booking.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder(
                    future: Future.wait([
                      ref
                          .read(bookingRepositoryProvider)
                          .getVehicle(booking.vehicleId),
                      Future.wait(
                        booking.serviceIds.map(
                          (id) => ref
                              .read(bookingRepositoryProvider)
                              .getService(id),
                        ),
                      ),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Carregando...',
                          style: TextStyle(color: Colors.grey[600]),
                        );
                      }

                      String vehicleText = 'Veículo não encontrado';
                      String servicesText = 'Serviço não encontrado';

                      if (snapshot.hasData) {
                        final data = snapshot.data!;
                        final vehicle = data[0] as dynamic;
                        final services = data[1] as List<dynamic>;

                        if (vehicle != null) {
                          vehicleText =
                              '${vehicle.brand} ${vehicle.model} • ${vehicle.plate}';
                        }

                        final serviceNames = services
                            .whereType<dynamic>()
                            .where((s) => s != null)
                            .map((s) => s.title as String)
                            .toList();

                        if (serviceNames.isNotEmpty) {
                          servicesText = serviceNames.join(', ');
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicleText,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            servicesText,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R\$ ${booking.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      if (booking.status == BookingStatus.scheduled &&
                          booking.scheduledTime
                                  .difference(DateTime.now())
                                  .inMinutes >
                              60)
                        TextButton(
                          onPressed: () {
                            _showCancelDialog(context, booking, ref);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Cancelar'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    Booking booking,
    WidgetRef ref,
  ) async {
    // Use cancellation warning helper for consistent penalty warnings
    final confirmed = await CancellationWarningHelper.showCancellationDialog(
      context: context,
      scheduledTime: booking.scheduledTime,
    );

    if (confirmed) {
      try {
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user == null) return;

        await ref
            .read(bookingRepositoryProvider)
            .cancelBooking(booking.id, actorId: user.uid);
        if (context.mounted) {
          final message = CancellationWarningHelper.getCancellationFeedback(
            booking.scheduledTime,
          );
          final isStrike = CancellationWarningHelper.shouldShowStrikeWarning(
            booking.scheduledTime,
          );
          if (isStrike) {
            AppToast.error(context, message: message);
          } else {
            AppToast.success(context, message: message);
          }
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.error(context, message: 'Erro ao cancelar: $e');
        }
      }
    }
  }

  Widget _buildStatusChip(BuildContext context, BookingStatus status) {
    Color color;
    String label;

    switch (status) {
      case BookingStatus.scheduled:
        color = Colors.orange;
        label = 'Agendado';
        break;
      case BookingStatus.confirmed:
        color = Colors.blue;
        label = 'Confirmado';
        break;
      case BookingStatus.checkIn:
        color = Colors.purple;
        label = 'Check-in';
        break;
      case BookingStatus.washing:
        color = Colors.blue[700]!;
        label = 'Lavando';
        break;
      case BookingStatus.vacuuming:
        color = Colors.teal;
        label = 'Aspirando';
        break;
      case BookingStatus.drying:
        color = Colors.cyan;
        label = 'Secando';
        break;
      case BookingStatus.polishing:
        color = Colors.indigo;
        label = 'Polindo';
        break;
      case BookingStatus.finished:
        color = Colors.green;
        label = 'Finalizado';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        label = 'Cancelado';
        break;
      case BookingStatus.noShow:
        color = Colors.grey;
        label = 'Não Compareceu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
