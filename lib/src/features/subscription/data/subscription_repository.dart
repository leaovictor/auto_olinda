import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../../auth/data/auth_repository.dart';

part 'subscription_repository.g.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;

  SubscriptionRepository(this._firestore);

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
        .where('status', isEqualTo: 'active')
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

  Future<Map<String, dynamic>> createSubscriptionIntent(
    String userId,
    SubscriptionPlan plan, {
    String? couponId,
  }) async {
    try {
      final functions = FirebaseFunctions.instance;
      final params = {'priceId': plan.stripePriceId};

      if (couponId != null) {
        params['couponId'] = couponId;
      }

      final result = await functions
          .httpsCallable('createPaymentSheet')
          .call(params);

      print('createPaymentSheet result: ${result.data}');

      return result.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create subscription intent: $e');
    }
  }

  Future<void> subscribeToPlan(
    String userId,
    SubscriptionPlan plan, {
    String? couponId,
  }) async {
    try {
      if (kIsWeb) {
        // Web Flow is now handled in the UI using createSubscriptionIntent
        // and WebPaymentSheet. This method might be deprecated for Web
        // or used as a fallback.
        throw UnimplementedError(
          'Use createSubscriptionIntent and WebPaymentSheet for Web',
        );
      } else {
        // Mobile Flow: Payment Sheet
        final data = await createSubscriptionIntent(
          userId,
          plan,
          couponId: couponId,
        );

        // Set the publishable key from the server response
        Stripe.publishableKey = data['publishableKey'];

        // 1. Initialize Stripe
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            customFlow: false,
            merchantDisplayName: 'AquaClean',
            paymentIntentClientSecret: data['paymentIntent'],
            setupIntentClientSecret: data['setupIntent'],
            customerEphemeralKeySecret: data['ephemeralKey'],
            customerId: data['customer'],
            style: ThemeMode.light,
          ),
        );

        // 2. Present Payment Sheet
        await Stripe.instance.presentPaymentSheet();
      }

      // 3. Payment successful (if no exception thrown)
    } catch (e) {
      if (e is StripeException) {
        throw Exception(
          'Payment cancelled or failed: ${e.error.localizedMessage}',
        );
      }
      throw Exception('Failed to start subscription: $e');
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instance;
      await functions.httpsCallable('cancelSubscription').call({
        'subscriptionId': subscriptionId,
      });
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  Future<void> reactivateSubscription(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instance;
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

      final functions = FirebaseFunctions.instance;
      final result = await functions
          .httpsCallable('changeSubscriptionPlan')
          .call({'subscriptionId': subscriptionId, 'newPriceId': newPriceId});

      print('changeSubscriptionPlan result: $result');
    } catch (e) {
      print('changeSubscriptionPlan error: $e');
      throw Exception('Failed to change subscription plan: $e');
    }
  }
}

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) {
  return SubscriptionRepository(ref.watch(firebaseFirestoreProvider));
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
