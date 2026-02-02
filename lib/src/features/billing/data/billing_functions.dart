import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'billing_functions.g.dart';

class BillingFunctionsService {
  final FirebaseFunctions _functions;

  BillingFunctionsService(this._functions);

  Future<String?> createPortalSession({required String returnUrl}) async {
    try {
      final callable = _functions.httpsCallable('billing_createPortalSession');
      final result = await callable.call({'returnUrl': returnUrl});

      final data = result.data as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      // Log error (Monitoring service)
      print('Error creating portal session: $e');
      rethrow;
    }
  }

  // Future createCheckoutSession() if needed in the future
}

@riverpod
BillingFunctionsService billingFunctionsService(
  BillingFunctionsServiceRef ref,
) {
  return BillingFunctionsService(FirebaseFunctions.instance);
}
