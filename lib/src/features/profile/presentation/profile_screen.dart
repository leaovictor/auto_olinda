import 'package:aquaclean_mobile/src/features/subscription/domain/subscription_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/data/auth_repository.dart';
import '../../booking/data/vehicle_repository.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../subscription/presentation/manage_subscription_screen.dart';
import '../../dashboard/presentation/shell/client_shell.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../common_widgets/atoms/secondary_button.dart';
import '../../../common_widgets/molecules/user_avatar.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../shared/widgets/app_version_display.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final vehiclesAsync = ref.watch(userVehiclesProvider);
    final subscriptionAsync = ref.watch(userSubscriptionProvider);
    final plansAsync = ref.watch(activePlansProvider);
    final theme = Theme.of(context);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: AppRefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentUserProfileProvider);
                await Future.delayed(const Duration(seconds: 1));
              },
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 500, // Ensure scrollable area
                  child: Center(
                    child: Text(
                      'Usuário não autenticado. Arraste para atualizar.',
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: AppRefreshIndicator(
            onRefresh: () async {
              // Note: Do NOT invalidate currentUserProfileProvider here.
              // Invalidating it recreates the Stream which temporarily yields null,
              // causing the user to briefly appear as "unauthenticated".
              ref.invalidate(userVehiclesProvider);
              ref.invalidate(userSubscriptionProvider);
              // Wait a bit to show the loading indicator
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and menu icon on the right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Meu Perfil',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () {
                          final toggle = ref.read(drawerToggleProvider);
                          toggle?.call();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // User Info Card
                  AppCard(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        UserAvatar(
                          photoUrl: user.photoUrl,
                          name: user.displayName ?? user.email,
                          radius: 32,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? 'Usuário',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Membro desde 2024',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.push('/edit-profile'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Perfil'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Actions
                  _buildSectionTitle(context, 'Acesso Rápido'),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () => context.push('/my-bookings'),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        'Meus Agendamentos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Ver histórico e status',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideX(),
                  const SizedBox(height: 32),

                  // Subscription Section
                  _buildSectionTitle(context, 'Assinatura'),
                  const SizedBox(height: 16),
                  subscriptionAsync.when(
                    data: (subscription) {
                      final isActive =
                          subscription != null &&
                          subscription.status == 'active';

                      String planName = subscription?.planId ?? '';
                      final plans = plansAsync.valueOrNull;

                      SubscriptionPlan? currentPlan;
                      if (isActive && plans != null) {
                        try {
                          currentPlan = plans.firstWhere(
                            (p) => p.stripePriceId == subscription.planId,
                            orElse: () => plans.firstWhere(
                              (p) => p.id == subscription.planId,
                              orElse: () => SubscriptionPlan(
                                id: 'unknown',
                                name: planName,
                                price: 0,
                                features: [],
                              ),
                            ),
                          );
                          planName = currentPlan.name;
                        } catch (e) {
                          debugPrint('Error resolving plan name: $e');
                        }
                      }

                      return AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isActive ? Icons.check_circle : Icons.star,
                                  color: isActive ? Colors.green : Colors.amber,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isActive
                                            ? 'Assinatura Ativa'
                                            : 'Seja Premium',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isActive
                                                  ? Colors.green[800]
                                                  : theme.colorScheme.primary,
                                            ),
                                      ),
                                      Text(
                                        isActive
                                            ? 'Plano: $planName'
                                            : 'Descontos exclusivos e prioridade.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            isActive
                                ? SecondaryButton(
                                    text: 'Gerenciar Assinatura',
                                    onPressed: () {
                                      if (currentPlan != null &&
                                          plans != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ManageSubscriptionScreen(
                                                  subscription: subscription!,
                                                  currentPlan: currentPlan!,
                                                  availablePlans: plans,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : PrimaryButton(
                                    text: 'VER PLANOS',
                                    onPressed: () => context.push('/plans'),
                                  ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX();
                    },
                    loading: () =>
                        const ShimmerLoading.rectangular(height: 150),
                    error: (err, stack) => Text('Erro: $err'),
                  ),

                  const SizedBox(height: 32),

                  // Vehicles Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(context, 'Meus Veículos'),
                      TextButton.icon(
                        onPressed: () => context.push('/add-vehicle'),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  vehiclesAsync.when(
                    data: (vehicles) {
                      if (vehicles.isEmpty) {
                        return AppCard(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'Nenhum veículo cadastrado.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vehicles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return AppCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        vehicle.type == 'suv'
                                            ? Icons.directions_car
                                            : Icons.local_taxi,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${vehicle.brand} ${vehicle.model}',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            vehicle.plate,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: theme.colorScheme.error,
                                      ),
                                      onPressed: () {
                                        // Delete logic
                                      },
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(delay: (300 + 50 * index).ms)
                              .slideX();
                        },
                      );
                    },
                    loading: () =>
                        const ShimmerLoading.rectangular(height: 100),
                    error: (err, stack) => Center(child: Text('Erro: $err')),
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(authRepositoryProvider).signOut();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair da Conta'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(child: AppVersionDisplay()),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '© ${DateTime.now().year} Victor Leão. Todos os direitos reservados.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Erro ao carregar perfil: $err'))),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
