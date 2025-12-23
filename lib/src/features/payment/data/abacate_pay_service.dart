import 'package:abacatepay/abacatepay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/data/admin_repository.dart';

final abacatePayServiceProvider = Provider<AbacatePayService>((ref) {
  return AbacatePayService(ref.watch(adminRepositoryProvider));
});

class AbacatePayService {
  final AdminRepository _adminRepository;
  AbacatePay? _client;
  String? _cachedApiKey;

  AbacatePayService(this._adminRepository);

  Future<AbacatePay> _getClient() async {
    // If we have a cached client and key hasn't changed (simplified for now), return it.
    // Ideally we should check if key changed. For now, let's fetch key every time or cache it.

    // Fetch settings
    final settings = await _adminRepository.getSettings().first;
    final apiKey = settings?['abacatePayApiKey'] as String?;

    if (apiKey == null || apiKey.isEmpty) {
      // Fallback to env or throw
      const envKey = String.fromEnvironment('ABACATE_PAY_API_KEY');
      if (envKey.isNotEmpty) {
        if (_cachedApiKey != envKey) {
          _cachedApiKey = envKey;
          _client = AbacatePay(apiKey: envKey);
        }
        return _client!;
      }
      throw Exception('AbacatePay API Key not configured in Admin Settings.');
    }

    if (_client == null || _cachedApiKey != apiKey) {
      _cachedApiKey = apiKey;
      _client = AbacatePay(apiKey: apiKey);
    }

    return _client!;
  }

  /// Creates a billing (cobrança) for a specific amount.
  /// Returns the billing object which contains the PIX URL/Code.
  Future<dynamic> createBilling({
    required double amount,
    required String customerEmail,
    required String customerName,
    required String description,
    String? customerCpf,
  }) async {
    // IMPLEMENTATION NOTE:
    // The previous implementation used 'client.createBilling' which is undefined.
    // Research indicates 'client.billing.createBilling(AbacatePayBillingData(...))' is correct,
    // but requires specific types (AbacatePayProduct, AbacatePayBillingFrequency) and fields (customerId)
    // that are currently unresolved in the environment.
    //
    // Pending correct API usage or documentation from user.
    throw UnimplementedError(
      'AbacatePay createBilling needs SDK verification. Missing types for AbacatePayBillingData.',
    );
  }

  Future<dynamic> getBilling(String billingId) async {
    try {
      // Note: Implement verified getBilling method based on package structure
      throw UnimplementedError('getBilling not implemented yet/verified');
    } catch (e) {
      throw Exception('Failed to get billing: $e');
    }
  }
}
