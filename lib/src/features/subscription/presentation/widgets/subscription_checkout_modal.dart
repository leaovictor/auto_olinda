import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../domain/subscription_plan.dart';
import '../../../profile/domain/vehicle.dart';
import '../../data/subscription_repository.dart';
import '../../../ecommerce/data/coupon_repository.dart';
import '../../../ecommerce/domain/coupon.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../../shared/utils/app_toast.dart';
import 'web_payment_sheet.dart';
import 'pix_payment_sheet.dart';
import '../../../auth/data/auth_repository.dart';

enum PaymentMethod { card, pix }

class SubscriptionCheckoutModal extends ConsumerStatefulWidget {
  final SubscriptionPlan plan;
  final String userId;
  final Vehicle selectedVehicle;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const SubscriptionCheckoutModal({
    required this.plan,
    required this.userId,
    required this.selectedVehicle,
    required this.onSuccess,
    required this.onError,
    super.key,
  });

  @override
  ConsumerState<SubscriptionCheckoutModal> createState() =>
      _SubscriptionCheckoutModalState();
}

class _SubscriptionCheckoutModalState
    extends ConsumerState<SubscriptionCheckoutModal> {
  PaymentMethod _selectedMethod = PaymentMethod.card;
  bool _isLoading = false;

  // Coupon state
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _cpfController =
      TextEditingController(); // CPF Controller
  String? _appliedCouponId;
  double _discountAmount = 0;
  bool _isValidatingCoupon = false;

  @override
  void dispose() {
    _couponController.dispose();
    _cpfController.dispose(); // Dispose CPF
    super.dispose();
  }

  double get _finalPrice => widget.plan.price - _discountAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Watch current user profile to check for CPF
    final userAsync = ref.watch(currentUserProfileProvider);
    final user = userAsync.value;
    final bool needsCpf =
        user != null && (user.cpf == null || user.cpf!.isEmpty);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_checkout,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Resumo da Compra',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Plan Summary
            _buildPlanSummary(theme),
            const SizedBox(height: 20),

            // CPF Input (If needed)
            if (needsCpf) ...[
              Text(
                'Dados do Titular',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error, // Highlight requirement
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CPF (Obrigatório)',
                  hintText: '000.000.000-00',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Coupon Section
            _buildCouponSection(theme),
            const SizedBox(height: 20),

            // Price Summary
            _buildPriceSummary(theme),
            const SizedBox(height: 24),

            // Payment Method Selection
            _buildPaymentMethodSelector(theme),
            const SizedBox(height: 24),

            // Action Button
            PrimaryButton(
              text: _selectedMethod == PaymentMethod.card
                  ? 'Pagar com Cartão'
                  : 'Pagar com PIX',
              isLoading: _isLoading,
              onPressed: _isLoading
                  ? null
                  : () => _handlePayment(needsCpf, user),
            ),
            const SizedBox(height: 16),

            // Security info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 14,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pagamento seguro processado por Stripe',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ... [Existing helper methods: _buildPlanSummary, _buildCouponSection, _buildPriceSummary, _buildPaymentMethodSelector, _validateCoupon, _clearCoupon] ...

  Future<void> _handlePayment(bool needsCpf, dynamic user) async {
    setState(() => _isLoading = true);

    try {
      // 0. Validate and Save CPF if needed
      if (needsCpf) {
        final cpf = _cpfController.text.trim();
        if (cpf.isEmpty || cpf.length < 11) {
          // Simple length check
          AppToast.error(context, message: 'Por favor, informe um CPF válido.');
          setState(() => _isLoading = false);
          return;
        }

        // Update user profile
        if (user != null) {
          final updatedUser = user.copyWith(cpf: cpf);
          await ref.read(authRepositoryProvider).updateUserProfile(updatedUser);
        }
      }

      // Check connectivity
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

      if (_selectedMethod == PaymentMethod.pix) {
        // PIX payment flow
        setState(() => _isLoading = false);

        if (!context.mounted) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          builder: (context) => PixPaymentSheet(
            plan: widget.plan,
            userId: widget.userId,
            couponId: _appliedCouponId,
            vehicleId: widget.selectedVehicle.id,
            vehiclePlate: widget.selectedVehicle.plate,
            vehicleCategory: widget.selectedVehicle.type,
            onSuccess: () {
              Navigator.pop(context); // Close PixPaymentSheet
              Navigator.pop(context); // Close CheckoutModal
              widget.onSuccess();
            },
            onError: (error) {
              Navigator.pop(context); // Close PixPaymentSheet
              widget.onError(error);
            },
          ),
        );
        return;
      }

      // Card payment flow
      final repository = ref.read(subscriptionRepositoryProvider);
      final intentData = await repository.createSubscriptionIntent(
        widget.userId,
        widget.plan,
        couponId: _appliedCouponId,
        vehicleId: widget.selectedVehicle.id,
        vehiclePlate: widget.selectedVehicle.plate,
        vehicleCategory: widget.selectedVehicle.type,
      );

      Stripe.publishableKey = intentData['publishableKey'];

      if (!context.mounted) return;
      setState(() => _isLoading = false);

      if (kIsWeb) {
        // Web: Show WebPaymentSheet
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => WebPaymentSheet(
            clientSecret: intentData['paymentIntent'],
            onSuccess: () {
              Navigator.pop(context); // Close WebPaymentSheet
              Navigator.pop(context); // Close CheckoutModal
              widget.onSuccess();
            },
            onError: (error) {
              Navigator.pop(context); // Close WebPaymentSheet
              widget.onError(error);
            },
          ),
        );
      } else {
        // Mobile: Native Payment Sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            customFlow: false,
            merchantDisplayName: 'AquaClean',
            paymentIntentClientSecret: intentData['paymentIntent'],
            setupIntentClientSecret: intentData['setupIntent'],
            customerEphemeralKeySecret: intentData['ephemeralKey'],
            customerId: intentData['customer'],
            style: ThemeMode.light,
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        if (!context.mounted) return;
        Navigator.pop(context); // Close CheckoutModal
        widget.onSuccess();
      }
    } catch (e) {
      if (!context.mounted) return;
      if (e is StripeException) {
        widget.onError(e.error.localizedMessage ?? 'Erro no pagamento');
      } else {
        widget.onError('Erro ao processar pagamento: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPlanSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.plan.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'MENSAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Show first 3 features
          ...widget.plan.features
              .take(3)
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (widget.plan.features.length > 3)
            Text(
              '+${widget.plan.features.length - 3} benefícios',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cupom de desconto',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                decoration: InputDecoration(
                  hintText: 'Digite o código',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  isDense: true,
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
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isLoading || _isValidatingCoupon
                    ? null
                    : () => _validateCoupon(context),
                child: _isValidatingCoupon
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Aplicar'),
              ),
            ),
          ],
        ),
        if (_appliedCouponId != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cupom aplicado! -R\$ ${_discountAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plano ${widget.plan.name}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                'R\$ ${widget.plan.price.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          if (_discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Desconto',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
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
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'R\$ ${_finalPrice.toStringAsFixed(2)}/mês',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forma de pagamento',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PaymentMethodCard(
                icon: Icons.credit_card,
                label: 'Cartão',
                isSelected: _selectedMethod == PaymentMethod.card,
                onTap: () =>
                    setState(() => _selectedMethod = PaymentMethod.card),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentMethodCard(
                icon: Icons.pix,
                label: 'PIX',
                isSelected: _selectedMethod == PaymentMethod.pix,
                onTap: () =>
                    setState(() => _selectedMethod = PaymentMethod.pix),
                badge: 'Em breve',
                isDisabled: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _validateCoupon(BuildContext context) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidatingCoupon = true);

    try {
      final result = await ref
          .read(couponRepositoryProvider)
          .validateCoupon(
            code: code,
            applicableTo: CouponApplicableTo.subscriptions,
            amount: widget.plan.price,
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
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final bool isDisabled;

  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected && !isDisabled
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected && !isDisabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: isSelected && !isDisabled ? 2 : 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isSelected && !isDisabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected && !isDisabled
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected && !isDisabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (badge != null)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
