import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/billing_repository.dart';
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
    // 1. Watch the subscription stream for this tenant
    final subAsync = ref.watch(subscriptionStreamProvider(tenantId));

    return subAsync.when(
      data: (subscription) {
        // 2. Access Control Logic
        // Allow access if active or trialing
        if (subscription.isActive) {
          return child;
        }

        // 3. Block Access -> Show Paywall
        return PaywallPage(status: subscription.status);
      },
      // 4. Handle Errors Gracefully (maybe allow access if it's a temporary network glitch?
      //    Or block for security? Sticking to blocked for safety per instructions "Gating by status")
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao verificar assinatura: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(subscriptionStreamProvider(tenantId)),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
      // 5. Loading State - Show a clean loading screen
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
