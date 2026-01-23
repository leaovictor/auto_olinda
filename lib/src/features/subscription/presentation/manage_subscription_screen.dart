import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../../../features/subscription/domain/subscription_details.dart';
import '../../../features/subscription/domain/subscription_invoice.dart';
import '../data/subscription_repository.dart';
import '../../../shared/utils/app_toast.dart';

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
  List<SubscriptionInvoice> _invoices = [];
  bool _isLoadingInvoices = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    _fetchInvoices();
  }

  Future<void> _fetchDetails() async {
    try {
      if (widget.subscription.stripeSubscriptionId == null &&
          widget.subscription.type != 'promo') {
        setState(() => _isLoadingDetails = false);
        return;
      }

      if (widget.subscription.type == 'promo') {
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

  Future<void> _fetchInvoices() async {
    if (widget.subscription.type == 'promo') {
      setState(() => _isLoadingInvoices = false);
      return;
    }

    try {
      final invoices = await ref
          .read(subscriptionRepositoryProvider)
          .getSubscriptionInvoices();

      if (mounted) {
        setState(() {
          _invoices = invoices;
          _isLoadingInvoices = false;
        });
      }
    } catch (e) {
      print('Error fetching invoices: $e');
      if (mounted) {
        setState(() => _isLoadingInvoices = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPromo = widget.subscription.type == 'promo';

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoadingDetails
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userSubscriptionProvider);
                await _fetchDetails();
                await _fetchInvoices();
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Header Section with back button and status
                  _buildHeaderCard(displayDetails, isPromo),

                  const SizedBox(height: 8),

                  // Payment Method Card
                  if (!isPromo) _buildPaymentMethodCard(displayDetails),

                  const SizedBox(height: 8),

                  // Benefits Card
                  _buildBenefitsCard(displayDetails),

                  const SizedBox(height: 8),

                  // Payment History Card
                  if (!isPromo) _buildPaymentHistoryCard(),

                  const SizedBox(height: 8),

                  // Change Plan Card
                  if (!isPromo && !displayDetails.cancelAtPeriodEnd)
                    _buildChangePlanCard(),

                  const SizedBox(height: 16),

                  // Cancel/Reactivate Section
                  if (!isPromo) _buildCancelSection(displayDetails),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(SubscriptionDetails details, bool isPromo) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/plans');
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPromo
                          ? Colors.blue
                          : (details.cancelAtPeriodEnd
                                ? Colors.orange
                                : const Color(0xFF00A67E)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPromo
                          ? 'Cortesia'
                          : (details.cancelAtPeriodEnd ? 'Cancelado' : 'Ativo'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Plan Name
              Text(
                widget.currentPlan.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'R\$ ${widget.currentPlan.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Text(
                    '/mês',
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Stripe ID
              GestureDetector(
                onTap: () {
                  final stripeId =
                      widget.subscription.stripeSubscriptionId ??
                      widget.subscription.id;
                  Clipboard.setData(ClipboardData(text: stripeId));
                  AppToast.success(context, message: 'ID copiado!');
                },
                child: Text(
                  'stripeId: ${widget.subscription.stripeSubscriptionId ?? widget.subscription.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(SubscriptionDetails details) {
    final pm = details.paymentMethod;
    final hasCard = pm != null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Método de Pagamento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Icon(
                hasCard ? Icons.check_circle : Icons.radio_button_unchecked,
                color: hasCard
                    ? const Color(0xFF00A67E)
                    : const Color(0xFFCCCCCC),
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (hasCard) ...[
            // Sub-label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Método de Pagamento',
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF00A67E),
                  size: 18,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Card Details Row
            Row(
              children: [
                // Card Brand Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pm.brand.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: pm.brand.toLowerCase() == 'visa'
                          ? const Color(0xFF1A1F71)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Card Number and Expiry
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•••• ${pm.last4}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      '(Expira ${pm.expMonth.toString().padLeft(2, '0')}/${pm.expYear})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Stripe Logo
                const Text(
                  'stripe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF635BFF),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ] else ...[
            // No payment method warning
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCC80), width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Nenhum método de pagamento salvo',
                      style: TextStyle(fontSize: 13, color: Color(0xFF996E00)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(SubscriptionDetails details) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Benefícios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Icon(
                Icons.radio_button_unchecked,
                color: Color(0xFFCCCCCC),
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Benefits List
          ...widget.currentPlan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00A67E),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const Text(
            'Histórico de Pagamento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),

          const SizedBox(height: 16),

          if (_isLoadingInvoices)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_invoices.isEmpty)
            const Text(
              'Nenhum pagamento registrado',
              style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
            )
          else
            ..._invoices.take(5).map((invoice) => _buildInvoiceRow(invoice)),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(SubscriptionInvoice invoice) {
    final date = DateTime.fromMillisecondsSinceEpoch(invoice.created * 1000);
    final dateFormatted = DateFormat("MMM dd, yyyy", 'en_US').format(date);
    final amount = invoice.amountPaid / 100;
    final amountFormatted = 'R\$ ${amount.toStringAsFixed(2)}';
    final isPaid = invoice.status == 'paid';
    final isPending = invoice.status == 'open';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 3,
            child: Text(
              dateFormatted,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),

          // Amount (only for first row style)
          if (isPaid && invoice == _invoices.first)
            Expanded(
              flex: 2,
              child: Text(
                amountFormatted,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            )
          else
            const Expanded(flex: 2, child: SizedBox()),

          // Status Badge or Download Icon
          if (isPending) ...[
            const Text(
              'Failed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.file_download_outlined,
              size: 20,
              color: const Color(0xFFE53935),
            ),
          ] else if (isPaid) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00A67E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Pago',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (invoice.invoicePdf != null)
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(invoice.invoicePdf!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Color(0xFF00A67E),
                ),
              )
            else
              const Icon(
                Icons.file_download_outlined,
                size: 20,
                color: Color(0xFF666666),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangePlanCard() {
    final otherPlans = widget.availablePlans
        .where((plan) => plan.id != widget.currentPlan.id)
        .toList();

    if (otherPlans.isEmpty) return const SizedBox();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const Text(
            'Mudar de Plano',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Escolha um novo plano:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // List of plans
          ...otherPlans.map((plan) {
            final isUpgrade = plan.price > widget.currentPlan.price;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${plan.price.toStringAsFixed(2)} / mês',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF00A67E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _handleChangePlan(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUpgrade
                          ? const Color(0xFFFF6B00)
                          : Colors.white,
                      foregroundColor: isUpgrade
                          ? Colors.white
                          : const Color(0xFF333333),
                      side: isUpgrade
                          ? null
                          : const BorderSide(color: Color(0xFFDDDDDD)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      isUpgrade ? 'Upgrade' : 'Downgrade',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCancelSection(SubscriptionDetails details) {
    if (details.cancelAtPeriodEnd) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleReactivate,
          icon: const Icon(Icons.replay, size: 18),
          label: const Text('Reativar Assinatura'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A67E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      );
    }

    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : _handleCancel,
        child: const Text(
          'Cancelar Assinatura',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar Assinatura'),
        content: const Text(
          'Tem certeza que deseja cancelar a renovação automática? '
          'Sua assinatura continuará ativa até o final do período atual.',
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
      await _fetchDetails();
      if (!mounted) return;
      AppToast.success(
        context,
        message: 'Assinatura cancelada. Válida até o fim do período atual.',
      );
      ref.invalidate(userSubscriptionProvider);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, message: 'Erro ao cancelar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReactivate() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .reactivateSubscription(widget.subscription.id);
      await _fetchDetails();
      if (!mounted) return;
      AppToast.success(context, message: 'Assinatura reativada com sucesso!');
      ref.invalidate(userSubscriptionProvider);
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, message: 'Erro ao reativar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleChangePlan(SubscriptionPlan newPlan) async {
    final isUpgrade = newPlan.price > widget.currentPlan.price;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B00),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
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
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
