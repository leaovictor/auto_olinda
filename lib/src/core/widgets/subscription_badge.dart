import 'package:flutter/material.dart';
import '../../features/booking/domain/booking.dart';

/// Centralized widget for displaying subscription badges across the app
/// Staff sees this without accessing financial data - just a visual indicator
class SubscriptionBadge extends StatelessWidget {
  final Booking booking;

  const SubscriptionBadge({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Only show if payment is marked as subscription
    final isSubscriber =
        booking.paymentStatus == BookingPaymentStatus.subscription;

    if (!isSubscriber) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade600, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'ASSINANTE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
