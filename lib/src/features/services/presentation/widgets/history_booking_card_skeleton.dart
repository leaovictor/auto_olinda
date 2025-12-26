import 'package:flutter/material.dart';
import '../../../../shared/widgets/shimmer_loading.dart';

/// Skeleton loading card that mimics the booking card layout
/// Uses shimmer effect for a premium loading experience
class HistoryBookingCardSkeleton extends StatelessWidget {
  const HistoryBookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Icon + Title + Status
            Row(
              children: [
                // Service icon placeholder
                const ShimmerLoading.circular(width: 44, height: 44),
                const SizedBox(width: 12),
                // Title and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerLoading.rectangular(height: 18, width: 120),
                      SizedBox(height: 6),
                      ShimmerLoading.rectangular(height: 14, width: 160),
                    ],
                  ),
                ),
                // Status badge
                const ShimmerLoading.rectangular(height: 28, width: 80),
              ],
            ),
            const SizedBox(height: 16),
            // Divider
            Container(height: 1, color: Colors.grey[100]),
            const SizedBox(height: 16),
            // Footer row: Time + Price + Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerLoading.rectangular(height: 16, width: 60),
                ShimmerLoading.rectangular(height: 20, width: 80),
                ShimmerLoading.rectangular(height: 32, width: 90),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display a list of skeleton cards
class HistorySkeletonList extends StatelessWidget {
  final int itemCount;

  const HistorySkeletonList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const HistoryBookingCardSkeleton(),
    );
  }
}
