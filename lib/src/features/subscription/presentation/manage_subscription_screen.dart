import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../../../features/subscription/domain/subscription_details.dart';
import '../data/subscription_repository.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';

import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../shared/utils/app_toast.dart';
import 'widgets/subscription_status_card.dart';
import 'widgets/subscription_payment_method_card.dart';
import 'widgets/subscription_benefits_list.dart';

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
  SubscriptionDetails? _details;
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      if (widget.subscription.stripeSubscriptionId == null &&
          widget.subscription.type != 'promo') {
        // Legacy or issue, skip details
        setState(() => _isLoadingDetails = false);
        return;
      }

      if (widget.subscription.type == 'promo') {
        // Promo subs might not have stripe details like cards
        setState(() => _isLoadingDetails = false);
        return;
      }

      final details = await ref
          .read(subscriptionRepositoryProvider)
          .getSubscriptionDetails(widget.subscription.id);

      if (mounted) {
        setState(() {
          _details = details;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      print('Error fetching subscription details: $e');
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPromo = widget.subscription.type == 'promo';
    // Use details if available, otherwise fallback to subscription object
    // For promo, we might construct a fake details object or handle it in UI

    final displayDetails =
        _details ??
        SubscriptionDetails(
          status: widget.subscription.status,
          cancelAtPeriodEnd: widget.subscription.cancelAtPeriodEnd ?? false,
          currentPeriodEnd:
              widget.subscription.endDate?.millisecondsSinceEpoch != null
              ? (widget.subscription.endDate!.millisecondsSinceEpoch ~/ 1000)
              : (DateTime.now()
                        .add(const Duration(days: 30))
                        .millisecondsSinceEpoch ~/
                    1000),
          paymentMethod: null,
        );

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/plans');
            }
          },
        ),
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userSubscriptionProvider);
          await _fetchDetails();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoadingDetails)
                const Center(child: CircularProgressIndicator())
              else ...[
                // Status Card
                SubscriptionStatusCard(
                  plan: widget.currentPlan,
                  details: displayDetails,
                  isPromo: isPromo,
                ),

                const SizedBox(height: 24),

                // Benefits
                SubscriptionBenefitsList(benefits: widget.currentPlan.features),
                // If plan.features is List<String>, pass it. Check SubscriptionPlan model.
                // Step 114 shows features is List<String>, but argument name in widget is 'benefits'.
                // I need to update the widget or the call.
                // Widget (Step 118) has 'final List<String> benefits;' input.
                const SizedBox(height: 24),

                // Payment Method (Only for non-promo)
                if (!isPromo)
                  SubscriptionPaymentMethodCard(
                    paymentMethod: displayDetails.paymentMethod,
                    onUpdatePressed: () {
                      // TODO: Navigate to update payment method screen
                      // Or show a helpful toast for now
                      AppToast.info(
                        context,
                        message: 'Função de atualizar cartão em breve.',
                      );
                    },
                  ),

                const SizedBox(height: 24),

                // Copy ID Button for Support
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar ID da Assinatura (Suporte)'),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: widget.subscription.id),
                      );
                      AppToast.success(context, message: 'ID copiado!');
                      print('Copied ID: ${widget.subscription.id}');
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                if (!isPromo) ...[
                  if (displayDetails.cancelAtPeriodEnd) ...[
                    PrimaryButton(
                      text: 'REATIVAR ASSINATURA',
                      icon: Icons.replay,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleReactivate,
                    ),
                  ] else ...[
                    // Danger Zone / Cancel
                    // Make it discrete as requested
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _handleCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Cancelar Assinatura'),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 32),

                // Other Plans Section (Upgrade/Downgrade)
                if (!displayDetails.cancelAtPeriodEnd && !isPromo) ...[
                  _buildHeadline(context, 'Mudar de Plano'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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

      // Refresh details to update UI
      await _fetchDetails();

      if (!mounted) return;

      AppToast.success(
        context,
        message: 'Assinatura cancelada. Válida até o fim do período atual.',
      );

      // context.pop(); // Don't pop, let them see the status change
      ref.invalidate(userSubscriptionProvider);
    } catch (e) {
      if (!mounted) return;

      AppToast.error(context, message: 'Erro ao cancelar: $e');
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

      // Refresh details
      await _fetchDetails();

      if (!mounted) return;

      AppToast.success(context, message: 'Assinatura reativada com sucesso!');

      // context.pop();
      ref.invalidate(userSubscriptionProvider);
    } catch (e) {
      if (!mounted) return;

      AppToast.error(context, message: 'Erro ao reativar: $e');
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

      await _fetchDetails();

      if (!mounted) return;

      AppToast.success(
        context,
        message: 'Plano alterado para ${newPlan.name} com sucesso!',
      );

      context.pop();
      ref.invalidate(userSubscriptionProvider);
    } catch (e) {
      if (!mounted) return;

      AppToast.error(context, message: 'Erro ao alterar plano: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
