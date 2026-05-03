import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../../../features/subscription_plans/domain/subscription_plan.dart';
import '../../../features/subscription_plans/domain/subscriber.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../data/subscription_repository.dart';
import '../../owner_dashboard/presentation/shell/client_shell.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../common_widgets/atoms/secondary_button.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/utils/app_toast.dart';
import '../../appointments/data/vehicle_repository.dart';
import '../../profile/domain/vehicle.dart';
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
  Vehicle? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(activePlansProvider);
    final subscriptionsAsync = ref.watch(userSubscriptionsProvider);
    final vehiclesAsync = ref.watch(userVehiclesProvider); // Watch vehicles
    final user = ref.watch(authStateChangesProvider).value;
    // Watch user profile to ensure sync before redirect
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final theme = Theme.of(context);

    // Auto-select first vehicle if none selected AND no extra provided
    ref.listen<AsyncValue<List<Vehicle>>>(userVehiclesProvider, (
      previous,
      next,
    ) {
      next.whenData((vehicles) {
        // If we haven't selected a vehicle, try to select one.
        if (_selectedVehicle == null) {
          // Check for extra from navigation
          final extra = GoRouterState.of(context).extra;
          if (extra is Vehicle) {
            // Validate extra vehicle belongs to list to avoid stale data
            final match = vehicles.where((v) => v.id == extra.id).firstOrNull;
            if (match != null) {
              setState(() {
                _selectedVehicle = match;
              });
              return;
            }
          }

          if (vehicles.isNotEmpty) {
            setState(() {
              _selectedVehicle = vehicles.first;
            });
          }
        }
      });
    });

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
              ref.invalidate(
                currentUserProfileProvider,
              ); // Force profile refresh
              if (user == null) {
                ref.invalidate(authStateChangesProvider);
              }
              await Future.delayed(const Duration(seconds: 1));
            },
            child: subscriptionsAsync.when(
              data: (subscriptions) {
                // 1. Get GLOBAL active subscription (One Per CPF Rule)
                final activeGlobalSubscription = subscriptions
                    .where((s) => s.isActive)
                    .firstOrNull;

                // 2. Check context of Selected Vehicle
                // If no vehicle selected, we just show plans (or empty state logic)
                // But usually we auto-select first.
                final isSelectedVehicleActive =
                    _selectedVehicle != null &&
                    activeGlobalSubscription != null &&
                    activeGlobalSubscription.vehicleId == _selectedVehicle!.id;

                if (isSelectedVehicleActive) {
                  // --- SELF-HEALING: Force Sync if profile is lagging ---
                  final isProfileSynced =
                      userProfile?.subscriptionStatus == 'active';

                  if (!isProfileSynced) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_isSyncing) return; // Debounce
                      _forceSyncSubscription(
                        activeGlobalSubscription.id,
                        activeGlobalSubscription.stripeSubscriptionId,
                      );
                    });
                  }

                  // Render Active View for THIS vehicle
                  return plansAsync.when(
                    data: (plans) {
                      final currentPlan = plans.firstWhere(
                        (p) => p.id == activeGlobalSubscription.planId,
                        orElse: () => plans.first, // Fallback
                      );

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: _buildVehicleSelector(
                                theme,
                                vehiclesAsync,
                              ),
                            ),
                            _buildActiveSubscriptionView(
                              context,
                              activeGlobalSubscription,
                              currentPlan,
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: AppLoader()),
                    error: (e, s) =>
                        Center(child: Text('Erro ao carregar plano: $e')),
                  );
                }

                // 3. Swap Mode or New Subscription Mode
                // If we have an active subscription but it's NOT this vehicle, it's a SWAPScenario.
                final isSwapMode =
                    activeGlobalSubscription != null &&
                    _selectedVehicle != null &&
                    activeGlobalSubscription.vehicleId != _selectedVehicle!.id;

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
                          if (user != null) ...[
                            _buildVehicleSelector(theme, vehiclesAsync),
                            const SizedBox(height: 24),
                          ],

                          if (isSwapMode) ...[
                            _buildSwapInfoBanner(
                              theme,
                              activeGlobalSubscription,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Plans List
                          ..._filterPlans(
                            plans,
                            _selectedVehicle,
                          ).asMap().entries.map((entry) {
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
                                swapSubscription: isSwapMode
                                    ? activeGlobalSubscription
                                    : null,
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
    int index, {
    Subscriber? swapSubscription,
  }) {
    final theme = Theme.of(context);
    final isPopular = index == 1; // Mock logic for "Popular" plan

    // Swap Logic Check
    bool canSwap = true;
    String? swapWarning;

    if (swapSubscription != null) {
      final lastChange = swapSubscription.lastPlateChange;
      if (lastChange != null) {
        final daysSinceChange = DateTime.now().difference(lastChange).inDays;
        if (daysSinceChange < 30) {
          canSwap = false;
          final releaseDate = lastChange.add(const Duration(days: 30));
          swapWarning =
              'Disponível em ${DateFormat('dd/MM').format(releaseDate)}';
        }
      }
    }

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

              if (swapWarning != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            swapWarning,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              PrimaryButton(
                text: swapSubscription != null
                    ? 'TROCAR PARA ESTE CARRO'
                    : 'ASSINAR AGORA',
                onPressed:
                    (userId == null || _selectedVehicle == null || !canSwap)
                    ? null
                    : () {
                        if (swapSubscription != null) {
                          _handleSwap(
                            context,
                            userId,
                            plan,
                            _selectedVehicle!,
                            swapSubscription,
                          );
                        } else {
                          _handleSubscribe(
                            context,
                            userId,
                            plan,
                            _selectedVehicle!,
                          );
                        }
                      },
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
    Vehicle vehicle, // Receive selected vehicle
  ) async {
    // Double check category compatibility
    if (!_isPlanCompatible(plan, vehicle)) {
      AppToast.error(
        context,
        message: 'Este veículo não é compatível com o plano selecionado.',
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubscriptionCheckoutModal(
        plan: plan,
        userId: userId,
        selectedVehicle: vehicle, // Pass vehicle
        onSuccess: () => _handlePaymentSuccess(context, plan),
        onError: (error) {
          AppToast.error(context, message: 'Erro no pagamento: $error');
        },
      ),
    );
  }

  Future<void> _handleSwap(
    BuildContext context,
    String userId,
    SubscriptionPlan newPlan,
    Vehicle newVehicle,
    Subscriber activeSubscription,
  ) async {
    try {
      AppToast.info(context, message: 'Processando troca...');

      final repo = ref.read(subscriptionRepositoryProvider);

      // Load OLD plan to check price diff if needed (repository handles it, but we need the object)
      final oldPlan = await repo.getSubscriptionPlan(activeSubscription.planId);
      if (oldPlan == null) throw Exception('Plano atual não encontrado');

      await repo.swapSubscriptionVehicle(
        subscriptionId: activeSubscription.id,
        userId: userId,
        oldVehicleId: activeSubscription.vehicleId ?? '',
        newVehicleId: newVehicle.id,
        newVehiclePlate: newVehicle.plate,
        newVehicleCategory: newVehicle.type,
        newPlan: newPlan,
        oldPlan: oldPlan,
      );

      AppToast.success(context, message: 'Veículo trocado com sucesso!');

      // Refresh
      ref.invalidate(userSubscriptionsProvider);
      ref.invalidate(currentUserProfileProvider);

      setState(() {
        _showConfetti = true;
      });
    } catch (e) {
      AppToast.error(context, message: 'Erro ao trocar car: $e');
    }
  }

  // --- Helper Methods ---

  Widget _buildSwapInfoBanner(ThemeData theme, Subscriber currentSub) {
    final lastChange = currentSub.lastPlateChange;
    String message = 'Você pode trocar o carro da sua assinatura.';

    if (lastChange != null) {
      final daysSinceChange = DateTime.now().difference(lastChange).inDays;
      final remaining = 30 - daysSinceChange;
      if (remaining > 0) {
        message = 'Você poderá trocar de carro novamente em $remaining dias.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo de Troca de Veículo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelector(
    ThemeData theme,
    AsyncValue<List<Vehicle>> vehiclesAsync,
  ) {
    return vehiclesAsync.when(
      data: (vehicles) {
        if (vehicles.isEmpty) {
          return AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Você precisa de um veículo para assinar.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/add-vehicle'),
                  child: const Text('Adicionar Veículo'),
                ),
              ],
            ),
          );
        }

        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecione o Veículo',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Vehicle>(
                initialValue: _selectedVehicle,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                isExpanded: true,
                items: vehicles.map((v) {
                  return DropdownMenuItem(
                    value: v,
                    child: Text(
                      '${v.model} (${v.plate}) - ${v.type.toUpperCase()}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (vehicle) {
                  setState(() {
                    _selectedVehicle = vehicle;
                  });
                },
              ),
            ],
          ),
        );
      },
      loading: () => const ShimmerLoading.rectangular(height: 80),
      error: (_, __) => const Text('Erro ao carregar veículos'),
    );
  }

  List<SubscriptionPlan> _filterPlans(
    List<SubscriptionPlan> plans,
    Vehicle? vehicle,
  ) {
    if (vehicle == null) return plans;
    return plans.where((p) => _isPlanCompatible(p, vehicle)).toList();
  }

  bool _isPlanCompatible(SubscriptionPlan plan, Vehicle vehicle) {
    final vType = vehicle.type.toLowerCase();
    final pCategory = plan.category
        .toLowerCase(); // Ensure SubscriptionPlan has category

    if (pCategory == 'any' || pCategory.isEmpty) return true;

    // Strict filtering based on user request:
    // Sedan cannot see Hatch plans.
    // SUV cannot see Hatch or Sedan plans (usually).

    // Hatch/Compact -> Only Hatch plans (or Any)
    if (vType == 'hatch' || vType == 'compact') {
      return pCategory == 'hatch' || pCategory == 'compact';
    }

    // Sedan/Coupe -> Only Sedan plans (or Any)
    // CANNOT use Hatch plans.
    if (vType == 'sedan' || vType == 'coupe') {
      return pCategory == 'sedan' || pCategory == 'coupe';
    }

    // SUV/Pickup -> Only SUV plans (or Any)
    if (vType == 'suv' || vType == 'pickup' || vType == 'crossover') {
      return pCategory == 'suv' || pCategory == 'pickup';
    }

    // Default strict: types must match loosely
    return vType == pCategory;
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
      // Force refresh user profile to update subscriptionStatus
      ref.invalidate(authStateChangesProvider);
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(userSubscriptionsProvider); // Invalidate plural provider

      setState(() {
        _showConfetti = true;
      });

      AppToast.success(
        context,
        message: 'Assinatura do plano ${plan.name} realizada com sucesso!',
      );

      // Wait for animation and navigation update
      // Logic moved to build() to ensure robust redirect
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

  // --- Force Sync Logic ---
  bool _isSyncing = false;

  Future<void> _forceSyncSubscription(
    String subscriptionId,
    String? stripeSubId,
  ) async {
    if (_isSyncing) return;
    if (stripeSubId == null) {
      print("Cannot force sync: missing stripeSubscriptionId");
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      print("FORCE SYNC: Calling syncSubscriptionStatus for $stripeSubId");
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.syncSubscriptionStatus(stripeSubId);

      // After sync, invalidate providers to fetch fresh data
      ref.invalidate(userSubscriptionProvider);
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(authStateChangesProvider);

      print("FORCE SYNC: Success! Providers invalidated.");
    } catch (e) {
      print("FORCE SYNC: Failed - $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }
}
