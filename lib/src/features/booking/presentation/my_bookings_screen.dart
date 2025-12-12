import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../features/booking/domain/booking.dart';
import '../../auth/data/auth_repository.dart';
import '../../booking/data/booking_repository.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../shared/utils/app_toast.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Ativos'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: AppRefreshIndicator(
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
            final activeBookings = bookings
                .where(
                  (b) =>
                      b.status != BookingStatus.cancelled &&
                      b.status != BookingStatus.finished,
                )
                .toList();

            final historyBookings = bookings
                .where(
                  (b) =>
                      b.status == BookingStatus.cancelled ||
                      b.status == BookingStatus.finished,
                )
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(context, activeBookings, isActive: true),
                _buildBookingList(context, historyBookings, isActive: false),
              ],
            );
          },
          loading: () => const Center(child: AppLoader()),
          error: (err, stack) => Center(child: Text('Erro: $err')),
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    List<Booking> bookings, {
    required bool isActive,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.calendar_today : Icons.history,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? 'Nenhum agendamento ativo'
                  : 'Nenhum histórico encontrado',
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
                      if (isActive &&
                          booking.status == BookingStatus.scheduled &&
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text(
          'Tem certeza que deseja cancelar este agendamento? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmar Cancelamento'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user == null) return;

        await ref
            .read(bookingRepositoryProvider)
            .cancelBooking(booking.id, actorId: user.uid);
        if (context.mounted) {
          AppToast.success(
            context,
            message: 'Agendamento cancelado com sucesso',
          );
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
