import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

class PaymentService {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  Future<bool> initPaymentSheet(double amount) async {
    try {
      // 1. Call Cloud Function to get payment intent
      final callable = _functions.httpsCallable('createBookingPaymentIntent');
      final result = await callable.call({'amount': amount, 'currency': 'brl'});

      final data = result.data as Map<String, dynamic>;

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'AquaClean',
          paymentIntentClientSecret: data['paymentIntent'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['customer'],
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF0066FF), // AquaClean Primary Blue
            ),
          ),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error initializing Payment Sheet: $e');
      return false;
    }
  }

  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      debugPrint('Error presenting Payment Sheet: $e');
      return false;
    } catch (e) {
      debugPrint('Error presenting Payment Sheet: $e');
      return false;
    }
  }
}
