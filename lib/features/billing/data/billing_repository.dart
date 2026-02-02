import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/subscription.dart';

part 'billing_repository.g.dart';

class BillingRepository {
  final FirebaseFirestore _firestore;

  BillingRepository(this._firestore);

  Stream<Subscription> watchSubscription(String tenantId) {
    return _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('billing')
        .doc('subscription')
        .snapshots()
        .map((snapshot) => Subscription.fromFirestore(snapshot));
  }
}

@riverpod
BillingRepository billingRepository(BillingRepositoryRef ref) {
  return BillingRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<Subscription> subscriptionStream(
  SubscriptionStreamRef ref,
  String tenantId,
) {
  return ref.watch(billingRepositoryProvider).watchSubscription(tenantId);
}
