import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:abacatepay/abacatepay.dart'; // Ensure package is available
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../../auth/data/auth_repository.dart';
import '../../payment/data/abacate_pay_service.dart';

part 'subscription_repository.g.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;
  final AbacatePayService _paymentService;

  SubscriptionRepository(this._firestore, this._paymentService);

  Stream<List<SubscriptionPlan>> getActivePlans() {
    return _firestore
        .collection('plans')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SubscriptionPlan.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  Stream<Subscriber?> getUserSubscription(String userId) {
    return _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['active', 'trialing'])
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return Subscriber.fromJson({
            ...snapshot.docs.first.data(),
            'id': snapshot.docs.first.id,
          });
        });
  }

  Future<Billing> subscribeToPlan(
    String userId,
    SubscriptionPlan plan, {
    String? couponId,
    required String userEmail,
    required String userName,
    String? userCpf,
  }) async {
    try {
      final billing = await _paymentService.createBilling(
        amount: plan.price,
        customerEmail: userEmail,
        customerName: userName,
        description: 'Assinatura ${plan.name}',
        customerCpf: userCpf,
      );
      return billing;
    } catch (e) {
      throw Exception('Failed to start subscription: $e');
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('cancelSubscription').call({
        'subscriptionId': subscriptionId,
      });
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  Future<void> reactivateSubscription(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('reactivateSubscription').call({
        'subscriptionId': subscriptionId,
      });
    } catch (e) {
      throw Exception('Failed to reactivate subscription: $e');
    }
  }

  Future<void> changeSubscriptionPlan(
    String subscriptionId,
    String newPriceId,
  ) async {
    try {
      // Debug logging
      print('changeSubscriptionPlan called');
      print('subscriptionId: $subscriptionId');
      print('newPriceId: $newPriceId');

      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final result = await functions
          .httpsCallable('changeSubscriptionPlan')
          .call({'subscriptionId': subscriptionId, 'newPriceId': newPriceId});

      print('changeSubscriptionPlan result: $result');
    } catch (e) {
      print('changeSubscriptionPlan error: $e');
      throw Exception('Failed to change subscription plan: $e');
    }
  }

  Future<Subscriber?> getAnyUserSubscription(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return Subscriber.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      print('DEBUG: Error fetching any subscription: $e');
      return null;
    }
  }

  Future<void> syncSubscriptionStatus(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('syncSubscriptionStatus').call({
        'subscriptionId': subscriptionId,
      });
    } catch (e) {
      throw Exception('Failed to sync subscription status: $e');
    }
  }
}

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) {
  return SubscriptionRepository(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(abacatePayServiceProvider),
  );
}

@riverpod
Stream<List<SubscriptionPlan>> activePlans(Ref ref) {
  return ref.watch(subscriptionRepositoryProvider).getActivePlans();
}

@riverpod
Stream<Subscriber?> userSubscription(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(subscriptionRepositoryProvider)
      .getUserSubscription(user.uid);
}

/// Provider to get subscription for any user ID (used by staff to check if customer is premium)
/// Using manual provider family to avoid needing build_runner
final subscriptionByUserIdProvider = StreamProvider.family<Subscriber?, String>(
  (ref, userId) {
    return ref
        .watch(subscriptionRepositoryProvider)
        .getUserSubscription(userId);
  },
);
