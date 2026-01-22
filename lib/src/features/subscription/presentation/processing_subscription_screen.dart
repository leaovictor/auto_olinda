import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../auth/data/auth_repository.dart';
import '../data/subscription_repository.dart';
import '../../../common_widgets/atoms/secondary_button.dart';

class ProcessingSubscriptionScreen extends ConsumerStatefulWidget {
  const ProcessingSubscriptionScreen({super.key});

  @override
  ConsumerState<ProcessingSubscriptionScreen> createState() =>
      _ProcessingSubscriptionScreenState();
}

class _ProcessingSubscriptionScreenState
    extends ConsumerState<ProcessingSubscriptionScreen> {
  bool _isProcessing = true;
  String _statusMessage = 'Processando sua assinatura...';
  int _attemptCount = 0;
  static const int maxAttempts = 30; // 60 seconds (2s interval)

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  Future<void> _startPolling() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      _handleError('Usuário não autenticado');
      return;
    }

    // Poll for subscription activation
    for (int i = 0; i < maxAttempts; i++) {
      if (!mounted) return;

      _attemptCount = i + 1;
      setState(() {
        _statusMessage =
            'Aguardando confirmação... ($_attemptCount/$maxAttempts)';
      });

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // Check subscription status
      final repo = ref.read(subscriptionRepositoryProvider);
      final subscription = await repo.getAnyUserSubscription(user.uid);

      print(
        '🔵 ProcessingSubscription: Poll #$_attemptCount - Status: ${subscription?.status}',
      );

      if (subscription != null && subscription.isActive) {
        // Success! Subscription is active
        print('✅ ProcessingSubscription: Subscription ACTIVE!');

        // Force refresh user profile
        ref.invalidate(authStateChangesProvider);

        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Assinatura ativada com sucesso!';
        });

        // Show success message briefly
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        // Navigate to dashboard
        context.go('/dashboard');
        return;
      }

      // If incomplete, try to sync
      if (subscription != null && subscription.status == 'incomplete') {
        print(
          '⚠️ ProcessingSubscription: Subscription incomplete, attempting sync...',
        );
        if (subscription.stripeSubscriptionId != null) {
          try {
            await repo.syncSubscriptionStatus(
              subscription.stripeSubscriptionId!,
            );
          } catch (e) {
            print('❌ ProcessingSubscription: Sync failed - $e');
          }
        }
      }
    }

    // Timeout - show option to continue later
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'A ativação está demorando mais que o esperado.';
      });
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _statusMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessing) ...[
                  // Loading animation
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/loading.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Processando Pagamento',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: _attemptCount / maxAttempts,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Isso pode levar alguns segundos...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ] else ...[
                  // Timeout or error state
                  Icon(
                    Icons.schedule,
                    size: 100,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _statusMessage,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Não se preocupe! Seu pagamento foi processado. A ativação pode levar alguns minutos.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SecondaryButton(
                    text: 'Continuar',
                    onPressed: () => context.go('/dashboard'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isProcessing = true;
                        _attemptCount = 0;
                      });
                      _startPolling();
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
