import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../auth/data/auth_repository.dart';
import '../data/subscription_repository.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class CustomerPlansScreen extends ConsumerStatefulWidget {
  const CustomerPlansScreen({super.key});

  @override
  ConsumerState<CustomerPlansScreen> createState() =>
      _CustomerPlansScreenState();
}

class _CustomerPlansScreenState extends ConsumerState<CustomerPlansScreen> {
  bool _isLoading = false;
  bool _showConfetti = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(activePlansProvider);
    final user = ref.watch(authRepositoryProvider).currentUser;
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: Text(
              'Planos de Assinatura',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
              onPressed: () => context.go('/dashboard'),
            ),
          ),
          body: plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum plano disponível no momento.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: plans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _buildPlanCard(context, plan, user?.uid, index);
                },
              );
            },
            loading: () => ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 24),
              itemBuilder: (context, index) =>
                  const ShimmerLoading.rectangular(height: 300),
            ),
            error: (err, stack) => Center(child: Text('Erro: $err')),
          ),
        ),
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/Confetti.json',
                fit: BoxFit.cover,
                repeat: false,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan,
    String? userId,
    int index,
  ) {
    final theme = Theme.of(context);
    final isPopular = index == 1; // Mock logic for "Popular" plan

    return Stack(
      children: [
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isPopular) const SizedBox(height: 16),
              Text(
                plan.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.price.toStringAsFixed(0),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '/mês',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 24),
              ...plan.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'ASSINAR AGORA',
                isLoading: _isLoading,
                onPressed: _isLoading || userId == null
                    ? null
                    : () => _handleSubscribe(context, userId, plan),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1),
        if (isPopular)
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'MAIS POPULAR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: (100 * index + 200).ms).scale(),
      ],
    );
  }

  Future<void> _handleSubscribe(
    BuildContext context,
    String userId,
    SubscriptionPlan plan,
  ) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .subscribeToPlan(userId, plan);

      if (!context.mounted) return;

      setState(() {
        _showConfetti = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Assinatura do plano ${plan.name} realizada com sucesso!',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Wait for animation
      await Future.delayed(const Duration(seconds: 3));

      if (!context.mounted) return;
      context.go('/dashboard'); // Go back to dashboard
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao assinar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
