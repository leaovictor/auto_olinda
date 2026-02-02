import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../domain/tenant.dart';
import '../../subscription/domain/subscription_plan.dart';
import '../../admin/data/admin_repository.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../common_widgets/atoms/app_loader.dart';

class PublicLandingPage extends ConsumerWidget {
  final Tenant tenant;

  const PublicLandingPage({super.key, required this.tenant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: We need a provider that specifically filters plans for THIS tenant
    // For now, let's use a temporary provider or just the adminPlansProvider
    // if we are sure the current user context is correct (but this is public!)

    // We'll use the repository directly to fetch plans for this tenant
    final plansAsync = ref.watch(tenantPlansProvider(tenant.id));
    final theme = Theme.of(context);
    final primaryColor = Color(
      int.parse(tenant.branding.primaryColor.replaceAll('#', '0xFF')),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            if (tenant.branding.logoUrl != null)
              Image.network(tenant.branding.logoUrl!, height: 32)
            else
              Icon(Icons.waves, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              tenant.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login Cliente'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO SECTION
            Container(
              width: double.infinity,
              color: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Text(
                        'Cuidado Especial para seu Veículo',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 24),
                      Text(
                        'Assine nossos planos e garanta seu carro sempre limpo em ${tenant.name}. Praticidade, qualidade e economia.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 250,
                        height: 56,
                        child: PrimaryButton(
                          text: 'VER PLANOS',
                          onPressed: () {
                            // Scroll to plans
                          },
                          backgroundColor: Colors.white,
                          textColor: primaryColor,
                        ),
                      ).animate().scale(delay: 500.ms),
                    ],
                  ),
                ),
              ),
            ),

            // PLANS SECTION
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Nossos Planos Mensais',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  plansAsync.when(
                    data: (plans) {
                      if (plans.isEmpty) {
                        return const Center(
                          child: Text('Nenhum plano disponível no momento.'),
                        );
                      }
                      return Wrap(
                        spacing: 32,
                        runSpacing: 32,
                        alignment: WrapAlignment.center,
                        children: plans
                            .map(
                              (plan) => _buildPricingCard(
                                context,
                                plan,
                                primaryColor,
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const AppLoader(),
                    error: (err, _) => Text('Erro ao carregar planos: $err'),
                  ),
                ],
              ),
            ),

            // FOOTER
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(48),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    tenant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Powered by LavaFlow',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    SubscriptionPlan plan,
    Color primaryColor,
  ) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            plan.name.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'R\$ ${plan.price.toInt()}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const Text('/mês', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 32),
          ...plan.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'ASSINAR AGORA',
              onPressed: () {
                context.push('/signup?planId=${plan.id}&tenantId=${tenant.id}');
              },
              backgroundColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Provider for fetching plans of a specific tenant
final tenantPlansProvider =
    StreamProvider.family<List<SubscriptionPlan>, String>((ref, tenantId) {
      return ref.watch(adminRepositoryProvider).getPlans(tenantId);
    });
