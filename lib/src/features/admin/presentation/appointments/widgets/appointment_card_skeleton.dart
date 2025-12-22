import 'package:flutter/material.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';

/// Skeleton loading card that mimics the appointment card layout
/// Uses shimmer effect for a premium loading experience
class AppointmentCardSkeleton extends StatelessWidget {
  const AppointmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Status bar skeleton
            ShimmerLoading.rectangular(width: 5, height: double.infinity),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const ShimmerLoading.rectangular(
                          height: 18,
                          width: 140,
                        ),
                        const ShimmerLoading.rectangular(height: 24, width: 80),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Client name
                    const ShimmerLoading.rectangular(height: 16, width: 180),
                    const SizedBox(height: 8),
                    // Vehicle info with badge
                    Row(
                      children: [
                        ShimmerLoading.circular(width: 14, height: 14),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const ShimmerLoading.rectangular(
                            height: 12,
                            width: 80,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status pill
                    const ShimmerLoading.rectangular(height: 14, width: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display a list of skeleton cards
class AppointmentSkeletonList extends StatelessWidget {
  final int itemCount;

  const AppointmentSkeletonList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const AppointmentCardSkeleton(),
    );
  }
}
