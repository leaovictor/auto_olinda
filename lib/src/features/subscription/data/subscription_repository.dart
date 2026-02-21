import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../../../features/subscription/domain/subscription_details.dart';
import '../../../features/subscription/domain/subscription_invoice.dart';
import '../../auth/data/auth_repository.dart';

import '../../admin/data/analytics_repository.dart';

part 'subscription_repository.g.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;

  final AnalyticsRepository _analytics;

  SubscriptionRepository(this._firestore)
    : _analytics = AnalyticsRepository(_firestore);

  /// Swap the vehicle for an existing subscription.
  /// This involves:
  /// 1. Verifying 30-day limit (optional strict check).
  /// 2. Changing the Stripe Subscription Plan if the new plan is different.
  /// 3. Updating the Firestore subscription document with new vehicle details and `lastPlateChange`.
  Future<void> swapSubscriptionVehicle({
    required String subscriptionId,
    required String userId,
    required String oldVehicleId,
    required String newVehicleId,
    required String newVehiclePlate,
    required String newVehicleCategory,
    required SubscriptionPlan newPlan,
    required SubscriptionPlan oldPlan,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );

      // 1. If Plan/Price is different, calling Stripe Change
      if (newPlan.id != oldPlan.id) {
        print('SWAP: Changing plan from ${oldPlan.name} to ${newPlan.name}');
        print('SWAP: Changing plan from ${oldPlan.name} to ${newPlan.name}');
        await changeSubscriptionPlan(subscriptionId, newPlan.stripePriceId);

        // Log plan change
        await _analytics.logSubscriptionStatusChange(
          subscriptionId: subscriptionId,
          userId: userId,
          previousStatus: 'active', // Assuming it was active
          newStatus: 'active',
          reason: 'vehicle_swap_upgrade',
          planId: newPlan.id,
          planValue: newPlan.price,
        );
      }

      // 2. Call Cloud Function to validate and update vehicle (enforces 30-day rule)
      print('SWAP: Calling updateSubscriptionVehicle for $newVehiclePlate');
      await functions.httpsCallable('updateSubscriptionVehicle').call({
        'subscriptionId': subscriptionId,
        'newVehicleId': newVehicleId,
        // The Cloud Function uses newVehicleId to fetch details, or we might need to pass plate/category if the function expects it.
        // My new function `subscription_vehicle.ts` expects `subscriptionId` and `newVehicleId`.
      });

      print('SWAP: Successfully swapped to vehicle $newVehiclePlate');
    } catch (e) {
      print('SWAP Error: $e');
      // Map Cloud Function errors to user friendly messages if possible
      if (e is FirebaseFunctionsException) {
        throw Exception(e.message ?? 'Erro ao trocar veículo');
      }
      throw Exception('Falha ao trocar de veículo: $e');
    }
  }

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

  Stream<List<Subscriber>> getUserSubscriptions(String userId) {
    return _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['active', 'trialing'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Subscriber.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  // Legacy method kept for backward compatibility but modified to return the first if available
  Stream<Subscriber?> getUserSubscription(String userId) {
    return getUserSubscriptions(userId).map((list) {
      if (list.isEmpty) return null;
      return list.first;
    });
  }

  Future<Map<String, dynamic>> createSubscriptionIntent(
    String userId,
    SubscriptionPlan plan, {
    String? couponId,
    String? vehicleId,
    String? vehiclePlate,
    String? vehicleCategory,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final params = {'priceId': plan.stripePriceId};

      if (couponId != null) {
        params['couponId'] = couponId;
      }
      if (vehicleId != null) params['vehicleId'] = vehicleId;
      if (vehiclePlate != null) params['vehiclePlate'] = vehiclePlate;
      if (vehicleCategory != null) params['vehicleCategory'] = vehicleCategory;

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
    String? vehicleId,
    String? vehiclePlate,
    String? vehicleCategory,
  }) async {
    try {
      if (kIsWeb) {
        // Web Flow is now handled in the UI using createSubscriptionIntent
        // and WebPaymentSheet.
        throw UnimplementedError(
          'Use createSubscriptionIntent and WebPaymentSheet for Web',
        );
      } else {
        // Mobile Flow: Payment Sheet
        final data = await createSubscriptionIntent(
          userId,
          plan,
          couponId: couponId,
          vehicleId: vehicleId,
          vehiclePlate: vehiclePlate,
          vehicleCategory: vehicleCategory,
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
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('cancelSubscription').call({
        'subscriptionId': subscriptionId,
      });

      // Log cancellation
      try {
        final sub = await getSubscriptionById(subscriptionId);
        if (sub != null) {
          await _analytics.logSubscriptionStatusChange(
            subscriptionId: subscriptionId,
            userId: sub.userId,
            previousStatus: sub.status,
            newStatus: 'canceled', // Intention
            reason: 'user_cancelled',
            planId: sub.planId,
          );
        }
      } catch (e) {
        print('Error logging cancellation: $e');
      }
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

      // Log reactivation
      try {
        final sub = await getSubscriptionById(subscriptionId);
        if (sub != null) {
          await _analytics.logSubscriptionStatusChange(
            subscriptionId: subscriptionId,
            userId: sub.userId,
            previousStatus: 'canceled',
            newStatus: 'active',
            reason: 'user_reactivated',
            planId: sub.planId,
          );
        }
      } catch (e) {
        print('Error logging reactivation: $e');
      }
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

      // Log plan change (partial info as we don't have full plan details available here without fetch)
      // We'll skip logging here for now or would need to fetch plan details which adds latency.
      // The cloud function could/should log this too.

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

  /// Returns the first active/trialing subscription linked to [plate] for [userId].
  /// Used to restore Premium when a vehicle is deleted and re-added with the same plate.
  Future<Subscriber?> checkExistingSubscriptionByPlate(
    String userId,
    String plate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['active', 'trialing'])
          .get();

      if (snapshot.docs.isEmpty) return null;

      final normalizedPlate = plate.toUpperCase();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final linkedPlate = (data['linkedPlate'] as String? ?? '')
            .toUpperCase();
        if (linkedPlate == normalizedPlate) {
          return Subscriber.fromJson({...data, 'id': doc.id});
        }
      }
      return null;
    } catch (e) {
      print('DEBUG: Error checking subscription by plate: $e');
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

  Future<SubscriptionPlan?> getSubscriptionPlan(String planId) async {
    try {
      final doc = await _firestore.collection('plans').doc(planId).get();
      if (!doc.exists) return null;
      return SubscriptionPlan.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('DEBUG: Error fetching subscription plan: $e');
      return null;
    }
  }

  Future<Subscriber?> getSubscriptionById(String subscriptionId) async {
    try {
      final doc = await _firestore
          .collection('subscriptions')
          .doc(subscriptionId)
          .get();
      if (!doc.exists) return null;
      return Subscriber.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  /// Syncs all user subscriptions from Stripe API
  /// This ensures that even if a plan is deactivated, the user's
  /// active subscription in Stripe remains valid in the app
  Future<void> syncUserSubscriptionsFromStripe() async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('syncUserSubscriptionsFromStripe').call();
    } catch (e) {
      throw Exception('Failed to sync subscriptions from Stripe: $e');
    }
  }

  /// Get plan including inactive ones - used for existing subscribers
  /// even when the plan is no longer available for new sign-ups
  Future<SubscriptionPlan?> getSubscriptionPlanIncludingInactive(
    String planId,
  ) async {
    try {
      final doc = await _firestore.collection('plans').doc(planId).get();
      if (!doc.exists) return null;
      return SubscriptionPlan.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('DEBUG: Error fetching plan (including inactive): $e');
      return null;
    }
  }

  /// Admin creates a subscription manually using a PaymentMethod ID (from CardField)
  Future<void> adminCreateSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required String paymentMethodId,
    String? couponId,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final params = {
        'userId': userId,
        'priceId': plan.stripePriceId,
        'paymentMethodId': paymentMethodId,
      };
      if (couponId != null) {
        params['couponId'] = couponId;
      }
      await functions.httpsCallable('adminCreateSubscription').call(params);

      // Log creation
      await _analytics.logSubscriptionStatusChange(
        subscriptionId:
            'new_admin_sub', // We don't get the ID back easily from this specific call structure without return
        userId: userId,
        previousStatus: 'none',
        newStatus: 'active',
        reason: 'admin_created',
        planId: plan.id,
        planValue: plan.price,
      );
    } catch (e) {
      if (e is FirebaseFunctionsException) {
        throw Exception(e.message ?? e.toString());
      }
      throw Exception('Failed to create subscription: $e');
    }
  }

  Future<SubscriptionDetails> getSubscriptionDetails(
    String subscriptionId,
  ) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final result = await functions
          .httpsCallable('getSubscriptionDetails')
          .call({'subscriptionId': subscriptionId});

      return SubscriptionDetails.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } catch (e) {
      throw Exception('Failed to get subscription details: $e');
    }
  }

  /// Fetch subscription invoices (payment history)
  Future<List<SubscriptionInvoice>> getSubscriptionInvoices() async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final result = await functions
          .httpsCallable('getSubscriptionInvoices')
          .call();

      final data = result.data as Map<String, dynamic>;
      final invoices = data['invoices'] as List<dynamic>;

      return invoices.map((invoice) {
        return SubscriptionInvoice.fromJson(
          Map<String, dynamic>.from(invoice as Map),
        );
      }).toList();
    } catch (e) {
      print('Error fetching subscription invoices: $e');
      return [];
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

final userSubscriptionsProvider = StreamProvider<List<Subscriber>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(subscriptionRepositoryProvider)
      .getUserSubscriptions(user.uid);
});

