import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/tenant.dart';
import '../../auth/data/auth_repository.dart';

part 'tenant_repository.g.dart';

class TenantRepository {
  final FirebaseFirestore _firestore;

  TenantRepository(this._firestore);

  /// Streams the tenant document for the given [tenantId].
  Stream<Tenant?> watchTenant(String tenantId) {
    return _firestore
        .collection('tenants')
        .doc(tenantId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Tenant.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  /// Fetches a tenant once.
  Future<Tenant?> getTenant(String tenantId) async {
    final doc = await _firestore.collection('tenants').doc(tenantId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Tenant.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Creates a new tenant document (called by superAdmin or onboarding flow).
  Future<String> createTenant({
    required String name,
    required String ownerUid,
    String? logoUrl,
    String? primaryColor,
    String? phone,
    String? city,
    String? state,
  }) async {
    final ref = _firestore.collection('tenants').doc();
    await ref.set({
      'id': ref.id,
      'name': name,
      'ownerUid': ownerUid,
      'status': 'active',
      'plan': 'starter',
      'logoUrl': logoUrl,
      'primaryColor': primaryColor ?? '#1A73E8',
      'stripeConnectOnboarded': false,
      'platformFeePercent': 5,
      'phone': phone,
      'city': city,
      'state': state,
      'createdAt': FieldValue.serverTimestamp(),
      'settings': {
        'maxSlotsPerHour': 2,
        'openingHours': {
          'monday': {'open': '08:00', 'close': '18:00'},
          'tuesday': {'open': '08:00', 'close': '18:00'},
          'wednesday': {'open': '08:00', 'close': '18:00'},
          'thursday': {'open': '08:00', 'close': '18:00'},
          'friday': {'open': '08:00', 'close': '18:00'},
          'saturday': {'open': '08:00', 'close': '13:00'},
          'sunday': {'open': null, 'close': null},
        },
      },
    });
    return ref.id;
  }

  /// Updates mutable tenant fields (branding, settings).
  Future<void> updateTenant(String tenantId, Map<String, dynamic> data) {
    return _firestore
        .collection('tenants')
        .doc(tenantId)
        .update({...data, 'updatedAt': FieldValue.serverTimestamp()});
  }

  /// Fetches all tenants (superAdmin only — enforced by Firestore rules).
  Stream<List<Tenant>> watchAllTenants() {
    return _firestore
        .collection('tenants')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Tenant.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}

@Riverpod(keepAlive: true)
TenantRepository tenantRepository(Ref ref) {
  return TenantRepository(ref.watch(firebaseFirestoreProvider));
}

/// Streams the current user's tenant document.
/// Returns null if user has no tenantId (superAdmin, unauthenticated).
@Riverpod(keepAlive: true)
Stream<Tenant?> currentTenant(Ref ref) {
  final userAsync = ref.watch(currentUserProfileProvider);
  final tenantId = userAsync.valueOrNull?.tenantId;
  if (tenantId == null || tenantId.isEmpty) return Stream.value(null);
  return ref.watch(tenantRepositoryProvider).watchTenant(tenantId);
}
