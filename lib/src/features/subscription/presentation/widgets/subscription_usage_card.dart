import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/subscription_repository.dart';
import '../../domain/subscriber.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../booking/domain/booking.dart';

class SubscriptionUsageCard extends ConsumerWidget {
  const SubscriptionUsageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(userSubscriptionsProvider);

    return subscriptionsAsync.when(
      data: (subscriptions) {
        if (subscriptions.isEmpty) {
          return const SizedBox.shrink();
        }

        if (subscriptions.length == 1) {
          final sub = subscriptions.first;
          if (!sub.isActive) return const SizedBox.shrink();
          return _SingleSubscriptionCard(subscription: sub);
        }

        // Multiple subscriptions: Horizontal list
        return SizedBox(
          height: 200, // Approximate height for the card
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              if (!sub.isActive) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: _SingleSubscriptionCard(subscription: sub),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SingleSubscriptionCard extends ConsumerWidget {
  final Subscriber subscription;

  const _SingleSubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(subscriptionPlanProvider(subscription.planId));
    final bookingsAsync = ref.watch(userBookingsProvider(subscription.userId));

    return planAsync.when(
      data: (plan) {
        final baseWashes = plan?.washesPerMonth ?? 4;
        final bonusWashes = subscription.bonusWashes;
        final totalWashes = baseWashes + bonusWashes;

        int usedWashes = 0;
        if (bookingsAsync.hasValue) {
          final bookings = bookingsAsync.value!;
          final cycleStart = _getCycleStartDate(subscription);

          // Count used washes in current cycle
          // IMPORTANT: Washes count as "used" as soon as scheduled (not just when finished)
          // This prevents over-scheduling and gives transparent usage tracking
          usedWashes = bookings.where((b) {
            // Must be a subscription payment
            final isSubscription =
                b.paymentStatus == BookingPaymentStatus.subscription;

            // Count all active statuses (scheduled, confirmed, in-progress, finished)
            // Only exclude: cancelled (credit returned) and noShow
            final isActive =
                b.status != BookingStatus.cancelled &&
                b.status != BookingStatus.noShow;

            // Must be in current cycle (this month)
            final inCycle = b.scheduledTime.isAfter(cycleStart);

            // If subscription is tied to a specific vehicle, only count that vehicle's bookings
            bool vehicleMatch = true;
            if (subscription.vehicleId != null) {
              // If booking has vehicleId (it should), check match.
              // Warning: If Booking doesn't expose vehicleId in the list view, we might have an issue.
              // Assuming it does for now; if it breaks, I'll fix.
              // But wait, Booking domain object usually has vehicleId.
              // Let's check safely.
              // Actually the Booking entity DOES have vehicleId.
              if (b.vehicleId != subscription.vehicleId) {
                vehicleMatch = false;
              }
            }

            return isSubscription && isActive && inCycle && vehicleMatch;
          }).length;
        }

        final progress = (usedWashes / totalWashes).clamp(0.0, 1.0);

        // Format date
        final dateFormat = DateFormat('dd/MM', 'pt_BR');
        final renewalDate = subscription.endDate != null
            ? dateFormat.format(subscription.endDate!)
            : '---';

        // Title: Include Vehicle Plate if available
        String title = "Suas Lavagens";
        if (subscription.linkedPlate != null) {
          title = "Lavagens - ${subscription.linkedPlate}";
        } else if (subscription.vehicleCategory != null) {
          title = "Assinatura ${subscription.vehicleCategory}";
        }

        return Stack(
          key: ValueKey('subscription_card_${subscription.id}'),
          clipBehavior: Clip.none,
          children: [
            Container(
              // Remove margin if in list, handled by parent padding?
              // But single view needs margin if not handled by parent constraints.
              // Parent handles width.
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E3192),
                    Color(0xFF1BFFFF),
                  ], // Premium Blue/Cyan
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1BFFFF).withValues(alpha: 0.3),
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
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "$usedWashes / $totalWashes",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.black.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.autorenew,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Renova em $renewalDate",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (bonusWashes > 0)
              Positioned(
                top: -12,
                right: 10,
                child: _TicketBadge(count: bonusWashes),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  DateTime _getCycleStartDate(Subscriber sub) {
    if (sub.endDate != null) {
      final end = sub.endDate!;
      return DateTime(end.year, end.month - 1, end.day);
    }
    final now = DateTime.now();
    final startDay = sub.startDate.day;
    var cycleStart = DateTime(now.year, now.month, startDay);
    if (now.isBefore(cycleStart)) {
      cycleStart = DateTime(now.year, now.month - 1, startDay);
    }
    return cycleStart;
  }
}

class _TicketBadge extends StatelessWidget {
  final int count;

  const _TicketBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    // Removed Transform.rotate to avoid potential layout mutation issues
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _TicketClipper(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: const Color(0xFF00C853), // Green Accent
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '+$count',
                  style: const TextStyle(
                    color: Color(0xFF00C853),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Dashed line simulation
              CustomPaint(
                size: const Size(1, 20),
                painter: _DashedLinePainter(),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.local_car_wash, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 5.0; // Radius of the sidebar cutouts

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height / 2 - radius);

    // Right cutout
    path.arcToPoint(
      Offset(size.width, size.height / 2 + radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height / 2 + radius);

    // Left cutout
    path.arcToPoint(
      Offset(0, size.height / 2 - radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashHeight = 3;
    const dashSpace = 2;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
