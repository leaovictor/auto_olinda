import 'package:cloud_firestore/cloud_firestore.dart';
import 'tenant_service.dart';

/// A thin helper that automatically scopes every Firestore path under
/// `tenants/{tenantId}/...`.
///
/// Usage:
/// ```dart
/// // In a repository that has access to a Ref:
/// final col = TenantFirestore.col('appointments', tenantId);
/// final doc = TenantFirestore.doc('users', uid, tenantId);
/// ```
///
/// The [tenantId] parameter should be obtained by calling [requireTenantId]
/// from within a Riverpod provider, or by reading it from TenantService.
class TenantFirestore {
  TenantFirestore._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection helpers ─────────────────────────────────────────────────────

  /// Returns a scoped [CollectionReference]:
  /// `tenants/{tenantId}/{collection}`
  static CollectionReference<Map<String, dynamic>> col(
    String collection,
    String tenantId,
  ) {
    return _db.collection('tenants').doc(tenantId).collection(collection);
  }

  /// Returns a scoped [DocumentReference]:
  /// `tenants/{tenantId}/{collection}/{docId}`
  static DocumentReference<Map<String, dynamic>> doc(
    String collection,
    String docId,
    String tenantId,
  ) {
    return col(collection, tenantId).doc(docId);
  }

  /// Returns a scoped [CollectionReference] for a sub-collection:
  /// `tenants/{tenantId}/{collection}/{docId}/{subCollection}`
  static CollectionReference<Map<String, dynamic>> subCol(
    String collection,
    String docId,
    String subCollection,
    String tenantId,
  ) {
    return doc(collection, docId, tenantId).collection(subCollection);
  }

  // ── Tenant document ────────────────────────────────────────────────────────

  /// The tenant root document itself: `tenants/{tenantId}`
  static DocumentReference<Map<String, dynamic>> tenantDoc(String tenantId) {
    return _db.collection('tenants').doc(tenantId);
  }

  // ── CollectionGroup (cross-tenant queries, admin use only) ─────────────────

  /// Raw (unscoped) collection group — use only in server-side admin contexts.
  static Query<Map<String, dynamic>> globalGroup(String collection) {
    return _db.collectionGroup(collection);
  }
}
