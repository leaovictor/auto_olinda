import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/atoms/app_loader.dart';
import '../../../../features/subscription/domain/subscription_plan.dart';
import '../../data/admin_repository.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_text_field.dart';

class PlansScreen extends ConsumerWidget {
  final bool showAppBar;
  const PlansScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(adminPlansProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: showAppBar
          ? AppBar(
              title: const Text(
                'Gerenciar Planos',
                style: AdminTheme.headingMedium,
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AdminTheme.textPrimary),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AdminTheme.bgDark.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            )
          : null,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
          boxShadow: [
            BoxShadow(
              color: AdminTheme.gradientPrimary[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showPlanDialog(context, ref),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: plansAsync.when(
          data: (plans) {
            if (plans.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum plano cadastrado.',
                  style: TextStyle(color: AdminTheme.textSecondary),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: showAppBar ? kToolbarHeight + 40 : 16,
                bottom: 80,
              ),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
                  child: ListTile(
                    title: Text(plan.name, style: AdminTheme.headingSmall),
                    subtitle: Text(
                      'R\$ ${plan.price.toStringAsFixed(2)} - ${plan.washesPerMonth == -1 ? "Ilimitado" : "${plan.washesPerMonth} lavagens/mês"}',
                      style: AdminTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () =>
                              _showPlanDialog(context, ref, plan: plan),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () =>
                              _confirmDelete(context, ref, plan.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: AppLoader()),
          error: (err, stack) => Center(
            child: Text(
              'Erro: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  void _showPlanDialog(
    BuildContext context,
    WidgetRef ref, {
    SubscriptionPlan? plan,
  }) {
    final nameController = TextEditingController(text: plan?.name);
    final priceController = TextEditingController(text: plan?.price.toString());
    // -1 for unlimited
    final washesController = TextEditingController(
      text: plan?.washesPerMonth.toString() ?? '4',
    );
    final stripePriceIdController = TextEditingController(
      text: plan?.stripePriceId,
    );
    final featuresController = TextEditingController(
      text: plan?.features.join(', '),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: Text(
          plan == null ? 'Novo Plano' : 'Editar Plano',
          style: AdminTheme.headingSmall,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminTextField(
                controller: nameController,
                label: 'Nome do Plano',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AdminTextField(
                      controller: priceController,
                      label: 'Preço (R\$)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AdminTextField(
                      controller: washesController,
                      label: 'Lavagens/Mês',
                      hint: '-1 para Ilimitado',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AdminTextField(
                controller: stripePriceIdController,
                label: 'Stripe Price ID',
              ),
              const SizedBox(height: 16),
              AdminTextField(
                controller: featuresController,
                label: 'Recursos (separados por vírgula)',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AdminTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newPlan = SubscriptionPlan(
                id: plan?.id ?? '',
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                washesPerMonth: int.tryParse(washesController.text) ?? 4,
                stripePriceId: stripePriceIdController.text,
                features: featuresController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
              );

              if (plan == null) {
                ref.read(adminRepositoryProvider).addPlan(newPlan);
              } else {
                ref.read(adminRepositoryProvider).updatePlan(newPlan);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.gradientPrimary[0],
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Excluir Plano', style: AdminTheme.headingSmall),
        content: const Text(
          'Tem certeza que deseja excluir este plano?',
          style: TextStyle(color: AdminTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AdminTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminRepositoryProvider).deletePlan(planId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
