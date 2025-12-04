import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> subscribeToPlan(
    String userId,
    SubscriptionPlan plan, {
    String? couponId,
  }) async {
    try {
      final functions = FirebaseFunctions.instance;

      if (kIsWeb) {
        // Web Flow: Create Checkout Session and Redirect
        final successUrl = Uri.base.origin; // Redirect back to the app
        final cancelUrl = Uri.base.origin;

        final params = {
          'priceId': plan.stripePriceId,
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
        };

        // Note: Coupons for Checkout Session need to be passed differently or handled in the function
        // The current createCheckoutSession in stripe.ts doesn't seem to accept couponId directly in the top level
        // but let's check if we need to update stripe.ts for coupons on web later.
        // For now, let's get the basic flow working.

        final result = await functions
            .httpsCallable('createCheckoutSession')
            .call(params);

        final data = result.data as Map<String, dynamic>;
        final url = data['url'] as String;

        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch Stripe Checkout URL');
        }
      } else {
        // Mobile Flow: Payment Sheet
        final params = {'priceId': plan.stripePriceId};

        if (couponId != null) {
          params['couponId'] = couponId;
        }

        final result = await functions
            .httpsCallable('createPaymentSheet')
            .call(params);

        final data = result.data as Map<String, dynamic>;

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
      // The webhook will update the backend, but we can optimistically assume success
      // or wait for the stream to update.
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
