import 'package:cloud_functions/cloud_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/config/stripe_config.dart';

final stripeConfigServiceProvider = Provider<StripeConfigService>((ref) {
  return StripeConfigService();
});

class StripeConfigService {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  /// Fetches the Stripe Publishable Key from Cloud Functions.
  ///
  /// This function calls `getPublicStripeConfig` which securely reads
  /// the key from `admin_settings/payments`.
  Future<String> getPublishableKey() async {
    try {
      final callable = _functions.httpsCallable('getPublicStripeConfig');
      final result = await callable.call();

      final data = result.data as Map<dynamic, dynamic>?;
      if (data != null && data['publishableKey'] != null) {
        final key = data['publishableKey'] as String;
        if (key.isNotEmpty) {
          // debugPrint('🟢 StripeConfigService: Loaded key from Cloud Function');
          return key;
        }
      }
    } catch (e) {
      // debugPrint(
      //   '⚠️ StripeConfigService: Failed to fetch key from Cloud Function: $e',
      // );
      // If unauthenticated, it might fail if we restricted rule access,
      // but logic handles fallback.
    }

    // Fallback to static config or empty string
    // debugPrint('⚠️ StripeConfigService: Using fallback static key');
    return StripeConfig.publishableKey;
  }
}
