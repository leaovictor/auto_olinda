import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/store_license.dart';
import '../../auth/data/auth_repository.dart';

part 'license_repository.g.dart';

/// The storeId for the current installation.
/// Option A: single-tenant — hardcoded per deployment.
/// Change this value when onboarding a new lavajato.
const String kCurrentStoreId = 'auto_olinda_principal';

class LicenseRepository {
  final FirebaseFirestore _firestore;

  LicenseRepository(this._firestore);

  /// Watch the license for the given storeId in real time.
  Stream<StoreLicense?> watchLicense(String storeId) {
    return _firestore
        .collection('store_licenses')
        .doc(storeId)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          try {
            return StoreLicense.fromJson({...doc.data()!, 'storeId': doc.id});
          } catch (e) {
            return null;
          }
        });
  }

  /// One-time fetch.
  Future<StoreLicense?> getLicense(String storeId) async {
    final doc =
        await _firestore.collection('store_licenses').doc(storeId).get();
    if (!doc.exists || doc.data() == null) return null;
    return StoreLicense.fromJson({...doc.data()!, 'storeId': doc.id});
  }

  /// Create or update a license document (founder only).
  Future<void> saveLicense(StoreLicense license) async {
    final data = license.toJson();
    data.remove('storeId');
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection('store_licenses')
        .doc(license.storeId)
        .set(data, SetOptions(merge: true));
  }

  /// List all store licenses (founder dashboard).
  Stream<List<StoreLicense>> watchAllLicenses() {
    return _firestore.collection('store_licenses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return StoreLicense.fromJson({...doc.data(), 'storeId': doc.id});
        } catch (_) {
          return null;
        }
      }).whereType<StoreLicense>().toList();
    });
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
LicenseRepository licenseRepository(Ref ref) {
  return LicenseRepository(ref.watch(firebaseFirestoreProvider));
}

/// Provider for the current storeId (Option A: hardcoded).
@Riverpod(keepAlive: true)
String currentStoreId(Ref ref) => kCurrentStoreId;

/// Real-time stream of the current store's license.
@Riverpod(keepAlive: true)
Stream<StoreLicense?> currentStoreLicense(Ref ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  return ref.watch(licenseRepositoryProvider).watchLicense(storeId);
}

/// Convenience: is the current store's license valid right now?
final isLicenseActiveProvider = StreamProvider<bool>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  return ref
      .watch(licenseRepositoryProvider)
      .watchLicense(storeId)
      .map((license) {
    if (license == null) return false;
    return license.isActive && !license.isExpired;
  });
});
