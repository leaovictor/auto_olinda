import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../data/subscription_repository.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import '../../../common_widgets/atoms/secondary_button.dart';

class ManageSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscriber subscription;
  final SubscriptionPlan currentPlan;
  final List<SubscriptionPlan> availablePlans;

  const ManageSubscriptionScreen({
    required this.subscription,
    required this.currentPlan,
    required this.availablePlans,
    super.key,
  });

  @override
  ConsumerState<ManageSubscriptionScreen> createState() =>
      _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState
    extends ConsumerState<ManageSubscriptionScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCancelPending = widget.subscription.cancelAtPeriodEnd ?? false;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Gerenciar Assinatura',
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
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Plan Card
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plano Atual',
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
                          color: isCancelPending
                              ? Colors.orange.withAlpha(30)
                              : Colors.green.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCancelPending
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                        child: Text(
                          isCancelPending ? 'CANCELAMENTO PENDENTE' : 'ATIVO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isCancelPending
                                ? Colors.orange
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.currentPlan.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${widget.currentPlan.price.toStringAsFixed(2)} / mês',
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
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(widget.subscription.startDate),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    'Próxima Renovação',
                    DateFormat('dd/MM/yyyy').format(
                      widget.subscription.endDate ??
                          widget.subscription.startDate.add(
                            const Duration(days: 30),
                          ),
                    ),
                  ),
                  if (isCancelPending) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'Cancelamento em',
                      DateFormat('dd/MM/yyyy').format(
                        widget.subscription.endDate ??
                            widget.subscription.startDate.add(
                              const Duration(days: 30),
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (isCancelPending) ...[
              PrimaryButton(
                text: 'REATIVAR ASSINATURA',
                icon: Icons.replay,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleReactivate,
              ),
            ] else ...[
              SecondaryButton(
                text: 'Pausar Renovação / Cancelar',
                icon: Icons.cancel_outlined,
                onPressed: _isLoading ? null : _handleCancel,
              ),
            ],

            const SizedBox(height: 32),

            // Other Plans Section
            if (!isCancelPending) ...[
              Text(
                'Outros Planos Disponíveis',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.availablePlans
                  .where((plan) => plan.id != widget.currentPlan.id)
                  .map(
                    (plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPlanChangeCard(context, plan),
                    ),
                  ),
            ],
          ],
        ),
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

  Widget _buildPlanChangeCard(BuildContext context, SubscriptionPlan plan) {
    final theme = Theme.of(context);
    final isUpgrade = plan.price > widget.currentPlan.price;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${plan.price.toStringAsFixed(2)} / mês',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _handleChangePlan(plan),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUpgrade
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
            ),
            child: Text(
              isUpgrade ? 'Upgrade' : 'Downgrade',
              style: TextStyle(
                color: isUpgrade
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: const Text(
          'Tem certeza que deseja cancelar a renovação automática? '
          'Sua assinatura continuará ativa e você terá acesso a todos os benefícios até o final do período atual. '
          'Isso funciona como uma "pausa" na cobrança.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .cancelSubscription(widget.subscription.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Assinatura cancelada. Válida até o fim do período atual.',
          ),
        ),
      );

      context.pop();
      ref.invalidate(userSubscriptionProvider);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleReactivate() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .reactivateSubscription(widget.subscription.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assinatura reativada com sucesso!')),
      );

      context.pop();
      ref.invalidate(userSubscriptionProvider);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao reativar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleChangePlan(SubscriptionPlan newPlan) async {
    final isUpgrade = newPlan.price > widget.currentPlan.price;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isUpgrade ? 'Upgrade' : 'Downgrade'} de Plano'),
        content: Text(
          'Deseja alterar de ${widget.currentPlan.name} para ${newPlan.name}? '
          '${isUpgrade ? 'Você será cobrado proporcionalmente pela mudança.' : 'Um crédito proporcional será aplicado na próxima fatura.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      // Debug logging
      print('DEBUG: Changing plan');
      print('DEBUG: subscription.id = ${widget.subscription.id}');
      print('DEBUG: newPlan.stripePriceId = ${newPlan.stripePriceId}');
      print('DEBUG: newPlan.name = ${newPlan.name}');

      // Validate parameters
      if (widget.subscription.id.isEmpty) {
        throw Exception('Subscription ID is empty');
      }
      if (newPlan.stripePriceId.isEmpty) {
        throw Exception('Stripe Price ID is empty for plan ${newPlan.name}');
      }

      await ref
          .read(subscriptionRepositoryProvider)
          .changeSubscriptionPlan(
            widget.subscription.id,
            newPlan.stripePriceId,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plano alterado para ${newPlan.name} com sucesso!'),
        ),
      );

      context.pop();
      ref.invalidate(userSubscriptionProvider);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar plano: $e'),
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
