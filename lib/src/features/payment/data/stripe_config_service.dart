import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/config/stripe_config.dart';

final stripeConfigServiceProvider = Provider<StripeConfigService>((ref) {
  return StripeConfigService();
});

class StripeConfigService {
  Future<String> getPublishableKey() async {
    // Strict Mode: Use only the build-time configuration (dart-define)
    // This avoids network calls and ensures consistency.
    return StripeConfig.publishableKey;
  }
}
