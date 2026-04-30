import 'package:cloud_firestore/cloud_firestore.dart';

/// Extension that provides tenant-scoped Firestore collection access.
///
/// USAGE: Always use this instead of `_firestore.collection(...)` directly.
///
/// ```dart
/// // WRONG — leaks data across tenants:
/// _firestore.collection('appointments')
///
/// // RIGHT — tenant-isolated:
/// _firestore.tenantCol(tenantId, 'appointments')
/// ```
extension TenantFirestore on FirebaseFirestore {
  /// Returns a reference to `tenants/{tenantId}/{collectionName}`.
  CollectionReference<Map<String, dynamic>> tenantCol(
    String tenantId,
    String collectionName,
  ) {
    assert(tenantId.isNotEmpty, 'tenantId must not be empty');
    return collection('tenants').doc(tenantId).collection(collectionName);
  }

  /// Returns the tenant document reference.
  DocumentReference<Map<String, dynamic>> tenantDoc(String tenantId) {
    assert(tenantId.isNotEmpty, 'tenantId must not be empty');
    return collection('tenants').doc(tenantId);
  }
}
