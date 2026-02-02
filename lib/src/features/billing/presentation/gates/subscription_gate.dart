import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/billing_repository.dart';
import '../../domain/subscription.dart';
import '../pages/paywall_page.dart';

// You must provide the tenantId.
// In a real app, you might obtain this from a userProvider that reads the current user doc.

class SubscriptionGate extends ConsumerWidget {
  final Widget child;
  final String tenantId;

  const SubscriptionGate({
    super.key,
    required this.child,
    required this.tenantId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(subscriptionStreamProvider(tenantId));

    return subAsync.when(
      data: (subscription) {
        // Core Logic:
        // 1. Is it Active or Trialing? -> Allow Access
        if (subscription.isActive) {
          return child;
        }

        // 2. Otherwise -> Paywall
        return PaywallPage(status: subscription.status);
      },
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Erro ao validar assinatura: $err')),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
