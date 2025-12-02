import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/booking/domain/booking.dart';
import '../../booking/data/booking_repository.dart';
import '../../auth/data/auth_repository.dart';
import 'widgets/staff_booking_card.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(todayBookingsProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Painel do Staff',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
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
                  context.push('/booking/$result');
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
            unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
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
                      b.status == BookingStatus.pending ||
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
                _buildBookingList(
                  context,
                  ready,
                  'Nenhum serviço finalizado hoje.',
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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
