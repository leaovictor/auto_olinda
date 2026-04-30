import 'package:aquaclean_mobile/src/features/subscription/domain/subscription_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/data/auth_repository.dart';
import '../../booking/data/vehicle_repository.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../dashboard/presentation/shell/client_shell.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/secondary_button.dart';
import '../../../common_widgets/molecules/user_avatar.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../admin/presentation/settings/admin_settings_screen.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../shared/widgets/app_footer.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final vehiclesAsync = ref.watch(userVehiclesProvider);
    final subscriptionAsync = ref.watch(userSubscriptionProvider);
    final plansAsync = ref.watch(activePlansProvider);
    final settingsAsync = ref.watch(adminSettingsProvider);
    final theme = Theme.of(context);

    // Resolve the real plan using stripePriceId lookup (handles inactive plans too)
    final planId = subscriptionAsync.valueOrNull?.planId ?? '';
    final resolvedPlanAsync = planId.isNotEmpty
        ? ref.watch(resolvedPlanProvider(planId))
        : const AsyncValue<SubscriptionPlan?>.data(null);

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

        final whatsappNumber =
            settingsAsync.valueOrNull?['whatsappSupportNumber'] as String?;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          floatingActionButton:
              whatsappNumber != null && whatsappNumber.isNotEmpty
              ? _buildWhatsAppButton(context, whatsappNumber)
              : null,
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

                  // Feedback Section
                  _buildSectionTitle(context, 'Fale Conosco'),
                  const SizedBox(height: 8),
                  Text(
                    'Sua opinião é muito importante para nós! Relate bugs, envie elogios ou sugira melhorias.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeedbackCard(
                          context,
                          icon: Icons.bug_report,
                          title: 'Reportar\nBug',
                          color: Colors.red.shade400,
                          onTap: () => _sendFeedbackEmail(
                            context,
                            'bug',
                            '🐛 Relato de Bug - CleanFlow',
                          ),
                        ).animate().fadeIn(delay: 100.ms).scale(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeedbackCard(
                          context,
                          icon: Icons.thumb_up,
                          title: 'Enviar\nElogio',
                          color: Colors.green.shade400,
                          onTap: () => _sendFeedbackEmail(
                            context,
                            'compliment',
                            '⭐ Elogio - CleanFlow',
                          ),
                        ).animate().fadeIn(delay: 200.ms).scale(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeedbackCard(
                          context,
                          icon: Icons.lightbulb_outline,
                          title: 'Sugerir\nMelhoria',
                          color: Colors.blue.shade400,
                          onTap: () => _sendFeedbackEmail(
                            context,
                            'suggestion',
                            '💡 Sugestão de Melhoria - CleanFlow',
                          ),
                        ).animate().fadeIn(delay: 300.ms).scale(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Subscription Section — only shown when there is an active subscription.
                  // Canceled subscriptions return null from userSubscriptionProvider
                  // (which filters by status: active/trialing), so the section is hidden.
                  subscriptionAsync.when(
                    data: (subscription) {
                      // Hide entirely if no active subscription
                      if (subscription == null) return const SizedBox.shrink();

                      final isActive =
                          subscription.status == 'active' ||
                          subscription.status == 'trialing';

                      // Also hide if somehow a canceled doc slipped through
                      if (!isActive) return const SizedBox.shrink();

                      // Use the resolved plan (fetched by stripePriceId)
                      final currentPlan = resolvedPlanAsync.valueOrNull;
                      final isPlanLoading = resolvedPlanAsync.isLoading;

                      final planName =
                          currentPlan?.name ??
                          (isPlanLoading ? '...' : subscription.planId);

                      // All active plans for the "change plan" picker
                      final allPlans = plansAsync.valueOrNull ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(context, 'Assinatura'),
                          const SizedBox(height: 16),
                          AppCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Assinatura Ativa',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[800],
                                                ),
                                          ),
                                          Text(
                                            'Plano: $planName',
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
                                isPlanLoading
                                    ? const SizedBox(
                                        height: 40,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : SecondaryButton(
                                        text: 'Gerenciar Assinatura',
                                        onPressed: () {
                                          final plan =
                                              currentPlan ??
                                              SubscriptionPlan(
                                                id: subscription.planId,
                                                name: planName,
                                                price: 0,
                                                features: [],
                                                stripePriceId:
                                                    subscription.planId,
                                              );
                                          context.push(
                                            '/manage-subscription',
                                            extra: {
                                              'subscription': subscription,
                                              'currentPlan': plan,
                                              'availablePlans': allPlans,
                                            },
                                          );
                                        },
                                      ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideX(),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                    loading: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Assinatura'),
                        const SizedBox(height: 16),
                        const ShimmerLoading.rectangular(height: 150),
                        const SizedBox(height: 32),
                      ],
                    ),
                    error: (err, stack) => const SizedBox.shrink(),
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
                  const SizedBox(height: 24),
                  const AppFooter(),
                  const SizedBox(height: 100),
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

  Widget _buildFeedbackCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFeedbackEmail(
    BuildContext context,
    String feedbackType,
    String subject,
  ) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'contato@victorleao.dev.br',
      query: 'subject=${Uri.encodeComponent(subject)}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Não foi possível abrir o cliente de e-mail. '
                'Por favor, envie um e-mail manualmente para contato@victorleao.dev.br',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir e-mail: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildWhatsAppButton(BuildContext context, String phoneNumber) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25D366).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'whatsapp_support_button',
        backgroundColor: const Color(0xFF25D366),
        onPressed: () => _openWhatsApp(context, phoneNumber),
        child: const Icon(Icons.chat, color: Colors.white, size: 28),
      ),
    ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms);
  }

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    // Remove non-digit characters
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    final url = Uri.parse('https://wa.me/$cleanPhone');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppToast.error(context, message: 'Não foi possível abrir o WhatsApp');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, message: 'Erro ao abrir WhatsApp: $e');
      }
    }
  }
}
