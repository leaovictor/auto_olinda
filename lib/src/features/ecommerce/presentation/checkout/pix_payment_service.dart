import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PixPaymentService {
  Future<void> handlePixPayment({
    required BuildContext context,
    required int amountInCents,
    String description = 'Pagamento via Pix',
  }) async {
    try {
      // 1. Call Cloud Function to get client_secret
      final result = await FirebaseFunctions.instance
          .httpsCallable('createPixPaymentIntent')
          .call({'amount': amountInCents, 'description': description});

      final data = result.data as Map<String, dynamic>;
      final clientSecret = data['clientSecret'] as String?;

      if (clientSecret == null) {
        throw Exception('Falha ao obter client_secret do servidor.');
      }

      // 2. Confirm Payment with Pix
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.fromJson({
          'paymentMethodType': 'Pix',
          'billingDetails': {'email': 'email@exemplo.com'},
        }),
      );

      // 3. Feedback to User (Note: Stripe SDK handles the UI for Pix mostly,
      // primarily showing the QR Code. Flow continues here after success/close)

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pagamento Pix iniciado! Verifique o app do seu banco.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no servidor: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on StripeException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no Stripe: ${e.error.localizedMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro desconhecido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
