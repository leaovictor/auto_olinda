import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/pricing_matrix.dart';
import '../../auth/data/auth_repository.dart';

part 'pricing_repository.g.dart';

class PricingRepository {
  final FirebaseFirestore _firestore;

  PricingRepository(this._firestore);

  Future<PricingMatrix> getPricingMatrix() async {
    try {
      final doc = await _firestore
          .collection('prices')
          .doc('pricing_matrix')
          .get();

      if (doc.exists) {
        return PricingMatrix.fromJson(doc.data()!);
      } else {
        // Return default empty matrix if not found
        // In a real app, this might throw an error or initialize with defaults
        return PricingMatrix(prices: {}, updatedAt: DateTime.now());
      }
    } catch (e) {
      // Log error
      developer.log('Error fetching pricing matrix', error: e);
      rethrow;
    }
  }

  Future<void> updatePricingMatrix(PricingMatrix matrix) async {
    await _firestore
        .collection('prices')
        .doc('pricing_matrix')
        .set(matrix.toJson());
  }

  Stream<PricingMatrix> watchPricingMatrix() {
    return _firestore
        .collection('prices')
        .doc('pricing_matrix')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return PricingMatrix.fromJson(doc.data()!);
          }
          return PricingMatrix(prices: {}, updatedAt: DateTime.now());
        });
  }
}

@Riverpod(keepAlive: true)
PricingRepository pricingRepository(Ref ref) {
  return PricingRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Future<PricingMatrix> pricingMatrix(Ref ref) {
  return ref.watch(pricingRepositoryProvider).getPricingMatrix();
}

@riverpod
Stream<PricingMatrix> pricingMatrixStream(Ref ref) {
  return ref.watch(pricingRepositoryProvider).watchPricingMatrix();
}
