import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../features/booking/domain/booking.dart';
import '../../../../features/booking/data/vehicle_repository.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import 'rating_dialog.dart';

class ActiveBookingsCarousel extends ConsumerStatefulWidget {
  final AsyncValue<List<Booking>> bookingsAsync;

  const ActiveBookingsCarousel({super.key, required this.bookingsAsync});

  @override
  ConsumerState<ActiveBookingsCarousel> createState() =>
      _ActiveBookingsCarouselState();
}

class _ActiveBookingsCarouselState
    extends ConsumerState<ActiveBookingsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.93);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return widget.bookingsAsync.when(
      data: (bookings) {
        // Filter only bookings that are IN PROGRESS (checked-in and being worked on)
        // or finished but not yet rated
        final inProgressBookings = bookings.where((b) {
          // Include if checked-in or actively being worked on
          if (b.status == BookingStatus.checkIn ||
              b.status == BookingStatus.washing ||
              b.status == BookingStatus.vacuuming ||
              b.status == BookingStatus.polishing ||
              b.status == BookingStatus.drying) {
            return true;
          }
          // Include finished but unrated
          if (b.status == BookingStatus.finished && !b.isRated) {
            return true;
          }
          return false;
        }).toList();

        if (inProgressBookings.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 180, // Increased height for the button
              child: PageView.builder(
                controller: _pageController,
                itemCount: inProgressBookings.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final booking = inProgressBookings[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: BookingCard(booking: booking),
                  );
                },
              ),
            ),
            if (inProgressBookings.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  inProgressBookings.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const ShimmerLoading.rectangular(height: 160),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class BookingCard extends ConsumerWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFinished = booking.status == BookingStatus.finished;
    final vehicleAsync = ref.watch(vehicleByIdProvider(booking.vehicleId));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isFinished ? 'Lavagem Finalizada' : 'Lavagem em Andamento',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (!isFinished)
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: theme.colorScheme.primary,
                            size: 8,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AO VIVO',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .fade(duration: 1000.ms)
                    .then(delay: 500.ms)
                    .fade(begin: 1, end: 0.5, duration: 1000.ms),
            ],
          ),
          const SizedBox(height: 12),
          // Content Row
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isFinished
                        ? Colors.green.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFinished ? Icons.check_circle : Icons.local_car_wash,
                    color: isFinished
                        ? Colors.green
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: vehicleAsync.when(
                    data: (vehicle) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          vehicle?.model ?? 'Veículo',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${vehicle?.plate ?? ''} • ${DateFormat('dd/MM HH:mm').format(booking.scheduledTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(booking.status),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isFinished
                                ? Colors.green
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const ShimmerLoading.rectangular(
                      height: 40,
                      width: 100,
                    ),
                    error: (_, __) => const Text('Erro'),
                  ),
                ),
                // Action button
                if (isFinished)
                  FilledButton.icon(
                    onPressed: () => _openRatingDialog(context, ref),
                    icon: const Icon(Icons.star, size: 18),
                    label: const Text('Avaliar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () => context.push('/booking/${booking.id}'),
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: theme.colorScheme.onSurface,
                      size: 16,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  void _openRatingDialog(BuildContext context, WidgetRef ref) async {
    final vehicleAsync = ref.read(vehicleByIdProvider(booking.vehicleId));
    final vehicleModel = vehicleAsync.valueOrNull?.model;

    await RatingDialog.show(
      context,
      bookingId: booking.id,
      userId: booking.userId,
      vehicleModel: vehicleModel,
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return 'Pendente';
      case BookingStatus.confirmed:
        return 'Confirmado';
      case BookingStatus.washing:
        return 'Lavando';
      case BookingStatus.drying:
        return 'Secando';
      case BookingStatus.vacuuming:
        return 'Aspirando';
      case BookingStatus.polishing:
        return 'Polindo';
      case BookingStatus.checkIn:
        return 'Check-in';
      case BookingStatus.finished:
        return 'Finalizado';
      case BookingStatus.cancelled:
        return 'Cancelado';
      case BookingStatus.noShow:
        return 'Não Compareceu';
    }
  }
}
