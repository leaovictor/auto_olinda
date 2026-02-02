import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../billing/data/billing_functions.dart';

part 'tenant_repository.g.dart';

@riverpod
TenantRepository tenantRepository(TenantRepositoryRef ref) {
  return TenantRepository(
    FirebaseFirestore.instance,
    ref.read(billingFunctionsServiceProvider),
  );
}

class TenantRepository {
  final FirebaseFirestore _firestore;
  final BillingFunctionsService _billingFunctions;

  TenantRepository(this._firestore, this._billingFunctions);

  /// Creates a new Tenant via Cloud Function to ensure Stripe ID creation
  Future<String> createTenant({
    required String name,
    required String ownerId,
    required String ownerEmail,
  }) async {
    // 1. Call Cloud Function (Handles Tenant Doc + Stripe Customer + User Link)
    final tenantId = await _billingFunctions.createTenant(name: name);

    // 2. Initialize Default Data (This remains client-side for flexibility)
    final tenantRef = _firestore.collection('tenants').doc(tenantId);

    await tenantRef.collection('services').add({
      'name': 'Lavagem Simples',
      'price': 40.0,
      'description': 'Lavagem externa completa com cera líquida.',
      'durationMinutes': 45,
      'isActive': true,
      'category': 'wash',
    });

    return tenantId;
  }
}
