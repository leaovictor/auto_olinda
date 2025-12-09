import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../features/booking/domain/booking.dart';
import '../../booking/data/booking_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import 'widgets/staff_booking_card.dart';
import '../data/plate_lookup_service.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsForDateProvider(_selectedDate));
    final statsAsync = ref.watch(todayStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _selectDate(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Painel - ${DateFormat('dd/MM').format(_selectedDate)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.calendar_today,
                size: 18,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
            tooltip: 'Buscar por Placa',
            onPressed: () => context.push('/staff/scan'),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.onPrimary),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Header
          Container(
            color: theme.colorScheme.primary,
            child: statsAsync.when(
              data: (stats) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _buildStatChip(
                      context,
                      'Fila',
                      stats.queue.toString(),
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      context,
                      'Em Andamento',
                      stats.inProgress.toString(),
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      context,
                      'Finalizados',
                      stats.finished.toString(),
                      Colors.green,
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 0),
              error: (_, __) => const SizedBox(height: 0),
            ),
          ),
          // Tab Bar
          Container(
            color: theme.colorScheme.primary,
            child: bookingsAsync.when(
              data: (bookings) {
                final queue = bookings
                    .where(
                      (b) =>
                          b.status == BookingStatus.scheduled ||
                          b.status == BookingStatus.confirmed ||
                          b.status == BookingStatus.checkIn,
                    )
                    .length;

                final inProgress = bookings
                    .where(
                      (b) =>
                          b.status == BookingStatus.washing ||
                          b.status == BookingStatus.vacuuming ||
                          b.status == BookingStatus.drying ||
                          b.status == BookingStatus.polishing,
                    )
                    .length;

                final ready = bookings
                    .where((b) => b.status == BookingStatus.finished)
                    .length;

                return TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onPrimary.withValues(
                    alpha: 0.7,
                  ),
                  indicatorColor: theme.colorScheme.onPrimary,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Fila'),
                          if (queue > 0) ...[
                            const SizedBox(width: 6),
                            _buildBadge(queue),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Em Andamento'),
                          if (inProgress > 0) ...[
                            const SizedBox(width: 6),
                            _buildBadge(inProgress),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Prontos'),
                          if (ready > 0) ...[
                            const SizedBox(width: 6),
                            _buildBadge(ready),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onPrimary.withValues(
                  alpha: 0.7,
                ),
                indicatorColor: theme.colorScheme.onPrimary,
                tabs: const [
                  Tab(text: 'Fila'),
                  Tab(text: 'Em Andamento'),
                  Tab(text: 'Prontos'),
                ],
              ),
              error: (_, __) => TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onPrimary.withValues(
                  alpha: 0.7,
                ),
                indicatorColor: theme.colorScheme.onPrimary,
                tabs: const [
                  Tab(text: 'Fila'),
                  Tab(text: 'Em Andamento'),
                  Tab(text: 'Prontos'),
                ],
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: bookingsAsync.when(
              data: (bookings) {
                final queue = bookings
                    .where(
                      (b) =>
                          b.status == BookingStatus.scheduled ||
                          b.status == BookingStatus.confirmed ||
                          b.status == BookingStatus.checkIn,
                    )
                    .toList();

                final inProgress = bookings
                    .where(
                      (b) =>
                          b.status == BookingStatus.washing ||
                          b.status == BookingStatus.vacuuming ||
                          b.status == BookingStatus.drying ||
                          b.status == BookingStatus.polishing,
                    )
                    .toList();

                final ready = bookings
                    .where((b) => b.status == BookingStatus.finished)
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(
                      context,
                      queue,
                      'Nenhum veículo na fila.',
                    ),
                    _buildBookingList(
                      context,
                      inProgress,
                      'Nenhum serviço em andamento.',
                    ),
                    _buildBookingList(
                      context,
                      ready,
                      'Nenhum serviço finalizado.',
                    ),
                  ],
                );
              },
              loading: () => const Center(child: AppLoader()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/staff/scan'),
        icon: const Icon(Icons.search),
        label: const Text('Buscar Placa'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    List<Booking> bookings,
    String emptyMessage,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(bookingsForDateProvider(_selectedDate));
        ref.invalidate(todayStatsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return StaffBookingCard(booking: booking);
        },
      ),
    );
  }
}
