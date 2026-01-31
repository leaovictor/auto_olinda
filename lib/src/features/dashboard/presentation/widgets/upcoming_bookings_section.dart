import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../../../features/booking/domain/booking.dart';
import '../../../../features/booking/presentation/providers/booking_title_provider.dart';
import '../../../../features/booking/data/vehicle_repository.dart';
import '../../../../shared/widgets/shimmer_loading.dart';

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
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => context.push('/booking/${booking.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            foregroundPainter: _CardDottedBorderPainter(
              color: isConfirmed
                  ? Colors.green.withValues(alpha: 0.6)
                  : Colors.orange.withValues(alpha: 0.6),
              strokeWidth: 2,
              gap: 6,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isConfirmed
                            ? [
                                Colors.green.shade50,
                                Colors.white,
                                Colors.green.shade50,
                              ]
                            : [
                                Colors.orange.shade50,
                                Colors.amber.shade50,
                                Colors.orange.shade50,
                              ],
                      ),
                    ),
                  ),

                  // Diagonal stripes pattern (subtle)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DiagonalStripesPainter(
                        color: (isConfirmed ? Colors.green : Colors.orange)
                            .withValues(alpha: 0.03),
                      ),
                    ),
                  ),

                  // Main content
                  Row(
                    children: [
                      // Left stub section (tear-off section)
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isConfirmed
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.orange.withValues(alpha: 0.12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ticket icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isConfirmed
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isConfirmed
                                                ? Colors.green
                                                : Colors.orange)
                                            .withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.confirmation_number_rounded,
                                color: isConfirmed
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Time
                            Text(
                              timeFormat.format(booking.scheduledTime),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isConfirmed
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),

                            // Date
                            Text(
                              dateFormat.format(booking.scheduledTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isConfirmed
                                    ? Colors.green.shade600
                                    : Colors.orange.shade600,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),

                      // Perforated edge
                      CustomPaint(
                        size: const Size(8, 180),
                        painter: _PerforatedEdgePainter(
                          color: isConfirmed
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                        ),
                      ),

                      // Right main section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with status badge
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isConfirmed
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : Colors.orange.withValues(
                                              alpha: 0.15,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        width: 1,
                                        color: isConfirmed
                                            ? Colors.green.withValues(
                                                alpha: 0.4,
                                              )
                                            : Colors.orange.withValues(
                                                alpha: 0.4,
                                              ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isConfirmed
                                              ? Icons.check_circle
                                              : Icons.schedule,
                                          size: 12,
                                          color: isConfirmed
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isConfirmed
                                              ? 'Confirmado'
                                              : 'Agendado',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: isConfirmed
                                                    ? Colors.green.shade700
                                                    : Colors.orange.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ref
                                      .watch(
                                        bookingServiceTitleProvider(booking),
                                      )
                                      .when(
                                        data: (title) => Text(
                                          title.toUpperCase(),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 13,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        loading: () => Text(
                                          'CARREGANDO...',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        error: (_, __) => Text(
                                          'LAVAGEM',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Vehicle info
                              vehicleAsync.when(
                                data: (vehicle) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.directions_car_rounded,
                                            color: theme.colorScheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                vehicle?.model ?? 'Veículo',
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (vehicle != null)
                                                Text(
                                                  '${vehicle.brand} • ${vehicle.plate}',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                        fontSize: 12,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                loading: () => const ShimmerLoading.rectangular(
                                  height: 40,
                                  width: double.infinity,
                                ),
                                error: (_, __) =>
                                    const Text('Erro ao carregar veículo'),
                              ),

                              const SizedBox(height: 16),

                              // Dotted divider
                              CustomPaint(
                                size: const Size(double.infinity, 1),
                                painter: _DottedLinePainter(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.2),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Action button
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.tonalIcon(
                                  onPressed: () => context.push(
                                    '/smart-map',
                                    extra: booking,
                                  ),
                                  icon: const Icon(
                                    Icons.map_outlined,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Traçar Rota',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for perforated edge
class _PerforatedEdgePainter extends CustomPainter {
  final Color color;

  _PerforatedEdgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const circleRadius = 6.0;
    const spacing = 14.0;
    final circleCount = (size.height / spacing).floor();

    for (int i = 0; i <= circleCount; i++) {
      final y = i * spacing;
      canvas.drawCircle(Offset(size.width / 2, y), circleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for diagonal stripes
class _DiagonalStripesPainter extends CustomPainter {
  final Color color;

  _DiagonalStripesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    final maxLines = ((size.width + size.height) / spacing).ceil();

    for (int i = 0; i < maxLines; i++) {
      final startX = i * spacing;
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for dotted line
class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardDottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _CardDottedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );

    final Path path = Path()..addRRect(rrect);

    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        double length = distance + gap;
        canvas.drawPath(
          pathMetric.extractPath(
            distance,
            length > pathMetric.length ? pathMetric.length : length,
          ),
          paint,
        );
        distance += gap * 2;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
