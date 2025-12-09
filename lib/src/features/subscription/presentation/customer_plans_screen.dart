import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../../auth/data/auth_repository.dart';
import '../data/subscription_repository.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../common_widgets/atoms/secondary_button.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/utils/app_toast.dart';
import '../../ecommerce/data/coupon_repository.dart';
import '../../ecommerce/domain/coupon.dart';
import 'manage_subscription_screen.dart';
import 'widgets/web_payment_sheet.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';

class CustomerPlansScreen extends ConsumerStatefulWidget {
  const CustomerPlansScreen({super.key});

  @override
  ConsumerState<CustomerPlansScreen> createState() =>
      _CustomerPlansScreenState();
}

class _CustomerPlansScreenState extends ConsumerState<CustomerPlansScreen> {
  bool _isLoading = false;
  bool _showConfetti = false;

  // Coupon state
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCouponId;
  double _discountAmount = 0;
  bool _isValidatingCoupon = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

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
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
              onPressed: () => context.go('/dashboard'),
            ),
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

              // Coupon Input Section
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        labelText: 'Cupom de desconto',
                        hintText: 'Digite o código',
                        border: const OutlineInputBorder(),
                        suffixIcon: _appliedCouponId != null
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: _clearCoupon,
                              )
                            : null,
                      ),
                      enabled: !_isLoading && !_isValidatingCoupon,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isLoading || _isValidatingCoupon
                        ? null
                        : () => _validateCoupon(context, plan.price),
                    child: _isValidatingCoupon
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Aplicar'),
                  ),
                ],
              ),

              // Discount Display
              if (_discountAmount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Valor original:',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'R\$ ${plan.price.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Desconto:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '- R\$ ${_discountAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'R\$ ${(plan.price - _discountAmount).toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
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

  // ... (existing imports)

  Widget _buildActiveSubscriptionView(
    BuildContext context,
    Subscriber subscription,
    SubscriptionPlan plan,
  ) {
    final theme = Theme.of(context);
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
                        color: Colors.green.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        'ATIVO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
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
                  'Próxima Renovação',
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
    setState(() => _isLoading = true);
    try {
      // Check connectivity first
      if (kIsWeb) {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          if (!context.mounted) return;
          AppToast.error(
            context,
            message: 'Sem conexão com a internet. Verifique sua rede.',
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      if (kIsWeb) {
        // Web Flow: Bottom Sheet with Payment Element
        final repository = ref.read(subscriptionRepositoryProvider);
        print('Starting createSubscriptionIntent...');
        final intentData = await repository.createSubscriptionIntent(
          userId,
          plan,
          couponId: _appliedCouponId,
        );
        print('createSubscriptionIntent success. IntentData: $intentData');

        // Set publishable key for Web
        Stripe.publishableKey = intentData['publishableKey'];

        if (!context.mounted) return;

        setState(() => _isLoading = false); // Stop loading to show sheet

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => WebPaymentSheet(
            clientSecret: intentData['paymentIntent'],
            onSuccess: () {
              Navigator.pop(context); // Close sheet
              _handlePaymentSuccess(context, plan);
            },
            onError: (error) {
              Navigator.pop(context); // Close sheet
              AppToast.error(context, message: 'Erro no pagamento: $error');
            },
          ),
        );
      } else {
        // Mobile Flow: Native Payment Sheet
        await ref
            .read(subscriptionRepositoryProvider)
            .subscribeToPlan(userId, plan, couponId: _appliedCouponId);

        if (!context.mounted) return;
        _handlePaymentSuccess(context, plan);
      }
    } catch (e, stackTrace) {
      print('Subscription Error: $e');
      print('Stack Trace: $stackTrace');
      if (!context.mounted) return;
      AppToast.error(context, message: 'Erro ao processar assinatura: $e');
      setState(() => _isLoading = false);
    }
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

  Future<void> _validateCoupon(BuildContext context, double planPrice) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidatingCoupon = true);

    try {
      final result = await ref
          .read(couponRepositoryProvider)
          .validateCoupon(
            code: code,
            applicableTo: CouponApplicableTo.subscriptions,
            amount: planPrice,
          );

      if (!context.mounted) return;

      if (result['valid'] == true) {
        setState(() {
          _appliedCouponId = result['couponId'];
          _discountAmount = result['discount']?.toDouble() ?? 0;
        });

        AppToast.success(
          context,
          message:
              'Cupom aplicado! Desconto: R\$ ${_discountAmount.toStringAsFixed(2)}',
        );
      } else {
        _clearCoupon();
        AppToast.error(context, message: result['error'] ?? 'Cupom inválido');
      }
    } catch (e) {
      print('Erro ao validar cupom: $e');
      if (!context.mounted) return;

      _clearCoupon();
      AppToast.error(context, message: 'Erro ao validar cupom');
    } finally {
      if (mounted) {
        setState(() => _isValidatingCoupon = false);
      }
    }
  }

  void _clearCoupon() {
    setState(() {
      _appliedCouponId = null;
      _discountAmount = 0;
      _couponController.clear();
    });
  }

  Future<void> _navigateToManageSubscription(
    BuildContext context,
    Subscriber subscription,
    SubscriptionPlan currentPlan,
  ) async {
    final plansAsync = await ref.read(activePlansProvider.future);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageSubscriptionScreen(
          subscription: subscription,
          currentPlan: currentPlan,
          availablePlans: plansAsync,
        ),
      ),
    );
  }
}
