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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pagamento Seguro',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: RepaintBoundary(
              child: CardField(autofocus: false, enablePostalCode: false),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Pagar Agora',
            isLoading: _isLoading,
            onPressed: _handlePayment,
          ),
          const SizedBox(height: 24),
          // Add extra padding for bottom safe area
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    print('Starting _handlePayment...');
    setState(() => _isLoading = true);

    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
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
      print('Stripe Error: ${e.error.localizedMessage}');
      print('Stripe Error Details: ${e.error}');
      widget.onError(e.error.localizedMessage ?? 'Erro desconhecido');
    } catch (e, stackTrace) {
      print('Payment Error: $e');
      print('Stack Trace: $stackTrace');
      widget.onError(e.toString());
    } finally {
      if (mounted && !_isSuccess) {
        setState(() => _isLoading = false);
      }
    }
  }
}
