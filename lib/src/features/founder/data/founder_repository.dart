import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../license/domain/store_license.dart';
import '../../license/data/license_repository.dart';
import '../../auth/data/auth_repository.dart';

part 'founder_repository.g.dart';

/// Repository for the founder's cross-store operations.
/// Only accessible by users with role == 'founder'.
class FounderRepository {
  final FirebaseFirestore _firestore;
  final LicenseRepository _licenseRepo;

  FounderRepository(this._firestore, this._licenseRepo);

  /// Watch all store licenses (founder dashboard).
  Stream<List<StoreLicense>> watchAllStores() =>
      _licenseRepo.watchAllLicenses();

  /// Save / update a store license.
  Future<void> saveLicense(StoreLicense license) =>
      _licenseRepo.saveLicense(license);

  /// Activate a store's license.
  Future<void> activateLicense({
    required String storeId,
    required DateTime expiresAt,
    required String modalidade,
    double contractValue = 15000,
  }) async {
    await _licenseRepo.saveLicense(
      StoreLicense(
        storeId: storeId,
        storeName: '', // Will be merged — existing name is kept
        status: 'active',
        modalidade: modalidade,
        licenseStartDate: DateTime.now(),
        licenseExpiresAt: expiresAt,
        contractValue: contractValue,
        contractSignedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Suspend a store immediately.
  Future<void> suspendLicense(String storeId) async {
    await _firestore.collection('store_licenses').doc(storeId).update({
      'status': 'suspended',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create a new store license (onboarding a new lavajato).
  Future<void> createStore({
    required String storeId,
    required String storeName,
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
    required String modalidade,
    int trialDays = 14,
  }) async {
    final now = DateTime.now();
    final license = StoreLicense(
      storeId: storeId,
      storeName: storeName,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      ownerPhone: ownerPhone,
      modalidade: modalidade,
      status: 'trial',
      trialEndsAt: now.add(Duration(days: trialDays)),
      createdAt: now,
      updatedAt: now,
    );
    await _licenseRepo.saveLicense(license);
  }

  /// Computed MRR across all active stores.
  Future<double> computeMRR(List<StoreLicense> stores) async {
    double mrr = 0;
    for (final store in stores) {
      if (!store.isActive) continue;
      if (store.modalidade == 'anual') {
        // Monthly equivalent of annual contract
        mrr += store.contractValue / 12;
      }
      // Royalties MRR would need real revenue data — skip for now
    }
    return mrr;
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
FounderRepository founderRepository(Ref ref) {
  return FounderRepository(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(licenseRepositoryProvider),
  );
}

@riverpod
Stream<List<StoreLicense>> allStores(Ref ref) {
  return ref.watch(founderRepositoryProvider).watchAllStores();
}
