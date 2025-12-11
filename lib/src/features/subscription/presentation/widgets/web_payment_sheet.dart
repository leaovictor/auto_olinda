import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../common_widgets/atoms/primary_button.dart';

class WebPaymentSheet extends StatefulWidget {
  final String clientSecret;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const WebPaymentSheet({
    required this.clientSecret,
    required this.onSuccess,
    required this.onError,
    super.key,
  });

  @override
  State<WebPaymentSheet> createState() => _WebPaymentSheetState();
}

class _WebPaymentSheetState extends State<WebPaymentSheet> {
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _cardComplete = false;

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
              'Pagamento Concluído!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finalizando agendamento...',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pagamento Seguro',
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
            const SizedBox(height: 8),
            Text(
              'Toque no campo abaixo para inserir os dados do cartão',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Card Field - Web version
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // This helps with focus issues on mobile web
                FocusScope.of(context).unfocus();
                Future.delayed(const Duration(milliseconds: 100), () {
                  FocusScope.of(context).requestFocus(FocusNode());
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 60,
                  child: CardField(
                    enablePostalCode: false,
                    countryCode: 'BR',
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Número do cartão',
                      hintStyle: TextStyle(color: theme.colorScheme.outline),
                    ),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                    onCardChanged: (details) {
                      final isComplete = details?.complete ?? false;
                      if (_cardComplete != isComplete) {
                        setState(() {
                          _cardComplete = isComplete;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test card hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Teste: 4242 4242 4242 4242 | MM/AA | CVC',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
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
                  'Processado com segurança por Stripe',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              text: _cardComplete ? 'Pagar Agora' : 'Preencha o cartão',
              isLoading: _isLoading,
              onPressed: _cardComplete ? _handlePayment : null,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    debugPrint('🔵 WebPaymentSheet: Starting payment...');
    setState(() => _isLoading = true);

    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      debugPrint(
        '🟢 WebPaymentSheet: Payment result - ${paymentIntent.status}',
      );

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        widget.onSuccess();
      } else if (paymentIntent.status == PaymentIntentsStatus.RequiresAction) {
        widget.onError('Ação necessária para completar o pagamento.');
      } else {
        widget.onError(
          'Pagamento não concluído. Status: ${paymentIntent.status.name}',
        );
      }
    } on StripeException catch (e) {
      debugPrint('❌ Stripe Error: ${e.error.localizedMessage}');
      widget.onError(e.error.localizedMessage ?? 'Erro desconhecido no Stripe');
    } catch (e, stackTrace) {
      debugPrint('❌ Payment Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      widget.onError('Erro ao processar pagamento: $e');
    } finally {
      if (mounted && !_isSuccess) {
        setState(() => _isLoading = false);
      }
    }
  }
}
