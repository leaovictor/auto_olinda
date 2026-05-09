import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsaasRepository {
  final FirebaseFunctions _functions;
  AsaasRepository(this._functions);

  /// Creates a customer in Asaas and links it to the user profile
  Future<String> createCustomer({
    required String name,
    required String cpfCnpj,
    required String email,
    required String phone,
  }) async {
    try {
      final result = await _functions.httpsCallable('createAsaasCustomer').call({
        'name': name,
        'cpfCnpj': cpfCnpj,
        'email': email,
        'phone': phone,
      });
      return result.data['customerId'];
    } catch (e) {
      throw Exception('Erro ao criar cliente no Asaas: $e');
    }
  }

  /// Creates a Pix payment and returns QR code data
  Future<Map<String, dynamic>> createPixPayment({
    required String customerId,
    required double value,
    required String description,
    String? externalReference,
  }) async {
    try {
      final result = await _functions.httpsCallable('createAsaasPixPayment').call({
        'customerId': customerId,
        'value': value,
        'description': description,
        'externalReference': externalReference,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Erro ao gerar Pix: $e');
    }
  }

  /// Creates a recurring credit card subscription
  Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required double value,
    required String nextDueDate,
    String? cycle,
    Map<String, dynamic>? creditCard,
    Map<String, dynamic>? creditCardHolderInfo,
  }) async {
    try {
      final result = await _functions.httpsCallable('createAsaasSubscription').call({
        'customerId': customerId,
        'value': value,
        'nextDueDate': nextDueDate,
        'cycle': cycle ?? 'MONTHLY',
        'creditCard': creditCard,
        'creditCardHolderInfo': creditCardHolderInfo,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Erro ao criar assinatura no Asaas: $e');
    }
  }
}

final asaasRepositoryProvider = Provider<AsaasRepository>((ref) {
  return AsaasRepository(
    FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
  );
});
