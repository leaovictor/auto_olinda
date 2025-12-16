import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../domain/subscription_plan.dart';
import '../../../../common_widgets/atoms/primary_button.dart';

class PixPaymentSheet extends StatefulWidget {
  final SubscriptionPlan plan;
  final String userId;
  final String? couponId;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const PixPaymentSheet({
    required this.plan,
    required this.userId,
    required this.onSuccess,
    required this.onError,
    this.couponId,
    super.key,
  });

  @override
  State<PixPaymentSheet> createState() => _PixPaymentSheetState();
}

class _PixPaymentSheetState extends State<PixPaymentSheet> {
  bool _isLoading = true;
  bool _isSuccess = false;
  bool _isPolling = false;
  String? _error;
  String? _clientSecret;
  int? _amount;

  @override
  void initState() {
    super.initState();
    _createPixPayment();
  }

  Future<void> _createPixPayment() async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );

      final result = await functions
          .httpsCallable('createSubscriptionPixPayment')
          .call({
            'priceId': widget.plan.stripePriceId,
            'couponId': widget.couponId,
          });

      final data = result.data as Map<String, dynamic>;
      _clientSecret = data['clientSecret'] as String?;
      _amount = data['amount'] as int?;

      if (_clientSecret == null) {
        throw Exception('Falha ao criar pagamento PIX');
      }

      // Set publishable key
      Stripe.publishableKey = data['publishableKey'];

      // Confirm the payment intent with PIX method
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: _clientSecret!,
        data: PaymentMethodParams.fromJson({
          'paymentMethodType': 'Pix',
          'billingDetails': {'email': 'cliente@aquaclean.app'},
        }),
      );

      // Start polling for payment confirmation
      _startPollingForConfirmation();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error creating PIX payment: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _startPollingForConfirmation() {
    setState(() => _isPolling = true);
    _pollPaymentStatus();
  }

  Future<void> _pollPaymentStatus() async {
    if (!mounted) return;

    // Poll for up to 5 minutes (300 seconds)
    for (int i = 0; i < 60; i++) {
      if (!mounted || _isSuccess) return;

      await Future.delayed(const Duration(seconds: 5));

      try {
        // Check payment status by re-retrieving the payment intent
        final paymentIntent = await Stripe.instance.retrievePaymentIntent(
          _clientSecret!,
        );

        debugPrint('Polling: Payment status = ${paymentIntent.status}');

        if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
          if (mounted) {
            setState(() {
              _isSuccess = true;
              _isPolling = false;
            });
            await Future.delayed(const Duration(seconds: 2));
            widget.onSuccess();
          }
          return;
        } else if (paymentIntent.status == PaymentIntentsStatus.Canceled) {
          if (mounted) {
            setState(() => _isPolling = false);
            widget.onError('Pagamento cancelado');
          }
          return;
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    }

    // Timeout after 5 minutes
    if (mounted) {
      setState(() => _isPolling = false);
      widget.onError(
        'Tempo limite excedido. Verifique se o pagamento foi realizado.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (_isSuccess) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Pagamento Confirmado!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sua assinatura foi ativada.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Gerando código PIX...', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: theme.colorScheme.error, size: 64),
            const SizedBox(height: 16),
            Text(
              'Erro ao gerar PIX',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Tentar Novamente',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _createPixPayment();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }

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
              children: [
                Icon(
                  Icons.pix,
                  color: const Color(0xFF32BCAD), // PIX green color
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pagamento via PIX',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Valor a pagar:', style: theme.textTheme.titleMedium),
                  Text(
                    'R\$ ${(_amount != null ? _amount! / 100 : widget.plan.price).toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF32BCAD).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF32BCAD).withAlpha(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF32BCAD),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Como pagar',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF32BCAD),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(theme, '1', 'Abra o app do seu banco'),
                  _buildInstructionStep(theme, '2', 'Escolha pagar via PIX'),
                  _buildInstructionStep(
                    theme,
                    '3',
                    'Escaneie o QR Code ou copie o código',
                  ),
                  _buildInstructionStep(theme, '4', 'Confirme o pagamento'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Test mode notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.science,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modo de teste: Use o simulador da Stripe para aprovar o pagamento',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Polling status
            if (_isPolling)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aguardando confirmação do pagamento...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(ThemeData theme, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF32BCAD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
