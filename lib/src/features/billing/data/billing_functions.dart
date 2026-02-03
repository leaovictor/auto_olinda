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
      print('Error creating portal session: $e');
      rethrow;
    }
  }

  Future<String> createTenant({required String name}) async {
    try {
      final callable = _functions.httpsCallable('tenant_createTenant');
      final result = await callable.call({'name': name});

      final data = result.data as Map<String, dynamic>;
      if (data['status'] == 'success') {
        return data['data']['tenantId'] as String;
      } else {
        throw Exception(data['message'] ?? 'Failed to create tenant');
      }
    } on FirebaseFunctionsException catch (e) {
      print('Erro na Cloud Function: [${e.code}] ${e.message}');
      print('Detalhes: ${e.details}');
      throw Exception(e.message ?? 'Falha ao criar estética');
    } catch (e) {
      print('Erro ao criar estética: $e');
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
