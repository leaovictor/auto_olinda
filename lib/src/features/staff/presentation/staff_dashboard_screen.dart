import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../features/booking/domain/booking.dart';
import '../../booking/data/booking_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import 'widgets/staff_booking_card.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

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
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
              icon: Icon(
                Icons.qr_code_scanner,
                color: theme.colorScheme.onPrimary,
              ),
              onPressed: () async {
                final String? result = await context.push<String>(
                  '/staff/scan',
                );
                if (result != null && context.mounted) {
                  context.push('/staff/booking/$result');
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: theme.colorScheme.onPrimary),
              onPressed: () {
                ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
          bottom: TabBar(
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
        body: bookingsAsync.when(
          data: (bookings) {
            final queue = bookings
                .where(
                  (b) =>
                      b.status == BookingStatus.scheduled ||
                      b.status == BookingStatus.confirmed,
                )
                .toList();

            final inProgress = bookings
                .where(
                  (b) =>
                      b.status == BookingStatus.washing ||
                      b.status == BookingStatus.drying,
                )
                .toList();

            final ready = bookings
                .where((b) => b.status == BookingStatus.finished)
                .toList();

            return TabBarView(
              children: [
                _buildBookingList(context, queue, 'Nenhum veículo na fila.'),
                _buildBookingList(
                  context,
                  inProgress,
                  'Nenhum serviço em andamento.',
                ),
                _buildBookingList(context, ready, 'Nenhum serviço finalizado.'),
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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return StaffBookingCard(booking: booking);
      },
    );
  }
}