/// Family key: (vehicleId, plate) — plate is the primary lookup key;
/// vehicleId is kept as a fallback for legacy documents.
typedef VehicleSubKey = ({String vehicleId, String plate});

final vehicleSubscriptionProvider =
    StreamProvider.family<Subscriber?, VehicleSubKey>((ref, key) {
      final user = ref.watch(authStateChangesProvider).value;
      if (user == null) return Stream.value(null);

      final normalizedPlate = key.plate.toUpperCase();

      return ref
          .watch(subscriptionRepositoryProvider)
          .getUserSubscriptions(user.uid)
          .map((subscriptions) {
            if (subscriptions.isEmpty) return null;

            // 1. Prefer match by plate (survives vehicle doc deletion)
            for (final sub in subscriptions) {
              if ((sub.linkedPlate ?? '').toUpperCase() == normalizedPlate) {
                return sub;
              }
            }
            // 2. Fallback: match by vehicleId (legacy documents)
            for (final sub in subscriptions) {
              if (sub.vehicleId == key.vehicleId) return sub;
            }
            // 3. Final fallback: if the user has any active subscription,
            //    treat this vehicle as covered (handles legacy subscriptions
            //    that were created before linkedPlate was stored in Stripe metadata).
            return subscriptions.first;
          });
    });

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

final subscriptionPlanProvider =
    FutureProvider.family<SubscriptionPlan?, String>((ref, planId) {
      return ref
          .watch(subscriptionRepositoryProvider)
          .getSubscriptionPlan(planId);
    });
