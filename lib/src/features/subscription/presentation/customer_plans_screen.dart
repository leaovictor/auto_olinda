import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../data/subscription_repository.dart';
import '../../dashboard/presentation/shell/client_shell.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../common_widgets/atoms/secondary_button.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/utils/app_toast.dart';
import 'widgets/subscription_checkout_modal.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';

class CustomerPlansScreen extends ConsumerStatefulWidget {
  const CustomerPlansScreen({super.key});

  @override
  ConsumerState<CustomerPlansScreen> createState() =>
      _CustomerPlansScreenState();
}

class _CustomerPlansScreenState extends ConsumerState<CustomerPlansScreen> {
  bool _showConfetti = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(activePlansProvider);
    final subscriptionAsync = ref.watch(userSubscriptionProvider);
    final user = ref.watch(authStateChangesProvider).value;
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
            actions: [
              IconButton(
                icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
                onPressed: () {
                  final toggle = ref.read(drawerToggleProvider);
                  toggle?.call();
                },
              ),
            ],
          ),
          body: AppRefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activePlansProvider);
              ref.invalidate(userSubscriptionProvider);
              if (user == null) {
                ref.invalidate(authStateChangesProvider);
              }
              await Future.delayed(const Duration(seconds: 1));
            },
            child: subscriptionAsync.when(
              data: (subscription) {
                if (subscription != null && subscription.status == 'active') {
                  return plansAsync.when(
                    data: (plans) {
                      final currentPlan = plans.firstWhere(
                        (p) => p.stripePriceId == subscription.planId,
                        orElse: () => const SubscriptionPlan(
                          id: 'unknown',
                          name: 'Plano Desconhecido',
                          price: 0,
                          features: [],
                          stripePriceId: '',
                        ),
                      );
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: _buildActiveSubscriptionView(
                          context,
                          subscription,
                          currentPlan,
                        ),
                      );
                    },
                    loading: () => const Center(child: AppLoader()),
                    error: (err, stack) => Center(child: Text('Erro: $err')),
                  );
                }

                return plansAsync.when(
                  data: (plans) {
                    if (plans.isEmpty) {
                      return Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
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
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Plans List
                          ...plans.asMap().entries.map((entry) {
                            final index = entry.key;
                            final plan = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < plans.length - 1 ? 24 : 0,
                              ),
                              child: _buildPlanCard(
                                context,
                                plan,
                                user?.uid,
                                index,
                              ),
                            );
                          }),
                          const SizedBox(height: 200),
                        ],
                      ),
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
                );
              },
              loading: () => const Center(child: AppLoader()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            ),
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
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'ASSINAR AGORA',
                onPressed: userId == null
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

  // ... (existing imports)

  Widget _buildActiveSubscriptionView(
    BuildContext context,
    Subscriber subscription,
    SubscriptionPlan plan,
  ) {
    final theme = Theme.of(context);
    final isPromo = subscription.type == 'promo';
    final nextRenewal =
        subscription.endDate ??
        subscription.startDate.add(const Duration(days: 30));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meu Plano',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPromo
                            ? Colors.blue.withAlpha(30)
                            : Colors.green.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPromo ? Colors.blue : Colors.green,
                        ),
                      ),
                      child: Text(
                        isPromo ? 'CORTESIA' : 'ATIVO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isPromo ? Colors.blue : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  plan.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${plan.price.toStringAsFixed(2)} / mês',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 24),
                _buildInfoRow(
                  context,
                  'Data de Adesão',
                  DateFormat('dd/MM/yyyy').format(subscription.startDate),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  isPromo ? 'Válido até' : 'Próxima Renovação',
                  DateFormat('dd/MM/yyyy').format(nextRenewal),
                ),
                const SizedBox(height: 32),
                SecondaryButton(
                  text: 'Gerenciar Assinatura',
                  onPressed: () {
                    // Navigate to manage subscription screen
                    _navigateToManageSubscription(context, subscription, plan);
                  },
                ),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubscribe(
    BuildContext context,
    String userId,
    SubscriptionPlan plan,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubscriptionCheckoutModal(
        plan: plan,
        userId: userId,
        onSuccess: () => _handlePaymentSuccess(context, plan),
        onError: (error) {
          AppToast.error(context, message: 'Erro no pagamento: $error');
        },
      ),
    );
  }

  Future<void> _handlePaymentSuccess(
    BuildContext context,
    SubscriptionPlan plan,
  ) async {
    AppToast.info(
      context,
      message: 'Verificando assinatura...',
      duration: const Duration(seconds: 2),
    );

    // Wait for subscription to become active
    bool isActive = false;
    // Try for 60 seconds (2s interval * 30)
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // Force refresh of the main provider
      ref.invalidate(userSubscriptionProvider);

      // Debug fetch
      final repo = ref.read(subscriptionRepositoryProvider);
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        final debugSub = await repo.getAnyUserSubscription(user.uid);
        print('DEBUG POLL: Sub status for ${user.uid}: ${debugSub?.status}');

        if (debugSub != null) {
          if (debugSub.isActive) {
            print('DEBUG POLL: Subscription attached and ACTIVE!');
            isActive = true;
            break;
          } else if (debugSub.status == 'incomplete') {
            // Force sync!
            print(
              'DEBUG POLL: Syncing incomplete subscription ${debugSub.id}...',
            );
            if (debugSub.stripeSubscriptionId == null) {
              print('DEBUG POLL: Cannot sync, missing stripeSubscriptionId');
            } else {
              try {
                await repo.syncSubscriptionStatus(
                  debugSub.stripeSubscriptionId!,
                );
              } catch (e) {
                print('DEBUG POLL: Sync failed: $e');
              }
            }
          }
        }
      }
    }

    if (!context.mounted) return;

    if (isActive) {
      setState(() {
        _showConfetti = true;
      });

      AppToast.success(
        context,
        message: 'Assinatura do plano ${plan.name} realizada com sucesso!',
      );

      // Wait for animation
      await Future.delayed(const Duration(seconds: 3));
    } else {
      AppToast.warning(
        context,
        message:
            'Pagamento recebido, mas a ativação está demorando. Verifique em instantes.',
      );
    }
  }

  Future<void> _navigateToManageSubscription(
    BuildContext context,
    Subscriber subscription,
    SubscriptionPlan currentPlan,
  ) async {
    final plansAsync = await ref.read(activePlansProvider.future);

    if (!context.mounted) return;

    context.push(
      '/manage-subscription',
      extra: {
        'subscription': subscription,
        'currentPlan': currentPlan,
        'availablePlans': plansAsync,
      },
    );
  }
}
