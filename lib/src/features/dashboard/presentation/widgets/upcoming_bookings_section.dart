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
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: InkWell(
          onTap: () => context.push('/booking/${booking.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Time + Status
                Row(
                  children: [
                    // Date/Time column - Larger and more prominent
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isConfirmed
                              ? [
                                  Colors.green.withValues(alpha: 0.15),
                                  Colors.green.withValues(alpha: 0.05),
                                ]
                              : [
                                  theme.colorScheme.primaryContainer,
                                  theme.colorScheme.primaryContainer.withValues(
                                    alpha: 0.5,
                                  ),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isConfirmed
                                        ? Colors.green
                                        : theme.colorScheme.primary)
                                    .withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            timeFormat.format(booking.scheduledTime),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: isConfirmed
                                  ? Colors.green.shade700
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateFormat.format(booking.scheduledTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isConfirmed
                                  ? Colors.green.shade600
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Status badge - More prominent
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 1.5,
                          color: isConfirmed
                              ? Colors.green.withValues(alpha: 0.4)
                              : Colors.orange.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isConfirmed ? Icons.check_circle : Icons.schedule,
                            size: 14,
                            color: isConfirmed
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isConfirmed ? 'Confirmado' : 'Agendado',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isConfirmed
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Vehicle info - Better spacing
                vehicleAsync.when(
                  data: (vehicle) => Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_car_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
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
                            const SizedBox(height: 2),
                            if (vehicle != null)
                              Text(
                                '${vehicle.brand} • ${vehicle.plate}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const ShimmerLoading.rectangular(
                    height: 44,
                    width: double.infinity,
                  ),
                  error: (_, __) => const Text('Erro ao carregar veículo'),
                ),

                const SizedBox(height: 16),

                // Action button - Larger and more prominent
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push('/smart-map', extra: booking),
                    icon: const Icon(Icons.map_outlined, size: 20),
                    label: const Text(
                      'Traçar Rota',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
