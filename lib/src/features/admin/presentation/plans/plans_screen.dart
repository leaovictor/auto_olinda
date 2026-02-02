import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/atoms/app_loader.dart';
import '../../../../features/subscription/domain/subscription_plan.dart';
import '../../data/admin_repository.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_text_field.dart';
import '../../../auth/data/auth_repository.dart';

class PlansScreen extends ConsumerWidget {
  final bool showAppBar;
  const PlansScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribersAsync = ref.watch(subscribersProvider);
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
              color: AdminTheme.gradientPrimary[0].withValues(alpha: 0.3),
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

                // Count active subscribers for this plan
                final subscriberCount = subscribersAsync.when(
                  data: (subs) => subs
                      .where(
                        (s) =>
                            s.planId == plan.id &&
                            (s.status == 'active' || s.status == 'trialing'),
                      )
                      .length,
                  loading: () => 0,
                  error: (_, __) => 0,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AdminTheme.glassmorphicDecoration(
                    opacity: plan.isActive ? 0.6 : 0.3, // Dim if inactive
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: AdminTheme.headingSmall.copyWith(
                              decoration: plan.isActive
                                  ? null
                                  : TextDecoration.lineThrough,
                              color: plan.isActive
                                  ? AdminTheme.textPrimary
                                  : AdminTheme.textSecondary,
                            ),
                          ),
                        ),
                        if (!plan.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Text(
                              'SUSPENSO',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${plan.price.toStringAsFixed(2)} - ${plan.washesPerMonth == -1 ? "Ilimitado" : "${plan.washesPerMonth} lavagens/mês"}',
                          style: AdminTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 14,
                              color: AdminTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$subscriberCount assinantes ativos',
                              style: const TextStyle(
                                color: AdminTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick toggle for Active Status
                        Switch(
                          value: plan.isActive,
                          activeThumbColor: Colors.green,
                          activeTrackColor: Colors.green.withValues(alpha: 0.3),
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.withValues(
                            alpha: 0.3,
                          ),
                          onChanged: (val) {
                            final updatedPlan = plan.copyWith(isActive: val);
                            ref
                                .read(adminRepositoryProvider)
                                .updatePlan(updatedPlan);
                          },
                        ),
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
    String selectedCategory = plan?.category.isNotEmpty == true
        ? plan!.category
              .toLowerCase() // Ensure lowercase
        : 'any';
    final categories = ['hatch', 'sedan', 'suv', 'pickup', 'moto', 'any'];

    // Validate initialization - fallback to 'any' if category not found in list
    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'any';
    }

    bool isActive = plan?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: AdminTheme.inputDecoration(
                      label: 'Categoria do Veículo',
                    ),
                    dropdownColor: AdminTheme.bgCard,
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat.toUpperCase(),
                          style: const TextStyle(color: AdminTheme.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedCategory = val;
                        });
                      }
                    },
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
                  const SizedBox(height: 16),
                  // Active Status Checkbox
                  CheckboxListTile(
                    title: const Text(
                      'Plano Ativo (Visível no App)',
                      style: TextStyle(color: AdminTheme.textPrimary),
                    ),
                    value: isActive,
                    activeColor: AdminTheme.gradientPrimary[0],
                    checkColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setState(() {
                        isActive = val ?? true;
                      });
                    },
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
                  final user = ref.read(currentUserProfileProvider).valueOrNull;
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
                    category: selectedCategory,
                    isActive: isActive,
                    tenantId: user?.tenantId ?? '',
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
          );
        },
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
