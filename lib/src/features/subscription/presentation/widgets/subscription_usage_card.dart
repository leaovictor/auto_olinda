import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/subscription_repository.dart';
import '../../domain/subscriber.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../booking/domain/booking.dart';
import '../../../../core/providers/system_settings_provider.dart';

class SubscriptionUsageCard extends ConsumerWidget {
  const SubscriptionUsageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(userSubscriptionsProvider);

    return subscriptionsAsync.when(
      data: (subscriptions) {
        final active = subscriptions.where((s) => s.isActive).toList();
        if (active.isEmpty) return const SizedBox.shrink();

        if (active.length == 1) {
          return _SingleSubscriptionCard(subscription: active.first);
        }

        // Multiple subscriptions: horizontal list
        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: active.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: _SingleSubscriptionCard(subscription: active[index]),
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
    final planAsync = ref.watch(resolvedPlanProvider(subscription.planId));
    final bookingsAsync = ref.watch(userBookingsProvider(subscription.userId));

    // While loading the plan, show the card with default values (no flicker)
    final plan = planAsync.valueOrNull;
    final isPlanLoading = planAsync.isLoading;

    final baseWashes = plan?.washesPerMonth ?? 4;
    final bonusWashes = subscription.bonusWashes;
    final totalWashes = baseWashes + bonusWashes;
    final planName = plan?.name;

    int usedWashes = 0;
    if (bookingsAsync.hasValue) {
      final bookings = bookingsAsync.value!;
      final cycleStart = _getCycleStartDate(subscription);

      usedWashes = bookings.where((b) {
        // Must be a subscription payment
        final isSubscription =
            b.paymentStatus == BookingPaymentStatus.subscription;

        // Count active statuses OR cancelled with penalty
        final shouldCount =
            b.status != BookingStatus.cancelled ||
            (b.status == BookingStatus.cancelled &&
                (b.penaltyApplied ?? false));

        // Must be within the current billing cycle
        final inCycle = b.scheduledTime.isAfter(cycleStart);

        // Vehicle matching: by vehicleId first, then by linkedPlate fallback
        bool vehicleMatch = true;
        if (subscription.vehicleId != null) {
          vehicleMatch = b.vehicleId == subscription.vehicleId;
        } else if (subscription.linkedPlate != null) {
          // If no vehicleId stored, we can't reliably filter by vehicle.
          // Count all subscription bookings in the cycle for this user.
          // This is the safest fallback — matches the backend logic.
          vehicleMatch = true;
        }

        return isSubscription && shouldCount && inCycle && vehicleMatch;
      }).length;
    }

    final progress = totalWashes > 0
        ? (usedWashes / totalWashes).clamp(0.0, 1.0)
        : 0.0;

    // Renewal / expiry date
    final dateFormat = DateFormat('dd/MM', 'pt_BR');
    final isCanceling = subscription.cancelAtPeriodEnd ?? false;

    String renewalDateStr;
    if (subscription.endDate != null) {
      renewalDateStr = dateFormat.format(subscription.endDate!);
    } else {
      // Calculate next renewal from startDate (same day next month)
      final start = subscription.startDate;
      final now = DateTime.now();
      var next = DateTime(now.year, now.month, start.day);
      if (!next.isAfter(now)) {
        next = DateTime(now.year, now.month + 1, start.day);
      }
      renewalDateStr = dateFormat.format(next);
    }

    // Title
    String title = 'Suas Lavagens';
    if (subscription.linkedPlate != null) {
      title = 'Lavagens · ${subscription.linkedPlate}';
    } else if (subscription.vehicleCategory != null) {
      title = 'Assinatura ${subscription.vehicleCategory}';
    }

    final isLimitReached = usedWashes >= totalWashes;

    return Stack(
      key: ValueKey('subscription_card_${subscription.id}'),
      clipBehavior: Clip.none,
      children: [
        AnimatedOpacity(
          opacity: isPlanLoading ? 0.7 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isCanceling
                  ? const LinearGradient(
                      colors: [Color(0xFF5A3E2B), Color(0xFFE07B39)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isCanceling
                      ? const Color(0xFFE07B39).withValues(alpha: 0.3)
                      : const Color(0xFF1BFFFF).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header row ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (planName != null && !isPlanLoading) ...[
                            const SizedBox(height: 2),
                            Text(
                              planName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Wash count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$usedWashes / $totalWashes',
                        style: TextStyle(
                          color: isLimitReached
                              ? Colors.orangeAccent
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Wash icons ────────────────────────────────────
                _buildWashIcons(usedWashes, totalWashes),

                const SizedBox(height: 8),

                // ── Progress bar ──────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.black.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(
                      isLimitReached ? Colors.orangeAccent : Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Footer row ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Renewal / expiry info
                    Row(
                      children: [
                        Icon(
                          isCanceling ? Icons.warning_amber : Icons.autorenew,
                          color: isCanceling
                              ? Colors.orangeAccent
                              : Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCanceling
                              ? 'Expira em $renewalDateStr'
                              : 'Renova em $renewalDateStr',
                          style: TextStyle(
                            color: isCanceling
                                ? Colors.orangeAccent
                                : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // WhatsApp button when limit reached
                    if (isLimitReached)
                      InkWell(
                        onTap: () =>
                            _openWhatsAppForBonus(ref, subscription),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Solicitar mais',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
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

        // Bonus washes ticket badge
        if (bonusWashes > 0)
          Positioned(
            top: -12,
            right: 10,
            child: _TicketBadge(count: bonusWashes),
          ),
      ],
    );
  }

  /// Renders individual wash icons (up to 8; shows "+N" beyond that).
  Widget _buildWashIcons(int used, int total) {
    const maxIcons = 8;
    final displayCount = total.clamp(1, maxIcons);
    final overflow = total > maxIcons ? total - maxIcons : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < displayCount; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              Icons.local_car_wash,
              size: 16,
              color: i < used
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
        if (overflow > 0)
          Text(
            '+$overflow',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
      ],
    );
  }

  /// FIX: Safe previous month — avoids month=0 crash in January.
  DateTime _getCycleStartDate(Subscriber sub) {
    final now = DateTime.now();
    final startDay = sub.startDate.day;

    var cycleStart = DateTime(now.year, now.month, startDay);
    if (now.isBefore(cycleStart)) {
      // Go back one month safely
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      cycleStart = DateTime(prevYear, prevMonth, startDay);
    }

    return cycleStart;
  }

  void _openWhatsAppForBonus(WidgetRef ref, Subscriber subscription) {
    final whatsappNumber = ref.read(supportPhoneNumberProvider);
    if (whatsappNumber == null || whatsappNumber.isEmpty) return;

    final cleanNumber = whatsappNumber.replaceAll(RegExp(r'\D'), '');
    final plate = subscription.linkedPlate ?? 'meu veículo';

    final message = Uri.encodeComponent(
      'Olá! Gostaria de solicitar lavagens adicionais para minha assinatura.\n\n'
      'Veículo: $plate\n'
      'Lavagens extras necessárias: 1 ou mais\n\n'
      'Aguardo retorno. Obrigado!',
    );

    launchUrl(
      Uri.parse('https://wa.me/$cleanNumber?text=$message'),
      mode: LaunchMode.externalApplication,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ticket Badge (bonus washes)
// ─────────────────────────────────────────────────────────────────────────────

class _TicketBadge extends StatelessWidget {
  final int count;

  const _TicketBadge({required this.count});

  @override
  Widget build(BuildContext context) {
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
          color: const Color(0xFF00C853),
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
    const double radius = 5.0;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height / 2 - radius);
    path.arcToPoint(
      Offset(size.width, size.height / 2 + radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height / 2 + radius);
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
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
