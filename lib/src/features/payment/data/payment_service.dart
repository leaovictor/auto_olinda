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

  Future<Map<String, dynamic>> createPaymentIntent(double amount) async {
    debugPrint(
      '🔵 PaymentService: Creating payment intent for amount: $amount',
    );
    final callable = _functions.httpsCallable('createBookingPaymentIntent');
    final result = await callable.call({'amount': amount, 'currency': 'brl'});
    debugPrint('🔵 PaymentService: Received response: ${result.data}');
    return result.data as Map<String, dynamic>;
  }

  Future<bool> initPaymentSheet(double amount) async {
    try {
      debugPrint('🟢 PaymentService: Initializing payment sheet...');

      // 1. Call Cloud Function to get payment intent
      final data = await createPaymentIntent(amount);
      debugPrint('🟢 PaymentService: Got data from cloud function');
      debugPrint('   - paymentIntent: ${data['paymentIntent'] != null}');
      debugPrint('   - ephemeralKey: ${data['ephemeralKey'] != null}');
      debugPrint('   - customer: ${data['customer']}');
      debugPrint('   - publishableKey: ${data['publishableKey'] != null}');

      // 2. Set publishable key
      if (data['publishableKey'] != null) {
        Stripe.publishableKey = data['publishableKey'];
        debugPrint('🟢 PaymentService: Set publishable key');
      } else {
        debugPrint('⚠️ PaymentService: No publishable key returned!');
      }

      // Validate required fields
      if (data['paymentIntent'] == null) {
        debugPrint('❌ PaymentService: Missing paymentIntent!');
        return false;
      }

      // 3. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'AquaClean',
          paymentIntentClientSecret: data['paymentIntent'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['customer'],
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Color(0xFF0066FF)),
          ),
        ),
      );

      debugPrint('✅ PaymentService: Payment sheet initialized successfully!');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Payment Sheet: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> presentPaymentSheet() async {
    try {
      debugPrint('🟢 PaymentService: Presenting payment sheet...');
      await Stripe.instance.presentPaymentSheet();
      debugPrint('✅ PaymentService: Payment completed successfully!');
      return true;
    } on StripeException catch (e) {
      debugPrint('❌ Stripe Error: ${e.error.code} - ${e.error.message}');
      debugPrint('   localizedMessage: ${e.error.localizedMessage}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Error presenting Payment Sheet: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Creates a Checkout Session for mobile web payments.
  /// Returns a URL to redirect the user to Stripe's hosted payment page.
  Future<Map<String, dynamic>> createCheckoutSession({
    required double amount,
    String? successUrl,
    String? cancelUrl,
    required String? vehicleId,
    required List<String> serviceIds,
    required String? scheduledTime,
  }) async {
    debugPrint(
      '🔵 PaymentService: Creating checkout session for amount: $amount',
    );
    final callable = _functions.httpsCallable('createBookingCheckoutSession');
    final result = await callable.call({
      'amount': amount,
      'currency': 'brl',
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
      'vehicleId': vehicleId,
      'serviceIds': serviceIds,
      'scheduledTime': scheduledTime,
    });
    debugPrint('🔵 PaymentService: Received checkout session: ${result.data}');
    return result.data as Map<String, dynamic>;
  }
}
