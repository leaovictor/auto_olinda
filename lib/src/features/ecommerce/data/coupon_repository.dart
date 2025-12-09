import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/coupon.dart';

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return CouponRepository();
});

class CouponRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  /// Get all active coupons
  Stream<List<Coupon>> watchActiveCoupons() {
    return _firestore
        .collection('coupons')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Coupon.fromJson(data);
          }).toList();
        });
  }

  /// Get coupon by code
  Future<Coupon?> getCouponByCode(String code) async {
    final querySnapshot = await _firestore
        .collection('coupons')
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final data = querySnapshot.docs.first.data();
    data['id'] = querySnapshot.docs.first.id;
    return Coupon.fromJson(data);
  }

  /// Validate coupon
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required CouponApplicableTo applicableTo,
    required double amount,
  }) async {
    try {
      final result = await _functions.httpsCallable('validateCoupon').call({
        'code': code,
        'applicableTo': applicableTo.name,
        'amount': amount,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to validate coupon: $e');
    }
  }

  /// Apply coupon (increments usage count)
  Future<void> applyCoupon(String couponId) async {
    try {
      await _functions.httpsCallable('applyCoupon').call({
        'couponId': couponId,
      });
    } catch (e) {
      throw Exception('Failed to apply coupon: $e');
    }
  }

  /// Create coupon (Admin only)
  Future<void> createCoupon(Coupon coupon) async {
    final data = coupon.toJson();
    data.remove('id');
    data['code'] = coupon.code.toUpperCase(); // Force uppercase

    final docRef = await _firestore.collection('coupons').add(data);

    // Sync with Stripe
    try {
      await _functions.httpsCallable('createStripeCoupon').call({
        'couponId': docRef.id,
        'code': coupon.code.toUpperCase(),
        'type': coupon.type.name,
        'value': coupon.value,
      });
    } catch (e) {
      print('Error syncing coupon with Stripe: $e');
    }
  }

  /// Update coupon (Admin only)
  Future<void> updateCoupon(Coupon coupon) async {
    final data = coupon.toJson();
    data.remove('id');
    data['code'] = coupon.code.toUpperCase();

    await _firestore.collection('coupons').doc(coupon.id).update(data);
  }

  /// Delete coupon (Admin only)
  Future<void> deleteCoupon(String couponId) async {
    await _firestore.collection('coupons').doc(couponId).delete();
  }

  /// Get coupon usage statistics
  Future<Map<String, dynamic>> getCouponStats(String couponId) async {
    try {
      final result = await _functions.httpsCallable('getCouponUsage').call({
        'couponId': couponId,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to get coupon stats: $e');
    }
  }
}
