import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/subscription_repository.dart';

class SubscriptionUsageCard extends ConsumerWidget {
  const SubscriptionUsageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(userSubscriptionProvider);

    return subscriptionAsync.when(
      data: (subscription) {
        if (subscription == null || !subscription.isActive) {
          return const SizedBox.shrink();
        }

        // TODO: Implement planLimits and usage in Subscriber model
        // For now, using default values for GTM demonstration
        const totalWashes = 4; // subscription.planLimits?.washesPerMonth ?? 4;
        const usedWashes = 0; // subscription.usage?.washesUsedThisMonth ?? 0;
        final progress = (usedWashes / totalWashes).clamp(0.0, 1.0);

        // Format date
        final dateFormat = DateFormat('dd/MM', 'pt_BR');
        final renewalDate = subscription.endDate != null
            ? dateFormat.format(subscription.endDate!)
            : '---';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  const Text(
                    "Suas Lavagens",
                    style: TextStyle(
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
                  const Icon(Icons.autorenew, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "Renova em $renewalDate",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () =>
          const SizedBox.shrink(), // Don't show skeleton here to avoid clutter
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
