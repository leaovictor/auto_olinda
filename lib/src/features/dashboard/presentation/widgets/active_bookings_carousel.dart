import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../features/booking/domain/booking.dart';
import '../../../../features/booking/data/booking_repository.dart';
import '../../../../features/booking/data/vehicle_repository.dart';
import '../../../../shared/widgets/shimmer_loading.dart';

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
        final activeBookings = bookings.where((b) {
          if (b.status == BookingStatus.cancelled) return false;
          if (b.status == BookingStatus.finished) {
            return !b.isRated;
          }
          return true;
        }).toList();

        if (activeBookings.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 180, // Increased height for the button
              child: PageView.builder(
                controller: _pageController,
                itemCount: activeBookings.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final booking = activeBookings[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: BookingCard(booking: booking),
                  );
                },
              ),
            ),
            if (activeBookings.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  activeBookings.length,
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

class BookingCard extends ConsumerStatefulWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  ConsumerState<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends ConsumerState<BookingCard> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booking = widget.booking;
    final isFinished = booking.status == BookingStatus.finished;

    final vehicleAsync = ref.watch(vehicleByIdProvider(booking.vehicleId));

    return Stack(
      children: [
        Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isFinished ? 'Lavagem Finalizada' : 'Lavagem em Andamento',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
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
              const SizedBox(height: 16),
              Row(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        vehicleAsync.when(
                          data: (vehicle) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle?.model ?? 'Veículo',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${vehicle?.plate ?? ''} • ${DateFormat('dd/MM HH:mm').format(booking.scheduledTime)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          loading: () => const ShimmerLoading.rectangular(
                            height: 20,
                            width: 100,
                          ),
                          error: (_, __) => Text(
                            'Veículo não encontrado',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(booking.status),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isFinished)
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
              if (isFinished) ...[
                const Spacer(),
                if (_rating > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Deixe um comentário (opcional)',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 2,
                      minLines: 1,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
        if (isFinished && _rating > 0)
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => _rateService(context, booking.id),
              icon: const Icon(Icons.check, color: Colors.green),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(4),
              ),
              tooltip: 'Enviar Avaliação',
            ),
          ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Future<void> _rateService(BuildContext context, String bookingId) async {
    try {
      await ref
          .read(bookingRepositoryProvider)
          .markAsRated(
            bookingId,
            _rating,
            _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );
      // Force refresh of the bookings list
      ref.invalidate(userBookingsProvider(widget.booking.userId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Obrigado pela sua avaliação!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao avaliar: $e')));
      }
    }
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
