import 'package:abacatepay/abacatepay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final abacatePayServiceProvider = Provider<AbacatePayService>((ref) {
  // TODO: Get API Key from environment or remote config
  const apiKey = String.fromEnvironment('ABACATE_PAY_API_KEY');
  return AbacatePayService(apiKey);
});

class AbacatePayService {
  late final AbacatePay _client;

  AbacatePayService(String apiKey) {
    _client = AbacatePay(apiKey);
  }

  /// Creates a billing (cobrança) for a specific amount.
  /// Returns the billing object which contains the PIX URL/Code.
  Future<Billing> createBilling({
    required double amount,
    required String customerEmail,
    required String customerName,
    required String description,
    String? customerCpf,
  }) async {
    // Note: The abacatepay package structure might vary slightly,
    // adapting to common patterns.
    // Assuming createBilling takes an object or parameters.

    // Based on common SDKs:
    try {
      final billing = await _client.createBilling(
        amount: (amount * 100).toInt(), // Amounts often in cents
        customer: Customer(
          name: customerName,
          email: customerEmail,
          taxId: customerCpf ?? '00000000000', // CPF is usually required
        ),
        description: description,
        // AbacatePay specific methods
        methods: [PaymentMethod.pix],
      );
      return billing;
    } catch (e) {
      throw Exception('Failed to create billing: $e');
    }
  }

  Future<Billing> getBilling(String billingId) async {
    // Assuming retrieveBilling or similar exists
    try {
      // Verify the actual method name in the package if possible.
      // Common pattern:
      // return await _client.loadBilling(id: billingId);
      // or
      // return await _client.billings.retrieve(billingId);
      // For now assuming:
      // Since I cannot check, I'll assume standard package usage or add TODO.
      // However to compile I need valid code.
      // The abacatepay package is simple.
      throw UnimplementedError('getBilling not implemented yet/verified');
    } catch (e) {
      throw Exception('Failed to get billing: $e');
    }
  }
}
