import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../features/booking/domain/booking.dart';
import '../../../../features/booking/data/vehicle_repository.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../common_widgets/atoms/app_card.dart';

/// Section showing upcoming bookings (scheduled or confirmed, not yet checked-in)
class UpcomingBookingsSection extends ConsumerWidget {
  final AsyncValue<List<Booking>> bookingsAsync;

  const UpcomingBookingsSection({super.key, required this.bookingsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return bookingsAsync.when(
      data: (bookings) {
        // Filter only upcoming bookings (not yet checked-in)
        final upcomingBookings = bookings.where((b) {
          return b.status == BookingStatus.scheduled ||
              b.status == BookingStatus.confirmed;
        }).toList();

        // Sort by scheduled time (nearest first)
        upcomingBookings.sort(
          (a, b) => a.scheduledTime.compareTo(b.scheduledTime),
        );

        if (upcomingBookings.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Próximas Lavagens',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (upcomingBookings.length > 2)
                  TextButton(
                    onPressed: () => context.push('/my-bookings'),
                    child: const Text('Ver todos'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...upcomingBookings.take(3).map((booking) {
              return _UpcomingBookingCard(
                booking: booking,
              ).animate().fadeIn().slideX(begin: 0.1);
            }),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximas Lavagens',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const ShimmerLoading.rectangular(height: 80),
        ],
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _UpcomingBookingCard extends ConsumerWidget {
  final Booking booking;

  const _UpcomingBookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vehicleAsync = ref.watch(vehicleByIdProvider(booking.vehicleId));
    final dateFormat = DateFormat('EEE, d MMM', 'pt_BR');
    final timeFormat = DateFormat('HH:mm');

    final isConfirmed = booking.status == BookingStatus.confirmed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: InkWell(
          onTap: () => context.push('/booking/${booking.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Date/Time column
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? Colors.green.withValues(alpha: 0.1)
                            : theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            timeFormat.format(booking.scheduledTime),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isConfirmed
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            dateFormat.format(booking.scheduledTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isConfirmed
                                  ? Colors.green.shade700
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Vehicle info
                    Expanded(
                      child: vehicleAsync.when(
                        data: (vehicle) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle?.model ?? 'Veículo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (vehicle != null)
                              Text(
                                '${vehicle.brand} • ${vehicle.plate}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        loading: () => const ShimmerLoading.rectangular(
                          height: 20,
                          width: 100,
                        ),
                        error: (_, __) => const Text('Erro'),
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isConfirmed
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        isConfirmed ? 'Confirmado' : 'Agendado',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isConfirmed ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/smart-map', extra: booking),
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Traçar Rota'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
